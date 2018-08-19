const std = @import("std");
const lessThanField = @import("../../util.zig").lessThanField;
const Math = @import("../../math.zig");
const Gbe = @import("../../gbe.zig");
const GbeSystem = @import("../../gbe_system.zig");
const GRIDSIZE_SUBPIXELS = @import("../level.zig").GRIDSIZE_SUBPIXELS;
const Audio = @import("../audio.zig");
const GameSession = @import("../game.zig").GameSession;
const GameUtil = @import("../util.zig");
const physInWall = @import("../physics.zig").physInWall;
const Constants = @import("../constants.zig");
const C = @import("../components.zig");
const Prototypes = @import("../prototypes.zig");

const SystemData = struct{
  id: Gbe.EntityId,
  creature: *C.Creature,
  phys: *C.PhysObject,
  monster: *C.Monster,
  transform: *C.Transform,
};

pub const run = GbeSystem.build(GameSession, SystemData, think);

fn think(gs: *GameSession, self: SystemData) bool {
  if (GameUtil.decrementTimer(&self.monster.spawning_timer)) {
    self.creature.hit_points = self.monster.full_hit_points;
  } else if (self.monster.spawning_timer > 0) {
    self.phys.speed = 0;
    self.phys.push_dir = null;
  } else {
    monsterMove(gs, self);
    if (self.monster.can_shoot or self.monster.can_drop_webs) {
      monsterAttack(gs, self);
    }
  }
  return true;
}

fn monsterMove(gs: *GameSession, self: SystemData) void {
  const gc = gs.getGameController();

  self.phys.push_dir = null;

  if (gc.freeze_monsters_timer > 0) {
    self.phys.speed = 0;
    return;
  }

  if (gc.monster_count < 5) {
    self.monster.personality = C.Monster.Personality.Chase;
  }

  const monster_values = Constants.getMonsterValues(self.monster.monster_type);
  const move_speed =
    if (gc.enemy_speed_level < monster_values.move_speed.len)
      monster_values.move_speed[gc.enemy_speed_level]
    else
      monster_values.move_speed[monster_values.move_speed.len - 1];

  // look ahead for corners
  const pos = self.transform.pos;
  const fwd = Math.Direction.normal(self.phys.facing);
  const left = Math.Direction.rotateCcw(self.phys.facing);
  const right = Math.Direction.rotateCw(self.phys.facing);
  const left_normal = Math.Direction.normal(left);
  const right_normal = Math.Direction.normal(right);

  var wall_in_front = false;
  var left_corner = false;
  var right_corner = false;

  if (physInWall(self.phys, pos)) {
    // stuck in a wall
    return;
  }

  var i: u31 = 0;
  while (i < move_speed) : (i += 1) {
    const new_pos = Math.Vec2.add(pos, Math.Vec2.scale(fwd, i));
    const left_pos = Math.Vec2.add(new_pos, left_normal);
    const right_pos = Math.Vec2.add(new_pos, right_normal);

    if (i > 0 and physInWall(self.phys, new_pos)) {
      wall_in_front = true;
    }
    if (!physInWall(self.phys, left_pos)) {
      left_corner = true;
    }
    if (!physInWall(self.phys, right_pos)) {
      right_corner = true;
    }
  }

  if (chooseTurn(gs, self.monster.personality, pos, self.phys.facing, !wall_in_front, left_corner, right_corner)) |dir| {
    self.phys.push_dir = dir;
  }

  // TODO - sometimes randomly stop/change direction

  self.phys.speed = @intCast(i32, move_speed);
}

fn monsterAttack(gs: *GameSession, self: SystemData) void {
  const gc = gs.getGameController();
  if (gc.freeze_monsters_timer > 0) {
    return;
  }
  if (self.monster.next_attack_timer > 0) {
    self.monster.next_attack_timer -= 1;
  } else {
    if (self.monster.can_shoot) {
      _ = Prototypes.EventSound.spawn(gs, C.EventSound{
        .sample = Audio.Sample.MonsterShot,
      });
      // spawn the bullet one quarter of a grid cell in front of the monster
      const pos = self.transform.pos;
      const dir_vec = Math.Direction.normal(self.phys.facing);
      const ofs = Math.Vec2.scale(dir_vec, GRIDSIZE_SUBPIXELS / 4);
      const bullet_pos = Math.Vec2.add(pos, ofs);
      _ = Prototypes.Bullet.spawn(gs, Prototypes.Bullet.Params{
        .inflictor_player_controller_id = null,
        .owner_id = self.id,
        .pos = bullet_pos,
        .facing = self.phys.facing,
        .bullet_type = Prototypes.Bullet.BulletType.MonsterBullet,
        .cluster_size = 1,
      });
    } else if (self.monster.can_drop_webs) {
      _ = Prototypes.Web.spawn(gs, Prototypes.Web.Params{
        .pos = self.transform.pos,
      });
    }
    self.monster.next_attack_timer = gs.gbe.getRand().range(u32, 75, 400);
  }
}

// this function needs more args if this is going to be any good
fn getChaseTarget(gs: *GameSession) ?Math.Vec2 {
  // chase the first player in the entity list
  if (gs.gbe.iter(C.Player).next()) |player| {
    if (gs.gbe.find(player.entity_id, C.Transform)) |player_transform| {
      return player_transform.pos;
    }
  }
  return null;
}

fn chooseTurn(
  gs: *GameSession,
  personality: C.Monster.Personality,
  pos: Math.Vec2,
  facing: Math.Direction,
  can_go_forward: bool,
  can_go_left: bool,
  can_go_right: bool,
) ?Math.Direction {
  const left = Math.Direction.rotateCcw(facing);
  const right = Math.Direction.rotateCw(facing);

  var choices = GameUtil.Choices.init();

  if (personality == C.Monster.Personality.Chase) {
    if (getChaseTarget(gs)) |target_pos| {
      const fwd = Math.Direction.normal(facing);
      const left_normal = Math.Direction.normal(left);
      const right_normal = Math.Direction.normal(right);

      const forward_point = Math.Vec2.add(pos, Math.Vec2.scale(fwd, GRIDSIZE_SUBPIXELS));
      const left_point = Math.Vec2.add(pos, Math.Vec2.scale(left_normal, GRIDSIZE_SUBPIXELS));
      const right_point = Math.Vec2.add(pos, Math.Vec2.scale(right_normal, GRIDSIZE_SUBPIXELS));

      const forward_point_dist = Math.Vec2.manhattanDistance(forward_point, target_pos);
      const left_point_dist = Math.Vec2.manhattanDistance(left_point, target_pos);
      const right_point_dist = Math.Vec2.manhattanDistance(right_point, target_pos);

      if (can_go_forward) {
        choices.add(facing, forward_point_dist);
      }
      if (can_go_left) {
        choices.add(left, left_point_dist);
      }
      if (can_go_right) {
        choices.add(right, right_point_dist);
      }

      if (choices.choose()) |best_direction| {
        if (best_direction != facing) {
          return best_direction;
        }
      }

      return null;
    }
  }

  // wandering
  if (can_go_forward) {
    choices.add(facing, 2);
  }
  if (can_go_left) {
    choices.add(left, 1);
  }
  if (can_go_right) {
    choices.add(right, 1);
  }
  const total_score = blk: {
    var total: u32 = 0;
    for (choices.choices[0..choices.num_choices]) |choice| {
      total += choice.score;
    }
    break :blk total;
  };
  var r = gs.gbe.getRand().range(u32, 0, total_score);
  for (choices.choices[0..choices.num_choices]) |choice| {
    if (r < choice.score) {
      return choice.direction;
    } else {
      r -= choice.score;
    }
  }

  return null;
}

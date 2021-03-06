const gbe = @import("gbe");
const GameSession = @import("../game.zig").GameSession;
const constants = @import("../constants.zig");
const c = @import("../components.zig");
const p = @import("../prototypes.zig");

pub fn run(gs: *GameSession) void {
    var it = gs.ecs.iter(struct {
        id: gbe.EntityId,
        bullet: *const c.Bullet,
        transform: *const c.Transform,
        inbox: gbe.Inbox(1, c.EventCollide, "self_id"),
    });
    while (it.next()) |self| {
        const event = self.inbox.one();

        _ = p.Sparks.spawn(gs, .{
            .pos = self.transform.pos,
            .impact_sound = !gbe.EntityId.isZero(event.other_id),
        }) catch undefined;

        if (!gbe.EntityId.isZero(event.other_id)) {
            _ = p.EventTakeDamage.spawn(gs, .{
                .inflictor_player_controller_id = self.bullet.inflictor_player_controller_id,
                .self_id = event.other_id,
                .amount = self.bullet.damage,
            }) catch undefined;
        }

        gs.ecs.markForRemoval(self.id);
    }
}

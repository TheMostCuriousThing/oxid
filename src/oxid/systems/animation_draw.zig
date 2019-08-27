const std = @import("std");
const gbe = @import("gbe");
const GameSession = @import("../game.zig").GameSession;
const c = @import("../components.zig");
const p = @import("../prototypes.zig");
const getSimpleAnim = @import("../graphics.zig").getSimpleAnim;

const SystemData = struct {
    transform: *const c.Transform,
    animation: *const c.Animation,
};

pub const run = gbe.buildSystem(GameSession, SystemData, think);

fn think(gs: *GameSession, self: SystemData) gbe.ThinkResult {
    const animcfg = getSimpleAnim(self.animation.simple_anim);
    std.debug.assert(self.animation.frame_index < animcfg.frames.len);
    _ = p.EventDraw.spawn(gs, c.EventDraw {
        .pos = self.transform.pos,
        .graphic = animcfg.frames[self.animation.frame_index],
        .transform = .Identity,
        .z_index = self.animation.z_index,
    }) catch undefined;
    return .Remain;
}

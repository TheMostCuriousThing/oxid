const draw = @import("../../common/draw.zig");
const GameSession = @import("../game.zig").GameSession;
const c = @import("../components.zig");
const p = @import("../prototypes.zig");

pub fn run(gs: *GameSession) void {
    var it = gs.ecs.iter(struct {
        player: *const c.Player,
    });
    while (it.next()) |self| {
        if (self.player.line_of_fire) |box| {
            _ = p.EventDrawBox.spawn(gs, .{
                .box = box,
                .color = draw.black,
            }) catch undefined;
        }
    }
}

const build_options = @import("build_options");
const std = @import("std");
const HunkSide = @import("zig-hunk").HunkSide;

const pdraw = @import("pdraw");
const pcx_helper = @import("../common/pcx_helper.zig");
const draw = @import("../common/draw.zig");
const constants = @import("constants.zig");

const graphics_filename = build_options.assets_path ++ "/mytiles.pcx";
const transparent_color_index = 27;

pub const Graphic = enum {
    pit,
    pla_bullet,
    pla_bullet2,
    pla_bullet3,
    pla_spark1,
    pla_spark2,
    mon_bullet,
    mon_spark1,
    mon_spark2,
    floor,
    man_icons,
    man1_walk1,
    man1_walk2,
    man2_walk1,
    man2_walk2,
    man_dying1,
    man_dying2,
    man_dying3,
    man_dying4,
    man_dying5,
    man_dying6,
    wall,
    wall2,
    evilwall_tl,
    evilwall_tr,
    evilwall_bl,
    evilwall_br,
    spider1,
    spider2,
    fast_bug1,
    fast_bug2,
    juggernaut,
    explode1,
    explode2,
    explode3,
    explode4,
    spawn1,
    spawn2,
    squid1,
    squid2,
    knight1,
    knight2,
    web1,
    web2,
    power_up,
    speed_up,
    life_up,
    coin,
};

pub fn getGraphicTile(graphic: Graphic) draw.Tile {
    return switch (graphic) {
        .pit => .{ .tx = 1, .ty = 0 },
        .floor => .{ .tx = 2, .ty = 0 },
        .wall => .{ .tx = 3, .ty = 0 },
        .wall2 => .{ .tx = 4, .ty = 0 },
        .evilwall_tl => .{ .tx = 0, .ty = 6 },
        .evilwall_tr => .{ .tx = 1, .ty = 6 },
        .evilwall_bl => .{ .tx = 0, .ty = 7 },
        .evilwall_br => .{ .tx = 1, .ty = 7 },
        .pla_bullet => .{ .tx = 2, .ty = 1 },
        .pla_bullet2 => .{ .tx = 3, .ty = 1 },
        .pla_bullet3 => .{ .tx = 4, .ty = 1 },
        .pla_spark1 => .{ .tx = 1, .ty = 1 },
        .pla_spark2 => .{ .tx = 0, .ty = 1 },
        .mon_bullet => .{ .tx = 2, .ty = 3 },
        .mon_spark1 => .{ .tx = 1, .ty = 3 },
        .mon_spark2 => .{ .tx = 0, .ty = 3 },
        .man_icons => .{ .tx = 5, .ty = 0 },
        .man1_walk1 => .{ .tx = 6, .ty = 1 },
        .man1_walk2 => .{ .tx = 7, .ty = 1 },
        .man2_walk1 => .{ .tx = 6, .ty = 0 },
        .man2_walk2 => .{ .tx = 7, .ty = 0 },
        .man_dying1 => .{ .tx = 0, .ty = 4 },
        .man_dying2 => .{ .tx = 1, .ty = 4 },
        .man_dying3 => .{ .tx = 2, .ty = 4 },
        .man_dying4 => .{ .tx = 3, .ty = 4 },
        .man_dying5 => .{ .tx = 4, .ty = 4 },
        .man_dying6 => .{ .tx = 5, .ty = 4 },
        .spider1 => .{ .tx = 3, .ty = 2 },
        .spider2 => .{ .tx = 4, .ty = 2 },
        .fast_bug1 => .{ .tx = 5, .ty = 2 },
        .fast_bug2 => .{ .tx = 6, .ty = 2 },
        .juggernaut => .{ .tx = 7, .ty = 2 },
        .explode1 => .{ .tx = 0, .ty = 5 },
        .explode2 => .{ .tx = 1, .ty = 5 },
        .explode3 => .{ .tx = 2, .ty = 5 },
        .explode4 => .{ .tx = 3, .ty = 5 },
        .spawn1 => .{ .tx = 2, .ty = 2 },
        .spawn2 => .{ .tx = 1, .ty = 2 },
        .squid1 => .{ .tx = 3, .ty = 3 },
        .squid2 => .{ .tx = 4, .ty = 3 },
        .knight1 => .{ .tx = 5, .ty = 3 },
        .knight2 => .{ .tx = 6, .ty = 3 },
        .web1 => .{ .tx = 6, .ty = 4 },
        .web2 => .{ .tx = 7, .ty = 4 },
        .life_up => .{ .tx = 4, .ty = 5 },
        .power_up => .{ .tx = 6, .ty = 5 },
        .speed_up => .{ .tx = 5, .ty = 5 },
        .coin => .{ .tx = 4, .ty = 6 },
    };
}

pub const SimpleAnim = enum {
    pla_sparks,
    mon_sparks,
    explosion,
};

pub const SimpleAnimConfig = struct {
    frames: []const Graphic,
    ticks_per_frame: u32,
};

pub fn getSimpleAnim(simpleAnim: SimpleAnim) SimpleAnimConfig {
    return switch (simpleAnim) {
        .pla_sparks => .{
            .frames = &[_]Graphic{ .pla_spark1, .pla_spark2 },
            .ticks_per_frame = constants.duration60(6),
        },
        .mon_sparks => .{
            .frames = &[_]Graphic{ .mon_spark1, .mon_spark2 },
            .ticks_per_frame = constants.duration60(6),
        },
        .explosion => .{
            .frames = &[_]Graphic{ .explode1, .explode2, .explode3, .explode4 },
            .ticks_per_frame = constants.duration60(6),
        },
    };
}

pub fn loadTileset(
    hunk_side: *HunkSide,
    out_tileset: *draw.Tileset,
    out_palette: []u8,
) pcx_helper.LoadPcxError!void {
    std.debug.assert(out_palette.len == 48);

    const mark = hunk_side.getMark();
    defer hunk_side.freeToMark(mark);

    const img = try pcx_helper.loadPcx(
        hunk_side,
        graphics_filename,
        transparent_color_index,
    );

    out_tileset.texture = pdraw.uploadTexture(img.width, img.height, img.pixels);
    out_tileset.xtiles = 8;
    out_tileset.ytiles = 8;

    std.mem.copy(u8, out_palette, img.palette[0..]);
}

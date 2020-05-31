pub const Key = enum {
    @"return",
    escape,
    backspace,
    tab,
    space,
    exclaim,
    quotedbl,
    hash,
    percent,
    dollar,
    ampersand,
    quote,
    leftparen,
    rightparen,
    asterisk,
    plus,
    comma,
    minus,
    period,
    slash,
    @"0",
    @"1",
    @"2",
    @"3",
    @"4",
    @"5",
    @"6",
    @"7",
    @"8",
    @"9",
    colon,
    semicolon,
    less,
    equals,
    greater,
    question,
    at,
    leftbracket,
    backslash,
    rightbracket,
    caret,
    underscore,
    backquote,
    a,
    b,
    c,
    d,
    e,
    f,
    g,
    h,
    i,
    j,
    k,
    l,
    m,
    n,
    o,
    p,
    q,
    r,
    s,
    t,
    u,
    v,
    w,
    x,
    y,
    z,
    capslock,
    f1,
    f2,
    f3,
    f4,
    f5,
    f6,
    f7,
    f8,
    f9,
    f10,
    f11,
    f12,
    printscreen,
    scrolllock,
    pause,
    insert,
    home,
    pageup,
    delete,
    end,
    pagedown,
    right,
    left,
    down,
    up,
    numlockclear,
    kp_divide,
    kp_multiply,
    kp_minus,
    kp_plus,
    kp_enter,
    kp_1,
    kp_2,
    kp_3,
    kp_4,
    kp_5,
    kp_6,
    kp_7,
    kp_8,
    kp_9,
    kp_0,
    kp_period,
    application,
    power,
    kp_equals,
    f13,
    f14,
    f15,
    f16,
    f17,
    f18,
    f19,
    f20,
    f21,
    f22,
    f23,
    f24,
    execute,
    help,
    menu,
    select,
    stop,
    again,
    undo,
    cut,
    copy,
    paste,
    find,
    mute,
    volumeup,
    volumedown,
    kp_comma,
    kp_equalsas400,
    alterase,
    sysreq,
    cancel,
    clear,
    prior,
    return2,
    separator,
    out,
    oper,
    clearagain,
    crsel,
    exsel,
    kp_00,
    kp_000,
    thousandsseparator,
    decimalseparator,
    currencyunit,
    currencysubunit,
    kp_leftparen,
    kp_rightparen,
    kp_leftbrace,
    kp_rightbrace,
    kp_tab,
    kp_backspace,
    kp_a,
    kp_b,
    kp_c,
    kp_d,
    kp_e,
    kp_f,
    kp_xor,
    kp_power,
    kp_percent,
    kp_less,
    kp_greater,
    kp_ampersand,
    kp_dblampersand,
    kp_verticalbar,
    kp_dblverticalbar,
    kp_colon,
    kp_hash,
    kp_space,
    kp_at,
    kp_exclam,
    kp_memstore,
    kp_memrecall,
    kp_memclear,
    kp_memadd,
    kp_memsubtract,
    kp_memmultiply,
    kp_memdivide,
    kp_plusminus,
    kp_clear,
    kp_clearentry,
    kp_binary,
    kp_octal,
    kp_decimal,
    kp_hexadecimal,
    lctrl,
    lshift,
    lalt,
    lgui,
    rctrl,
    rshift,
    ralt,
    rgui,
    mode,
    audionext,
    audioprev,
    audiostop,
    audioplay,
    audiomute,
    mediaselect,
    www,
    mail,
    calculator,
    computer,
    ac_search,
    ac_home,
    ac_back,
    ac_forward,
    ac_stop,
    ac_refresh,
    ac_bookmarks,
    brightnessdown,
    brightnessup,
    displayswitch,
    kbdillumtoggle,
    kbdillumdown,
    kbdillumup,
    eject,
    sleep,
    app1,
    app2,
    audiorewind,
    audiofastforward,
};

pub const key_names = blk: {
    var array: [@typeInfo(Key).Enum.fields.len][]const u8 = undefined;
    inline for (@typeInfo(Key).Enum.fields) |field, i| {
        array[i] = field.name;
    }
    break :blk array;
};

pub const JoyButton = struct {
    which: usize,
    button: u32,
};

pub const JoyAxis = struct {
    which: usize,
    axis: u32,
};

pub const InputSource = union(enum) {
    key: Key,
    joy_button: JoyButton,
    joy_axis_neg: JoyAxis,
    joy_axis_pos: JoyAxis,
};

pub fn areInputSourcesEqual(a: InputSource, b: InputSource) bool {
    return switch (a) {
        .key => |a_i| switch (b) {
            .key => |b_i| a_i == b_i,
            else => false,
        },
        .joy_button => |a_i| switch (b) {
            .joy_button => |b_i| a_i.which == b_i.which and a_i.button == b_i.button,
            else => false,
        },
        .joy_axis_neg => |a_i| switch (b) {
            .joy_axis_neg => |b_i| a_i.which == b_i.which and a_i.axis == b_i.axis,
            else => false,
        },
        .joy_axis_pos => |a_i| switch (b) {
            .joy_axis_pos => |b_i| a_i.which == b_i.which and a_i.axis == b_i.axis,
            else => false,
        },
    };
}

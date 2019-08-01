const gbe = @import("gbe");
const c = @import("components.zig");

pub const GameSession = gbe.Session(struct {
    Animation: gbe.ComponentList(c.Animation, 10),
    Bullet: gbe.ComponentList(c.Bullet, 10),
    Creature: gbe.ComponentList(c.Creature, 100),
    GameController: gbe.ComponentList(c.GameController, 1),
    MainController: gbe.ComponentList(c.MainController, 1),
    Monster: gbe.ComponentList(c.Monster, 50),
    PhysObject: gbe.ComponentList(c.PhysObject, 100),
    Pickup: gbe.ComponentList(c.Pickup, 10),
    Player: gbe.ComponentList(c.Player, 50),
    PlayerController: gbe.ComponentList(c.PlayerController, 4),
    RemoveTimer: gbe.ComponentList(c.RemoveTimer, 50),
    SimpleGraphic: gbe.ComponentList(c.SimpleGraphic, 50),
    Transform: gbe.ComponentList(c.Transform, 100),
    Voice: gbe.ComponentList(c.Voice, 100),
    Web: gbe.ComponentList(c.Web, 100),
    EventAwardLife: gbe.ComponentList(c.EventAwardLife, 20),
    EventAwardPoints: gbe.ComponentList(c.EventAwardPoints, 20),
    EventCollide: gbe.ComponentList(c.EventCollide, 50),
    EventConferBonus: gbe.ComponentList(c.EventConferBonus, 5),
    EventDraw: gbe.ComponentList(c.EventDraw, 100),
    EventDrawBox: gbe.ComponentList(c.EventDrawBox, 100),
    EventRawInput: gbe.ComponentList(c.EventRawInput, 20),
    EventGameInput: gbe.ComponentList(c.EventGameInput, 20),
    EventMenuInput: gbe.ComponentList(c.EventMenuInput, 20),
    EventMonsterDied: gbe.ComponentList(c.EventMonsterDied, 20),
    EventPlayerDied: gbe.ComponentList(c.EventPlayerDied, 20),
    EventPlayerOutOfLives: gbe.ComponentList(c.EventPlayerOutOfLives, 20),
    EventPostScore: gbe.ComponentList(c.EventPostScore, 20),
    EventShowMessage: gbe.ComponentList(c.EventShowMessage, 5),
    EventSystemCommand: gbe.ComponentList(c.EventSystemCommand, 5),
    EventTakeDamage: gbe.ComponentList(c.EventTakeDamage, 20),
});

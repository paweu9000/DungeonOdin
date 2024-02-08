package GAME

import RL "vendor:raylib"
import "core:fmt"

Type :: enum {
    ENEMY, PLAYER
}

Direction :: enum {
    N, S, W, E, NE, NW, SE, SW
}

State :: enum {
    ATTACK, IDLE, MOVE
}

Hitbox :: struct {
    x, y: i32,
    radius: f32,
    color: RL.Color
}

Actor :: struct {
    mDrawOrder: int,
    mVelocity: RL.Vector2,
    mType: Type,
    mDirection: Direction,
    mState: State,
    mTextures: [dynamic]RL.Texture2D,
    mCurrentTexture: RL.Texture2D,
    mHitbox: Hitbox,
    mFrame, mMovementSpeed, mMass: f32
}

Player :: struct {
    using actor: Actor
}

Enemy :: struct {
    using actor: Actor
}

update_actor :: proc(actor: ^Actor){
    process_player_input(actor)
    process_actor_state(actor)
    actor.mDrawOrder = int(actor.mHitbox.y)
}

draw_actor :: proc(actor: ^Actor) {
    circle := actor.mHitbox
    RL.DrawCircle(circle.x, circle.y, circle.radius, circle.color)
    RL.DrawTexture(actor.mCurrentTexture, circle.x-128, circle.y-127, RL.WHITE)
}

createPlayer :: proc() -> ^Player {
    player := new(Player)
    player.mState = State.IDLE
    player.mType = Type.PLAYER
    player.mMovementSpeed = 1.2
    player.mMass = 0.3
    player.mHitbox = Hitbox{418, 417, 10, RL.GREEN}
    player.mTextures = game.textures["player_idle_S"]
    player.mFrame = 0;
    player.mCurrentTexture = player.mTextures[0];
    return player
}

process_actor_state :: proc(actor: ^Actor) {
    hb := actor.mHitbox
    ms := actor.mMovementSpeed
    if actor.mState != State.MOVE do return
    switch actor.mDirection {
        case Direction.N:
            actor.mVelocity = RL.Vector2{0, -ms};
        case Direction.W:
            actor.mVelocity = RL.Vector2{-ms, 0};
        case Direction.E:
            actor.mVelocity = RL.Vector2{ms, 0};
        case Direction.S:
            actor.mVelocity = RL.Vector2{0, ms};
        case Direction.NE:
            actor.mVelocity = RL.Vector2{ms, -ms};
        case Direction.NW:
            actor.mVelocity = RL.Vector2{-ms, -ms};
        case Direction.SE:
            actor.mVelocity = RL.Vector2{ms, ms};
        case Direction.SW:
            actor.mVelocity = RL.Vector2{-ms, ms};
    }
    actor.mHitbox.x = hb.x + i32(actor.mVelocity[0])
    actor.mHitbox.y = hb.y + i32(actor.mVelocity[1])
}

process_player_input :: proc(player: ^Actor) {
    player.mState = State.ATTACK
    if RL.IsKeyDown(RL.KeyboardKey.SPACE) do return
    player.mState = State.MOVE
    if (RL.IsKeyDown(RL.KeyboardKey.W) && RL.IsKeyDown(RL.KeyboardKey.D)) {player.mDirection = Direction.NE;}
    else if (RL.IsKeyDown(RL.KeyboardKey.W) && RL.IsKeyDown(RL.KeyboardKey.A)) {player.mDirection = Direction.NW;}
    else if (RL.IsKeyDown(RL.KeyboardKey.S) && RL.IsKeyDown(RL.KeyboardKey.A)) {player.mDirection = Direction.SW;}
    else if (RL.IsKeyDown(RL.KeyboardKey.S) && RL.IsKeyDown(RL.KeyboardKey.D)) {player.mDirection = Direction.SE;}
    else if (RL.IsKeyDown(RL.KeyboardKey.W)) {player.mDirection = Direction.N;}
    else if (RL.IsKeyDown(RL.KeyboardKey.A)) {player.mDirection = Direction.W;}
    else if (RL.IsKeyDown(RL.KeyboardKey.D))  {player.mDirection = Direction.E;}
    else if (RL.IsKeyDown(RL.KeyboardKey.S)) {player.mDirection = Direction.S;}
    else {player.mState = State.IDLE}
}

generate_texture_name :: proc()

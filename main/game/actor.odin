package GAME

import RL "vendor:raylib"
import "core:fmt"
import "core:strings"

Type :: enum {
    ENEMY, PLAYER
}

Direction :: enum {
    N, S, W, E, NE, NW, SE, SW
}

State :: enum {
    ATTACK, IDLE, MOVE
}

MonsterCategory :: enum {
    SKELETON, SLIME
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
    using actor: Actor,
    mCategory: MonsterCategory
}

update_actor :: proc(actor: ^Actor){
    if actor.mType == Type.PLAYER {
        process_player_input(actor)
    }
    process_actor_state(actor)
    update_textures(actor)
    update_frame(actor)
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

createEnemy :: proc(category: MonsterCategory) -> ^Enemy {
    enemy := new(Enemy)
    enemy.mDirection = Direction.S
    enemy.mState = State.IDLE
    enemy.mType = Type.ENEMY
    enemy.mCategory = category
    enemy.mMovementSpeed = 0.6
    enemy.mMass = 2.0
    enemy.mHitbox = Hitbox{RL.GetRandomValue(30, 1500), RL.GetRandomValue(30, 800), 10, RL.RED}
    enemy.mTextures = game.textures["skeleton_idle_S"]
    enemy.mFrame = 0
    enemy.mCurrentTexture = enemy.mTextures[0]
    return enemy
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

update_textures :: proc(actor: ^Actor) {
    actor.mTextures = game.textures[generate_texture_name(actor)]
}

update_frame :: proc(actor: ^Actor) {
    if int(actor.mFrame) < len(actor.mTextures) {
        actor.mFrame += game.deltaTime * f32(len(actor.mTextures)) * actor.mMovementSpeed
    }
    if int(actor.mFrame) > len(actor.mTextures)-1 {actor.mFrame = 0}
    actor.mCurrentTexture = actor.mTextures[int(actor.mFrame)]
}

generate_texture_name :: proc(actor: ^Actor) -> string {
    part1: string
    switch actor.mType {
        case Type.PLAYER:
            part1 = "player_"
        case Type.ENEMY:
            part1 = "skeleton_"
    }
    part2: string
    switch actor.mState {
        case State.IDLE:
            part2 = "idle_";
        case State.MOVE:
            part2 = "walk_";
        case State.ATTACK:
            part2 = "attack_";
    }
    part3: string
    switch (actor.mDirection)
    {
        case Direction.N:
            part3 = "N";
        case Direction.W:
            part3 = "W";
        case Direction.E:
            part3 = "E";
        case Direction.S:
           part3 = "S";
        case Direction.NE:
            part3 = "NE";
        case Direction.NW:
            part3 = "NW";
        case Direction.SE:
            part3 = "SE";
        case Direction.SW:
            part3 = "SW";
    }
    return strings.concatenate({part1, part2, part3})
}

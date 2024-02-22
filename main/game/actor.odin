package GAME

import RL "vendor:raylib"
import "core:fmt"
import "core:strings"
import "../managers"

Type :: enum {
    ENEMY, PLAYER
}

Direction :: enum {
    N, S, W, E, NE, NW, SE, SW
}

State :: enum {
    ATTACK, IDLE, MOVE, DEATH, DEAD
}

MonsterCategory :: enum {
    SKELETON, SLIME
}

Hitbox :: struct {
    x, y: f32,
    radius: f32,
    color: RL.Color
}

Component :: struct {
    mTexture: RL.Texture2D,
    mDirection: Direction,
    mTextures: [dynamic]RL.Texture2D,
    mFrame: f32,
    mPos: RL.Vector2,
    mVel: RL.Vector2,
    mVec: RL.Vector2,
    mHitbox: Hitbox,
    mDmg: i32
}

Actor :: struct {
    mID: int,
    mDrawOrder: int,
    mVelocity: RL.Vector2,
    mType: Type,
    mDirection: Direction,
    mState: State,
    mTexture: string,
    mHitbox: Hitbox,
    mFrame, mMovementSpeed, mMass: f32,
    mComponents: [dynamic]^Component,
    mHp, mMaxHp: i32,
    mHitmap: map[^Component]bool
}

Player :: struct {
    using actor: Actor
}

Enemy :: struct {
    using actor: Actor,
    mCategory: MonsterCategory
}

update_actor :: proc(actor: ^Actor){
    if actor.mType == Type.PLAYER && actor.mID == game.client_id {
        process_player_input(actor)
    }
    else if actor.mType == .ENEMY {
        checkEnemyState(actor)
    }
    process_actor_state(actor)
    update_textures(actor)
    update_frame(actor)
    actor.mDrawOrder = int(actor.mHitbox.y)
    if actor.mState == State.DEAD && actor.mType != .PLAYER {
        removeActor(actor)
    }
}

draw_actor :: proc(actor: ^Actor) {
    circle := actor.mHitbox
    if game.showHitbox {
        RL.DrawCircle(i32(circle.x), i32(circle.y), circle.radius, circle.color)
    }
    // RL.DrawTexture(actor.mCurrentTexture, i32(circle.x-128), i32(circle.y-127), RL.WHITE)
    filename := actor.mType == .PLAYER ? "player" : "enemy"
    managers.drawTexture(game.sprite_manager, filename, actor.mTexture, int(actor.mFrame), {circle.x-42, circle.y-56})
    for comp in actor.mComponents {
        if game.showHitbox {
            c_hb := comp.mHitbox
            RL.DrawCircle(i32(c_hb.x), i32(c_hb.y), c_hb.radius, c_hb.color)
        }
        src := RL.Rectangle{0, 0, 256, 256}
        dest := RL.Rectangle{comp.mPos.x, comp.mPos.y, 256, 256}
        
        RL.DrawTexturePro(comp.mTexture, src, dest, comp.mVec, calculateRotation(comp.mDirection), RL.BLACK)
    }
}

createPlayer :: proc(id: int) -> ^Player {
    player := new(Player)
    player.mID = id
    player.mState = State.IDLE
    player.mType = Type.PLAYER
    player.mMovementSpeed = 1.2
    player.mHp = 10
    player.mMaxHp = 10
    player.mHitmap = make(map[^Component]bool)
    player.mMass = 0.3
    player.mHitbox = Hitbox{500, 500, 10, RL.GREEN}
    player.mTexture = "player_idle_S"
    player.mFrame = 0;
    return player
}

createEnemy :: proc(category: MonsterCategory) -> ^Enemy {
    enemy := new(Enemy)
    enemy.mDirection = Direction.S
    enemy.mState = State.IDLE
    enemy.mType = Type.ENEMY
    enemy.mHitmap = make(map[^Component]bool)
    enemy.mCategory = category
    enemy.mMovementSpeed = 0.6
    enemy.mMass = 2.0
    enemy.mHp = 3
    enemy.mMaxHp = 3
    enemy.mHitbox = Hitbox{f32(RL.GetRandomValue(30, 1500)), f32(RL.GetRandomValue(30, 800)), 10, RL.RED}
    // enemy.mHitbox = Hitbox{500, 500, 10, RL.RED}
    enemy.mTexture = "skeleton_idle_S"
    enemy.mFrame = 0
    return enemy
}

process_actor_state :: proc(actor: ^Actor) {
    if actor.mHp <= 0 {
        actor.mState = actor.mState == .DEAD ? .DEAD : .DEATH
    }
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
    actor.mHitbox.x = hb.x + actor.mVelocity[0]
    actor.mHitbox.y = hb.y + actor.mVelocity[1]
}

process_player_input :: proc(player: ^Actor) {
    if player.mState == State.DEATH || player.mState == State.DEAD do return
    player.mState = State.ATTACK
    if RL.IsKeyDown(RL.KeyboardKey.SPACE) do return
    player.mState = State.MOVE
    switch {
        case RL.IsKeyDown(RL.KeyboardKey.W) && RL.IsKeyDown(RL.KeyboardKey.D): player.mDirection = Direction.NE
        case RL.IsKeyDown(RL.KeyboardKey.W) && RL.IsKeyDown(RL.KeyboardKey.A): player.mDirection = Direction.NW
        case RL.IsKeyDown(RL.KeyboardKey.S) && RL.IsKeyDown(RL.KeyboardKey.A): player.mDirection = Direction.SW
        case RL.IsKeyDown(RL.KeyboardKey.S) && RL.IsKeyDown(RL.KeyboardKey.D): player.mDirection = Direction.SE
        case RL.IsKeyDown(RL.KeyboardKey.W): player.mDirection = Direction.N
        case RL.IsKeyDown(RL.KeyboardKey.A): player.mDirection = Direction.W
        case RL.IsKeyDown(RL.KeyboardKey.D): player.mDirection = Direction.E
        case RL.IsKeyDown(RL.KeyboardKey.S): player.mDirection = Direction.S
        case: player.mState = State.IDLE
    }
}

update_textures :: proc(actor: ^Actor) {
    actor.mTexture = generate_texture_name(actor)
}

update_frame :: proc(actor: ^Actor) {
    if actor.mState == .DEAD do return
    if actor.mType == .PLAYER && game.client_id != actor.mID do return
    tex_len := managers.getTexturesLen(game.sprite_manager, actor.mTexture)
    if int(actor.mFrame) < tex_len {
        actor.mFrame += game.deltaTime * f32(tex_len) * actor.mMovementSpeed * 1.5
    }
    if int(actor.mFrame) > tex_len-1 && actor.mState == State.DEATH {
        actor.mState = State.DEAD
        actor.mFrame -= 1
    }
    if int(actor.mFrame) > tex_len-1 && actor.mState != State.DEATH {actor.mFrame = 0}
    #partial switch (actor.mState) {
        case .DEAD:
            clear(&actor.mComponents)
        case .DEATH:
            clear(&actor.mComponents)
        case:
            for i in 0..<len(actor.mComponents) {
                actor.mComponents[i].mPos += actor.mComponents[i].mVel
                actor.mComponents[i].mHitbox.x += actor.mComponents[i].mVel[0]
                actor.mComponents[i].mHitbox.y += actor.mComponents[i].mVel[1]
                actor.mComponents[i].mFrame += game.deltaTime * f32(len(actor.mComponents[i].mTextures)) * actor.mMovementSpeed * 5
                if (int(actor.mComponents[i].mFrame) > len(actor.mComponents[i].mTextures)-1) {ordered_remove(&actor.mComponents, i)}
            }
            if (actor.mState == State.ATTACK && 
                actor.mFrame > 2.9 && actor.mFrame < 3) {
                createComponent(actor)
            }
    }
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
        case State.DEATH:
            part2 = "death_"
        case State.DEAD:
            part2 = "death_"
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

applyForce :: proc(actor: ^Actor, force: RL.Vector2)
{
    actor.mHitbox.x = force.x
    actor.mHitbox.y = force.y
}

checkEnemyState :: proc(enemy: ^Actor)
{
    switch {
        case int(enemy.mFrame) == managers.getTexturesLen(game.sprite_manager, enemy.mTexture)-1 && enemy.mState == .DEAD:
            return
        case game.player.mState == .DEAD:
            enemy.mState = .IDLE
            return
        case enemy.mHp <= 0 && enemy.mState != .DEATH:
            enemy.mState = State.DEATH
            enemy.mFrame = 0
            return
        case enemy.mState == .DEATH || enemy.mState == .DEAD:
            return
    }
    player_hb := RL.Vector2{game.player.mHitbox.x, game.player.mHitbox.y}
    enemy_hb := RL.Vector2{enemy.mHitbox.x, enemy.mHitbox.y}
    sub_enemy_hb := enemy_hb - player_hb
    res := sub_enemy_hb.x * sub_enemy_hb.x + sub_enemy_hb.y * sub_enemy_hb.y
    switch {
        case res > 75000:
            enemy.mState = .IDLE
        case res < 1300:
            enemy.mState = .ATTACK
        case:
            enemy.mState = .MOVE
    }
    enemy.mDirection = calculateDirection(enemy_hb, player_hb)
}

createComponent :: proc(actor: ^Actor) {
    component := new(Component)
    component.mTextures = game.textures["swoosh"]
    component.mFrame = 0
    component.mTexture = component.mTextures[int(component.mFrame)]
    component.mDirection = actor.mDirection
    component.mPos = RL.Vector2{actor.mHitbox.x-165, actor.mHitbox.y-138}
    ms := actor.mMovementSpeed*2
    switch component.mDirection {
        case Direction.N:
            component.mVel = RL.Vector2{0, -ms};
        case Direction.W:
            component.mVel = RL.Vector2{-ms, 0};
        case Direction.E:
            component.mVel = RL.Vector2{ms, 0};
        case Direction.S:
            component.mVel = RL.Vector2{0, ms};
        case Direction.NE:
            component.mVel = RL.Vector2{ms, -ms};
        case Direction.NW:
            component.mVel = RL.Vector2{-ms, -ms};
        case Direction.SE:
            component.mVel = RL.Vector2{ms, ms};
        case Direction.SW:
            component.mVel = RL.Vector2{-ms, ms};
    }
    switch component.mDirection {
        case Direction.N: component.mVec = RL.Vector2{256, -40}
        case Direction.NE: component.mVec = RL.Vector2{140, -85}
        case Direction.E: component.mVec = RL.Vector2{-10, 0}
        case Direction.SE: component.mVec = RL.Vector2{-80, 155}
        case Direction.S: component.mVec = RL.Vector2{20, 292}
        case Direction.SW: component.mVec = RL.Vector2{180, 350}
        case Direction.W: component.mVec = RL.Vector2{280, 260}
        case Direction.NW: component.mVec = RL.Vector2{320, 110}
    } 
    hitbox := Hitbox{actor.mHitbox.x, actor.mHitbox.y, 15, RL.PINK}
    component.mHitbox = hitbox
    component.mDmg = 1
    append(&actor.mComponents, component)
}
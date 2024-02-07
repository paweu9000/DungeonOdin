package actor

import RL "vendor:raylib"

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
    x, y: int,
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

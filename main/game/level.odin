package GAME

import RL "vendor:raylib"

Prop :: struct {
    mTexture: RL.Texture2D,
    mPosition: RL.Vector2,
    mTextures: [dynamic]RL.Texture2D,
    mFrame: f32
}

Tile :: struct {
    isSolid: bool,
    mHitbox: RL.Rectangle,
    mTexture: RL.Texture2D,
    mVec: RL.Vector2,
    mProps: [dynamic]^Prop
}

Tileset :: struct {
    mTiles: [dynamic]^Tile,
    layer: i16
}

Level :: struct {
    mLayers: [dynamic]^Tileset
}

createProp :: proc(name: string, pos: RL.Vector2) -> ^Prop {
    prop := new(Prop)
    prop.mTextures = game.textures[name]
    prop.mFrame = 0
    prop.mTexture = prop.mTextures[i32(prop.mFrame)]
    prop.mPosition = pos
    return prop
}

createTile :: proc(solid: bool, hitbox: RL.Rectangle, texture: RL.Texture2D, vec: RL.Vector2) -> ^Tile {
    tile := new(Tile)
    tile.isSolid = solid
    tile.mHitbox = hitbox
    tile.mTexture = texture
    tile.mVec = vec
    return tile
}

initLevel :: proc() -> ^Level {
    tileset1 := new(Tileset)
    tileset1.layer = 1
    tileset2 := new(Tileset)
    tileset2.layer = 2
    for i in 0 ..< 10 {
        for j in 0 ..< 10 {
            hb1 := RL.Rectangle{f32(j*256), f32(i*256), 256, 256}
            tile1 := createTile(false, hb1, game.textures["ground_1"][1], RL.Vector2{f32(j*256), f32(i*256)})
            append(&tile1.mProps, createProp("prop_tile_1_N", RL.Vector2{f32(j*256-128), f32(i*256-128)}))
            append(&tile1.mProps, createProp("prop_tile_1_N", RL.Vector2{f32(j*256+128), f32(i*256+128)}))
            append(&tileset1.mTiles, tile1)
            hb2 := RL.Rectangle{f32(j*256+117), f32(i*256+80), 20, 90}
            tile2 := createTile(true, hb2, game.textures["wall_1_N"][0], RL.Vector2{f32(j*256), f32(i*256)})
            append(&tileset2.mTiles, tile2)
        }
    }
    level := new(Level)
    append(&level.mLayers, tileset1)
    append(&level.mLayers, tileset2)
    return level
}

drawLevel :: proc(level: ^Level) {
    for layer in level.mLayers {
        for tile in layer.mTiles {
            RL.DrawTexture(tile.mTexture, i32(tile.mVec.x), i32(tile.mVec.y), RL.WHITE)
            if tile.isSolid && game.showHitbox {
                RL.DrawRectangleLines(i32(tile.mHitbox.x), i32(tile.mHitbox.y), 
                                i32(tile.mHitbox.width), i32(tile.mHitbox.height), RL.PINK)
            }
            for prop in tile.mProps {
                RL.DrawTexture(prop.mTexture, i32(prop.mPosition.x), i32(prop.mPosition.y), RL.WHITE)
            }
        }
    }
}

checkForWallCollision :: proc(actor: ^Actor, lvl: ^Level) -> bool {
    actor_hb := actor.mHitbox
    tileset := lvl.mLayers[1] //2nd layer
    for tile in tileset.mTiles {
        if RL.CheckCollisionCircleRec(RL.Vector2{actor_hb.x, actor_hb.y}, actor_hb.radius, tile.mHitbox)
        {
            return true
        }
    }
    return false
}

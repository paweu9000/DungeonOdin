package GAME

import RL "vendor:raylib"

Tile :: struct {
    isSolid: bool,
    mHitbox: RL.Rectangle,
    mTexture: RL.Texture2D,
    mVec: RL.Vector2
}

Tileset :: struct {
    mTiles: [dynamic]^Tile,
    layer: i16
}

Level :: struct {
    mLayers: [dynamic]^Tileset
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
            if tile.isSolid {
                RL.DrawRectangleLines(i32(tile.mHitbox.x), i32(tile.mHitbox.y), 
                                i32(tile.mHitbox.width), i32(tile.mHitbox.height), RL.PINK)
            }
        }
    }
}

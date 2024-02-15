package GAME

import RL "vendor:raylib"
import "core:fmt"
import "core:strings"

ORB_RADIUS :: 110

Toolip :: struct {
    mText: string
}

Orb :: struct {
    mFillPercent: int,
    mTexture: RL.Texture2D,
    mPos: RL.Vector2,
    mBackTexture: RL.Texture2D,
    mFrontTexture: RL.Texture2D
}

HealthPanel :: struct {
    mOrb: ^Orb,
    mPos: RL.Vector2,
    mTexture: RL.Texture2D
}

createHealthPanel :: proc() -> ^HealthPanel {
    orb := new(Orb)
    orb.mFillPercent = 100
    orb.mTexture = game.textures["health_orb"][0]
    orb.mBackTexture = game.textures["health_orb"][2]
    orb.mFrontTexture = game.textures["health_orb"][3]
    h_panel := new(HealthPanel)
    h_panel.mPos = RL.Vector2{0, f32(game.height - 130)}
    h_panel.mTexture = game.textures["health_orb"][1]
    orb.mPos = h_panel.mPos + RL.Vector2{0, -100}
    h_panel.mOrb = orb
    return h_panel
}

drawHealthPanel :: proc(panel: ^HealthPanel) {
    DrawOrb(panel.mOrb, panel.mPos)
    RL.DrawTexture(panel.mTexture, i32(panel.mPos[0]), i32(panel.mPos[1]), RL.WHITE)
    RL.DrawTexture(panel.mOrb.mTexture, i32(panel.mOrb.mPos[0]), i32(panel.mOrb.mPos[1]), RL.WHITE)
    if RL.CheckCollisionPointCircle(RL.GetMousePosition(), panel.mPos + RL.Vector2{115, 20}, ORB_RADIUS) {
        tooltip := fmt.tprintf("%v / %v", game.player.mHp, game.player.mMaxHp)
        tooltip_text := strings.clone_to_cstring(tooltip, context.allocator)
        vec := RL.GetMousePosition()
        RL.DrawText(tooltip_text, i32(vec[0]), i32(vec[1]), 20, RL.WHITE)
    }
}

DrawOrb :: proc(orb: ^Orb, panel_pos: RL.Vector2) {
    // Cut circle for Player HP
    circlepos := RL.Vector2{panel_pos[0], panel_pos[1]} + RL.Vector2{115, 20}
    RL.DrawTexture(orb.mBackTexture, i32(orb.mPos[0]+10), i32(orb.mPos[1]+10), RL.WHITE)
    clipheight := ORB_RADIUS * orb.mFillPercent/100
    yOffset := f32(ORB_RADIUS - clipheight*2)
    clipRect := RL.Rectangle{circlepos[0]-ORB_RADIUS, circlepos[1]+yOffset, 
                            ORB_RADIUS*2, ORB_RADIUS*2}
    RL.BeginScissorMode(i32(clipRect.x), i32(clipRect.y), i32(clipRect.width), i32(clipRect.height))
    RL.DrawCircleV(circlepos, ORB_RADIUS, RL.Color{52, 0, 0, 255})
    RL.EndScissorMode()
    RL.DrawTexture(orb.mFrontTexture, i32(orb.mPos[0]+10), i32(orb.mPos[1]+10), RL.WHITE)
    // end cutting
}
package GAME

import RL "vendor:raylib"

ORB_RADIUS :: 110

Orb :: struct {
    mFillPercent: int,
    mTexture: RL.Texture2D,
    mPos: RL.Vector2
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
    h_panel := new(HealthPanel)
    h_panel.mPos = RL.Vector2{0, f32(game.height - 130)}
    h_panel.mTexture = game.textures["health_orb"][1]
    orb.mPos = h_panel.mPos + RL.Vector2{0, -100}
    h_panel.mOrb = orb
    return h_panel
}

drawHealthPanel :: proc(panel: ^HealthPanel) {
    // Cut circle for Player HP
    circlepos := panel.mPos + RL.Vector2{115, 20}
    clipheight := ORB_RADIUS * panel.mOrb.mFillPercent/100
    // yOffset := ORB_RADIUS - clipheight
    clipRect := RL.Rectangle{circlepos[0]-ORB_RADIUS, circlepos[1]+f32(ORB_RADIUS-clipheight*2), 
                            ORB_RADIUS*2, ORB_RADIUS*2}
    RL.BeginScissorMode(i32(clipRect.x), i32(clipRect.y), i32(clipRect.width), i32(clipRect.height))
    RL.DrawCircleV(panel.mPos + RL.Vector2{115, 20}, ORB_RADIUS, RL.Color{136, 8, 8, 255})
    RL.EndScissorMode()
    // end cutting
    RL.DrawTexture(panel.mTexture, i32(panel.mPos[0]), i32(panel.mPos[1]), RL.WHITE)
    RL.DrawTexture(panel.mOrb.mTexture, i32(panel.mOrb.mPos[0]), i32(panel.mOrb.mPos[1]), RL.WHITE)
}
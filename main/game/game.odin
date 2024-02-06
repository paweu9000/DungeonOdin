package game

import RL "vendor:raylib"
import "core:fmt"

Game :: struct {
    width: i32,
    height: i32
}

game := Game{1600, 900}

init :: proc() {
    RL.SetWindowState({.WINDOW_RESIZABLE, .VSYNC_HINT, .FULLSCREEN_MODE});
    RL.InitWindow(game.width, game.height, "Dungeon");
    RL.SetTargetFPS(144);
}

runLoop :: proc() {
    for !RL.WindowShouldClose() {
        processState()
        update()
        draw()
    }
    RL.CloseWindow();
}

processState :: proc() {

}

update :: proc() {

}

draw :: proc() {
    RL.BeginDrawing();
    RL.ClearBackground(RL.LIGHTGRAY);
    RL.DrawRectangleRec({900, 500, 50, 50}, RL.RED);
    RL.EndDrawing();
}



package GAME

import RL "vendor:raylib"
import "core:fmt"
import "core:os"
import "core:strings"
import "core:slice"

Game :: struct {
    width: i32,
    height: i32,
    textures: map[string][dynamic]RL.Texture2D,
    actors: [dynamic]^Actor,
    player: ^Player,
    deltaTime: f32,
    level: ^Level,
    showHitbox: bool
}

game := new(Game)

init :: proc() {
    game.width = 1600
    game.height = 900
    game.showHitbox = false
    game.textures = make(map[string][dynamic]RL.Texture2D)
    RL.SetWindowState({.WINDOW_RESIZABLE, .VSYNC_HINT, .FULLSCREEN_MODE})
    RL.InitWindow(game.width, game.height, "Dungeon")
    RL.SetTargetFPS(144);
    drawLoadingScreen()
    loadAllTextures()
    game.level = initLevel()
    player := createPlayer()
    append(&game.actors, player)
    game.player = player
    enemy := createEnemy(MonsterCategory.SKELETON)
    append(&game.actors, enemy)
    enemy1 := createEnemy(MonsterCategory.SKELETON)
    append(&game.actors, enemy1)
    enemy2 := createEnemy(MonsterCategory.SKELETON)
    append(&game.actors, enemy2)
}

runLoop :: proc() {
    for !RL.WindowShouldClose() {
        game.deltaTime = RL.GetFrameTime()
        processInput()
        update()
        draw()
    }
    RL.CloseWindow();
}

processInput :: proc() {
    if (RL.IsKeyPressed(RL.KeyboardKey.H))
    {
        game.showHitbox = !game.showHitbox
    }
}

update :: proc() {
    for act in game.actors {
        update_actor(act)
    }
    processWallCollision()
    checkForCollision()
    checkAttackCollision()
    sortByDrawOrder()
}

drawLoadingScreen :: proc() {
    RL.BeginDrawing();
    RL.ClearBackground(RL.LIGHTGRAY);
    RL.DrawText("LOADING ASSETS...", game.width/3, game.height/3, 32, RL.BLACK)
    RL.EndDrawing();
}

sortByDrawOrder :: proc() {
    slice.sort_by(game.actors[:], proc(ac1, ac2: ^Actor) -> bool {
        return ac1.mDrawOrder < ac2.mDrawOrder
    })
}

draw :: proc() {
    RL.BeginDrawing();
    RL.ClearBackground(RL.LIGHTGRAY);
    // drawLevel(game.level)
    for act in game.actors {
        draw_actor(act)
    }
    RL.DrawFPS(10, 10)
    RL.EndDrawing();
}

loadAllTextures :: proc() {
    // PLAYER
    // IDLE
    loadDirTextures(game, "/assets/playable character/warrior/warrior_armed_idle/N/", "player_idle_N");
    loadDirTextures(game, "/assets/playable character/warrior/warrior_armed_idle/S/", "player_idle_S");
    loadDirTextures(game, "/assets/playable character/warrior/warrior_armed_idle/W/", "player_idle_W");
    loadDirTextures(game, "/assets/playable character/warrior/warrior_armed_idle/E/", "player_idle_E");
    loadDirTextures(game, "/assets/playable character/warrior/warrior_armed_idle/SE/", "player_idle_SE");
    loadDirTextures(game, "/assets/playable character/warrior/warrior_armed_idle/NE/", "player_idle_NE");
    loadDirTextures(game, "/assets/playable character/warrior/warrior_armed_idle/SW/", "player_idle_SW");
    loadDirTextures(game, "/assets/playable character/warrior/warrior_armed_idle/NW/", "player_idle_NW");

    // WALK
    loadDirTextures(game, "/assets/playable character/warrior/warrior_armed_walk/S/", "player_walk_S");
    loadDirTextures(game, "/assets/playable character/warrior/warrior_armed_walk/N/", "player_walk_N");
    loadDirTextures(game, "/assets/playable character/warrior/warrior_armed_walk/W/", "player_walk_W");
    loadDirTextures(game, "/assets/playable character/warrior/warrior_armed_walk/E/", "player_walk_E");
    loadDirTextures(game, "/assets/playable character/warrior/warrior_armed_walk/SE/", "player_walk_SE");
    loadDirTextures(game, "/assets/playable character/warrior/warrior_armed_walk/NE/", "player_walk_NE");
    loadDirTextures(game, "/assets/playable character/warrior/warrior_armed_walk/SW/", "player_walk_SW");
    loadDirTextures(game, "/assets/playable character/warrior/warrior_armed_walk/NW/", "player_walk_NW");

    // ATTACK
    loadDirTextures(game, "/assets/playable character/warrior/warrior_armed_attack/S/", "player_attack_S");
    loadDirTextures(game, "/assets/playable character/warrior/warrior_armed_attack/N/", "player_attack_N");
    loadDirTextures(game, "/assets/playable character/warrior/warrior_armed_attack/W/", "player_attack_W");
    loadDirTextures(game, "/assets/playable character/warrior/warrior_armed_attack/E/", "player_attack_E");
    loadDirTextures(game, "/assets/playable character/warrior/warrior_armed_attack/SE/", "player_attack_SE");
    loadDirTextures(game, "/assets/playable character/warrior/warrior_armed_attack/NE/", "player_attack_NE");
    loadDirTextures(game, "/assets/playable character/warrior/warrior_armed_attack/SW/", "player_attack_SW");
    loadDirTextures(game, "/assets/playable character/warrior/warrior_armed_attack/NW/", "player_attack_NW");

    // GROUND
    loadDirTextures(game, "/assets/environment/", "ground_1");

    // WALL
    loadDirTextures(game, "/assets/prop/wall1/N/", "wall_1_N");
    loadDirTextures(game, "/assets/prop/wall2/E/", "wall_2_E");

    // SKELETON
    // IDLE
    loadDirTextures(game, "/assets/enemy/skeleton/skeleton_default_idle/E/", "skeleton_idle_E");
    loadDirTextures(game, "/assets/enemy/skeleton/skeleton_default_idle/W/", "skeleton_idle_W");
    loadDirTextures(game, "/assets/enemy/skeleton/skeleton_default_idle/S/", "skeleton_idle_S");
    loadDirTextures(game, "/assets/enemy/skeleton/skeleton_default_idle/N/", "skeleton_idle_N");
    loadDirTextures(game, "/assets/enemy/skeleton/skeleton_default_idle/NE/", "skeleton_idle_NE");
    loadDirTextures(game, "/assets/enemy/skeleton/skeleton_default_idle/SE/", "skeleton_idle_SE");
    loadDirTextures(game, "/assets/enemy/skeleton/skeleton_default_idle/NW/", "skeleton_idle_NW");
    loadDirTextures(game, "/assets/enemy/skeleton/skeleton_default_idle/SW/", "skeleton_idle_SW");

    // WALK
    loadDirTextures(game, "/assets/enemy/skeleton/skeleton_default_walk/E/", "skeleton_walk_E");
    loadDirTextures(game, "/assets/enemy/skeleton/skeleton_default_walk/W/", "skeleton_walk_W");
    loadDirTextures(game, "/assets/enemy/skeleton/skeleton_default_walk/S/", "skeleton_walk_S");
    loadDirTextures(game, "/assets/enemy/skeleton/skeleton_default_walk/N/", "skeleton_walk_N");
    loadDirTextures(game, "/assets/enemy/skeleton/skeleton_default_walk/NE/", "skeleton_walk_NE");
    loadDirTextures(game, "/assets/enemy/skeleton/skeleton_default_walk/SE/", "skeleton_walk_SE");
    loadDirTextures(game, "/assets/enemy/skeleton/skeleton_default_walk/NW/", "skeleton_walk_NW");
    loadDirTextures(game, "/assets/enemy/skeleton/skeleton_default_walk/SW/", "skeleton_walk_SW");

    // ATTACK
    loadDirTextures(game, "/assets/enemy/skeleton/skeleton_default_attack/E/", "skeleton_attack_E");
    loadDirTextures(game, "/assets/enemy/skeleton/skeleton_default_attack/W/", "skeleton_attack_W");
    loadDirTextures(game, "/assets/enemy/skeleton/skeleton_default_attack/S/", "skeleton_attack_S");
    loadDirTextures(game, "/assets/enemy/skeleton/skeleton_default_attack/N/", "skeleton_attack_N");
    loadDirTextures(game, "/assets/enemy/skeleton/skeleton_default_attack/NE/", "skeleton_attack_NE");
    loadDirTextures(game, "/assets/enemy/skeleton/skeleton_default_attack/SE/", "skeleton_attack_SE");
    loadDirTextures(game, "/assets/enemy/skeleton/skeleton_default_attack/NW/", "skeleton_attack_NW");
    loadDirTextures(game, "/assets/enemy/skeleton/skeleton_default_attack/SW/", "skeleton_attack_SW");

    // DEATH
    loadDirTextures(game, "/assets/enemy/skeleton/skeleton_special_death/E/", "skeleton_death_E");
    loadDirTextures(game, "/assets/enemy/skeleton/skeleton_special_death/W/", "skeleton_death_W");
    loadDirTextures(game, "/assets/enemy/skeleton/skeleton_special_death/S/", "skeleton_death_S");
    loadDirTextures(game, "/assets/enemy/skeleton/skeleton_special_death/N/", "skeleton_death_N");
    loadDirTextures(game, "/assets/enemy/skeleton/skeleton_special_death/NE/", "skeleton_death_NE");
    loadDirTextures(game, "/assets/enemy/skeleton/skeleton_special_death/SE/", "skeleton_death_SE");
    loadDirTextures(game, "/assets/enemy/skeleton/skeleton_special_death/NW/", "skeleton_death_NW");
    loadDirTextures(game, "/assets/enemy/skeleton/skeleton_special_death/SW/", "skeleton_death_SW");

    // PROPS
    loadDirTextures(game, "/assets/prop/tiles/N/", "prop_tile_1_N")
    loadDirTextures(game, "/assets/prop/tiles/SE/", "prop_tile_1_SE")
    loadDirTextures(game, "/assets/prop/brazier_lit/N/", "prop_brazier_lit_SE")

    // COMPONENTS
    loadDirTextures(game, "/assets/vfx/swoosh/", "swoosh")
}

loadDirTextures :: proc(game: ^Game, path: string, name: string) {
    abs_path := strings.concatenate({os.get_current_directory(), path})
    dir, _ := os.open(abs_path)
    files, _ := os.read_dir(dir, -1)
    textures := make([dynamic]RL.Texture2D)
    for file in files {
        new_tex := RL.LoadTexture(strings.clone_to_cstring(strings.concatenate({abs_path, file.name})))
        append(&textures, new_tex)
    }
    game.textures[name] = textures
}

checkForCollision :: proc() {
    for ac1 in game.actors {
        for ac2 in game.actors {
            if ac1 == ac2 {continue}
            if doHitboxOverlap(ac1.mHitbox, ac2.mHitbox)
            {
                result := calculateForce(ac1.mHitbox, ac2.mHitbox)
                applyForce(ac1, result.v1)
                applyForce(ac2, result.v2)
                dynamicCollision(ac1, ac2)
            }
        }
    }
}

processWallCollision :: proc() {
    for act in game.actors {
        if checkForWallCollision(act, game.level) {
            act.mHitbox.x -= act.mVelocity.x
            act.mHitbox.y -= act.mVelocity.y
        }
    }
}

checkAttackCollision :: proc() {
    for ac1 in game.actors {
        for ac2 in game.actors {
            if ac1 == ac2 {continue}
            for comp in ac1.mComponents {
                ac2_hb := ac2.mHitbox
                comp_hb := comp.mHitbox
                _, ok := ac2.mHitmap[comp]
                if ok {
                    continue
                }
                else if RL.CheckCollisionCircles(RL.Vector2{comp_hb.x, comp_hb.y}, comp_hb.radius,
                                            RL.Vector2{ac2_hb.x, ac2_hb.y}, ac2_hb.radius)
                {
                    val := true
                    ac2.mHitmap[comp] = val
                    ac2.mHp -= comp.mDmg
                }
            }
        }
    }
}

removeActor :: proc(actor: ^Actor) {
    for ac, index in game.actors {
        if actor == ac {
            unordered_remove(&game.actors, index)
        }
    }
}

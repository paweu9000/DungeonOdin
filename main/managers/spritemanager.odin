package managers

import "core:os"
import RL "vendor:raylib"
import "core:encoding/json"
import "core:fmt"
import "core:strings"
import "core:slice"

ManagerError :: enum {
    None, NonExistentValue
}

TextureData :: struct {
    x, h, w, y: int
}

SpriteManager :: struct {
    textures: map[string]RL.Texture2D,
    json_spritesheet: map[string][dynamic]^TextureData
}

initializeSpriteManager :: proc() -> ^SpriteManager {
    s_manager := new(SpriteManager)
    s_manager.textures = make(map[string]RL.Texture2D)
    s_manager.json_spritesheet = make(map[string][dynamic]^TextureData)
    return s_manager
}

loadTextures :: proc(manager: ^SpriteManager, dir, name: string) {
    tex_path := strings.concatenate({os.get_current_directory(), dir, "spritesheet.png"})
    json_path := strings.concatenate({os.get_current_directory(), dir, "spritesheet.json"})
    tex := RL.LoadTexture(strings.clone_to_cstring(tex_path))
    data, err := os.read_entire_file_from_filename(json_path)
    manager.textures[name] = tex
    if !err {panic("There was an error loading json")}
    json_data, _ := json.parse(data)
    frame_map := json_data.(json.Object)["frames"].(json.Object)
    arr: [dynamic]string
    for k, v in frame_map {
        append(&arr, k)
    }
    slice.sort(arr[:])
    createTextureData(manager, arr, name, frame_map)
}

createTextureData :: proc(manager: ^SpriteManager, arr: [dynamic]string, 
                        name: string, frame_map: json.Object) {
    for v, i in arr {
        state := arr[i][0:1]
        dir_index := strings.index(arr[i], "CAM")
        direction := arr[i][dir_index:dir_index+4]
        tex_name := generateTextureName(state, direction, name)
        tex_data := parseTextureData(frame_map[v].(json.Object))
        if manager.json_spritesheet[tex_name] == nil {
            new_array := make([dynamic]^TextureData)
            manager.json_spritesheet[tex_name] = new_array
        }
        append(&manager.json_spritesheet[tex_name], tex_data)
    }
}

parseTextureData :: proc(val: json.Object) -> ^TextureData {
    json_map := val["frame"].(json.Object)
    tex_data := new(TextureData)
    tex_data.x = int(json_map["x"].(json.Float))
    tex_data.y = int(json_map["y"].(json.Float))
    tex_data.w = int(json_map["w"].(json.Float))
    tex_data.h = int(json_map["h"].(json.Float))
    return tex_data
}

generateTextureName :: proc(state: string, direction: string, name: string) -> string {
    part2: string
    switch state {
        case "1": part2 = "_idle"
        case "2": part2 = "_attack"
        case "3": part2 = "_bow"
        case "4": part2 = "_cast"
        case "5": part2 = "_walk"
        case "6": part2 = "_run"
        case "7": part2 = "_death"
        case: break
    }
    part3: string
    switch direction {
        case "CAM0": part3 = "_SW"
        case "CAM1": part3 = "_W"
        case "CAM2": part3 = "_NW"
        case "CAM3": part3 = "_N"
        case "CAM4": part3 = "_NE"
        case "CAM5": part3 = "_E"
        case "CAM6": part3 = "_SE"
        case "CAM7": part3 = "_S"
        case: break
    }
    return strings.concatenate({name, part2, part3})
}

getTexturesLen :: proc(manager: ^SpriteManager, name: string) -> int {
    return len(manager.json_spritesheet[name])
}

drawTexture :: proc(manager: ^SpriteManager, filename, name: string, frame: int, pos: RL.Vector2) {
    data := manager.json_spritesheet[name][frame]
    RL.DrawTexturePro(manager.textures[filename], {f32(data.x), f32(data.y), f32(data.w), f32(data.h)}, 
        {pos.x, pos.y, f32(data.w)/1.75, f32(data.h)/1.75}, {0,0}, 0, RL.WHITE)
}
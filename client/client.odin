package client

import "core:fmt"
import "core:net"
import "core:log"
import "core:time"
import "core:encoding/json"
import rl "vendor:raylib"

Entity :: struct {
    id: i32,
    x: f32,
    y: f32,
    radius: f32,
    color: rl.Color
}

Player :: struct {
    using Entity
}

Game :: struct {
    player: ^Player,
    entities: [dynamic]^Entity
}

playerToJson :: proc(player: ^Player) -> []byte {
    pjson := Entity{player.id, player.x, player.y, player.radius, player.color}
    js, er := json.marshal(pjson)
    return js
}

main :: proc() {
    //SOCKET
    rand := int(time.to_unix_seconds(time.now()))
    socket, sock_err := net.make_bound_udp_socket(net.IP6_Loopback, rand)
    if sock_err != nil {panic("failed to make UDP socket2")}
    defer net.close(socket)
    //
    game := new(Game)
    player := new(Player)
    
    player.id = i32(rand)
    player.x = 300
    player.y = 300
    player.radius = 15
    player.color = rl.GREEN
    game.player = player
    append(&game.entities, player)

    rl.InitWindow(800, 500, "server test")
    defer rl.CloseWindow()
    rl.SetTargetFPS(60)

    for !rl.WindowShouldClose() {
        update(game)
        draw(game)
        mar := playerToJson(game.player)
        bytes_written, send_err := net.send_udp(socket, mar[:], {net.IP6_Loopback, 8080})
        if send_err != nil {panic("Failed to send packet")}
        recv_message: [4096]byte
        bytes_read, endpoint, recv_err := net.recv_udp(socket, recv_message[:])
        if recv_err != nil {panic("Failed to receive packet")}
        response_arr, err := json.parse(recv_message[:bytes_read])
        handleResponse(response_arr, game)
    }
}

handleResponse :: proc(arrjson: json.Value, state: ^Game) {
    arr := arrjson.(json.Array)
    for jsonobj in arr {
        obj := jsonobj.(json.Object)
        id := i32((obj["id"].(json.Float)))
        x := f32((obj["x"].(json.Float)))
        y := f32((obj["y"].(json.Float)))
        // radius := f32((obj["radius"].(json.Float)))
        // color_arr := obj["color"].(json.Array)
        // color := rl.Color{u8(color_arr[0].(json.Float)), u8(color_arr[1].(json.Float)), u8(color_arr[2].(json.Float)), u8(color_arr[3].(json.Float))}
        exist := false
        for e in state.entities {
            if id == e.id {
                exist = true
                e.x = x
                e.y = y
                break
            }
        }
        if !exist {
            radius := f32((obj["radius"].(json.Float)))
            color_arr := obj["color"].(json.Array)
            color := rl.Color{u8(color_arr[0].(json.Float)), u8(color_arr[1].(json.Float)), u8(color_arr[2].(json.Float)), u8(color_arr[3].(json.Float))}
            ent := new(Entity)
            ent.id = id
            ent.x = x
            ent.y = y
            ent.radius = radius
            ent.color = color
            append(&state.entities, ent)
        }
    }
}

draw :: proc(game: ^Game) {
    rl.BeginDrawing()
    rl.ClearBackground(rl.BLACK)
    for e in game.entities {
        rl.DrawCircle(i32(e.x), i32(e.y), e.radius, e.color)
    }
    rl.EndDrawing()
}

update :: proc(game: ^Game) {
    x, y: f32
    x = 0
    y = 0
    if rl.IsKeyDown(.W){
        x = 0
        y = -2
    }
    else if rl.IsKeyDown(.D){
        x = 2
        y = 0
    }
    else if rl.IsKeyDown(.S){
        x = 0
        y = 2
    }
    else if rl.IsKeyDown(.A){
        x = -2
        y = 0
    }
    for e in game.entities {
        if e.id == game.player.id {
            e.x += x
            e.y += y
        }
    }
}
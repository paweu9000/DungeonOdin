package server

import "core:net"
import "core:fmt"
import "core:log"
import "core:encoding/json"
import "core:strings"
import rl "vendor:raylib"

main :: proc() {
    state := new(State)
    state.current_players = make(map[int]Player)
    server_port := 8080
    sock2, err2 := net.make_bound_udp_socket(net.IP6_Loopback, server_port)
    if err2 != nil {panic("failed to make UDP socket2")}
    defer net.close(sock2)
    net.bind(sock2, {net.IP6_Loopback, server_port})

    for {
        recv_message: [4096]u8
        bytes_read, endpoint, recv_err := net.recv_udp(sock2, recv_message[:])
        if recv_err != nil {panic("Failed to receive packet")}
        if bytes_read > 0 {
            // fmt.println("Received message from: ", endpoint)
            // fmt.println(string(recv_message[:bytes_read]))
            val := recv_message[:bytes_read]
            // fmt.println(string(val[:]))
            js, err := json.parse(val)
            defer json.destroy_value(js)
            mp := js.(json.Object)
            sender_id := updatePlayers(mp, state)
            players_array: [dynamic]Player
            for id, player in state.current_players {
                if id != sender_id {
                    append_elem(&players_array, player)
                }
            }
            send_back_data, _ := json.marshal(players_array)
            net.send_udp(sock2, send_back_data, endpoint)
        }
    }
    net.close(sock2)
}

updatePlayers :: proc(m: json.Object, state: ^State) -> int {
    x := m["x"].(json.Float)
    y := m["y"].(json.Float)
    id := m["id"].(json.Float)
    radius := m["radius"].(json.Float)
    color := m["color"].(json.Array)
    pl := Player{int(id), x, y, radius, rl.Color{u8(color[0].(json.Float)), u8(color[1].(json.Float)), u8(color[2].(json.Float)), u8(color[3].(json.Float))}}
                
    state.current_players[int(id)] = pl
    return int(id)
}

State :: struct {
    current_players: map[int]Player
}

Player :: struct {
    id: int,
    x: f64,
    y: f64,
    radius: f64,
    color: rl.Color
}
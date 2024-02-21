package server

import "core:net"
import "core:fmt"
import "core:log"
import "core:encoding/json"
import "core:strings"
import rl "vendor:raylib"


State :: struct {
    current_players: map[int]Player
}

Player :: struct {
    id: int,
    x: int,
    y: int,
    frame: int,
    category: int,
    direction: int,
    state: int
}

main :: proc() {
    state := new(State)
    state.current_players = make(map[int]Player)
    server_port := 8080
    socket, err2 := net.make_bound_udp_socket(net.IP6_Loopback, server_port)
    if err2 != nil {panic("failed to make UDP socket2")}
    defer net.close(socket)
    net.bind(socket, {net.IP6_Loopback, server_port})

    handleNetworkTraffic(socket, state)
    // for {
    //     recv_message: [4096]u8
    //     bytes_read, endpoint, recv_err := net.recv_udp(socket, recv_message[:])
    //     if recv_err != nil {panic("Failed to receive packet")}
    //     if bytes_read > 0 {
    //         val := recv_message[:bytes_read]
    //         // fmt.println(string(val[:]))
    //         js, err := json.parse(val)
    //         defer json.destroy_value(js)
    //         mp := js.(json.Object)
    //         sender_id := updatePlayers(mp, state)
    //         // players_array: [dynamic]Player
    //         // for id, player in state.current_players {
    //         //     if id != sender_id {
    //         //         append_elem(&players_array, player)
    //         //     }
    //         // }
    //         // send_back_data, _ := json.marshal(players_array)
    //         // net.send_udp(socket, send_back_data, endpoint)
    //     }
    // }
    // net.close(sock2)
}

handleNetworkTraffic :: proc(socket: net.UDP_Socket, state: ^State) {
    for {
            handlePayload(socket, state)
            // players_array: [dynamic]Player
            // for id, player in state.current_players {
            //     if id != sender_id {
            //         append_elem(&players_array, player)
            //     }
            // }
            // send_back_data, _ := json.marshal(players_array)
            // net.send_udp(socket, send_back_data, endpoint)
    }
    net.close(socket)
}

handlePayload :: proc(socket: net.UDP_Socket, state: ^State) {
    recv_message: [4096]u8
    bytes_read, endpoint, recv_err := net.recv_udp(socket, recv_message[:])
    if recv_err != nil {panic("Failed to receive packet")}
    if bytes_read > 0 {
        val := recv_message[:bytes_read]
        js, err := json.parse(val)
        defer json.destroy_value(js)
        mp := js.(json.Object)
        sender_id := updatePlayers(mp, state)
        response := createResponse(state, sender_id)
        net.send_udp(socket, response, endpoint)
    }
}

createResponse :: proc(state: ^State, sender_id: int) -> []byte {
    players_array: [dynamic]Player
    for id, player in state.current_players {
        if id != sender_id {
            append_elem(&players_array, player)
        }
    }
    send_back_data, err := json.marshal(players_array)
    if err != nil {log.debugf("Response error: %v", err)}
    return send_back_data
}

updatePlayers :: proc(payload: json.Object, state: ^State) -> int {
    id := int(payload["id"].(json.Float))
    x := int(payload["x"].(json.Float))
    y := int(payload["y"].(json.Float))
    frame := int(payload["frame"].(json.Float))
    direction := int(payload["direction"].(json.Float))
    category := int(payload["category"].(json.Float))
    player_state := int(payload["state"].(json.Float))

    player_payload := Player{id, x, y, frame, category, direction, player_state}

    state.current_players[id] = player_payload
    
    return id
}

package server

import "core:net"
import "core:fmt"
import "core:log"
import "core:encoding/json"
import "core:strings"
import rl "vendor:raylib"


State :: struct {
    current_players: map[int]^Player
}

EquipmentData :: struct {
    weapon, belt, chest, arms: cstring,
    head, shoulders, boots, legs: cstring
}

Player :: struct {
    id: int,
    x: int,
    y: int,
    frame: int,
    category: int,
    direction: int,
    state: int,
    equipment: EquipmentData
}

main :: proc() {
    state := new(State)
    state.current_players = make(map[int]^Player)
    server_port := 8080
    socket, err2 := net.make_bound_udp_socket(net.IP6_Loopback, server_port)
    if err2 != nil {panic("failed to make UDP socket2")}
    defer net.close(socket)
    net.bind(socket, {net.IP6_Loopback, server_port})

    handleNetworkTraffic(socket, state)
}

handleNetworkTraffic :: proc(socket: net.UDP_Socket, state: ^State) {
    for {
            handlePayload(socket, state)
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
            append_elem(&players_array, player^)
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
    player_equipment := payload["equipment"].(json.Object)
    parsed_eq := mapEquipment(player_equipment)
    player: ^Player
    if id in state.current_players {
        player = state.current_players[id]
        player.equipment.arms = parsed_eq.arms
        player.equipment.belt = parsed_eq.belt
        player.equipment.boots = parsed_eq.boots
        player.equipment.chest = parsed_eq.chest
        player.equipment.head = parsed_eq.head
        player.equipment.legs = parsed_eq.legs
        player.equipment.shoulders = parsed_eq.shoulders
        player.equipment.weapon = parsed_eq.weapon
    } else {
        player = new(Player)
        state.current_players[id] = player
        player.equipment = parsed_eq
        player.id = id
    }
    player.x = x
    player.y = y
    player.frame = frame
    player.category = category
    player.direction = direction
    player.state = player_state
    
    return id
}

mapEquipment :: proc(eq_map: json.Object) -> EquipmentData {
    weapon := strings.clone_to_cstring(eq_map["weapon"].(json.String))
    belt := strings.clone_to_cstring(eq_map["belt"].(json.String))
    chest := strings.clone_to_cstring(eq_map["chest"].(json.String))
    arms := strings.clone_to_cstring(eq_map["arms"].(json.String))
    head := strings.clone_to_cstring(eq_map["head"].(json.String))
    shoulders := strings.clone_to_cstring(eq_map["shoulders"].(json.String))
    boots := strings.clone_to_cstring(eq_map["boots"].(json.String))
    legs := strings.clone_to_cstring(eq_map["legs"].(json.String))

    pl_equipment := EquipmentData{weapon, belt, chest, arms, head, shoulders, boots, legs}
    return pl_equipment
}

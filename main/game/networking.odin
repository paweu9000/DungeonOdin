package GAME

import "core:net"
import "core:encoding/json"
import "core:fmt"
import "core:log"
import "core:strings"
import RL "vendor:raylib"

OFFSET_X :: 128
OFFSET_Y :: 127

Category :: enum {
    PLAYER, SKELETON, SLIME
}

EquipmentData :: struct {
    weapon, belt, chest, arms: string, 
    head, shoulders, boots, legs: string
}

ActorPayload :: struct {
    id: int,
    x: int,
    y: int,
    frame: int,
    direction: Direction,
    category: Category,
    state: State,
    equipment: EquipmentData
}

createEquipmentData :: proc(player: ^Player) -> EquipmentData {
    eq := player.mEquipment
    eqData := EquipmentData{eq.weapon.name, eq.belt.name, eq.chest.name, eq.arms.name,
        eq.head.name, eq.shoulders.name, eq.boots.name, eq.legs.name}
    return eqData
}

parseEquipmentData :: proc(eq_map: json.Object) -> EquipmentData {
    weapon := eq_map["weapon"].(json.String)
    belt := eq_map["belt"].(json.String)
    chest := eq_map["chest"].(json.String)
    arms := eq_map["arms"].(json.String)
    head := eq_map["head"].(json.String)
    shoulders := eq_map["shoulders"].(json.String)
    boots := eq_map["boots"].(json.String)
    legs := eq_map["legs"].(json.String)

    pl_equipment := EquipmentData{weapon, belt, chest, arms, head, shoulders, boots, legs}

    return pl_equipment
}

handleNetworkTraffic :: proc (game: ^Game, socket: net.UDP_Socket) {
    sendPlayerPayload(game, socket)
    handleResponsePayload(game, socket)
}

sendPlayerPayload :: proc(game: ^Game, socket: net.UDP_Socket) {
    pl := game.player
    payload := ActorPayload{game.client_id, int(pl.mHitbox.x), int(pl.mHitbox.y),
                            int(pl.mFrame), pl.mDirection, .PLAYER, pl.mState, createEquipmentData(pl)}
    json_payload, err := json.marshal(payload)
    if err != nil {panic("There was an error creating actor payload")}
    bytes_written, send_err := net.send_udp(socket, json_payload[:], {net.IP6_Loopback, 8080})
    if send_err != nil {panic("Failed to send packet")}
}

handleResponsePayload :: proc(game: ^Game, socket: net.UDP_Socket) {
    recv_message: [4096]byte
    bytes_read, endpoint, recv_err := net.recv_udp(socket, recv_message[:])
    if recv_err != nil {log.debug("Failed to receive packet")}
    response_arr, err := json.parse(recv_message[:bytes_read])
    if err != nil {log.debug("Failed to parse response")}
    #partial switch v in response_arr {
        case json.Array: handlePlayerUpdates(response_arr.(json.Array))
        case json.Object: handleEnemyUpdates(response_arr.(json.Object))
    }
}

handlePlayerUpdates :: proc(json_array: json.Array) {
    for obj in json_array {
        payload := obj.(json.Object)
        id := int(payload["id"].(json.Float))
        x := payload["x"].(json.Float)
        y := payload["y"].(json.Float)
        frame := payload["frame"].(json.Float)
        direction := int(payload["direction"].(json.Float))
        category := int(payload["category"].(json.Float))
        state := int(payload["state"].(json.Float))
        equipment := parseEquipmentData(payload["equipment"].(json.Object))
                
        exists := false
        for act in game.actors {
            if act.mID == id {
                act.mHitbox.x = f32(x)
                act.mHitbox.y = f32(y)
                act.mFrame = f32(frame)
                act.mDirection = cast(Direction)direction
                act.mState = cast(State)state
                act.mTexture = generate_texture_name(act)
                updateEquipmentFromParsedData(equipment, act.mEquipment)
                exists = true
                break
                }
            }
            if !exists {
                act := new(Actor)
                act.mID = id
                act.mState = cast(State)state
                act.mType = .PLAYER
                act.mMovementSpeed = 2.4
                act.mHp = 10
                act.mMaxHp = 10
                act.mHitmap = make(map[^Component]bool)
                act.mMass = 0.3
                act.mHitbox = Hitbox{f32(x), f32(y), 10, RL.BLUE}
                act.mTexture = generate_texture_name(act)
                act.mFrame = f32(frame);
                act.mEquipment = createEquipmentFromParsedData(equipment)
                append(&game.actors, act)
            }
        }
}

handleEnemyUpdates :: proc(enemy_json: json.Object) {
    id := int(enemy_json["id"].(json.Float))
    is_existing_enemy := false
    for actor in game.actors {
        if actor.mID == id {
            actor.mHitbox.x = f32(enemy_json["x"].(json.Float))
            actor.mHitbox.y = f32(enemy_json["y"].(json.Float))
            is_existing_enemy = true
        }
    }
    if !is_existing_enemy {
        enemy := createEnemy(.SKELETON)
        enemy.mID = id
        enemy.mTexture = strings.concatenate({enemy_json["name"].(json.String), "_idle_S"})
        enemy.mHitbox.x = f32(enemy_json["x"].(json.Float))
        enemy.mHitbox.y = f32(enemy_json["y"].(json.Float))
        enemy.mMovementSpeed = f32(enemy_json["speed"].(json.Float))
        append(&game.actors, enemy)
    }
}
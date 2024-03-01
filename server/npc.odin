package server

import "core:fmt"
import "core:log"
import "core:encoding/json"
import "base:intrinsics"

NpcType :: enum {
    Friendly, Hostile, Neutral
}

Item :: struct {
    id: u64,
    name: cstring,
    droprate: int
}

Npc :: struct {
    id: u64,
    type: NpcType,
    name: cstring,
    level: int,
    speed: f32,
    x, y: int,
    droptable: []Item
}

createNpc :: proc(type: NpcType, name: cstring, level, x, y: int, speed: f32) {
    npc := new(Npc)
    npc.id = get_next_id()
    npc.type = type
    npc.name = name
    npc.x = x
    npc.y = y
    npc.level = level
    npc.speed = speed
    append(&state.npcs, npc)
}

get_next_id :: proc "contextless" () -> u64 {
    @(static) id: u64
    return 1+intrinsics.atomic_add(&id, 1)
}

createNpcPayload :: proc(npc_ptr: ^Npc) -> []byte {
    npc := npc_ptr^
    npc_payload, err := json.marshal(npc)
    if err != nil {log.debugf("Npc parsing error: %v", err)}
    return npc_payload
}
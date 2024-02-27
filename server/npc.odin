package server

NpcType :: enum {
    Friendly, Hostile, Neutral
}

Item :: struct {
    id: int,
    name: string,
    droprate: int
}

Npc :: struct {
    type: NpcType,
    name: string,
    level: int,
    speed: f32,
    droptable: []Item
}

createNpc :: proc(type: NpcType, name: string, level: int, speed: f32) {
    npc := new(Npc)
    npc.type = type
    npc.name = name
    npc.level = level
    npc.speed = speed
    append(&state.npcs, npc)
}
package GAME

import "core:log"
import RL "vendor:raylib"
import "core:strings"
import "../managers"
import "core:fmt"

ItemType :: enum {
    WEAPON, BELT, HEAD, CHEST, ARMS, SHOULDERS, BOOTS, LEGS, NEUTRAL, CONSUMABLE
}

Rarity :: enum {
    NORMAL, UNIQUE, EPIC, LEGENDARY
}

BonusStats :: struct {
    strength, dexterity, stamina, intelligence: int,
    luck: int
}

Item :: struct {
    name: string,
    type: ItemType,
    rarity: Rarity,
    stats: BonusStats
}

Equipment :: struct {
    weapon, belt, chest, arms, head, shoulders, boots, legs: ^Item
}

createItem :: proc(type: ItemType, rarity: Rarity, name: string) -> ^Item {
    item := new(Item)
    item.name = name
    item.type = type
    item.rarity = rarity
    item.stats = {5, 1, 2, 0, 3}
    return item
}

createEquipment :: proc() -> ^Equipment {
    return new(Equipment)
}

equipItem :: proc(equipment: ^Equipment, item: ^Item) {
    #partial switch item.type {
        case .ARMS: equipment.arms = item
        case .BELT: equipment.belt = item
        case .BOOTS: equipment.boots = item
        case .LEGS: equipment.legs = item
        case .SHOULDERS: equipment.shoulders = item
        case .WEAPON: equipment.weapon = item
        case .CHEST: equipment.chest = item
        case .HEAD: equipment.head = item
        case: log.debugf("Tried to equip unsuitable item")
    }
}

createTestEquipment :: proc() -> ^Equipment {
    eq := createEquipment()
    equipItem(eq, createItem(.LEGS, .NORMAL, "bluepants1"))
    equipItem(eq, createItem(.CHEST, .NORMAL, "bluevest1"))
    equipItem(eq, createItem(.WEAPON, .NORMAL, "boneclub1"))
    equipItem(eq, createItem(.BOOTS, .NORMAL, "blackboots1"))
    equipItem(eq, createItem(.ARMS, .NORMAL, "ahoularmguards1"))
    equipItem(eq, createItem(.HEAD, .NORMAL, "drkhelm1"))
    equipItem(eq, createItem(.SHOULDERS, .NORMAL, "drkshoulderpad1"))
    return eq
}

drawActorEquipment :: proc(actor: ^Actor) {
    if actor.mType == .ENEMY do return
    if actor.mType == .PLAYER && actor.mID == game.client_id {
        eq := actor.mEquipment
        managers.drawTexture(game.sprite_manager, eq.legs.name, generateEquipmentName(actor, eq.legs.name), 
                            int(actor.mFrame), {actor.mHitbox.x-42, actor.mHitbox.y-56})
        managers.drawTexture(game.sprite_manager, eq.chest.name, generateEquipmentName(actor, eq.chest.name), 
                            int(actor.mFrame), {actor.mHitbox.x-42, actor.mHitbox.y-56})
        managers.drawTexture(game.sprite_manager, eq.weapon.name, generateEquipmentName(actor, eq.weapon.name), 
                            int(actor.mFrame), {actor.mHitbox.x-42, actor.mHitbox.y-56})
        managers.drawTexture(game.sprite_manager, eq.boots.name, generateEquipmentName(actor, eq.boots.name), 
                            int(actor.mFrame), {actor.mHitbox.x-42, actor.mHitbox.y-56})
        managers.drawTexture(game.sprite_manager, eq.arms.name, generateEquipmentName(actor, eq.arms.name), 
                            int(actor.mFrame), {actor.mHitbox.x-42, actor.mHitbox.y-56})
        managers.drawTexture(game.sprite_manager, eq.head.name, generateEquipmentName(actor, eq.head.name), 
                            int(actor.mFrame), {actor.mHitbox.x-42, actor.mHitbox.y-56})
        managers.drawTexture(game.sprite_manager, eq.shoulders.name, generateEquipmentName(actor, eq.shoulders.name), 
                            int(actor.mFrame), {actor.mHitbox.x-42, actor.mHitbox.y-56})
    }
}

generateEquipmentName :: proc(actor: ^Actor, equipmentName: string) -> string {
    part2: string
    switch actor.mState {
            case State.IDLE:
                part2 = "idle_";
            case State.MOVE:
                part2 = "walk_";
            case State.ATTACK:
                part2 = "attack_";
            case State.DEATH:
                part2 = "death_"
            case State.DEAD:
                part2 = "death_"
    }
    part3: string
    switch (actor.mDirection)
    {
            case Direction.N:
                part3 = "N";
            case Direction.W:
                part3 = "W";
            case Direction.E:
                part3 = "E";
            case Direction.S:
               part3 = "S";
            case Direction.NE:
                part3 = "NE";
            case Direction.NW:
                part3 = "NW";
            case Direction.SE:
                part3 = "SE";
            case Direction.SW:
                part3 = "SW";
        }
    return strings.concatenate({equipmentName, "_", part2, part3})
}
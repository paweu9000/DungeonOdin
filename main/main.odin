package main

import "core:fmt"
import "game"

main :: proc() {
    game.init()
    game.runLoop()
}
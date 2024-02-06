package main

import "core:fmt"
import "game"

main :: proc() {
    fmt.println("Sup")
    game.init()
    game.runLoop()
}
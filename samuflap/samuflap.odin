package main

import "core:os"

import "../engine"

main :: proc() {
    eng, ok := engine.init()
    if !ok {
        os.exit(1)
    }
    defer engine.destroy(eng)
}


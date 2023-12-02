package main

import "core:c"
import "core:c/libc"
import "core:os"

import "../engine"
import samure "../lib/samurai-render"

on_event :: proc "c" (
    ctx: ^samure.context_t,
    event: ^samure.event,
    user_data: rawptr,
) {
    #partial switch event.type {
    case .POINTER_BUTTON:
        ctx.running = false
    }
}

on_render :: proc "c" (
    ctx: ^samure.context_t,
    layer_surface: ^samure.layer_surface,
    output_geo: samure.rect,
    user_data: rawptr,
) {}

on_update :: proc "c" (
    ctx: ^samure.context_t,
    delta_time: c.double,
    user_data: rawptr,
) {
    libc.printf("Update: %f\n", 1.0 / delta_time)
}

main :: proc() {
    ok := engine.init(on_event, on_render, on_update)
    if !ok {
        os.exit(1)
    }
    defer engine.destroy()

    engine.run()
}


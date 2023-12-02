package main

import "core:c"
import "core:c/libc"
import "core:os"

import "../engine"
import samure "../lib/samurai-render"
import gl "vendor:OpenGL"

VERT_SRC :: `#version 330 core
#extension GL_ARB_explicit_uniform_location : require
layout (location = 0) in vec3 aPos;

layout (location = 1) uniform mat4 proj;

void main()
{
   gl_Position = proj * vec4(aPos.x, aPos.y, aPos.z, 1.0);
}`

FRAG_SRC :: `#version 330 core
out vec4 FragColor;
void main()
{
   FragColor = vec4(1.0f, 0.5f, 0.2f, 1.0f);
}`

app_t :: struct {
    shader_prog: u32,
}
app: app_t

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
) {
    gl.ClearColor(1.0, 0.0, 0.0, 0.0)
    gl.Clear(gl.COLOR_BUFFER_BIT)

    gl.UseProgram(app.shader_prog)
}

on_update :: proc "c" (
    ctx: ^samure.context_t,
    delta_time: c.double,
    user_data: rawptr,
) {
}

main :: proc() {
    ok := engine.init(on_event, on_render, on_update)
    if !ok {
        os.exit(1)
    }
    defer engine.destroy()

    app.shader_prog, ok = engine.build_shader_program(VERT_SRC, FRAG_SRC)
    if !ok {
        os.exit(1)
    }

    engine.run()
}


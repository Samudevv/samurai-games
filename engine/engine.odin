package engine

import "core:dynlib"
import "core:fmt"
import "core:os"
import "core:strings"

import samure "../lib/samurai-render"
import gl "vendor:OpenGL"

GL_LIB :: "libGL.so"
gl_lib: dynlib.Library

glGetProcAddress :: proc(p: rawptr, name: cstring) {
    if gl_lib == nil {
        ok: bool = ---
        gl_lib, ok = dynlib.load_library(GL_LIB)
        if !ok {
            fmt.eprintf("failed to load %s\n", GL_LIB)
            os.exit(1)
        }
    }

    name_str := strings.clone_from_cstring(name)
    (cast(^rawptr)p)^ = dynlib.symbol_address(gl_lib, name_str)
}

engine_t :: struct {
    ctx: ^samure.context_t,
}

engine: engine_t

init :: proc(
    event: samure.event_callback,
    render: samure.render_callback,
    update: samure.update_callback,
) -> bool {
    cfg := samure.create_context_config(event, render, update, nil)
    cfg.gl = samure.default_opengl_config()
    cfg.backend = samure.backend_type.OPENGL
    cfg.pointer_interaction = true
    cfg.gl.major_version = 3
    cfg.gl.minor_version = 3
    cfg.gl.samples = 4

    ctx, err := samure.create_context(&cfg)
    if err != samure.ERROR_NONE {
        samure.perror("failed to create context", err)
        return false
    }
    engine.ctx = ctx

    samure.backend_opengl_make_context_current(
        samure.get_backend_opengl(ctx),
        nil,
    )
    gl.load_up_to(3, 3, glGetProcAddress)
    fmt.printf("OpenGL Version: %s\n", gl.GetString(gl.VERSION))

    return true
}

destroy :: proc() {
    samure.destroy_context(engine.ctx)
}

run :: proc() {
    samure.context_run(engine.ctx)
}

build_shader_program :: proc(
    vertexCode: string,
    fragmentCode: string,
) -> (
    u32,
    bool,
) {
    // build and compile shader
    vert_src := strings.clone_to_cstring(vertexCode)
    frag_src := strings.clone_to_cstring(fragmentCode)
    vert := gl.CreateShader(gl.VERTEX_SHADER)
    frag := gl.CreateShader(gl.FRAGMENT_SHADER)
    defer gl.DeleteShader(vert)
    defer gl.DeleteShader(frag)

    gl.ShaderSource(vert, 1, &vert_src, nil)
    gl.ShaderSource(frag, 1, &frag_src, nil)

    gl.CompileShader(vert)
    gl.CompileShader(frag)

    success: i32
    log: [512]u8
    gl.GetShaderiv(vert, gl.COMPILE_STATUS, &success)
    if success == 0 {
        gl.GetShaderInfoLog(vert, 512, nil, cast([^]u8)&log)
        log_str := strings.clone_from_bytes(log[:])
        fmt.eprintf("ERROR::VERTEX: %s\n", log_str)
        return 0, false
    }
    gl.GetShaderiv(frag, gl.COMPILE_STATUS, &success)
    if success == 0 {
        gl.GetShaderInfoLog(frag, 512, nil, cast([^]u8)&log)
        log_str := strings.clone_from_bytes(log[:])
        fmt.eprintf("ERROR::FRAGMENT: %s\n", log_str)
        return 0, false
    }

    shader_prog := gl.CreateProgram()
    gl.AttachShader(shader_prog, vert)
    gl.AttachShader(shader_prog, frag)
    gl.LinkProgram(shader_prog)

    gl.GetProgramiv(shader_prog, gl.LINK_STATUS, &success)
    if success == 0 {
        gl.GetProgramInfoLog(shader_prog, 512, nil, cast([^]u8)&log)
        log_str := strings.clone_from_bytes(log[:])
        fmt.eprintf("ERROR::PROGRAM: %s\n", log_str)
        return 0, false
    }

    return shader_prog, true
}


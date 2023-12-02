package engine

import "core:dynlib"
import "core:fmt"
import "core:os"
import "core:strings"

import samure "../lib/samurai-render"

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

engine :: struct {
    ctx: ^samure.context_t,
}

init :: proc() -> (engine, bool) {
    cfg := samure.create_context_config(nil, nil, nil, nil)
    ctx, err := samure.create_context(&cfg)
    if err != samure.ERROR_NONE {
        samure.perror("failed to create context", err)
        return engine{}, false
    }

    return engine{ctx = ctx}, true
}

destroy :: proc(eng: engine) {
    samure.destroy_context(eng.ctx)
}


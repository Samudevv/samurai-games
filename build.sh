#! /bin/sh

set -ex

selfdir=$(dirname $0)

echo Build C library ...
xmake config -P $selfdir/lib/samurai-render/lib/samurai-render --backend_opengl=y --backend_cairo=n
xmake -P $selfdir/lib/samurai-render/lib/samurai-render
ln -rs build/linux/x86_64/release/libsamurai-render.a build/linux/x86_64/release/libsamurai_render.a

samuflap/build.sh

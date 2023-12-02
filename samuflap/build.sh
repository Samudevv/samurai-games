#! /bin/sh

set -ex

selfdir=$(dirname $0)

echo Building samuflap ...

odin build $selfdir \
-extra-linker-flags="-L$selfdir/../build/linux/x86_64/release -lwayland-client -lwayland-cursor -lwayland-egl -lEGL" \
-out:$selfdir/samuflap \
-o:minimal

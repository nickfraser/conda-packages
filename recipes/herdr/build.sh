#!/usr/bin/env bash
set -euxo pipefail

export LIBGHOSTTY_VT_OPTIMIZE=ReleaseFast
export LIBGHOSTTY_VT_SIMD=true
export ZIG=zig

cargo build --release --locked

install -Dm755 target/release/herdr "${PREFIX}/bin/herdr"

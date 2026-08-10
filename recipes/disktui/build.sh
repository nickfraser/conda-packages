#!/usr/bin/env bash
set -euxo pipefail

cargo build --release --locked

install -Dm755 "target/${CARGO_BUILD_TARGET}/release/disktui" "${PREFIX}/bin/disktui"
install -Dm755 "target/${CARGO_BUILD_TARGET}/release/disktui-helper" "${PREFIX}/bin/disktui-helper"

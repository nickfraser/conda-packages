#!/usr/bin/env bash
set -euxo pipefail

cargo build --release --locked

install -Dm755 "target/${CARGO_BUILD_TARGET}/release/tuxedo" "${PREFIX}/bin/tuxedo"

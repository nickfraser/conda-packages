#!/usr/bin/env bash
set -euxo pipefail

cargo build --release --locked

install -Dm755 target/release/tuxedo "${PREFIX}/bin/tuxedo"

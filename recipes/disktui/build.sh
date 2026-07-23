#!/usr/bin/env bash
set -euxo pipefail

cargo build --release --locked

install -Dm755 target/release/disktui "${PREFIX}/bin/disktui"
install -Dm755 target/release/disktui-helper "${PREFIX}/bin/disktui-helper"

#!/usr/bin/env bash
set -euxo pipefail

make target/release/bin/cha
install -Dm755 target/release/bin/cha "${PREFIX}/bin/cha"

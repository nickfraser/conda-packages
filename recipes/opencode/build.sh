#!/usr/bin/env bash
set -euxo pipefail

export LD_LIBRARY_PATH="${BUILD_PREFIX}/lib:${PREFIX}/lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
export MODELS_DEV_API_JSON="${SRC_DIR}/models-dev-api.json"
export OPENCODE_DISABLE_MODELS_FETCH=true
export OPENCODE_VERSION="${PKG_VERSION}"
export OPENCODE_CHANNEL=prod

tar -xJf "${SRC_DIR}/opencode-node_modules-linux-x64-${PKG_VERSION}.tar.xz" -C "${SRC_DIR}"

pushd packages/opencode
bun --bun ./script/build.ts --single --skip-install
bun --bun ./script/schema.ts schema.json
install -Dm755 dist/opencode-*/bin/opencode "${PREFIX}/bin/opencode"
install -Dm644 schema.json "${PREFIX}/share/opencode/schema.json"
popd

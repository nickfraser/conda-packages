#!/usr/bin/env bash
set -euxo pipefail

install -d "${PREFIX}/share/pi"
cp -a \
  CHANGELOG.md \
  README.md \
  LICENSE \
  assets \
  docs \
  examples \
  export-html \
  node_modules \
  package.json \
  photon_rs_bg.wasm \
  pi \
  theme \
  "${PREFIX}/share/pi/"

chmod 755 "${PREFIX}/share/pi/pi"

install -d "${PREFIX}/bin"
cat > "${PREFIX}/bin/pi" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PREFIX_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

exec "${PREFIX_DIR}/share/pi/pi" "$@"
EOF

chmod 755 "${PREFIX}/bin/pi"

#!/usr/bin/env bash
set -euxo pipefail

make
make install PREFIX="${PREFIX}"

# Keep the package focused on the browser runtime for now.
rm -f "${PREFIX}/bin/mancha"
rm -rf "${PREFIX}/share/man"

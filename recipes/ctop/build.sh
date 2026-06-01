#!/usr/bin/env bash
set -euxo pipefail

export CGO_ENABLED=0

go build \
  -tags release \
  -ldflags "-w -X main.version=${PKG_VERSION} -X main.build=conda" \
  -o "${PREFIX}/bin/ctop"

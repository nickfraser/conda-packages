#!/usr/bin/env bash
set -euxo pipefail

export CGO_ENABLED=0

go build -o "${PREFIX}/bin/git-credential-gopass"

#!/usr/bin/env bash
set -euxo pipefail

./configure \
  --prefix="${PREFIX}" \
  --disable-pam \
  --disable-utmp \
  --disable-telnet

make -j"${CPU_COUNT}"
make install

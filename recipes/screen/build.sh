#!/usr/bin/env bash
set -euxo pipefail

./configure \
  --prefix="${PREFIX}" \
  --disable-pam \
  --disable-utmp \
  --disable-telnet

make -j"${CPU_COUNT}"

install -d "${PREFIX}/bin" "${PREFIX}/share/screen/utf8encodings"
install -m 755 "screen" "${PREFIX}/bin/screen-5.0.1"
ln -s "screen-5.0.1" "${PREFIX}/bin/screen"
install -m 644 utf8encodings/?? "${PREFIX}/share/screen/utf8encodings/"

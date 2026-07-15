#!/usr/bin/env bash
set -euxo pipefail

perl -0pi -e "s@int   AddXChars \(char \*, int, char \*\);\n@int   AddXChars (char *, int, char *);\nstatic inline int xatoi (const char *str)\n{\n\tint sign, value;\n\n\twhile (*str == ' ' || ((unsigned char)*str >= 9 && (unsigned char)*str <= 13))\n\t\tstr++;\n\tsign = 1;\n\tif (*str == '-' || *str == '+')\n\t\tsign = *str++ == '-' ? -1 : 1;\n\tvalue = 0;\n\twhile (*str >= '0' && *str <= '9') {\n\t\tvalue = value * 10 + (*str - '0');\n\t\tstr++;\n\t}\n\treturn sign < 0 ? -value : value;\n}\n@" misc.h

perl -0pi -e 's/\batoi\(/xatoi(/g' ansi.c attacher.c fileio.c process.c screen.c socket.c termcap.c tty.c

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

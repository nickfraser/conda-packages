#!/usr/bin/env bash
set -euxo pipefail

export LIBGHOSTTY_VT_OPTIMIZE=ReleaseFast
export LIBGHOSTTY_VT_SIMD=true
export ZIG=zig

# GLIBC added this wrapper in 2.27; use the kernel syscall for the 2.17 baseline.
"${CC}" ${CFLAGS} -c -x c -o copy-file-range.o - <<'EOF'
#define _GNU_SOURCE
#include <errno.h>
#include <sys/syscall.h>
#include <sys/types.h>
#include <unistd.h>

ssize_t copy_file_range(int fd_in, off_t *off_in, int fd_out, off_t *off_out,
                        size_t len, unsigned int flags)
{
#ifdef SYS_copy_file_range
  return syscall(SYS_copy_file_range, fd_in, off_in, fd_out, off_out, len, flags);
#else
  errno = ENOSYS;
  return -1;
#endif
}
EOF

export CARGO_BUILD_RUSTFLAGS="${CARGO_BUILD_RUSTFLAGS} -C link-arg=${PWD}/copy-file-range.o"

cargo build --release --locked

install -Dm755 "target/${CARGO_BUILD_TARGET}/release/herdr" "${PREFIX}/bin/herdr"

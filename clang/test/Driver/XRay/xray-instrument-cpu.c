// RUN: not %clang -o /dev/null -v -fxray-instrument -c %s
// XFAIL: amd64-, x86_64-, x86_64h-, arm, aarch64, arm64, powerpc64le-
// REQUIRES: linux
typedef int a;

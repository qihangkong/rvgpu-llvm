# REQUIRES: x86

# RUN: llvm-mc -filetype=obj -triple=x86_64-unknown-linux %s -o %t
# RUN: not ld.lld %t %t -o %t2 2>&1 | FileCheck -check-prefix=DEMANGLE %s

# DEMANGLE:    duplicate symbol: {{mul\(double, double\)|_Z3muldd}} in
# DEMANGLE:    duplicate symbol: foo in

# RUN: not ld.lld %t %t -o %t2 --no-demangle 2>&1 | \
# RUN:   FileCheck -check-prefix=NO_DEMANGLE %s

# NO_DEMANGLE: duplicate symbol: _Z3muldd in
# NO_DEMANGLE: duplicate symbol: foo in

# RUN: llvm-mc -filetype=obj -triple=x86_64-unknown-linux %S/Inputs/conflict.s -o %t2
# RUN: llvm-ar rcs %t.a %t2
# RUN: not ld.lld %t %t.a -u baz -o %t2 2>&1 | FileCheck -check-prefix=ARCHIVE %s

# ARCHIVE: duplicate symbol: foo in {{.*}}conflict.s.tmp and {{.*}}.a(conflict.s.tmp2)

.globl _Z3muldd, foo
_Z3muldd:
foo:
  mov $60, %rax
  mov $42, %rdi
  syscall

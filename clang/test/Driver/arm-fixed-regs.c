// RUN: %clang -target arm-none-gnueabi -ffixed-r9 -### %s 2> %t
// RUN: FileCheck --check-prefix=CHECK-FIXED-R9 < %t %s

// CHECK-FIXED-R9: "-target-feature" "+reserve-r9"

// RUN: %clang -target arm-none-gnueabi -ffixed-r4 -### %s 2> %t
// RUN: FileCheck --check-prefix=CHECK-FIXED-R4 < %t %s

// CHECK-FIXED-R4: "-target-feature" "+reserve-r4"

// RUN: %clang -target arm-none-gnueabi -ffixed-r5 -### %s 2> %t
// RUN: FileCheck --check-prefix=CHECK-FIXED-R5 < %t %s

// CHECK-FIXED-R5: "-target-feature" "+reserve-r5"

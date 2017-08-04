// RUN: %clang_cc1 -std=c++11 -fprofile-instrument=clang -fcoverage-mapping -dump-coverage-mapping -fexceptions -fcxx-exceptions -emit-llvm-only -triple %itanium_abi_triple -main-file-name deferred-region.cpp %s | FileCheck %s

#define IF if
#define STMT(S) S

// CHECK-LABEL: _Z3fooi:
void foo(int x) {
  if (x == 0) {
    return;
  } // CHECK: [[@LINE]]:4 -> [[@LINE+2]]:2 = (#0 - #1)

}

// CHECK-NEXT: _Z4foooi:
void fooo(int x) {
  if (x == 0) {
    return;
  } // CHECK: [[@LINE]]:4 -> [[@LINE+2]]:3 = (#0 - #1)

  if (x == 1) {
    return;
  } // CHECK: [[@LINE]]:4 -> [[@LINE+2]]:2 = ((#0 - #1) - #2)

}

// CHECK-LABEL: _Z3bazv:
void baz() { // CHECK: [[@LINE]]:12 -> [[@LINE+2]]:2
  return;    // CHECK-NOT: File
}

// CHECK-LABEL: _Z3bari:
void bar(int x) {
  IF (x)
    return; // CHECK: [[@LINE]]:11 -> [[@LINE+2]]:3 = (#0 - #1)

  IF (!x)
    return; // CHECK: [[@LINE]]:11 -> [[@LINE+2]]:3 = ((#0 - #1) - #2)

  foo(x);
}

// CHECK-LABEL: _Z4quuxi:
// Deferred regions are not emitted within macro expansions.
void quux(int x) {
  STMT(
  if (x == 0)
    return;)

  // CHECK-NOT: [[@LINE-2]]:{{.*}} -> [[@LINE+2]]

  if (x == 1)
    STMT(return;)

  // CHECK-NOT: [[@LINE-2]]:{{.*}} -> [[@LINE+3]]

  STMT(
  if (x == 2)
    return;

  // CHECK-NOT: [[@LINE-2]]:{{.*}} -> [[@LINE+2]]

  if (x == 3)
    return;
  )
}

// CHECK-LABEL: _Z8for_loopv:
void for_loop() {
  if (false)
    return; // CHECK: [[@LINE]]:11 -> [[@LINE+2]]:3 = (#0 - #1)

  for (int i = 0; i < 10; ++i) {
    if (i % 2 == 0)
      continue; // CHECK: [[@LINE]]:15 -> [[@LINE+2]]:5 = (#2 - #3)

    if (i % 5 == 0)
      break; // CHECK: [[@LINE]]:12 -> [[@LINE+2]]:5 = ((#2 - #3) - #4)

    int x = i; // CHECK: [[@LINE]]:5 -> [[@LINE+3]]:4 = ((#2 - #3) - #4)
    return; // CHECK-NOT: [[@LINE]]:11 -> [[@LINE+2]]

  }
}

struct Error {};

// CHECK-LABEL: _Z10while_loopv:
void while_loop() {
  if (false)
    return; // CHECK: [[@LINE]]:11 -> [[@LINE+2]]:3 = (#0 - #1)

  int x = 0;
  while (++x < 10) {
    if (x == 1)
      continue; // CHECK: [[@LINE]]:15 -> [[@LINE+2]]:5 = (#2 - #3)

    while (++x < 4) {
      if (x == 3)
        break; // CHECK: [[@LINE]]:14 -> [[@LINE+2]]:7 = (#4 - #5)

      while (++x < 5) {}
    }

    if (x == 0)
      throw Error(); // CHECK: [[@LINE]]:20 -> [[@LINE+2]]:5 = ((#2 - #3) - #7)

    while (++x < 9) {
      if (x == 0)
        break; // CHECK-NOT: [[@LINE]]:14 -> [[@LINE+2]]

    }
  }
}

// CHECK-LABEL: _Z5gotosv:
void gotos() {
  if (false)
    goto out; // CHECK: [[@LINE]]:13 -> [[@LINE+2]]:3 = (#0 - #1)

  return; // CHECK: [[@LINE]]:3 -> [[@LINE+4]]:2 = (#0 - #1)

out:
	return; // CHECK: [[@LINE]]:8 -> [[@LINE+1]]:2 = 0
}

int main() {
  foo(0);
  foo(1);
  fooo(0);
  fooo(1);
  baz();
  bar(0);
  bar(1);
  quux(0);
  quux(1);
  quux(2);
  quux(3);
  for_loop();
  while_loop();
  gotos();
  return 0;
}

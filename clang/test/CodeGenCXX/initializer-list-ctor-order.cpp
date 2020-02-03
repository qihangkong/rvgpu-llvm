// RUN: %clang_cc1 -std=c++11 %s -emit-llvm -o - -triple i686-linux-gnu | FileCheck %s --check-prefix=CHECK --check-prefix=CHECK-ITANIUM
// RUN: %clang_cc1 -std=c++11 %s -emit-llvm -o - -triple i686-windows   | FileCheck %s --check-prefix=CHECK --check-prefix=CHECK-MS

extern "C" {
int f();
int g();
}

struct A {
  A(int, int);
};


void foo() {
  A a{f(), g()};
}
// CHECK-ITANIUM-LABEL: define dso_local void @_Z3foov
// CHECK-MS-LABEL: define dso_local void @"?foo@@YAXXZ"
// CHECK: call i32 @f()
// CHECK: call i32 @g()

struct B : A {
  B();
};
B::B() : A{f(), g()} {}
// CHECK-ITANIUM-LABEL: define dso_local void @_ZN1BC2Ev
// CHECK-MS-LABEL: define dso_local x86_thiscallcc %struct.B* @"??0B@@QAE@XZ"
// CHECK: call i32 @f()
// CHECK: call i32 @g()

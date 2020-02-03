// RUN: %clang_cc1 -triple x86_64-apple-darwin -emit-llvm < %s | FileCheck -enable-var-scope -check-prefixes=CHECK,X86 %s
// RUN: %clang_cc1 -triple amdgcn -emit-llvm < %s | FileCheck -enable-var-scope -check-prefixes=CHECK,AMDGCN %s

// CHECK: @foo = common {{(dso_local )?}}addrspace(1) global
int foo __attribute__((address_space(1)));

// CHECK: @ban = common {{(dso_local )?}}addrspace(1) global
int ban[10] __attribute__((address_space(1)));

// CHECK: @a = common {{(dso_local )?}}global
int a __attribute__((address_space(0)));

// CHECK-LABEL: define {{(dso_local )?}}i32 @test1()
// CHECK: load i32, i32 addrspace(1)* @foo
int test1() { return foo; }

// CHECK-LABEL: define {{(dso_local )?}}i32 @test2(i32 %i)
// CHECK: load i32, i32 addrspace(1)*
// CHECK-NEXT: ret i32
int test2(int i) { return ban[i]; }

// Both A and B point into addrspace(2).
__attribute__((address_space(2))) int *A, *B;

// CHECK-LABEL: define {{(dso_local )?}}void @test3()
// X86: load i32 addrspace(2)*, i32 addrspace(2)** @B
// AMDGCN: load i32 addrspace(2)*, i32 addrspace(2)** addrspacecast (i32 addrspace(2)* addrspace(1)* @B to i32 addrspace(2)**)
// CHECK: load i32, i32 addrspace(2)*
// X86: load i32 addrspace(2)*, i32 addrspace(2)** @A
// AMDGCN: load i32 addrspace(2)*, i32 addrspace(2)** addrspacecast (i32 addrspace(2)* addrspace(1)* @A to i32 addrspace(2)**)
// CHECK: store i32 {{.*}}, i32 addrspace(2)*
void test3() {
  *A = *B;
}

// PR7437
typedef struct {
  float aData[1];
} MyStruct;

// CHECK-LABEL: define {{(dso_local )?}}void @test4(
// CHECK: call void @llvm.memcpy.p0i8.p2i8
// CHECK: call void @llvm.memcpy.p2i8.p0i8
void test4(MyStruct __attribute__((address_space(2))) *pPtr) {
  MyStruct s = pPtr[0];
  pPtr[0] = s;
}

// Make sure the right address space is used when doing arithmetic on a void
// pointer. Make sure no invalid bitcast is introduced.

// CHECK-LABEL: @void_ptr_arithmetic_test(
// X86: [[ALLOCA:%.*]] = alloca i8 addrspace(1)*
// X86-NEXT: store i8 addrspace(1)* %arg, i8 addrspace(1)** [[ALLOCA]]
// X86-NEXT: load i8 addrspace(1)*, i8 addrspace(1)** [[ALLOCA]]
// X86-NEXT: getelementptr i8, i8 addrspace(1)*
// X86-NEXT: ret i8 addrspace(1)*
void __attribute__((address_space(1)))*
void_ptr_arithmetic_test(void __attribute__((address_space(1))) *arg) {
    return arg + 4;
}

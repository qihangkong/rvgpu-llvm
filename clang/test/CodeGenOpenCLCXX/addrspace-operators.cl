//RUN: %clang_cc1 %s -triple spir -cl-std=clc++ -emit-llvm -O0 -o - | FileCheck %s

enum E {
  a,
  b,
};

class C {
public:
  void Assign(E e) { me = e; }
  void OrAssign(E e) { mi |= e; }
  E me;
  int mi;
};

__global E globE;
volatile __global int globVI;
__global int globI;
//CHECK-LABEL: define{{.*}} spir_func void @_Z3barv()
void bar() {
  C c;
  //CHECK: [[A1:%[.a-z0-9]+]] ={{.*}} addrspacecast %class.C* [[C:%[a-z0-9]+]] to %class.C addrspace(4)*
  //CHECK: call spir_func void @_ZNU3AS41C6AssignE1E(%class.C addrspace(4)* {{[^,]*}} [[A1]], i32 0)
  c.Assign(a);
  //CHECK: [[A2:%[.a-z0-9]+]] ={{.*}} addrspacecast %class.C* [[C]] to %class.C addrspace(4)*
  //CHECK: call spir_func void @_ZNU3AS41C8OrAssignE1E(%class.C addrspace(4)* {{[^,]*}} [[A2]], i32 0)
  c.OrAssign(a);

  E e;
  //CHECK: store i32 1, i32* %e
  e = b;
  //CHECK: store i32 0, i32 addrspace(1)* @globE
  globE = a;
  //CHECK: store i32 %or, i32 addrspace(1)* @globI
  globI |= b;
  //CHECK: store i32 %add, i32 addrspace(1)* @globI
  globI += a;
  //CHECK: [[GVIV1:%[0-9]+]] = load volatile i32, i32 addrspace(1)* @globVI
  //CHECK: [[AND:%[a-z0-9]+]] = and i32 [[GVIV1]], 1
  //CHECK: store volatile i32 [[AND]], i32 addrspace(1)* @globVI
  globVI &= b;
  //CHECK: [[GVIV2:%[0-9]+]] = load volatile i32, i32 addrspace(1)* @globVI
  //CHECK: [[SUB:%[a-z0-9]+]] = sub nsw i32 [[GVIV2]], 0
  //CHECK: store volatile i32 [[SUB]], i32 addrspace(1)* @globVI
  globVI -= a;
}

//CHECK: define linkonce_odr spir_func void @_ZNU3AS41C6AssignE1E(%class.C addrspace(4)* {{[^,]*}} {{[ %a-z0-9]*}}, i32{{[ %a-z0-9]*}})
//CHECK: [[THIS_ADDR:%[.a-z0-9]+]] = alloca %class.C addrspace(4)
//CHECK: [[E_ADDR:%[.a-z0-9]+]] = alloca i32
//CHECK: store %class.C addrspace(4)* {{%[a-z0-9]+}}, %class.C addrspace(4)** [[THIS_ADDR]]
//CHECK: store i32 {{%[a-z0-9]+}}, i32* [[E_ADDR]]
//CHECK: [[THIS1:%[.a-z0-9]+]] = load %class.C addrspace(4)*, %class.C addrspace(4)** [[THIS_ADDR]]
//CHECK: [[E:%[0-9]+]] = load i32, i32* [[E_ADDR]]
//CHECK: [[ME:%[a-z0-9]+]] = getelementptr inbounds %class.C, %class.C addrspace(4)* [[THIS1]], i32 0, i32 0
//CHECK: store i32 [[E]], i32 addrspace(4)* [[ME]]

//CHECK: define linkonce_odr spir_func void @_ZNU3AS41C8OrAssignE1E(%class.C addrspace(4)* {{[^,]*}} {{[ %a-z0-9]*}}, i32{{[ %a-z0-9]*}})
//CHECK: [[THIS_ADDR:%[.a-z0-9]+]] = alloca %class.C addrspace(4)
//CHECK: [[E_ADDR:%[.a-z0-9]+]] = alloca i32
//CHECK: store %class.C addrspace(4)* {{%[a-z0-9]+}}, %class.C addrspace(4)** [[THIS_ADDR]]
//CHECK: store i32 {{%[a-z0-9]+}}, i32* [[E_ADDR]]
//CHECK: [[THIS1:%[.a-z0-9]+]] = load %class.C addrspace(4)*, %class.C addrspace(4)** [[THIS_ADDR]]
//CHECK: [[E:%[0-9]+]] = load i32, i32* [[E_ADDR]]
//CHECK: [[MI_GEP:%[a-z0-9]+]] = getelementptr inbounds %class.C, %class.C addrspace(4)* [[THIS1]], i32 0, i32 1
//CHECK: [[MI:%[0-9]+]] = load i32, i32 addrspace(4)* [[MI_GEP]]
//CHECK: %or = or i32 [[MI]], [[E]]

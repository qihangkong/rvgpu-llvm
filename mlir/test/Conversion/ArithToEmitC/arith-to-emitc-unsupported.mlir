// RUN: mlir-opt -split-input-file -convert-arith-to-emitc -verify-diagnostics %s

func.func @arith_cast_f32(%arg0: f32) -> i32 {
  // expected-error @+1 {{failed to legalize operation 'arith.fptosi'}}
  %t = arith.fptosi %arg0 : f32 to i32
  return %t: i32
}

; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -vector-combine -S -mtriple=x86_64-- -mattr=SSE2 | FileCheck %s --check-prefixes=CHECK,SSE
; RUN: opt < %s -vector-combine -S -mtriple=x86_64-- -mattr=AVX2 | FileCheck %s --check-prefixes=CHECK,AVX

declare void @use(<4 x i32>)

; Eliminating an insert is profitable.

define <16 x i8> @ins0_ins0_add(i8 %x, i8 %y) {
; CHECK-LABEL: @ins0_ins0_add(
; CHECK-NEXT:    [[I0:%.*]] = insertelement <16 x i8> undef, i8 [[X:%.*]], i32 0
; CHECK-NEXT:    [[I1:%.*]] = insertelement <16 x i8> undef, i8 [[Y:%.*]], i32 0
; CHECK-NEXT:    [[R:%.*]] = add <16 x i8> [[I0]], [[I1]]
; CHECK-NEXT:    ret <16 x i8> [[R]]
;
  %i0 = insertelement <16 x i8> undef, i8 %x, i32 0
  %i1 = insertelement <16 x i8> undef, i8 %y, i32 0
  %r = add <16 x i8> %i0, %i1
  ret <16 x i8> %r
}

; Eliminating an insert is still profitable. Flags propagate. Mismatch types on index is ok.

define <8 x i16> @ins0_ins0_sub_flags(i16 %x, i16 %y) {
; CHECK-LABEL: @ins0_ins0_sub_flags(
; CHECK-NEXT:    [[I0:%.*]] = insertelement <8 x i16> undef, i16 [[X:%.*]], i8 5
; CHECK-NEXT:    [[I1:%.*]] = insertelement <8 x i16> undef, i16 [[Y:%.*]], i32 5
; CHECK-NEXT:    [[R:%.*]] = sub nuw nsw <8 x i16> [[I0]], [[I1]]
; CHECK-NEXT:    ret <8 x i16> [[R]]
;
  %i0 = insertelement <8 x i16> undef, i16 %x, i8 5
  %i1 = insertelement <8 x i16> undef, i16 %y, i32 5
  %r = sub nsw nuw <8 x i16> %i0, %i1
  ret <8 x i16> %r
}

; The inserts are free, but it's still better to scalarize.

define <2 x double> @ins0_ins0_fadd(double %x, double %y) {
; CHECK-LABEL: @ins0_ins0_fadd(
; CHECK-NEXT:    [[I0:%.*]] = insertelement <2 x double> undef, double [[X:%.*]], i32 0
; CHECK-NEXT:    [[I1:%.*]] = insertelement <2 x double> undef, double [[Y:%.*]], i32 0
; CHECK-NEXT:    [[R:%.*]] = fadd reassoc nsz <2 x double> [[I0]], [[I1]]
; CHECK-NEXT:    ret <2 x double> [[R]]
;
  %i0 = insertelement <2 x double> undef, double %x, i32 0
  %i1 = insertelement <2 x double> undef, double %y, i32 0
  %r = fadd reassoc nsz <2 x double> %i0, %i1
  ret <2 x double> %r
}

; Negative test - mismatched indexes. This could simplify.

define <16 x i8> @ins1_ins0_add(i8 %x, i8 %y) {
; CHECK-LABEL: @ins1_ins0_add(
; CHECK-NEXT:    [[I0:%.*]] = insertelement <16 x i8> undef, i8 [[X:%.*]], i32 1
; CHECK-NEXT:    [[I1:%.*]] = insertelement <16 x i8> undef, i8 [[Y:%.*]], i32 0
; CHECK-NEXT:    [[R:%.*]] = add <16 x i8> [[I0]], [[I1]]
; CHECK-NEXT:    ret <16 x i8> [[R]]
;
  %i0 = insertelement <16 x i8> undef, i8 %x, i32 1
  %i1 = insertelement <16 x i8> undef, i8 %y, i32 0
  %r = add <16 x i8> %i0, %i1
  ret <16 x i8> %r
}

; Negative test - not undef base vector. This could fold.

define <4 x i32> @ins0_ins0_mul(i32 %x, i32 %y) {
; CHECK-LABEL: @ins0_ins0_mul(
; CHECK-NEXT:    [[I0:%.*]] = insertelement <4 x i32> zeroinitializer, i32 [[X:%.*]], i32 0
; CHECK-NEXT:    [[I1:%.*]] = insertelement <4 x i32> undef, i32 [[Y:%.*]], i32 0
; CHECK-NEXT:    [[R:%.*]] = mul <4 x i32> [[I0]], [[I1]]
; CHECK-NEXT:    ret <4 x i32> [[R]]
;
  %i0 = insertelement <4 x i32> zeroinitializer, i32 %x, i32 0
  %i1 = insertelement <4 x i32> undef, i32 %y, i32 0
  %r = mul <4 x i32> %i0, %i1
  ret <4 x i32> %r
}

; Negative test - extra use. This could fold.

define <4 x i32> @ins0_ins0_xor(i32 %x, i32 %y) {
; CHECK-LABEL: @ins0_ins0_xor(
; CHECK-NEXT:    [[I0:%.*]] = insertelement <4 x i32> undef, i32 [[X:%.*]], i32 0
; CHECK-NEXT:    call void @use(<4 x i32> [[I0]])
; CHECK-NEXT:    [[I1:%.*]] = insertelement <4 x i32> undef, i32 [[Y:%.*]], i32 0
; CHECK-NEXT:    [[R:%.*]] = xor <4 x i32> [[I0]], [[I1]]
; CHECK-NEXT:    ret <4 x i32> [[R]]
;
  %i0 = insertelement <4 x i32> undef, i32 %x, i32 0
  call void @use(<4 x i32> %i0)
  %i1 = insertelement <4 x i32> undef, i32 %y, i32 0
  %r = xor <4 x i32> %i0, %i1
  ret <4 x i32> %r
}

; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s | FileCheck %s
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64"
target triple = "x86_64-pc-linux"


%0 = type <{ i64, i64, %1, %1, [21 x %2] }>
%1 = type <{ i64, i64, i64 }>
%2 = type <{ i32, i32, i8 addrspace(2)* }>
%3 = type { i8*, i8*, i8*, i8*, i32 }
%4 = type <{ %5*, i8*, i32, i32, [4 x i64], [4 x i64], [4 x i64], [4 x i64], [4 x i64] }>
%5 = type <{ void (i32)*, i8*, i32 (i8*, ...)* }>

define void @foo(i8* nocapture %_stubArgs) nounwind {
; CHECK-LABEL: foo:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    movq 48(%rdi), %rax
; CHECK-NEXT:    movl 64(%rdi), %edx
; CHECK-NEXT:    movl $200, %esi
; CHECK-NEXT:    addl 68(%rdi), %esi
; CHECK-NEXT:    imull $46, %edx, %ecx
; CHECK-NEXT:    addq %rsi, %rcx
; CHECK-NEXT:    shlq $4, %rcx
; CHECK-NEXT:    imull $47, %edx, %edx
; CHECK-NEXT:    addq %rsi, %rdx
; CHECK-NEXT:    shlq $4, %rdx
; CHECK-NEXT:    movaps (%rax,%rdx), %xmm0
; CHECK-NEXT:    cmpl $0, (%rdi)
; CHECK-NEXT:    jne .LBB0_1
; CHECK-NEXT:  # %bb.2: # %entry
; CHECK-NEXT:    xorps %xmm1, %xmm1
; CHECK-NEXT:    jmp .LBB0_3
; CHECK-NEXT:  .LBB0_1:
; CHECK-NEXT:    movaps (%rax,%rcx), %xmm1
; CHECK-NEXT:  .LBB0_3: # %entry
; CHECK-NEXT:    leaq -{{[0-9]+}}(%rsp), %rsp
; CHECK-NEXT:    movaps %xmm1, -{{[0-9]+}}(%rsp)
; CHECK-NEXT:    jne .LBB0_5
; CHECK-NEXT:  # %bb.4: # %entry
; CHECK-NEXT:    xorps %xmm0, %xmm0
; CHECK-NEXT:  .LBB0_5: # %entry
; CHECK-NEXT:    movaps %xmm0, -{{[0-9]+}}(%rsp)
; CHECK-NEXT:    addq $152, %rsp
; CHECK-NEXT:    retq
entry:
 %i0 = alloca i8*, align 8
 %i2 = alloca i8*, align 8
 %b.i = alloca [16 x <2 x double>], align 16
 %conv = bitcast i8* %_stubArgs to i32*
 %tmp1 = load i32, i32* %conv, align 4
 %ptr8 = getelementptr i8, i8* %_stubArgs, i64 16
 %i4 = bitcast i8* %ptr8 to <2 x double>*
 %ptr20 = getelementptr i8, i8* %_stubArgs, i64 48
 %i7 = bitcast i8* %ptr20 to <2 x double> addrspace(1)**
 %tmp21 = load <2 x double> addrspace(1)*, <2 x double> addrspace(1)** %i7, align 8
 %ptr28 = getelementptr i8, i8* %_stubArgs, i64 64
 %i9 = bitcast i8* %ptr28 to i32*
 %tmp29 = load i32, i32* %i9, align 4
 %ptr32 = getelementptr i8, i8* %_stubArgs, i64 68
 %i10 = bitcast i8* %ptr32 to i32*
 %tmp33 = load i32, i32* %i10, align 4
 %tmp17.i = mul i32 10, 20
 %tmp19.i = add i32 %tmp17.i, %tmp33
 %conv21.i = zext i32 %tmp19.i to i64
 %tmp6.i = and i32 42, -32
 %tmp42.i = add i32 %tmp6.i, 17
 %tmp44.i = insertelement <2 x i32> undef, i32 %tmp42.i, i32 1
 %tmp96676677.i = or i32 17, -4
 %ptr4438.i = getelementptr inbounds [16 x <2 x double>], [16 x <2 x double>]* %b.i, i64 0, i64 0
 %arrayidx4506.i = getelementptr [16 x <2 x double>], [16 x <2 x double>]* %b.i, i64 0, i64 4
 %tmp52.i = insertelement <2 x i32> %tmp44.i, i32 0, i32 0
 %tmp78.i = extractelement <2 x i32> %tmp44.i, i32 1
 %tmp97.i = add i32 %tmp78.i, %tmp96676677.i
 %tmp99.i = insertelement <2 x i32> %tmp52.i, i32 %tmp97.i, i32 1
 %tmp154.i = extractelement <2 x i32> %tmp99.i, i32 1
 %tmp156.i = extractelement <2 x i32> %tmp52.i, i32 0
 %tmp158.i = urem i32 %tmp156.i, %tmp1
 %i38 = mul i32 %tmp154.i, %tmp29
 %i39 = add i32 %tmp158.i, %i38
 %conv160.i = zext i32 %i39 to i64
 %tmp22.sum652.i = add i64 %conv160.i, %conv21.i
 %arrayidx161.i = getelementptr <2 x double>, <2 x double> addrspace(1)* %tmp21, i64 %tmp22.sum652.i
 %tmp162.i = load <2 x double>, <2 x double> addrspace(1)* %arrayidx161.i, align 16
 %tmp222.i = add i32 %tmp154.i, 1
 %i43 = mul i32 %tmp222.i, %tmp29
 %i44 = add i32 %tmp158.i, %i43
 %conv228.i = zext i32 %i44 to i64
 %tmp22.sum656.i = add i64 %conv228.i, %conv21.i
 %arrayidx229.i = getelementptr <2 x double>, <2 x double> addrspace(1)* %tmp21, i64 %tmp22.sum656.i
 %tmp230.i = load <2 x double>, <2 x double> addrspace(1)* %arrayidx229.i, align 16
 %cmp432.i = icmp ult i32 %tmp156.i, %tmp1

; %shl.i should not be sinked below the compare.

 %cond.i = select i1 %cmp432.i, <2 x double> %tmp162.i, <2 x double> zeroinitializer
 store <2 x double> %cond.i, <2 x double>* %ptr4438.i, align 16
 %cond448.i = select i1 %cmp432.i, <2 x double> %tmp230.i, <2 x double> zeroinitializer
 store <2 x double> %cond448.i, <2 x double>* %arrayidx4506.i, align 16
  ret void
}




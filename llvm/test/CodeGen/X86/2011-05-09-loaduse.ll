; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i686-- -mcpu=corei7 | FileCheck %s --check-prefixes=CHECK,X86
; RUN: llc < %s -mtriple=x86_64-- -mcpu=corei7 | FileCheck %s --check-prefixes=CHECK,X64

define float @test(<4 x float>* %A) nounwind {
; X86-LABEL: test:
; X86:       # %bb.0: # %entry
; X86-NEXT:    pushl %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movaps (%eax), %xmm0
; X86-NEXT:    shufps {{.*#+}} xmm0 = xmm0[3,3,3,3]
; X86-NEXT:    xorps %xmm1, %xmm1
; X86-NEXT:    movaps %xmm1, (%eax)
; X86-NEXT:    movss %xmm0, (%esp)
; X86-NEXT:    flds (%esp)
; X86-NEXT:    popl %eax
; X86-NEXT:    retl
;
; X64-LABEL: test:
; X64:       # %bb.0: # %entry
; X64-NEXT:    movaps (%rdi), %xmm0
; X64-NEXT:    shufps {{.*#+}} xmm0 = xmm0[3,3,3,3]
; X64-NEXT:    xorps %xmm1, %xmm1
; X64-NEXT:    movaps %xmm1, (%rdi)
; X64-NEXT:    retq
entry:
  %T = load <4 x float>, <4 x float>* %A
  %R = extractelement <4 x float> %T, i32 3
  store <4 x float><float 0.0, float 0.0, float 0.0, float 0.0>, <4 x float>* %A
  ret float %R
}


; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i686-- | FileCheck %s
; Sanity check that we ignore -sahf in 32-bit mode rather than asserting.
; RUN: llc < %s -mtriple=i686-- -mattr=-sahf | FileCheck %s

declare i1 @llvm.isunordered.f32(float, float)

define float @cmp(float %A, float %B, float %C, float %D) nounwind {
; CHECK-LABEL: cmp:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    flds {{[0-9]+}}(%esp)
; CHECK-NEXT:    flds {{[0-9]+}}(%esp)
; CHECK-NEXT:    fucompp
; CHECK-NEXT:    fnstsw %ax
; CHECK-NEXT:    # kill: def $ah killed $ah killed $ax
; CHECK-NEXT:    sahf
; CHECK-NEXT:    jbe .LBB0_1
; CHECK-NEXT:  # %bb.2: # %entry
; CHECK-NEXT:    leal {{[0-9]+}}(%esp), %eax
; CHECK-NEXT:    flds (%eax)
; CHECK-NEXT:    retl
; CHECK-NEXT:  .LBB0_1:
; CHECK-NEXT:    leal {{[0-9]+}}(%esp), %eax
; CHECK-NEXT:    flds (%eax)
; CHECK-NEXT:    retl
entry:
        %tmp.1 = fcmp uno float %A, %B          ; <i1> [#uses=1]
        %tmp.2 = fcmp oge float %A, %B          ; <i1> [#uses=1]
        %tmp.3 = or i1 %tmp.1, %tmp.2           ; <i1> [#uses=1]
        %tmp.4 = select i1 %tmp.3, float %C, float %D           ; <float> [#uses=1]
        ret float %tmp.4
}


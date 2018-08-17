; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=thumbv7-unknown-none-gnueabi | FileCheck %s --check-prefixes=THUMBV7

define { i64, i8 } @mulodi_test(i64 %l, i64 %r) unnamed_addr #0 {
; THUMBV7-LABEL: mulodi_test:
; THUMBV7:       @ %bb.0: @ %start
; THUMBV7-NEXT:    .save {r4, r5, r6, lr}
; THUMBV7-NEXT:    push {r4, r5, r6, lr}
; THUMBV7-NEXT:    umull r12, lr, r3, r0
; THUMBV7-NEXT:    movs r6, #0
; THUMBV7-NEXT:    umull r4, r5, r1, r2
; THUMBV7-NEXT:    umull r0, r2, r0, r2
; THUMBV7-NEXT:    add r4, r12
; THUMBV7-NEXT:    adds.w r12, r2, r4
; THUMBV7-NEXT:    adc r2, r6, #0
; THUMBV7-NEXT:    cmp r3, #0
; THUMBV7-NEXT:    it ne
; THUMBV7-NEXT:    movne r3, #1
; THUMBV7-NEXT:    cmp r1, #0
; THUMBV7-NEXT:    it ne
; THUMBV7-NEXT:    movne r1, #1
; THUMBV7-NEXT:    cmp r5, #0
; THUMBV7-NEXT:    it ne
; THUMBV7-NEXT:    movne r5, #1
; THUMBV7-NEXT:    ands r1, r3
; THUMBV7-NEXT:    cmp.w lr, #0
; THUMBV7-NEXT:    orr.w r1, r1, r5
; THUMBV7-NEXT:    it ne
; THUMBV7-NEXT:    movne.w lr, #1
; THUMBV7-NEXT:    orr.w r1, r1, lr
; THUMBV7-NEXT:    orrs r2, r1
; THUMBV7-NEXT:    mov r1, r12
; THUMBV7-NEXT:    pop {r4, r5, r6, pc}
start:
  %0 = tail call { i64, i1 } @llvm.umul.with.overflow.i64(i64 %l, i64 %r) #2
  %1 = extractvalue { i64, i1 } %0, 0
  %2 = extractvalue { i64, i1 } %0, 1
  %3 = zext i1 %2 to i8
  %4 = insertvalue { i64, i8 } undef, i64 %1, 0
  %5 = insertvalue { i64, i8 } %4, i8 %3, 1
  ret { i64, i8 } %5
}

; Function Attrs: nounwind readnone speculatable
declare { i64, i1 } @llvm.umul.with.overflow.i64(i64, i64) #1

attributes #0 = { nounwind readnone uwtable }
attributes #1 = { nounwind readnone speculatable }
attributes #2 = { nounwind }

; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-linux-gnu | FileCheck %s

;; Verify that the machine instructions generated from the first
;; getelementptr don't get sunk below the callbr. (Reduced from a bug
;; report.)

%struct1 = type { i8*, i32 }

define void @klist_dec_and_del(%struct1*) {
; CHECK-LABEL: klist_dec_and_del:
; CHECK:       # %bb.0:
; CHECK-NEXT:    leaq 8(%rdi), %rax
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # 8(%rdi) .Ltmp0
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:  # %bb.2:
; CHECK-NEXT:    retq
; CHECK-NEXT:  .Ltmp0: # Block address taken
; CHECK-NEXT:  .LBB0_1:
; CHECK-NEXT:    movq $0, -8(%rax)
; CHECK-NEXT:    retq
  %2 = getelementptr inbounds %struct1, %struct1* %0, i64 0, i32 1
  callbr void asm sideeffect "# $0 $1", "*m,X,~{memory},~{dirflag},~{fpsr},~{flags}"(i32* %2, i8* blockaddress(@klist_dec_and_del, %3))
          to label %6 [label %3]

3:
  %4 = getelementptr i32, i32* %2, i64 -2
  %5 = bitcast i32* %4 to i8**
  store i8* null, i8** %5, align 8
  br label %6

6:
  ret void
}

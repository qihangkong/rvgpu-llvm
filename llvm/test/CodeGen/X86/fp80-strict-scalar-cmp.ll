; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i686-unknown-unknown -mattr=-sse -O3 | FileCheck %s --check-prefixes=CHECK,X87-32
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -O3 | FileCheck %s --check-prefixes=CHECK,X87-64

define i32 @test_oeq_q(i32 %a, i32 %b, x86_fp80 %f1, x86_fp80 %f2) #0 {
; X87-32-LABEL: test_oeq_q:
; X87-32:       # %bb.0:
; X87-32-NEXT:    fldt {{[0-9]+}}(%esp)
; X87-32-NEXT:    fldt {{[0-9]+}}(%esp)
; X87-32-NEXT:    fucompp
; X87-32-NEXT:    wait
; X87-32-NEXT:    fnstsw %ax
; X87-32-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-32-NEXT:    sahf
; X87-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-32-NEXT:    jne .LBB0_3
; X87-32-NEXT:  # %bb.1:
; X87-32-NEXT:    jp .LBB0_3
; X87-32-NEXT:  # %bb.2:
; X87-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-32-NEXT:  .LBB0_3:
; X87-32-NEXT:    movl (%eax), %eax
; X87-32-NEXT:    retl
;
; X87-64-LABEL: test_oeq_q:
; X87-64:       # %bb.0:
; X87-64-NEXT:    movl %edi, %eax
; X87-64-NEXT:    fldt {{[0-9]+}}(%rsp)
; X87-64-NEXT:    fldt {{[0-9]+}}(%rsp)
; X87-64-NEXT:    fucompi %st(1), %st
; X87-64-NEXT:    fstp %st(0)
; X87-64-NEXT:    wait
; X87-64-NEXT:    cmovnel %esi, %eax
; X87-64-NEXT:    cmovpl %esi, %eax
; X87-64-NEXT:    retq
  %cond = call i1 @llvm.experimental.constrained.fcmp.f80(
                                               x86_fp80 %f1, x86_fp80 %f2, metadata !"oeq",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_ogt_q(i32 %a, i32 %b, x86_fp80 %f1, x86_fp80 %f2) #0 {
; X87-32-LABEL: test_ogt_q:
; X87-32:       # %bb.0:
; X87-32-NEXT:    fldt {{[0-9]+}}(%esp)
; X87-32-NEXT:    fldt {{[0-9]+}}(%esp)
; X87-32-NEXT:    fucompp
; X87-32-NEXT:    wait
; X87-32-NEXT:    fnstsw %ax
; X87-32-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-32-NEXT:    sahf
; X87-32-NEXT:    ja .LBB1_1
; X87-32-NEXT:  # %bb.2:
; X87-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-32-NEXT:    movl (%eax), %eax
; X87-32-NEXT:    retl
; X87-32-NEXT:  .LBB1_1:
; X87-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-32-NEXT:    movl (%eax), %eax
; X87-32-NEXT:    retl
;
; X87-64-LABEL: test_ogt_q:
; X87-64:       # %bb.0:
; X87-64-NEXT:    movl %edi, %eax
; X87-64-NEXT:    fldt {{[0-9]+}}(%rsp)
; X87-64-NEXT:    fldt {{[0-9]+}}(%rsp)
; X87-64-NEXT:    fucompi %st(1), %st
; X87-64-NEXT:    fstp %st(0)
; X87-64-NEXT:    wait
; X87-64-NEXT:    cmovbel %esi, %eax
; X87-64-NEXT:    retq
  %cond = call i1 @llvm.experimental.constrained.fcmp.f80(
                                               x86_fp80 %f1, x86_fp80 %f2, metadata !"ogt",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_oge_q(i32 %a, i32 %b, x86_fp80 %f1, x86_fp80 %f2) #0 {
; X87-32-LABEL: test_oge_q:
; X87-32:       # %bb.0:
; X87-32-NEXT:    fldt {{[0-9]+}}(%esp)
; X87-32-NEXT:    fldt {{[0-9]+}}(%esp)
; X87-32-NEXT:    fucompp
; X87-32-NEXT:    wait
; X87-32-NEXT:    fnstsw %ax
; X87-32-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-32-NEXT:    sahf
; X87-32-NEXT:    jae .LBB2_1
; X87-32-NEXT:  # %bb.2:
; X87-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-32-NEXT:    movl (%eax), %eax
; X87-32-NEXT:    retl
; X87-32-NEXT:  .LBB2_1:
; X87-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-32-NEXT:    movl (%eax), %eax
; X87-32-NEXT:    retl
;
; X87-64-LABEL: test_oge_q:
; X87-64:       # %bb.0:
; X87-64-NEXT:    movl %edi, %eax
; X87-64-NEXT:    fldt {{[0-9]+}}(%rsp)
; X87-64-NEXT:    fldt {{[0-9]+}}(%rsp)
; X87-64-NEXT:    fucompi %st(1), %st
; X87-64-NEXT:    fstp %st(0)
; X87-64-NEXT:    wait
; X87-64-NEXT:    cmovbl %esi, %eax
; X87-64-NEXT:    retq
  %cond = call i1 @llvm.experimental.constrained.fcmp.f80(
                                               x86_fp80 %f1, x86_fp80 %f2, metadata !"oge",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_olt_q(i32 %a, i32 %b, x86_fp80 %f1, x86_fp80 %f2) #0 {
; X87-32-LABEL: test_olt_q:
; X87-32:       # %bb.0:
; X87-32-NEXT:    fldt {{[0-9]+}}(%esp)
; X87-32-NEXT:    fldt {{[0-9]+}}(%esp)
; X87-32-NEXT:    fucompp
; X87-32-NEXT:    wait
; X87-32-NEXT:    fnstsw %ax
; X87-32-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-32-NEXT:    sahf
; X87-32-NEXT:    ja .LBB3_1
; X87-32-NEXT:  # %bb.2:
; X87-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-32-NEXT:    movl (%eax), %eax
; X87-32-NEXT:    retl
; X87-32-NEXT:  .LBB3_1:
; X87-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-32-NEXT:    movl (%eax), %eax
; X87-32-NEXT:    retl
;
; X87-64-LABEL: test_olt_q:
; X87-64:       # %bb.0:
; X87-64-NEXT:    movl %edi, %eax
; X87-64-NEXT:    fldt {{[0-9]+}}(%rsp)
; X87-64-NEXT:    fldt {{[0-9]+}}(%rsp)
; X87-64-NEXT:    fucompi %st(1), %st
; X87-64-NEXT:    fstp %st(0)
; X87-64-NEXT:    wait
; X87-64-NEXT:    cmovbel %esi, %eax
; X87-64-NEXT:    retq
  %cond = call i1 @llvm.experimental.constrained.fcmp.f80(
                                               x86_fp80 %f1, x86_fp80 %f2, metadata !"olt",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_ole_q(i32 %a, i32 %b, x86_fp80 %f1, x86_fp80 %f2) #0 {
; X87-32-LABEL: test_ole_q:
; X87-32:       # %bb.0:
; X87-32-NEXT:    fldt {{[0-9]+}}(%esp)
; X87-32-NEXT:    fldt {{[0-9]+}}(%esp)
; X87-32-NEXT:    fucompp
; X87-32-NEXT:    wait
; X87-32-NEXT:    fnstsw %ax
; X87-32-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-32-NEXT:    sahf
; X87-32-NEXT:    jae .LBB4_1
; X87-32-NEXT:  # %bb.2:
; X87-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-32-NEXT:    movl (%eax), %eax
; X87-32-NEXT:    retl
; X87-32-NEXT:  .LBB4_1:
; X87-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-32-NEXT:    movl (%eax), %eax
; X87-32-NEXT:    retl
;
; X87-64-LABEL: test_ole_q:
; X87-64:       # %bb.0:
; X87-64-NEXT:    movl %edi, %eax
; X87-64-NEXT:    fldt {{[0-9]+}}(%rsp)
; X87-64-NEXT:    fldt {{[0-9]+}}(%rsp)
; X87-64-NEXT:    fucompi %st(1), %st
; X87-64-NEXT:    fstp %st(0)
; X87-64-NEXT:    wait
; X87-64-NEXT:    cmovbl %esi, %eax
; X87-64-NEXT:    retq
  %cond = call i1 @llvm.experimental.constrained.fcmp.f80(
                                               x86_fp80 %f1, x86_fp80 %f2, metadata !"ole",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_one_q(i32 %a, i32 %b, x86_fp80 %f1, x86_fp80 %f2) #0 {
; X87-32-LABEL: test_one_q:
; X87-32:       # %bb.0:
; X87-32-NEXT:    fldt {{[0-9]+}}(%esp)
; X87-32-NEXT:    fldt {{[0-9]+}}(%esp)
; X87-32-NEXT:    fucompp
; X87-32-NEXT:    wait
; X87-32-NEXT:    fnstsw %ax
; X87-32-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-32-NEXT:    sahf
; X87-32-NEXT:    jne .LBB5_1
; X87-32-NEXT:  # %bb.2:
; X87-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-32-NEXT:    movl (%eax), %eax
; X87-32-NEXT:    retl
; X87-32-NEXT:  .LBB5_1:
; X87-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-32-NEXT:    movl (%eax), %eax
; X87-32-NEXT:    retl
;
; X87-64-LABEL: test_one_q:
; X87-64:       # %bb.0:
; X87-64-NEXT:    movl %edi, %eax
; X87-64-NEXT:    fldt {{[0-9]+}}(%rsp)
; X87-64-NEXT:    fldt {{[0-9]+}}(%rsp)
; X87-64-NEXT:    fucompi %st(1), %st
; X87-64-NEXT:    fstp %st(0)
; X87-64-NEXT:    wait
; X87-64-NEXT:    cmovel %esi, %eax
; X87-64-NEXT:    retq
  %cond = call i1 @llvm.experimental.constrained.fcmp.f80(
                                               x86_fp80 %f1, x86_fp80 %f2, metadata !"one",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_ord_q(i32 %a, i32 %b, x86_fp80 %f1, x86_fp80 %f2) #0 {
; X87-32-LABEL: test_ord_q:
; X87-32:       # %bb.0:
; X87-32-NEXT:    fldt {{[0-9]+}}(%esp)
; X87-32-NEXT:    fldt {{[0-9]+}}(%esp)
; X87-32-NEXT:    fucompp
; X87-32-NEXT:    wait
; X87-32-NEXT:    fnstsw %ax
; X87-32-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-32-NEXT:    sahf
; X87-32-NEXT:    jnp .LBB6_1
; X87-32-NEXT:  # %bb.2:
; X87-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-32-NEXT:    movl (%eax), %eax
; X87-32-NEXT:    retl
; X87-32-NEXT:  .LBB6_1:
; X87-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-32-NEXT:    movl (%eax), %eax
; X87-32-NEXT:    retl
;
; X87-64-LABEL: test_ord_q:
; X87-64:       # %bb.0:
; X87-64-NEXT:    movl %edi, %eax
; X87-64-NEXT:    fldt {{[0-9]+}}(%rsp)
; X87-64-NEXT:    fldt {{[0-9]+}}(%rsp)
; X87-64-NEXT:    fucompi %st(1), %st
; X87-64-NEXT:    fstp %st(0)
; X87-64-NEXT:    wait
; X87-64-NEXT:    cmovpl %esi, %eax
; X87-64-NEXT:    retq
  %cond = call i1 @llvm.experimental.constrained.fcmp.f80(
                                               x86_fp80 %f1, x86_fp80 %f2, metadata !"ord",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_ueq_q(i32 %a, i32 %b, x86_fp80 %f1, x86_fp80 %f2) #0 {
; X87-32-LABEL: test_ueq_q:
; X87-32:       # %bb.0:
; X87-32-NEXT:    fldt {{[0-9]+}}(%esp)
; X87-32-NEXT:    fldt {{[0-9]+}}(%esp)
; X87-32-NEXT:    fucompp
; X87-32-NEXT:    wait
; X87-32-NEXT:    fnstsw %ax
; X87-32-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-32-NEXT:    sahf
; X87-32-NEXT:    je .LBB7_1
; X87-32-NEXT:  # %bb.2:
; X87-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-32-NEXT:    movl (%eax), %eax
; X87-32-NEXT:    retl
; X87-32-NEXT:  .LBB7_1:
; X87-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-32-NEXT:    movl (%eax), %eax
; X87-32-NEXT:    retl
;
; X87-64-LABEL: test_ueq_q:
; X87-64:       # %bb.0:
; X87-64-NEXT:    movl %edi, %eax
; X87-64-NEXT:    fldt {{[0-9]+}}(%rsp)
; X87-64-NEXT:    fldt {{[0-9]+}}(%rsp)
; X87-64-NEXT:    fucompi %st(1), %st
; X87-64-NEXT:    fstp %st(0)
; X87-64-NEXT:    wait
; X87-64-NEXT:    cmovnel %esi, %eax
; X87-64-NEXT:    retq
  %cond = call i1 @llvm.experimental.constrained.fcmp.f80(
                                               x86_fp80 %f1, x86_fp80 %f2, metadata !"ueq",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_ugt_q(i32 %a, i32 %b, x86_fp80 %f1, x86_fp80 %f2) #0 {
; X87-32-LABEL: test_ugt_q:
; X87-32:       # %bb.0:
; X87-32-NEXT:    fldt {{[0-9]+}}(%esp)
; X87-32-NEXT:    fldt {{[0-9]+}}(%esp)
; X87-32-NEXT:    fucompp
; X87-32-NEXT:    wait
; X87-32-NEXT:    fnstsw %ax
; X87-32-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-32-NEXT:    sahf
; X87-32-NEXT:    jb .LBB8_1
; X87-32-NEXT:  # %bb.2:
; X87-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-32-NEXT:    movl (%eax), %eax
; X87-32-NEXT:    retl
; X87-32-NEXT:  .LBB8_1:
; X87-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-32-NEXT:    movl (%eax), %eax
; X87-32-NEXT:    retl
;
; X87-64-LABEL: test_ugt_q:
; X87-64:       # %bb.0:
; X87-64-NEXT:    movl %edi, %eax
; X87-64-NEXT:    fldt {{[0-9]+}}(%rsp)
; X87-64-NEXT:    fldt {{[0-9]+}}(%rsp)
; X87-64-NEXT:    fucompi %st(1), %st
; X87-64-NEXT:    fstp %st(0)
; X87-64-NEXT:    wait
; X87-64-NEXT:    cmovael %esi, %eax
; X87-64-NEXT:    retq
  %cond = call i1 @llvm.experimental.constrained.fcmp.f80(
                                               x86_fp80 %f1, x86_fp80 %f2, metadata !"ugt",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_uge_q(i32 %a, i32 %b, x86_fp80 %f1, x86_fp80 %f2) #0 {
; X87-32-LABEL: test_uge_q:
; X87-32:       # %bb.0:
; X87-32-NEXT:    fldt {{[0-9]+}}(%esp)
; X87-32-NEXT:    fldt {{[0-9]+}}(%esp)
; X87-32-NEXT:    fucompp
; X87-32-NEXT:    wait
; X87-32-NEXT:    fnstsw %ax
; X87-32-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-32-NEXT:    sahf
; X87-32-NEXT:    jbe .LBB9_1
; X87-32-NEXT:  # %bb.2:
; X87-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-32-NEXT:    movl (%eax), %eax
; X87-32-NEXT:    retl
; X87-32-NEXT:  .LBB9_1:
; X87-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-32-NEXT:    movl (%eax), %eax
; X87-32-NEXT:    retl
;
; X87-64-LABEL: test_uge_q:
; X87-64:       # %bb.0:
; X87-64-NEXT:    movl %edi, %eax
; X87-64-NEXT:    fldt {{[0-9]+}}(%rsp)
; X87-64-NEXT:    fldt {{[0-9]+}}(%rsp)
; X87-64-NEXT:    fucompi %st(1), %st
; X87-64-NEXT:    fstp %st(0)
; X87-64-NEXT:    wait
; X87-64-NEXT:    cmoval %esi, %eax
; X87-64-NEXT:    retq
  %cond = call i1 @llvm.experimental.constrained.fcmp.f80(
                                               x86_fp80 %f1, x86_fp80 %f2, metadata !"uge",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_ult_q(i32 %a, i32 %b, x86_fp80 %f1, x86_fp80 %f2) #0 {
; X87-32-LABEL: test_ult_q:
; X87-32:       # %bb.0:
; X87-32-NEXT:    fldt {{[0-9]+}}(%esp)
; X87-32-NEXT:    fldt {{[0-9]+}}(%esp)
; X87-32-NEXT:    fucompp
; X87-32-NEXT:    wait
; X87-32-NEXT:    fnstsw %ax
; X87-32-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-32-NEXT:    sahf
; X87-32-NEXT:    jb .LBB10_1
; X87-32-NEXT:  # %bb.2:
; X87-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-32-NEXT:    movl (%eax), %eax
; X87-32-NEXT:    retl
; X87-32-NEXT:  .LBB10_1:
; X87-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-32-NEXT:    movl (%eax), %eax
; X87-32-NEXT:    retl
;
; X87-64-LABEL: test_ult_q:
; X87-64:       # %bb.0:
; X87-64-NEXT:    movl %edi, %eax
; X87-64-NEXT:    fldt {{[0-9]+}}(%rsp)
; X87-64-NEXT:    fldt {{[0-9]+}}(%rsp)
; X87-64-NEXT:    fucompi %st(1), %st
; X87-64-NEXT:    fstp %st(0)
; X87-64-NEXT:    wait
; X87-64-NEXT:    cmovael %esi, %eax
; X87-64-NEXT:    retq
  %cond = call i1 @llvm.experimental.constrained.fcmp.f80(
                                               x86_fp80 %f1, x86_fp80 %f2, metadata !"ult",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_ule_q(i32 %a, i32 %b, x86_fp80 %f1, x86_fp80 %f2) #0 {
; X87-32-LABEL: test_ule_q:
; X87-32:       # %bb.0:
; X87-32-NEXT:    fldt {{[0-9]+}}(%esp)
; X87-32-NEXT:    fldt {{[0-9]+}}(%esp)
; X87-32-NEXT:    fucompp
; X87-32-NEXT:    wait
; X87-32-NEXT:    fnstsw %ax
; X87-32-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-32-NEXT:    sahf
; X87-32-NEXT:    jbe .LBB11_1
; X87-32-NEXT:  # %bb.2:
; X87-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-32-NEXT:    movl (%eax), %eax
; X87-32-NEXT:    retl
; X87-32-NEXT:  .LBB11_1:
; X87-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-32-NEXT:    movl (%eax), %eax
; X87-32-NEXT:    retl
;
; X87-64-LABEL: test_ule_q:
; X87-64:       # %bb.0:
; X87-64-NEXT:    movl %edi, %eax
; X87-64-NEXT:    fldt {{[0-9]+}}(%rsp)
; X87-64-NEXT:    fldt {{[0-9]+}}(%rsp)
; X87-64-NEXT:    fucompi %st(1), %st
; X87-64-NEXT:    fstp %st(0)
; X87-64-NEXT:    wait
; X87-64-NEXT:    cmoval %esi, %eax
; X87-64-NEXT:    retq
  %cond = call i1 @llvm.experimental.constrained.fcmp.f80(
                                               x86_fp80 %f1, x86_fp80 %f2, metadata !"ule",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_une_q(i32 %a, i32 %b, x86_fp80 %f1, x86_fp80 %f2) #0 {
; X87-32-LABEL: test_une_q:
; X87-32:       # %bb.0:
; X87-32-NEXT:    fldt {{[0-9]+}}(%esp)
; X87-32-NEXT:    fldt {{[0-9]+}}(%esp)
; X87-32-NEXT:    fucompp
; X87-32-NEXT:    wait
; X87-32-NEXT:    fnstsw %ax
; X87-32-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-32-NEXT:    sahf
; X87-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-32-NEXT:    jne .LBB12_3
; X87-32-NEXT:  # %bb.1:
; X87-32-NEXT:    jp .LBB12_3
; X87-32-NEXT:  # %bb.2:
; X87-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-32-NEXT:  .LBB12_3:
; X87-32-NEXT:    movl (%eax), %eax
; X87-32-NEXT:    retl
;
; X87-64-LABEL: test_une_q:
; X87-64:       # %bb.0:
; X87-64-NEXT:    movl %esi, %eax
; X87-64-NEXT:    fldt {{[0-9]+}}(%rsp)
; X87-64-NEXT:    fldt {{[0-9]+}}(%rsp)
; X87-64-NEXT:    fucompi %st(1), %st
; X87-64-NEXT:    fstp %st(0)
; X87-64-NEXT:    wait
; X87-64-NEXT:    cmovnel %edi, %eax
; X87-64-NEXT:    cmovpl %edi, %eax
; X87-64-NEXT:    retq
  %cond = call i1 @llvm.experimental.constrained.fcmp.f80(
                                               x86_fp80 %f1, x86_fp80 %f2, metadata !"une",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_uno_q(i32 %a, i32 %b, x86_fp80 %f1, x86_fp80 %f2) #0 {
; X87-32-LABEL: test_uno_q:
; X87-32:       # %bb.0:
; X87-32-NEXT:    fldt {{[0-9]+}}(%esp)
; X87-32-NEXT:    fldt {{[0-9]+}}(%esp)
; X87-32-NEXT:    fucompp
; X87-32-NEXT:    wait
; X87-32-NEXT:    fnstsw %ax
; X87-32-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-32-NEXT:    sahf
; X87-32-NEXT:    jp .LBB13_1
; X87-32-NEXT:  # %bb.2:
; X87-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-32-NEXT:    movl (%eax), %eax
; X87-32-NEXT:    retl
; X87-32-NEXT:  .LBB13_1:
; X87-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-32-NEXT:    movl (%eax), %eax
; X87-32-NEXT:    retl
;
; X87-64-LABEL: test_uno_q:
; X87-64:       # %bb.0:
; X87-64-NEXT:    movl %edi, %eax
; X87-64-NEXT:    fldt {{[0-9]+}}(%rsp)
; X87-64-NEXT:    fldt {{[0-9]+}}(%rsp)
; X87-64-NEXT:    fucompi %st(1), %st
; X87-64-NEXT:    fstp %st(0)
; X87-64-NEXT:    wait
; X87-64-NEXT:    cmovnpl %esi, %eax
; X87-64-NEXT:    retq
  %cond = call i1 @llvm.experimental.constrained.fcmp.f80(
                                               x86_fp80 %f1, x86_fp80 %f2, metadata !"uno",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_oeq_s(i32 %a, i32 %b, x86_fp80 %f1, x86_fp80 %f2) #0 {
; X87-32-LABEL: test_oeq_s:
; X87-32:       # %bb.0:
; X87-32-NEXT:    fldt {{[0-9]+}}(%esp)
; X87-32-NEXT:    fldt {{[0-9]+}}(%esp)
; X87-32-NEXT:    fcompp
; X87-32-NEXT:    wait
; X87-32-NEXT:    fnstsw %ax
; X87-32-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-32-NEXT:    sahf
; X87-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-32-NEXT:    jne .LBB14_3
; X87-32-NEXT:  # %bb.1:
; X87-32-NEXT:    jp .LBB14_3
; X87-32-NEXT:  # %bb.2:
; X87-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-32-NEXT:  .LBB14_3:
; X87-32-NEXT:    movl (%eax), %eax
; X87-32-NEXT:    retl
;
; X87-64-LABEL: test_oeq_s:
; X87-64:       # %bb.0:
; X87-64-NEXT:    movl %edi, %eax
; X87-64-NEXT:    fldt {{[0-9]+}}(%rsp)
; X87-64-NEXT:    fldt {{[0-9]+}}(%rsp)
; X87-64-NEXT:    fcompi %st(1), %st
; X87-64-NEXT:    fstp %st(0)
; X87-64-NEXT:    wait
; X87-64-NEXT:    cmovnel %esi, %eax
; X87-64-NEXT:    cmovpl %esi, %eax
; X87-64-NEXT:    retq
  %cond = call i1 @llvm.experimental.constrained.fcmps.f80(
                                               x86_fp80 %f1, x86_fp80 %f2, metadata !"oeq",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_ogt_s(i32 %a, i32 %b, x86_fp80 %f1, x86_fp80 %f2) #0 {
; X87-32-LABEL: test_ogt_s:
; X87-32:       # %bb.0:
; X87-32-NEXT:    fldt {{[0-9]+}}(%esp)
; X87-32-NEXT:    fldt {{[0-9]+}}(%esp)
; X87-32-NEXT:    fcompp
; X87-32-NEXT:    wait
; X87-32-NEXT:    fnstsw %ax
; X87-32-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-32-NEXT:    sahf
; X87-32-NEXT:    ja .LBB15_1
; X87-32-NEXT:  # %bb.2:
; X87-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-32-NEXT:    movl (%eax), %eax
; X87-32-NEXT:    retl
; X87-32-NEXT:  .LBB15_1:
; X87-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-32-NEXT:    movl (%eax), %eax
; X87-32-NEXT:    retl
;
; X87-64-LABEL: test_ogt_s:
; X87-64:       # %bb.0:
; X87-64-NEXT:    movl %edi, %eax
; X87-64-NEXT:    fldt {{[0-9]+}}(%rsp)
; X87-64-NEXT:    fldt {{[0-9]+}}(%rsp)
; X87-64-NEXT:    fcompi %st(1), %st
; X87-64-NEXT:    fstp %st(0)
; X87-64-NEXT:    wait
; X87-64-NEXT:    cmovbel %esi, %eax
; X87-64-NEXT:    retq
  %cond = call i1 @llvm.experimental.constrained.fcmps.f80(
                                               x86_fp80 %f1, x86_fp80 %f2, metadata !"ogt",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_oge_s(i32 %a, i32 %b, x86_fp80 %f1, x86_fp80 %f2) #0 {
; X87-32-LABEL: test_oge_s:
; X87-32:       # %bb.0:
; X87-32-NEXT:    fldt {{[0-9]+}}(%esp)
; X87-32-NEXT:    fldt {{[0-9]+}}(%esp)
; X87-32-NEXT:    fcompp
; X87-32-NEXT:    wait
; X87-32-NEXT:    fnstsw %ax
; X87-32-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-32-NEXT:    sahf
; X87-32-NEXT:    jae .LBB16_1
; X87-32-NEXT:  # %bb.2:
; X87-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-32-NEXT:    movl (%eax), %eax
; X87-32-NEXT:    retl
; X87-32-NEXT:  .LBB16_1:
; X87-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-32-NEXT:    movl (%eax), %eax
; X87-32-NEXT:    retl
;
; X87-64-LABEL: test_oge_s:
; X87-64:       # %bb.0:
; X87-64-NEXT:    movl %edi, %eax
; X87-64-NEXT:    fldt {{[0-9]+}}(%rsp)
; X87-64-NEXT:    fldt {{[0-9]+}}(%rsp)
; X87-64-NEXT:    fcompi %st(1), %st
; X87-64-NEXT:    fstp %st(0)
; X87-64-NEXT:    wait
; X87-64-NEXT:    cmovbl %esi, %eax
; X87-64-NEXT:    retq
  %cond = call i1 @llvm.experimental.constrained.fcmps.f80(
                                               x86_fp80 %f1, x86_fp80 %f2, metadata !"oge",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_olt_s(i32 %a, i32 %b, x86_fp80 %f1, x86_fp80 %f2) #0 {
; X87-32-LABEL: test_olt_s:
; X87-32:       # %bb.0:
; X87-32-NEXT:    fldt {{[0-9]+}}(%esp)
; X87-32-NEXT:    fldt {{[0-9]+}}(%esp)
; X87-32-NEXT:    fcompp
; X87-32-NEXT:    wait
; X87-32-NEXT:    fnstsw %ax
; X87-32-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-32-NEXT:    sahf
; X87-32-NEXT:    ja .LBB17_1
; X87-32-NEXT:  # %bb.2:
; X87-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-32-NEXT:    movl (%eax), %eax
; X87-32-NEXT:    retl
; X87-32-NEXT:  .LBB17_1:
; X87-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-32-NEXT:    movl (%eax), %eax
; X87-32-NEXT:    retl
;
; X87-64-LABEL: test_olt_s:
; X87-64:       # %bb.0:
; X87-64-NEXT:    movl %edi, %eax
; X87-64-NEXT:    fldt {{[0-9]+}}(%rsp)
; X87-64-NEXT:    fldt {{[0-9]+}}(%rsp)
; X87-64-NEXT:    fcompi %st(1), %st
; X87-64-NEXT:    fstp %st(0)
; X87-64-NEXT:    wait
; X87-64-NEXT:    cmovbel %esi, %eax
; X87-64-NEXT:    retq
  %cond = call i1 @llvm.experimental.constrained.fcmps.f80(
                                               x86_fp80 %f1, x86_fp80 %f2, metadata !"olt",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_ole_s(i32 %a, i32 %b, x86_fp80 %f1, x86_fp80 %f2) #0 {
; X87-32-LABEL: test_ole_s:
; X87-32:       # %bb.0:
; X87-32-NEXT:    fldt {{[0-9]+}}(%esp)
; X87-32-NEXT:    fldt {{[0-9]+}}(%esp)
; X87-32-NEXT:    fcompp
; X87-32-NEXT:    wait
; X87-32-NEXT:    fnstsw %ax
; X87-32-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-32-NEXT:    sahf
; X87-32-NEXT:    jae .LBB18_1
; X87-32-NEXT:  # %bb.2:
; X87-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-32-NEXT:    movl (%eax), %eax
; X87-32-NEXT:    retl
; X87-32-NEXT:  .LBB18_1:
; X87-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-32-NEXT:    movl (%eax), %eax
; X87-32-NEXT:    retl
;
; X87-64-LABEL: test_ole_s:
; X87-64:       # %bb.0:
; X87-64-NEXT:    movl %edi, %eax
; X87-64-NEXT:    fldt {{[0-9]+}}(%rsp)
; X87-64-NEXT:    fldt {{[0-9]+}}(%rsp)
; X87-64-NEXT:    fcompi %st(1), %st
; X87-64-NEXT:    fstp %st(0)
; X87-64-NEXT:    wait
; X87-64-NEXT:    cmovbl %esi, %eax
; X87-64-NEXT:    retq
  %cond = call i1 @llvm.experimental.constrained.fcmps.f80(
                                               x86_fp80 %f1, x86_fp80 %f2, metadata !"ole",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_one_s(i32 %a, i32 %b, x86_fp80 %f1, x86_fp80 %f2) #0 {
; X87-32-LABEL: test_one_s:
; X87-32:       # %bb.0:
; X87-32-NEXT:    fldt {{[0-9]+}}(%esp)
; X87-32-NEXT:    fldt {{[0-9]+}}(%esp)
; X87-32-NEXT:    fcompp
; X87-32-NEXT:    wait
; X87-32-NEXT:    fnstsw %ax
; X87-32-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-32-NEXT:    sahf
; X87-32-NEXT:    jne .LBB19_1
; X87-32-NEXT:  # %bb.2:
; X87-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-32-NEXT:    movl (%eax), %eax
; X87-32-NEXT:    retl
; X87-32-NEXT:  .LBB19_1:
; X87-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-32-NEXT:    movl (%eax), %eax
; X87-32-NEXT:    retl
;
; X87-64-LABEL: test_one_s:
; X87-64:       # %bb.0:
; X87-64-NEXT:    movl %edi, %eax
; X87-64-NEXT:    fldt {{[0-9]+}}(%rsp)
; X87-64-NEXT:    fldt {{[0-9]+}}(%rsp)
; X87-64-NEXT:    fcompi %st(1), %st
; X87-64-NEXT:    fstp %st(0)
; X87-64-NEXT:    wait
; X87-64-NEXT:    cmovel %esi, %eax
; X87-64-NEXT:    retq
  %cond = call i1 @llvm.experimental.constrained.fcmps.f80(
                                               x86_fp80 %f1, x86_fp80 %f2, metadata !"one",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_ord_s(i32 %a, i32 %b, x86_fp80 %f1, x86_fp80 %f2) #0 {
; X87-32-LABEL: test_ord_s:
; X87-32:       # %bb.0:
; X87-32-NEXT:    fldt {{[0-9]+}}(%esp)
; X87-32-NEXT:    fldt {{[0-9]+}}(%esp)
; X87-32-NEXT:    fcompp
; X87-32-NEXT:    wait
; X87-32-NEXT:    fnstsw %ax
; X87-32-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-32-NEXT:    sahf
; X87-32-NEXT:    jnp .LBB20_1
; X87-32-NEXT:  # %bb.2:
; X87-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-32-NEXT:    movl (%eax), %eax
; X87-32-NEXT:    retl
; X87-32-NEXT:  .LBB20_1:
; X87-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-32-NEXT:    movl (%eax), %eax
; X87-32-NEXT:    retl
;
; X87-64-LABEL: test_ord_s:
; X87-64:       # %bb.0:
; X87-64-NEXT:    movl %edi, %eax
; X87-64-NEXT:    fldt {{[0-9]+}}(%rsp)
; X87-64-NEXT:    fldt {{[0-9]+}}(%rsp)
; X87-64-NEXT:    fcompi %st(1), %st
; X87-64-NEXT:    fstp %st(0)
; X87-64-NEXT:    wait
; X87-64-NEXT:    cmovpl %esi, %eax
; X87-64-NEXT:    retq
  %cond = call i1 @llvm.experimental.constrained.fcmps.f80(
                                               x86_fp80 %f1, x86_fp80 %f2, metadata !"ord",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_ueq_s(i32 %a, i32 %b, x86_fp80 %f1, x86_fp80 %f2) #0 {
; X87-32-LABEL: test_ueq_s:
; X87-32:       # %bb.0:
; X87-32-NEXT:    fldt {{[0-9]+}}(%esp)
; X87-32-NEXT:    fldt {{[0-9]+}}(%esp)
; X87-32-NEXT:    fcompp
; X87-32-NEXT:    wait
; X87-32-NEXT:    fnstsw %ax
; X87-32-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-32-NEXT:    sahf
; X87-32-NEXT:    je .LBB21_1
; X87-32-NEXT:  # %bb.2:
; X87-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-32-NEXT:    movl (%eax), %eax
; X87-32-NEXT:    retl
; X87-32-NEXT:  .LBB21_1:
; X87-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-32-NEXT:    movl (%eax), %eax
; X87-32-NEXT:    retl
;
; X87-64-LABEL: test_ueq_s:
; X87-64:       # %bb.0:
; X87-64-NEXT:    movl %edi, %eax
; X87-64-NEXT:    fldt {{[0-9]+}}(%rsp)
; X87-64-NEXT:    fldt {{[0-9]+}}(%rsp)
; X87-64-NEXT:    fcompi %st(1), %st
; X87-64-NEXT:    fstp %st(0)
; X87-64-NEXT:    wait
; X87-64-NEXT:    cmovnel %esi, %eax
; X87-64-NEXT:    retq
  %cond = call i1 @llvm.experimental.constrained.fcmps.f80(
                                               x86_fp80 %f1, x86_fp80 %f2, metadata !"ueq",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_ugt_s(i32 %a, i32 %b, x86_fp80 %f1, x86_fp80 %f2) #0 {
; X87-32-LABEL: test_ugt_s:
; X87-32:       # %bb.0:
; X87-32-NEXT:    fldt {{[0-9]+}}(%esp)
; X87-32-NEXT:    fldt {{[0-9]+}}(%esp)
; X87-32-NEXT:    fcompp
; X87-32-NEXT:    wait
; X87-32-NEXT:    fnstsw %ax
; X87-32-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-32-NEXT:    sahf
; X87-32-NEXT:    jb .LBB22_1
; X87-32-NEXT:  # %bb.2:
; X87-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-32-NEXT:    movl (%eax), %eax
; X87-32-NEXT:    retl
; X87-32-NEXT:  .LBB22_1:
; X87-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-32-NEXT:    movl (%eax), %eax
; X87-32-NEXT:    retl
;
; X87-64-LABEL: test_ugt_s:
; X87-64:       # %bb.0:
; X87-64-NEXT:    movl %edi, %eax
; X87-64-NEXT:    fldt {{[0-9]+}}(%rsp)
; X87-64-NEXT:    fldt {{[0-9]+}}(%rsp)
; X87-64-NEXT:    fcompi %st(1), %st
; X87-64-NEXT:    fstp %st(0)
; X87-64-NEXT:    wait
; X87-64-NEXT:    cmovael %esi, %eax
; X87-64-NEXT:    retq
  %cond = call i1 @llvm.experimental.constrained.fcmps.f80(
                                               x86_fp80 %f1, x86_fp80 %f2, metadata !"ugt",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_uge_s(i32 %a, i32 %b, x86_fp80 %f1, x86_fp80 %f2) #0 {
; X87-32-LABEL: test_uge_s:
; X87-32:       # %bb.0:
; X87-32-NEXT:    fldt {{[0-9]+}}(%esp)
; X87-32-NEXT:    fldt {{[0-9]+}}(%esp)
; X87-32-NEXT:    fcompp
; X87-32-NEXT:    wait
; X87-32-NEXT:    fnstsw %ax
; X87-32-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-32-NEXT:    sahf
; X87-32-NEXT:    jbe .LBB23_1
; X87-32-NEXT:  # %bb.2:
; X87-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-32-NEXT:    movl (%eax), %eax
; X87-32-NEXT:    retl
; X87-32-NEXT:  .LBB23_1:
; X87-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-32-NEXT:    movl (%eax), %eax
; X87-32-NEXT:    retl
;
; X87-64-LABEL: test_uge_s:
; X87-64:       # %bb.0:
; X87-64-NEXT:    movl %edi, %eax
; X87-64-NEXT:    fldt {{[0-9]+}}(%rsp)
; X87-64-NEXT:    fldt {{[0-9]+}}(%rsp)
; X87-64-NEXT:    fcompi %st(1), %st
; X87-64-NEXT:    fstp %st(0)
; X87-64-NEXT:    wait
; X87-64-NEXT:    cmoval %esi, %eax
; X87-64-NEXT:    retq
  %cond = call i1 @llvm.experimental.constrained.fcmps.f80(
                                               x86_fp80 %f1, x86_fp80 %f2, metadata !"uge",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_ult_s(i32 %a, i32 %b, x86_fp80 %f1, x86_fp80 %f2) #0 {
; X87-32-LABEL: test_ult_s:
; X87-32:       # %bb.0:
; X87-32-NEXT:    fldt {{[0-9]+}}(%esp)
; X87-32-NEXT:    fldt {{[0-9]+}}(%esp)
; X87-32-NEXT:    fcompp
; X87-32-NEXT:    wait
; X87-32-NEXT:    fnstsw %ax
; X87-32-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-32-NEXT:    sahf
; X87-32-NEXT:    jb .LBB24_1
; X87-32-NEXT:  # %bb.2:
; X87-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-32-NEXT:    movl (%eax), %eax
; X87-32-NEXT:    retl
; X87-32-NEXT:  .LBB24_1:
; X87-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-32-NEXT:    movl (%eax), %eax
; X87-32-NEXT:    retl
;
; X87-64-LABEL: test_ult_s:
; X87-64:       # %bb.0:
; X87-64-NEXT:    movl %edi, %eax
; X87-64-NEXT:    fldt {{[0-9]+}}(%rsp)
; X87-64-NEXT:    fldt {{[0-9]+}}(%rsp)
; X87-64-NEXT:    fcompi %st(1), %st
; X87-64-NEXT:    fstp %st(0)
; X87-64-NEXT:    wait
; X87-64-NEXT:    cmovael %esi, %eax
; X87-64-NEXT:    retq
  %cond = call i1 @llvm.experimental.constrained.fcmps.f80(
                                               x86_fp80 %f1, x86_fp80 %f2, metadata !"ult",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_ule_s(i32 %a, i32 %b, x86_fp80 %f1, x86_fp80 %f2) #0 {
; X87-32-LABEL: test_ule_s:
; X87-32:       # %bb.0:
; X87-32-NEXT:    fldt {{[0-9]+}}(%esp)
; X87-32-NEXT:    fldt {{[0-9]+}}(%esp)
; X87-32-NEXT:    fcompp
; X87-32-NEXT:    wait
; X87-32-NEXT:    fnstsw %ax
; X87-32-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-32-NEXT:    sahf
; X87-32-NEXT:    jbe .LBB25_1
; X87-32-NEXT:  # %bb.2:
; X87-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-32-NEXT:    movl (%eax), %eax
; X87-32-NEXT:    retl
; X87-32-NEXT:  .LBB25_1:
; X87-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-32-NEXT:    movl (%eax), %eax
; X87-32-NEXT:    retl
;
; X87-64-LABEL: test_ule_s:
; X87-64:       # %bb.0:
; X87-64-NEXT:    movl %edi, %eax
; X87-64-NEXT:    fldt {{[0-9]+}}(%rsp)
; X87-64-NEXT:    fldt {{[0-9]+}}(%rsp)
; X87-64-NEXT:    fcompi %st(1), %st
; X87-64-NEXT:    fstp %st(0)
; X87-64-NEXT:    wait
; X87-64-NEXT:    cmoval %esi, %eax
; X87-64-NEXT:    retq
  %cond = call i1 @llvm.experimental.constrained.fcmps.f80(
                                               x86_fp80 %f1, x86_fp80 %f2, metadata !"ule",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_une_s(i32 %a, i32 %b, x86_fp80 %f1, x86_fp80 %f2) #0 {
; X87-32-LABEL: test_une_s:
; X87-32:       # %bb.0:
; X87-32-NEXT:    fldt {{[0-9]+}}(%esp)
; X87-32-NEXT:    fldt {{[0-9]+}}(%esp)
; X87-32-NEXT:    fcompp
; X87-32-NEXT:    wait
; X87-32-NEXT:    fnstsw %ax
; X87-32-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-32-NEXT:    sahf
; X87-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-32-NEXT:    jne .LBB26_3
; X87-32-NEXT:  # %bb.1:
; X87-32-NEXT:    jp .LBB26_3
; X87-32-NEXT:  # %bb.2:
; X87-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-32-NEXT:  .LBB26_3:
; X87-32-NEXT:    movl (%eax), %eax
; X87-32-NEXT:    retl
;
; X87-64-LABEL: test_une_s:
; X87-64:       # %bb.0:
; X87-64-NEXT:    movl %esi, %eax
; X87-64-NEXT:    fldt {{[0-9]+}}(%rsp)
; X87-64-NEXT:    fldt {{[0-9]+}}(%rsp)
; X87-64-NEXT:    fcompi %st(1), %st
; X87-64-NEXT:    fstp %st(0)
; X87-64-NEXT:    wait
; X87-64-NEXT:    cmovnel %edi, %eax
; X87-64-NEXT:    cmovpl %edi, %eax
; X87-64-NEXT:    retq
  %cond = call i1 @llvm.experimental.constrained.fcmps.f80(
                                               x86_fp80 %f1, x86_fp80 %f2, metadata !"une",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_uno_s(i32 %a, i32 %b, x86_fp80 %f1, x86_fp80 %f2) #0 {
; X87-32-LABEL: test_uno_s:
; X87-32:       # %bb.0:
; X87-32-NEXT:    fldt {{[0-9]+}}(%esp)
; X87-32-NEXT:    fldt {{[0-9]+}}(%esp)
; X87-32-NEXT:    fcompp
; X87-32-NEXT:    wait
; X87-32-NEXT:    fnstsw %ax
; X87-32-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-32-NEXT:    sahf
; X87-32-NEXT:    jp .LBB27_1
; X87-32-NEXT:  # %bb.2:
; X87-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-32-NEXT:    movl (%eax), %eax
; X87-32-NEXT:    retl
; X87-32-NEXT:  .LBB27_1:
; X87-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-32-NEXT:    movl (%eax), %eax
; X87-32-NEXT:    retl
;
; X87-64-LABEL: test_uno_s:
; X87-64:       # %bb.0:
; X87-64-NEXT:    movl %edi, %eax
; X87-64-NEXT:    fldt {{[0-9]+}}(%rsp)
; X87-64-NEXT:    fldt {{[0-9]+}}(%rsp)
; X87-64-NEXT:    fcompi %st(1), %st
; X87-64-NEXT:    fstp %st(0)
; X87-64-NEXT:    wait
; X87-64-NEXT:    cmovnpl %esi, %eax
; X87-64-NEXT:    retq
  %cond = call i1 @llvm.experimental.constrained.fcmps.f80(
                                               x86_fp80 %f1, x86_fp80 %f2, metadata !"uno",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

attributes #0 = { strictfp }

declare i1 @llvm.experimental.constrained.fcmp.f80(x86_fp80, x86_fp80, metadata, metadata)
declare i1 @llvm.experimental.constrained.fcmps.f80(x86_fp80, x86_fp80, metadata, metadata)

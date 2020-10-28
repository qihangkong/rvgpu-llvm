; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+sse2 | FileCheck %s --check-prefixes=SSE,SSE2
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+sse4.1 | FileCheck %s --check-prefixes=SSE,SSE41
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx | FileCheck %s --check-prefixes=AVX,AVX1
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx2 | FileCheck %s --check-prefixes=AVX,AVX2
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx512f,+avx512bw | FileCheck %s --check-prefixes=AVX,AVX512
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx512f,+avx512bw,+avx512vl | FileCheck %s --check-prefixes=AVX,AVX512

;
; vXi64
;

define i1 @test_v2i64(<2 x i64> %a0) {
; SSE2-LABEL: test_v2i64:
; SSE2:       # %bb.0:
; SSE2-NEXT:    pxor %xmm1, %xmm1
; SSE2-NEXT:    pcmpeqb %xmm0, %xmm1
; SSE2-NEXT:    pmovmskb %xmm1, %eax
; SSE2-NEXT:    cmpl $65535, %eax # imm = 0xFFFF
; SSE2-NEXT:    sete %al
; SSE2-NEXT:    retq
;
; SSE41-LABEL: test_v2i64:
; SSE41:       # %bb.0:
; SSE41-NEXT:    ptest %xmm0, %xmm0
; SSE41-NEXT:    sete %al
; SSE41-NEXT:    retq
;
; AVX-LABEL: test_v2i64:
; AVX:       # %bb.0:
; AVX-NEXT:    vptest %xmm0, %xmm0
; AVX-NEXT:    sete %al
; AVX-NEXT:    retq
  %1 = call i64 @llvm.experimental.vector.reduce.or.v2i64(<2 x i64> %a0)
  %2 = icmp eq i64 %1, 0
  ret i1 %2
}

define i1 @test_v4i64(<4 x i64> %a0) {
; SSE2-LABEL: test_v4i64:
; SSE2:       # %bb.0:
; SSE2-NEXT:    por %xmm1, %xmm0
; SSE2-NEXT:    pxor %xmm1, %xmm1
; SSE2-NEXT:    pcmpeqb %xmm0, %xmm1
; SSE2-NEXT:    pmovmskb %xmm1, %eax
; SSE2-NEXT:    cmpl $65535, %eax # imm = 0xFFFF
; SSE2-NEXT:    setne %al
; SSE2-NEXT:    retq
;
; SSE41-LABEL: test_v4i64:
; SSE41:       # %bb.0:
; SSE41-NEXT:    por %xmm1, %xmm0
; SSE41-NEXT:    ptest %xmm0, %xmm0
; SSE41-NEXT:    setne %al
; SSE41-NEXT:    retq
;
; AVX-LABEL: test_v4i64:
; AVX:       # %bb.0:
; AVX-NEXT:    vptest %ymm0, %ymm0
; AVX-NEXT:    setne %al
; AVX-NEXT:    vzeroupper
; AVX-NEXT:    retq
  %1 = call i64 @llvm.experimental.vector.reduce.or.v4i64(<4 x i64> %a0)
  %2 = icmp ne i64 %1, 0
  ret i1 %2
}

define i1 @test_v8i64(<8 x i64> %a0) {
; SSE2-LABEL: test_v8i64:
; SSE2:       # %bb.0:
; SSE2-NEXT:    por %xmm3, %xmm1
; SSE2-NEXT:    por %xmm2, %xmm1
; SSE2-NEXT:    por %xmm0, %xmm1
; SSE2-NEXT:    pxor %xmm0, %xmm0
; SSE2-NEXT:    pcmpeqb %xmm1, %xmm0
; SSE2-NEXT:    pmovmskb %xmm0, %eax
; SSE2-NEXT:    cmpl $65535, %eax # imm = 0xFFFF
; SSE2-NEXT:    sete %al
; SSE2-NEXT:    retq
;
; SSE41-LABEL: test_v8i64:
; SSE41:       # %bb.0:
; SSE41-NEXT:    por %xmm3, %xmm1
; SSE41-NEXT:    por %xmm2, %xmm1
; SSE41-NEXT:    por %xmm0, %xmm1
; SSE41-NEXT:    ptest %xmm1, %xmm1
; SSE41-NEXT:    sete %al
; SSE41-NEXT:    retq
;
; AVX1-LABEL: test_v8i64:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vorps %ymm1, %ymm0, %ymm0
; AVX1-NEXT:    vptest %ymm0, %ymm0
; AVX1-NEXT:    sete %al
; AVX1-NEXT:    vzeroupper
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test_v8i64:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpor %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    vptest %ymm0, %ymm0
; AVX2-NEXT:    sete %al
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    retq
;
; AVX512-LABEL: test_v8i64:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vextracti64x4 $1, %zmm0, %ymm1
; AVX512-NEXT:    vpor %ymm1, %ymm0, %ymm0
; AVX512-NEXT:    vptest %ymm0, %ymm0
; AVX512-NEXT:    sete %al
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
  %1 = call i64 @llvm.experimental.vector.reduce.or.v8i64(<8 x i64> %a0)
  %2 = icmp eq i64 %1, 0
  ret i1 %2
}

define i1 @test_v16i64(<16 x i64> %a0) {
; SSE2-LABEL: test_v16i64:
; SSE2:       # %bb.0:
; SSE2-NEXT:    por %xmm7, %xmm3
; SSE2-NEXT:    por %xmm5, %xmm3
; SSE2-NEXT:    por %xmm1, %xmm3
; SSE2-NEXT:    por %xmm6, %xmm2
; SSE2-NEXT:    por %xmm4, %xmm2
; SSE2-NEXT:    por %xmm3, %xmm2
; SSE2-NEXT:    por %xmm0, %xmm2
; SSE2-NEXT:    pxor %xmm0, %xmm0
; SSE2-NEXT:    pcmpeqb %xmm2, %xmm0
; SSE2-NEXT:    pmovmskb %xmm0, %eax
; SSE2-NEXT:    cmpl $65535, %eax # imm = 0xFFFF
; SSE2-NEXT:    setne %al
; SSE2-NEXT:    retq
;
; SSE41-LABEL: test_v16i64:
; SSE41:       # %bb.0:
; SSE41-NEXT:    por %xmm7, %xmm3
; SSE41-NEXT:    por %xmm5, %xmm3
; SSE41-NEXT:    por %xmm1, %xmm3
; SSE41-NEXT:    por %xmm6, %xmm2
; SSE41-NEXT:    por %xmm4, %xmm2
; SSE41-NEXT:    por %xmm3, %xmm2
; SSE41-NEXT:    por %xmm0, %xmm2
; SSE41-NEXT:    ptest %xmm2, %xmm2
; SSE41-NEXT:    setne %al
; SSE41-NEXT:    retq
;
; AVX1-LABEL: test_v16i64:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vorps %ymm3, %ymm1, %ymm1
; AVX1-NEXT:    vorps %ymm1, %ymm2, %ymm1
; AVX1-NEXT:    vorps %ymm1, %ymm0, %ymm0
; AVX1-NEXT:    vptest %ymm0, %ymm0
; AVX1-NEXT:    setne %al
; AVX1-NEXT:    vzeroupper
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test_v16i64:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpor %ymm3, %ymm1, %ymm1
; AVX2-NEXT:    vpor %ymm1, %ymm2, %ymm1
; AVX2-NEXT:    vpor %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    vptest %ymm0, %ymm0
; AVX2-NEXT:    setne %al
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    retq
;
; AVX512-LABEL: test_v16i64:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vporq %zmm1, %zmm0, %zmm0
; AVX512-NEXT:    vextracti64x4 $1, %zmm0, %ymm1
; AVX512-NEXT:    vpor %ymm1, %ymm0, %ymm0
; AVX512-NEXT:    vptest %ymm0, %ymm0
; AVX512-NEXT:    setne %al
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
  %1 = call i64 @llvm.experimental.vector.reduce.or.v16i64(<16 x i64> %a0)
  %2 = icmp ne i64 %1, 0
  ret i1 %2
}

;
; vXi32
;

define i1 @test_v2i32(<2 x i32> %a0) {
; SSE-LABEL: test_v2i32:
; SSE:       # %bb.0:
; SSE-NEXT:    movq %xmm0, %rax
; SSE-NEXT:    testq %rax, %rax
; SSE-NEXT:    sete %al
; SSE-NEXT:    retq
;
; AVX-LABEL: test_v2i32:
; AVX:       # %bb.0:
; AVX-NEXT:    vmovq %xmm0, %rax
; AVX-NEXT:    testq %rax, %rax
; AVX-NEXT:    sete %al
; AVX-NEXT:    retq
  %1 = call i32 @llvm.experimental.vector.reduce.or.v2i32(<2 x i32> %a0)
  %2 = icmp eq i32 %1, 0
  ret i1 %2
}

define i1 @test_v4i32(<4 x i32> %a0) {
; SSE2-LABEL: test_v4i32:
; SSE2:       # %bb.0:
; SSE2-NEXT:    pxor %xmm1, %xmm1
; SSE2-NEXT:    pcmpeqb %xmm0, %xmm1
; SSE2-NEXT:    pmovmskb %xmm1, %eax
; SSE2-NEXT:    cmpl $65535, %eax # imm = 0xFFFF
; SSE2-NEXT:    setne %al
; SSE2-NEXT:    retq
;
; SSE41-LABEL: test_v4i32:
; SSE41:       # %bb.0:
; SSE41-NEXT:    ptest %xmm0, %xmm0
; SSE41-NEXT:    setne %al
; SSE41-NEXT:    retq
;
; AVX-LABEL: test_v4i32:
; AVX:       # %bb.0:
; AVX-NEXT:    vptest %xmm0, %xmm0
; AVX-NEXT:    setne %al
; AVX-NEXT:    retq
  %1 = call i32 @llvm.experimental.vector.reduce.or.v4i32(<4 x i32> %a0)
  %2 = icmp ne i32 %1, 0
  ret i1 %2
}

define i1 @test_v8i32(<8 x i32> %a0) {
; SSE2-LABEL: test_v8i32:
; SSE2:       # %bb.0:
; SSE2-NEXT:    por %xmm1, %xmm0
; SSE2-NEXT:    pxor %xmm1, %xmm1
; SSE2-NEXT:    pcmpeqb %xmm0, %xmm1
; SSE2-NEXT:    pmovmskb %xmm1, %eax
; SSE2-NEXT:    cmpl $65535, %eax # imm = 0xFFFF
; SSE2-NEXT:    sete %al
; SSE2-NEXT:    retq
;
; SSE41-LABEL: test_v8i32:
; SSE41:       # %bb.0:
; SSE41-NEXT:    por %xmm1, %xmm0
; SSE41-NEXT:    ptest %xmm0, %xmm0
; SSE41-NEXT:    sete %al
; SSE41-NEXT:    retq
;
; AVX-LABEL: test_v8i32:
; AVX:       # %bb.0:
; AVX-NEXT:    vptest %ymm0, %ymm0
; AVX-NEXT:    sete %al
; AVX-NEXT:    vzeroupper
; AVX-NEXT:    retq
  %1 = call i32 @llvm.experimental.vector.reduce.or.v8i32(<8 x i32> %a0)
  %2 = icmp eq i32 %1, 0
  ret i1 %2
}

define i1 @test_v16i32(<16 x i32> %a0) {
; SSE2-LABEL: test_v16i32:
; SSE2:       # %bb.0:
; SSE2-NEXT:    por %xmm3, %xmm1
; SSE2-NEXT:    por %xmm2, %xmm1
; SSE2-NEXT:    por %xmm0, %xmm1
; SSE2-NEXT:    pxor %xmm0, %xmm0
; SSE2-NEXT:    pcmpeqb %xmm1, %xmm0
; SSE2-NEXT:    pmovmskb %xmm0, %eax
; SSE2-NEXT:    cmpl $65535, %eax # imm = 0xFFFF
; SSE2-NEXT:    setne %al
; SSE2-NEXT:    retq
;
; SSE41-LABEL: test_v16i32:
; SSE41:       # %bb.0:
; SSE41-NEXT:    por %xmm3, %xmm1
; SSE41-NEXT:    por %xmm2, %xmm1
; SSE41-NEXT:    por %xmm0, %xmm1
; SSE41-NEXT:    ptest %xmm1, %xmm1
; SSE41-NEXT:    setne %al
; SSE41-NEXT:    retq
;
; AVX1-LABEL: test_v16i32:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vorps %ymm1, %ymm0, %ymm0
; AVX1-NEXT:    vptest %ymm0, %ymm0
; AVX1-NEXT:    setne %al
; AVX1-NEXT:    vzeroupper
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test_v16i32:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpor %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    vptest %ymm0, %ymm0
; AVX2-NEXT:    setne %al
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    retq
;
; AVX512-LABEL: test_v16i32:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vextracti64x4 $1, %zmm0, %ymm1
; AVX512-NEXT:    vpor %ymm1, %ymm0, %ymm0
; AVX512-NEXT:    vptest %ymm0, %ymm0
; AVX512-NEXT:    setne %al
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
  %1 = call i32 @llvm.experimental.vector.reduce.or.v16i32(<16 x i32> %a0)
  %2 = icmp ne i32 %1, 0
  ret i1 %2
}

define i1 @test_v32i32(<32 x i32> %a0) {
; SSE2-LABEL: test_v32i32:
; SSE2:       # %bb.0:
; SSE2-NEXT:    por %xmm7, %xmm3
; SSE2-NEXT:    por %xmm5, %xmm3
; SSE2-NEXT:    por %xmm1, %xmm3
; SSE2-NEXT:    por %xmm6, %xmm2
; SSE2-NEXT:    por %xmm4, %xmm2
; SSE2-NEXT:    por %xmm3, %xmm2
; SSE2-NEXT:    por %xmm0, %xmm2
; SSE2-NEXT:    pxor %xmm0, %xmm0
; SSE2-NEXT:    pcmpeqb %xmm2, %xmm0
; SSE2-NEXT:    pmovmskb %xmm0, %eax
; SSE2-NEXT:    cmpl $65535, %eax # imm = 0xFFFF
; SSE2-NEXT:    sete %al
; SSE2-NEXT:    retq
;
; SSE41-LABEL: test_v32i32:
; SSE41:       # %bb.0:
; SSE41-NEXT:    por %xmm7, %xmm3
; SSE41-NEXT:    por %xmm5, %xmm3
; SSE41-NEXT:    por %xmm1, %xmm3
; SSE41-NEXT:    por %xmm6, %xmm2
; SSE41-NEXT:    por %xmm4, %xmm2
; SSE41-NEXT:    por %xmm3, %xmm2
; SSE41-NEXT:    por %xmm0, %xmm2
; SSE41-NEXT:    ptest %xmm2, %xmm2
; SSE41-NEXT:    sete %al
; SSE41-NEXT:    retq
;
; AVX1-LABEL: test_v32i32:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vorps %ymm3, %ymm1, %ymm1
; AVX1-NEXT:    vorps %ymm1, %ymm2, %ymm1
; AVX1-NEXT:    vorps %ymm1, %ymm0, %ymm0
; AVX1-NEXT:    vptest %ymm0, %ymm0
; AVX1-NEXT:    sete %al
; AVX1-NEXT:    vzeroupper
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test_v32i32:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpor %ymm3, %ymm1, %ymm1
; AVX2-NEXT:    vpor %ymm1, %ymm2, %ymm1
; AVX2-NEXT:    vpor %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    vptest %ymm0, %ymm0
; AVX2-NEXT:    sete %al
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    retq
;
; AVX512-LABEL: test_v32i32:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vpord %zmm1, %zmm0, %zmm0
; AVX512-NEXT:    vextracti64x4 $1, %zmm0, %ymm1
; AVX512-NEXT:    vpor %ymm1, %ymm0, %ymm0
; AVX512-NEXT:    vptest %ymm0, %ymm0
; AVX512-NEXT:    sete %al
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
  %1 = call i32 @llvm.experimental.vector.reduce.or.v32i32(<32 x i32> %a0)
  %2 = icmp eq i32 %1, 0
  ret i1 %2
}

;
; vXi16
;

define i1 @test_v2i16(<2 x i16> %a0) {
; SSE-LABEL: test_v2i16:
; SSE:       # %bb.0:
; SSE-NEXT:    movd %xmm0, %eax
; SSE-NEXT:    testl %eax, %eax
; SSE-NEXT:    sete %al
; SSE-NEXT:    retq
;
; AVX-LABEL: test_v2i16:
; AVX:       # %bb.0:
; AVX-NEXT:    vmovd %xmm0, %eax
; AVX-NEXT:    testl %eax, %eax
; AVX-NEXT:    sete %al
; AVX-NEXT:    retq
  %1 = call i16 @llvm.experimental.vector.reduce.or.v2i16(<2 x i16> %a0)
  %2 = icmp eq i16 %1, 0
  ret i1 %2
}

define i1 @test_v4i16(<4 x i16> %a0) {
; SSE-LABEL: test_v4i16:
; SSE:       # %bb.0:
; SSE-NEXT:    movq %xmm0, %rax
; SSE-NEXT:    testq %rax, %rax
; SSE-NEXT:    setne %al
; SSE-NEXT:    retq
;
; AVX-LABEL: test_v4i16:
; AVX:       # %bb.0:
; AVX-NEXT:    vmovq %xmm0, %rax
; AVX-NEXT:    testq %rax, %rax
; AVX-NEXT:    setne %al
; AVX-NEXT:    retq
  %1 = call i16 @llvm.experimental.vector.reduce.or.v4i16(<4 x i16> %a0)
  %2 = icmp ne i16 %1, 0
  ret i1 %2
}

define i1 @test_v8i16(<8 x i16> %a0) {
; SSE2-LABEL: test_v8i16:
; SSE2:       # %bb.0:
; SSE2-NEXT:    pxor %xmm1, %xmm1
; SSE2-NEXT:    pcmpeqb %xmm0, %xmm1
; SSE2-NEXT:    pmovmskb %xmm1, %eax
; SSE2-NEXT:    cmpl $65535, %eax # imm = 0xFFFF
; SSE2-NEXT:    sete %al
; SSE2-NEXT:    retq
;
; SSE41-LABEL: test_v8i16:
; SSE41:       # %bb.0:
; SSE41-NEXT:    ptest %xmm0, %xmm0
; SSE41-NEXT:    sete %al
; SSE41-NEXT:    retq
;
; AVX-LABEL: test_v8i16:
; AVX:       # %bb.0:
; AVX-NEXT:    vptest %xmm0, %xmm0
; AVX-NEXT:    sete %al
; AVX-NEXT:    retq
  %1 = call i16 @llvm.experimental.vector.reduce.or.v8i16(<8 x i16> %a0)
  %2 = icmp eq i16 %1, 0
  ret i1 %2
}

define i1 @test_v16i16(<16 x i16> %a0) {
; SSE2-LABEL: test_v16i16:
; SSE2:       # %bb.0:
; SSE2-NEXT:    por %xmm1, %xmm0
; SSE2-NEXT:    pxor %xmm1, %xmm1
; SSE2-NEXT:    pcmpeqb %xmm0, %xmm1
; SSE2-NEXT:    pmovmskb %xmm1, %eax
; SSE2-NEXT:    cmpl $65535, %eax # imm = 0xFFFF
; SSE2-NEXT:    setne %al
; SSE2-NEXT:    retq
;
; SSE41-LABEL: test_v16i16:
; SSE41:       # %bb.0:
; SSE41-NEXT:    por %xmm1, %xmm0
; SSE41-NEXT:    ptest %xmm0, %xmm0
; SSE41-NEXT:    setne %al
; SSE41-NEXT:    retq
;
; AVX-LABEL: test_v16i16:
; AVX:       # %bb.0:
; AVX-NEXT:    vptest %ymm0, %ymm0
; AVX-NEXT:    setne %al
; AVX-NEXT:    vzeroupper
; AVX-NEXT:    retq
  %1 = call i16 @llvm.experimental.vector.reduce.or.v16i16(<16 x i16> %a0)
  %2 = icmp ne i16 %1, 0
  ret i1 %2
}

define i1 @test_v32i16(<32 x i16> %a0) {
; SSE2-LABEL: test_v32i16:
; SSE2:       # %bb.0:
; SSE2-NEXT:    por %xmm3, %xmm1
; SSE2-NEXT:    por %xmm2, %xmm1
; SSE2-NEXT:    por %xmm0, %xmm1
; SSE2-NEXT:    pxor %xmm0, %xmm0
; SSE2-NEXT:    pcmpeqb %xmm1, %xmm0
; SSE2-NEXT:    pmovmskb %xmm0, %eax
; SSE2-NEXT:    cmpl $65535, %eax # imm = 0xFFFF
; SSE2-NEXT:    sete %al
; SSE2-NEXT:    retq
;
; SSE41-LABEL: test_v32i16:
; SSE41:       # %bb.0:
; SSE41-NEXT:    por %xmm3, %xmm1
; SSE41-NEXT:    por %xmm2, %xmm1
; SSE41-NEXT:    por %xmm0, %xmm1
; SSE41-NEXT:    ptest %xmm1, %xmm1
; SSE41-NEXT:    sete %al
; SSE41-NEXT:    retq
;
; AVX1-LABEL: test_v32i16:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vorps %ymm1, %ymm0, %ymm0
; AVX1-NEXT:    vptest %ymm0, %ymm0
; AVX1-NEXT:    sete %al
; AVX1-NEXT:    vzeroupper
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test_v32i16:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpor %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    vptest %ymm0, %ymm0
; AVX2-NEXT:    sete %al
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    retq
;
; AVX512-LABEL: test_v32i16:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vextracti64x4 $1, %zmm0, %ymm1
; AVX512-NEXT:    vpor %ymm1, %ymm0, %ymm0
; AVX512-NEXT:    vptest %ymm0, %ymm0
; AVX512-NEXT:    sete %al
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
  %1 = call i16 @llvm.experimental.vector.reduce.or.v32i16(<32 x i16> %a0)
  %2 = icmp eq i16 %1, 0
  ret i1 %2
}

define i1 @test_v64i16(<64 x i16> %a0) {
; SSE2-LABEL: test_v64i16:
; SSE2:       # %bb.0:
; SSE2-NEXT:    por %xmm7, %xmm3
; SSE2-NEXT:    por %xmm5, %xmm3
; SSE2-NEXT:    por %xmm1, %xmm3
; SSE2-NEXT:    por %xmm6, %xmm2
; SSE2-NEXT:    por %xmm4, %xmm2
; SSE2-NEXT:    por %xmm3, %xmm2
; SSE2-NEXT:    por %xmm0, %xmm2
; SSE2-NEXT:    pxor %xmm0, %xmm0
; SSE2-NEXT:    pcmpeqb %xmm2, %xmm0
; SSE2-NEXT:    pmovmskb %xmm0, %eax
; SSE2-NEXT:    cmpl $65535, %eax # imm = 0xFFFF
; SSE2-NEXT:    setne %al
; SSE2-NEXT:    retq
;
; SSE41-LABEL: test_v64i16:
; SSE41:       # %bb.0:
; SSE41-NEXT:    por %xmm7, %xmm3
; SSE41-NEXT:    por %xmm5, %xmm3
; SSE41-NEXT:    por %xmm1, %xmm3
; SSE41-NEXT:    por %xmm6, %xmm2
; SSE41-NEXT:    por %xmm4, %xmm2
; SSE41-NEXT:    por %xmm3, %xmm2
; SSE41-NEXT:    por %xmm0, %xmm2
; SSE41-NEXT:    ptest %xmm2, %xmm2
; SSE41-NEXT:    setne %al
; SSE41-NEXT:    retq
;
; AVX1-LABEL: test_v64i16:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vorps %ymm3, %ymm1, %ymm1
; AVX1-NEXT:    vorps %ymm1, %ymm2, %ymm1
; AVX1-NEXT:    vorps %ymm1, %ymm0, %ymm0
; AVX1-NEXT:    vptest %ymm0, %ymm0
; AVX1-NEXT:    setne %al
; AVX1-NEXT:    vzeroupper
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test_v64i16:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpor %ymm3, %ymm1, %ymm1
; AVX2-NEXT:    vpor %ymm1, %ymm2, %ymm1
; AVX2-NEXT:    vpor %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    vptest %ymm0, %ymm0
; AVX2-NEXT:    setne %al
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    retq
;
; AVX512-LABEL: test_v64i16:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vporq %zmm1, %zmm0, %zmm0
; AVX512-NEXT:    vextracti64x4 $1, %zmm0, %ymm1
; AVX512-NEXT:    vpor %ymm1, %ymm0, %ymm0
; AVX512-NEXT:    vptest %ymm0, %ymm0
; AVX512-NEXT:    setne %al
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
  %1 = call i16 @llvm.experimental.vector.reduce.or.v64i16(<64 x i16> %a0)
  %2 = icmp ne i16 %1, 0
  ret i1 %2
}

;
; vXi8
;

define i1 @test_v2i8(<2 x i8> %a0) {
; SSE-LABEL: test_v2i8:
; SSE:       # %bb.0:
; SSE-NEXT:    movd %xmm0, %eax
; SSE-NEXT:    testw %ax, %ax
; SSE-NEXT:    sete %al
; SSE-NEXT:    retq
;
; AVX-LABEL: test_v2i8:
; AVX:       # %bb.0:
; AVX-NEXT:    vmovd %xmm0, %eax
; AVX-NEXT:    testw %ax, %ax
; AVX-NEXT:    sete %al
; AVX-NEXT:    retq
  %1 = call i8 @llvm.experimental.vector.reduce.or.v2i8(<2 x i8> %a0)
  %2 = icmp eq i8 %1, 0
  ret i1 %2
}

define i1 @test_v4i8(<4 x i8> %a0) {
; SSE-LABEL: test_v4i8:
; SSE:       # %bb.0:
; SSE-NEXT:    movd %xmm0, %eax
; SSE-NEXT:    testl %eax, %eax
; SSE-NEXT:    setne %al
; SSE-NEXT:    retq
;
; AVX-LABEL: test_v4i8:
; AVX:       # %bb.0:
; AVX-NEXT:    vmovd %xmm0, %eax
; AVX-NEXT:    testl %eax, %eax
; AVX-NEXT:    setne %al
; AVX-NEXT:    retq
  %1 = call i8 @llvm.experimental.vector.reduce.or.v4i8(<4 x i8> %a0)
  %2 = icmp ne i8 %1, 0
  ret i1 %2
}

define i1 @test_v8i8(<8 x i8> %a0) {
; SSE-LABEL: test_v8i8:
; SSE:       # %bb.0:
; SSE-NEXT:    movq %xmm0, %rax
; SSE-NEXT:    testq %rax, %rax
; SSE-NEXT:    sete %al
; SSE-NEXT:    retq
;
; AVX-LABEL: test_v8i8:
; AVX:       # %bb.0:
; AVX-NEXT:    vmovq %xmm0, %rax
; AVX-NEXT:    testq %rax, %rax
; AVX-NEXT:    sete %al
; AVX-NEXT:    retq
  %1 = call i8 @llvm.experimental.vector.reduce.or.v8i8(<8 x i8> %a0)
  %2 = icmp eq i8 %1, 0
  ret i1 %2
}

define i1 @test_v16i8(<16 x i8> %a0) {
; SSE2-LABEL: test_v16i8:
; SSE2:       # %bb.0:
; SSE2-NEXT:    pxor %xmm1, %xmm1
; SSE2-NEXT:    pcmpeqb %xmm0, %xmm1
; SSE2-NEXT:    pmovmskb %xmm1, %eax
; SSE2-NEXT:    cmpl $65535, %eax # imm = 0xFFFF
; SSE2-NEXT:    setne %al
; SSE2-NEXT:    retq
;
; SSE41-LABEL: test_v16i8:
; SSE41:       # %bb.0:
; SSE41-NEXT:    ptest %xmm0, %xmm0
; SSE41-NEXT:    setne %al
; SSE41-NEXT:    retq
;
; AVX-LABEL: test_v16i8:
; AVX:       # %bb.0:
; AVX-NEXT:    vptest %xmm0, %xmm0
; AVX-NEXT:    setne %al
; AVX-NEXT:    retq
  %1 = call i8 @llvm.experimental.vector.reduce.or.v16i8(<16 x i8> %a0)
  %2 = icmp ne i8 %1, 0
  ret i1 %2
}

define i1 @test_v32i8(<32 x i8> %a0) {
; SSE2-LABEL: test_v32i8:
; SSE2:       # %bb.0:
; SSE2-NEXT:    por %xmm1, %xmm0
; SSE2-NEXT:    pxor %xmm1, %xmm1
; SSE2-NEXT:    pcmpeqb %xmm0, %xmm1
; SSE2-NEXT:    pmovmskb %xmm1, %eax
; SSE2-NEXT:    cmpl $65535, %eax # imm = 0xFFFF
; SSE2-NEXT:    sete %al
; SSE2-NEXT:    retq
;
; SSE41-LABEL: test_v32i8:
; SSE41:       # %bb.0:
; SSE41-NEXT:    por %xmm1, %xmm0
; SSE41-NEXT:    ptest %xmm0, %xmm0
; SSE41-NEXT:    sete %al
; SSE41-NEXT:    retq
;
; AVX-LABEL: test_v32i8:
; AVX:       # %bb.0:
; AVX-NEXT:    vptest %ymm0, %ymm0
; AVX-NEXT:    sete %al
; AVX-NEXT:    vzeroupper
; AVX-NEXT:    retq
  %1 = call i8 @llvm.experimental.vector.reduce.or.v32i8(<32 x i8> %a0)
  %2 = icmp eq i8 %1, 0
  ret i1 %2
}

define i1 @test_v64i8(<64 x i8> %a0) {
; SSE2-LABEL: test_v64i8:
; SSE2:       # %bb.0:
; SSE2-NEXT:    por %xmm3, %xmm1
; SSE2-NEXT:    por %xmm2, %xmm1
; SSE2-NEXT:    por %xmm0, %xmm1
; SSE2-NEXT:    pxor %xmm0, %xmm0
; SSE2-NEXT:    pcmpeqb %xmm1, %xmm0
; SSE2-NEXT:    pmovmskb %xmm0, %eax
; SSE2-NEXT:    cmpl $65535, %eax # imm = 0xFFFF
; SSE2-NEXT:    setne %al
; SSE2-NEXT:    retq
;
; SSE41-LABEL: test_v64i8:
; SSE41:       # %bb.0:
; SSE41-NEXT:    por %xmm3, %xmm1
; SSE41-NEXT:    por %xmm2, %xmm1
; SSE41-NEXT:    por %xmm0, %xmm1
; SSE41-NEXT:    ptest %xmm1, %xmm1
; SSE41-NEXT:    setne %al
; SSE41-NEXT:    retq
;
; AVX1-LABEL: test_v64i8:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vorps %ymm1, %ymm0, %ymm0
; AVX1-NEXT:    vptest %ymm0, %ymm0
; AVX1-NEXT:    setne %al
; AVX1-NEXT:    vzeroupper
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test_v64i8:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpor %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    vptest %ymm0, %ymm0
; AVX2-NEXT:    setne %al
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    retq
;
; AVX512-LABEL: test_v64i8:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vextracti64x4 $1, %zmm0, %ymm1
; AVX512-NEXT:    vpor %ymm1, %ymm0, %ymm0
; AVX512-NEXT:    vptest %ymm0, %ymm0
; AVX512-NEXT:    setne %al
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
  %1 = call i8 @llvm.experimental.vector.reduce.or.v64i8(<64 x i8> %a0)
  %2 = icmp ne i8 %1, 0
  ret i1 %2
}

define i1 @test_v128i8(<128 x i8> %a0) {
; SSE2-LABEL: test_v128i8:
; SSE2:       # %bb.0:
; SSE2-NEXT:    por %xmm7, %xmm3
; SSE2-NEXT:    por %xmm5, %xmm3
; SSE2-NEXT:    por %xmm1, %xmm3
; SSE2-NEXT:    por %xmm6, %xmm2
; SSE2-NEXT:    por %xmm4, %xmm2
; SSE2-NEXT:    por %xmm3, %xmm2
; SSE2-NEXT:    por %xmm0, %xmm2
; SSE2-NEXT:    pxor %xmm0, %xmm0
; SSE2-NEXT:    pcmpeqb %xmm2, %xmm0
; SSE2-NEXT:    pmovmskb %xmm0, %eax
; SSE2-NEXT:    cmpl $65535, %eax # imm = 0xFFFF
; SSE2-NEXT:    sete %al
; SSE2-NEXT:    retq
;
; SSE41-LABEL: test_v128i8:
; SSE41:       # %bb.0:
; SSE41-NEXT:    por %xmm7, %xmm3
; SSE41-NEXT:    por %xmm5, %xmm3
; SSE41-NEXT:    por %xmm1, %xmm3
; SSE41-NEXT:    por %xmm6, %xmm2
; SSE41-NEXT:    por %xmm4, %xmm2
; SSE41-NEXT:    por %xmm3, %xmm2
; SSE41-NEXT:    por %xmm0, %xmm2
; SSE41-NEXT:    ptest %xmm2, %xmm2
; SSE41-NEXT:    sete %al
; SSE41-NEXT:    retq
;
; AVX1-LABEL: test_v128i8:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vorps %ymm3, %ymm1, %ymm1
; AVX1-NEXT:    vorps %ymm1, %ymm2, %ymm1
; AVX1-NEXT:    vorps %ymm1, %ymm0, %ymm0
; AVX1-NEXT:    vptest %ymm0, %ymm0
; AVX1-NEXT:    sete %al
; AVX1-NEXT:    vzeroupper
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test_v128i8:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpor %ymm3, %ymm1, %ymm1
; AVX2-NEXT:    vpor %ymm1, %ymm2, %ymm1
; AVX2-NEXT:    vpor %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    vptest %ymm0, %ymm0
; AVX2-NEXT:    sete %al
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    retq
;
; AVX512-LABEL: test_v128i8:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vporq %zmm1, %zmm0, %zmm0
; AVX512-NEXT:    vextracti64x4 $1, %zmm0, %ymm1
; AVX512-NEXT:    vpor %ymm1, %ymm0, %ymm0
; AVX512-NEXT:    vptest %ymm0, %ymm0
; AVX512-NEXT:    sete %al
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
  %1 = call i8 @llvm.experimental.vector.reduce.or.v128i8(<128 x i8> %a0)
  %2 = icmp eq i8 %1, 0
  ret i1 %2
}

;
; Compare Truncated/Masked OR Reductions
;

define i1 @trunc_v2i64(<2 x i64> %a0) {
; SSE2-LABEL: trunc_v2i64:
; SSE2:       # %bb.0:
; SSE2-NEXT:    pshufd {{.*#+}} xmm1 = xmm0[2,3,2,3]
; SSE2-NEXT:    por %xmm0, %xmm1
; SSE2-NEXT:    movd %xmm1, %eax
; SSE2-NEXT:    testw %ax, %ax
; SSE2-NEXT:    sete %al
; SSE2-NEXT:    retq
;
; SSE41-LABEL: trunc_v2i64:
; SSE41:       # %bb.0:
; SSE41-NEXT:    ptest {{.*}}(%rip), %xmm0
; SSE41-NEXT:    sete %al
; SSE41-NEXT:    retq
;
; AVX-LABEL: trunc_v2i64:
; AVX:       # %bb.0:
; AVX-NEXT:    vptest {{.*}}(%rip), %xmm0
; AVX-NEXT:    sete %al
; AVX-NEXT:    retq
  %1 = call i64 @llvm.experimental.vector.reduce.or.v2i64(<2 x i64> %a0)
  %2 = trunc i64 %1 to i16
  %3 = icmp eq i16 %2, 0
  ret i1 %3
}

define i1 @mask_v8i32(<8 x i32> %a0) {
; SSE2-LABEL: mask_v8i32:
; SSE2:       # %bb.0:
; SSE2-NEXT:    por %xmm1, %xmm0
; SSE2-NEXT:    pand {{.*}}(%rip), %xmm0
; SSE2-NEXT:    pxor %xmm1, %xmm1
; SSE2-NEXT:    pcmpeqb %xmm0, %xmm1
; SSE2-NEXT:    pmovmskb %xmm1, %eax
; SSE2-NEXT:    cmpl $65535, %eax # imm = 0xFFFF
; SSE2-NEXT:    sete %al
; SSE2-NEXT:    retq
;
; SSE41-LABEL: mask_v8i32:
; SSE41:       # %bb.0:
; SSE41-NEXT:    por %xmm1, %xmm0
; SSE41-NEXT:    ptest {{.*}}(%rip), %xmm0
; SSE41-NEXT:    sete %al
; SSE41-NEXT:    retq
;
; AVX1-LABEL: mask_v8i32:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vptest {{.*}}(%rip), %ymm0
; AVX1-NEXT:    sete %al
; AVX1-NEXT:    vzeroupper
; AVX1-NEXT:    retq
;
; AVX2-LABEL: mask_v8i32:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpbroadcastq {{.*#+}} ymm1 = [9223372039002259456,9223372039002259456,9223372039002259456,9223372039002259456]
; AVX2-NEXT:    vptest %ymm1, %ymm0
; AVX2-NEXT:    sete %al
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    retq
;
; AVX512-LABEL: mask_v8i32:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vpbroadcastq {{.*#+}} ymm1 = [9223372039002259456,9223372039002259456,9223372039002259456,9223372039002259456]
; AVX512-NEXT:    vptest %ymm1, %ymm0
; AVX512-NEXT:    sete %al
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
  %1 = call i32 @llvm.experimental.vector.reduce.or.v8i32(<8 x i32> %a0)
  %2 = and i32 %1, 2147483648
  %3 = icmp eq i32 %2, 0
  ret i1 %3
}

define i1 @trunc_v16i16(<16 x i16> %a0) {
; SSE2-LABEL: trunc_v16i16:
; SSE2:       # %bb.0:
; SSE2-NEXT:    por %xmm1, %xmm0
; SSE2-NEXT:    pand {{.*}}(%rip), %xmm0
; SSE2-NEXT:    pxor %xmm1, %xmm1
; SSE2-NEXT:    pcmpeqb %xmm0, %xmm1
; SSE2-NEXT:    pmovmskb %xmm1, %eax
; SSE2-NEXT:    cmpl $65535, %eax # imm = 0xFFFF
; SSE2-NEXT:    setne %al
; SSE2-NEXT:    retq
;
; SSE41-LABEL: trunc_v16i16:
; SSE41:       # %bb.0:
; SSE41-NEXT:    por %xmm1, %xmm0
; SSE41-NEXT:    ptest {{.*}}(%rip), %xmm0
; SSE41-NEXT:    setne %al
; SSE41-NEXT:    retq
;
; AVX1-LABEL: trunc_v16i16:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vptest {{.*}}(%rip), %ymm0
; AVX1-NEXT:    setne %al
; AVX1-NEXT:    vzeroupper
; AVX1-NEXT:    retq
;
; AVX2-LABEL: trunc_v16i16:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpbroadcastq {{.*#+}} ymm1 = [71777214294589695,71777214294589695,71777214294589695,71777214294589695]
; AVX2-NEXT:    vptest %ymm1, %ymm0
; AVX2-NEXT:    setne %al
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    retq
;
; AVX512-LABEL: trunc_v16i16:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vpbroadcastq {{.*#+}} ymm1 = [71777214294589695,71777214294589695,71777214294589695,71777214294589695]
; AVX512-NEXT:    vptest %ymm1, %ymm0
; AVX512-NEXT:    setne %al
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
  %1 = call i16 @llvm.experimental.vector.reduce.or.v16i16(<16 x i16> %a0)
  %2 = trunc i16 %1 to i8
  %3 = icmp ne i8 %2, 0
  ret i1 %3
}

define i1 @mask_v128i8(<128 x i8> %a0) {
; SSE2-LABEL: mask_v128i8:
; SSE2:       # %bb.0:
; SSE2-NEXT:    por %xmm7, %xmm3
; SSE2-NEXT:    por %xmm5, %xmm3
; SSE2-NEXT:    por %xmm1, %xmm3
; SSE2-NEXT:    por %xmm6, %xmm2
; SSE2-NEXT:    por %xmm4, %xmm2
; SSE2-NEXT:    por %xmm3, %xmm2
; SSE2-NEXT:    por %xmm0, %xmm2
; SSE2-NEXT:    pand {{.*}}(%rip), %xmm2
; SSE2-NEXT:    pxor %xmm0, %xmm0
; SSE2-NEXT:    pcmpeqb %xmm2, %xmm0
; SSE2-NEXT:    pmovmskb %xmm0, %eax
; SSE2-NEXT:    cmpl $65535, %eax # imm = 0xFFFF
; SSE2-NEXT:    sete %al
; SSE2-NEXT:    retq
;
; SSE41-LABEL: mask_v128i8:
; SSE41:       # %bb.0:
; SSE41-NEXT:    por %xmm7, %xmm3
; SSE41-NEXT:    por %xmm5, %xmm3
; SSE41-NEXT:    por %xmm1, %xmm3
; SSE41-NEXT:    por %xmm6, %xmm2
; SSE41-NEXT:    por %xmm4, %xmm2
; SSE41-NEXT:    por %xmm3, %xmm2
; SSE41-NEXT:    por %xmm0, %xmm2
; SSE41-NEXT:    ptest {{.*}}(%rip), %xmm2
; SSE41-NEXT:    sete %al
; SSE41-NEXT:    retq
;
; AVX1-LABEL: mask_v128i8:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vorps %ymm3, %ymm1, %ymm1
; AVX1-NEXT:    vorps %ymm1, %ymm2, %ymm1
; AVX1-NEXT:    vorps %ymm1, %ymm0, %ymm0
; AVX1-NEXT:    vptest {{.*}}(%rip), %ymm0
; AVX1-NEXT:    sete %al
; AVX1-NEXT:    vzeroupper
; AVX1-NEXT:    retq
;
; AVX2-LABEL: mask_v128i8:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpor %ymm3, %ymm1, %ymm1
; AVX2-NEXT:    vpor %ymm1, %ymm2, %ymm1
; AVX2-NEXT:    vpor %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    vpbroadcastq {{.*#+}} ymm1 = [72340172838076673,72340172838076673,72340172838076673,72340172838076673]
; AVX2-NEXT:    vptest %ymm1, %ymm0
; AVX2-NEXT:    sete %al
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    retq
;
; AVX512-LABEL: mask_v128i8:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vporq %zmm1, %zmm0, %zmm0
; AVX512-NEXT:    vextracti64x4 $1, %zmm0, %ymm1
; AVX512-NEXT:    vpor %ymm1, %ymm0, %ymm0
; AVX512-NEXT:    vpbroadcastq {{.*#+}} ymm1 = [72340172838076673,72340172838076673,72340172838076673,72340172838076673]
; AVX512-NEXT:    vptest %ymm1, %ymm0
; AVX512-NEXT:    sete %al
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
  %1 = call i8 @llvm.experimental.vector.reduce.or.v128i8(<128 x i8> %a0)
  %2 = and i8 %1, 1
  %3 = icmp eq i8 %2, 0
  ret i1 %3
}

%struct.Box = type { i32, i32, i32, i32 }
define zeroext i1 @PR44781(%struct.Box* %0) {
; SSE2-LABEL: PR44781:
; SSE2:       # %bb.0:
; SSE2-NEXT:    movdqu (%rdi), %xmm0
; SSE2-NEXT:    pand {{.*}}(%rip), %xmm0
; SSE2-NEXT:    pxor %xmm1, %xmm1
; SSE2-NEXT:    pcmpeqb %xmm0, %xmm1
; SSE2-NEXT:    pmovmskb %xmm1, %eax
; SSE2-NEXT:    cmpl $65535, %eax # imm = 0xFFFF
; SSE2-NEXT:    sete %al
; SSE2-NEXT:    retq
;
; SSE41-LABEL: PR44781:
; SSE41:       # %bb.0:
; SSE41-NEXT:    movdqu (%rdi), %xmm0
; SSE41-NEXT:    ptest {{.*}}(%rip), %xmm0
; SSE41-NEXT:    sete %al
; SSE41-NEXT:    retq
;
; AVX-LABEL: PR44781:
; AVX:       # %bb.0:
; AVX-NEXT:    vmovdqu (%rdi), %xmm0
; AVX-NEXT:    vptest {{.*}}(%rip), %xmm0
; AVX-NEXT:    sete %al
; AVX-NEXT:    retq
  %2 = bitcast %struct.Box* %0 to <4 x i32>*
  %3 = load <4 x i32>, <4 x i32>* %2, align 4
  %4 = call i32 @llvm.experimental.vector.reduce.or.v4i32(<4 x i32> %3)
  %5 = and i32 %4, 15
  %6 = icmp eq i32 %5, 0
  ret i1 %6
}

declare i64 @llvm.experimental.vector.reduce.or.v2i64(<2 x i64>)
declare i64 @llvm.experimental.vector.reduce.or.v4i64(<4 x i64>)
declare i64 @llvm.experimental.vector.reduce.or.v8i64(<8 x i64>)
declare i64 @llvm.experimental.vector.reduce.or.v16i64(<16 x i64>)

declare i32 @llvm.experimental.vector.reduce.or.v2i32(<2 x i32>)
declare i32 @llvm.experimental.vector.reduce.or.v4i32(<4 x i32>)
declare i32 @llvm.experimental.vector.reduce.or.v8i32(<8 x i32>)
declare i32 @llvm.experimental.vector.reduce.or.v16i32(<16 x i32>)
declare i32 @llvm.experimental.vector.reduce.or.v32i32(<32 x i32>)

declare i16 @llvm.experimental.vector.reduce.or.v2i16(<2 x i16>)
declare i16 @llvm.experimental.vector.reduce.or.v4i16(<4 x i16>)
declare i16 @llvm.experimental.vector.reduce.or.v8i16(<8 x i16>)
declare i16 @llvm.experimental.vector.reduce.or.v16i16(<16 x i16>)
declare i16 @llvm.experimental.vector.reduce.or.v32i16(<32 x i16>)
declare i16 @llvm.experimental.vector.reduce.or.v64i16(<64 x i16>)

declare i8 @llvm.experimental.vector.reduce.or.v2i8(<2 x i8>)
declare i8 @llvm.experimental.vector.reduce.or.v4i8(<4 x i8>)
declare i8 @llvm.experimental.vector.reduce.or.v8i8(<8 x i8>)
declare i8 @llvm.experimental.vector.reduce.or.v16i8(<16 x i8>)
declare i8 @llvm.experimental.vector.reduce.or.v32i8(<32 x i8>)
declare i8 @llvm.experimental.vector.reduce.or.v64i8(<64 x i8>)
declare i8 @llvm.experimental.vector.reduce.or.v128i8(<128 x i8>)

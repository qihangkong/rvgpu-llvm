; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -fast-isel -mtriple=i386-unknown-unknown -mattr=+avx512f,+avx512vl | FileCheck %s --check-prefix=ALL --check-prefix=X32
; RUN: llc < %s -fast-isel -mtriple=x86_64-unknown-unknown -mattr=+avx512f,+avx512vl | FileCheck %s --check-prefix=ALL --check-prefix=X64

; NOTE: This should use IR equivalent to what is generated by clang/test/CodeGen/avx512vl-builtins.c

define <2 x double> @test_mm_movddup_pd(<2 x double> %a0) {
; X32-LABEL: test_mm_movddup_pd:
; X32:       # BB#0:
; X32-NEXT:    vmovddup {{.*#+}} xmm0 = xmm0[0,0]
; X32-NEXT:    retl
;
; X64-LABEL: test_mm_movddup_pd:
; X64:       # BB#0:
; X64-NEXT:    vmovddup {{.*#+}} xmm0 = xmm0[0,0]
; X64-NEXT:    retq
  %res = shufflevector <2 x double> %a0, <2 x double> undef, <2 x i32> zeroinitializer
  ret <2 x double> %res
}

define <2 x double> @test_mm_mask_movddup_pd(<2 x double> %a0, i8 %a1, <2 x double> %a2) {
; X32-LABEL: test_mm_mask_movddup_pd:
; X32:       # BB#0:
; X32-NEXT:    pushl %eax
; X32-NEXT:  .Ltmp0:
; X32-NEXT:    .cfi_def_cfa_offset 8
; X32-NEXT:    movb {{[0-9]+}}(%esp), %al
; X32-NEXT:    andb $3, %al
; X32-NEXT:    movb %al, {{[0-9]+}}(%esp)
; X32-NEXT:    movzbl {{[0-9]+}}(%esp), %eax
; X32-NEXT:    kmovw %eax, %k1
; X32-NEXT:    vmovddup {{.*#+}} xmm0 {%k1} = xmm1[0,0]
; X32-NEXT:    popl %eax
; X32-NEXT:    retl
;
; X64-LABEL: test_mm_mask_movddup_pd:
; X64:       # BB#0:
; X64-NEXT:    andb $3, %dil
; X64-NEXT:    movb %dil, -{{[0-9]+}}(%rsp)
; X64-NEXT:    movzbl -{{[0-9]+}}(%rsp), %eax
; X64-NEXT:    kmovw %eax, %k1
; X64-NEXT:    vmovddup {{.*#+}} xmm0 {%k1} = xmm1[0,0]
; X64-NEXT:    retq
  %trn1 = trunc i8 %a1 to i2
  %arg1 = bitcast i2 %trn1 to <2 x i1>
  %res0 = shufflevector <2 x double> %a2, <2 x double> undef, <2 x i32> zeroinitializer
  %res1 = select <2 x i1> %arg1, <2 x double> %res0, <2 x double> %a0
  ret <2 x double> %res1
}

define <2 x double> @test_mm_maskz_movddup_pd(i8 %a0, <2 x double> %a1) {
; X32-LABEL: test_mm_maskz_movddup_pd:
; X32:       # BB#0:
; X32-NEXT:    pushl %eax
; X32-NEXT:  .Ltmp1:
; X32-NEXT:    .cfi_def_cfa_offset 8
; X32-NEXT:    movb {{[0-9]+}}(%esp), %al
; X32-NEXT:    andb $3, %al
; X32-NEXT:    movb %al, {{[0-9]+}}(%esp)
; X32-NEXT:    movzbl {{[0-9]+}}(%esp), %eax
; X32-NEXT:    kmovw %eax, %k1
; X32-NEXT:    vmovddup {{.*#+}} xmm0 {%k1} {z} = xmm0[0,0]
; X32-NEXT:    popl %eax
; X32-NEXT:    retl
;
; X64-LABEL: test_mm_maskz_movddup_pd:
; X64:       # BB#0:
; X64-NEXT:    andb $3, %dil
; X64-NEXT:    movb %dil, -{{[0-9]+}}(%rsp)
; X64-NEXT:    movzbl -{{[0-9]+}}(%rsp), %eax
; X64-NEXT:    kmovw %eax, %k1
; X64-NEXT:    vmovddup {{.*#+}} xmm0 {%k1} {z} = xmm0[0,0]
; X64-NEXT:    retq
  %trn1 = trunc i8 %a0 to i2
  %arg0 = bitcast i2 %trn1 to <2 x i1>
  %res0 = shufflevector <2 x double> %a1, <2 x double> undef, <2 x i32> zeroinitializer
  %res1 = select <2 x i1> %arg0, <2 x double> %res0, <2 x double> zeroinitializer
  ret <2 x double> %res1
}

define <4 x double> @test_mm256_movddup_pd(<4 x double> %a0) {
; X32-LABEL: test_mm256_movddup_pd:
; X32:       # BB#0:
; X32-NEXT:    vmovddup {{.*#+}} ymm0 = ymm0[0,0,2,2]
; X32-NEXT:    retl
;
; X64-LABEL: test_mm256_movddup_pd:
; X64:       # BB#0:
; X64-NEXT:    vmovddup {{.*#+}} ymm0 = ymm0[0,0,2,2]
; X64-NEXT:    retq
  %res = shufflevector <4 x double> %a0, <4 x double> undef, <4 x i32> <i32 0, i32 0, i32 2, i32 2>
  ret <4 x double> %res
}

define <4 x double> @test_mm256_mask_movddup_pd(<4 x double> %a0, i8 %a1, <4 x double> %a2) {
; X32-LABEL: test_mm256_mask_movddup_pd:
; X32:       # BB#0:
; X32-NEXT:    pushl %eax
; X32-NEXT:  .Ltmp2:
; X32-NEXT:    .cfi_def_cfa_offset 8
; X32-NEXT:    movb {{[0-9]+}}(%esp), %al
; X32-NEXT:    andb $15, %al
; X32-NEXT:    movb %al, (%esp)
; X32-NEXT:    movzbl (%esp), %eax
; X32-NEXT:    kmovw %eax, %k1
; X32-NEXT:    vmovddup {{.*#+}} ymm0 {%k1} = ymm1[0,0,2,2]
; X32-NEXT:    popl %eax
; X32-NEXT:    retl
;
; X64-LABEL: test_mm256_mask_movddup_pd:
; X64:       # BB#0:
; X64-NEXT:    andb $15, %dil
; X64-NEXT:    movb %dil, -{{[0-9]+}}(%rsp)
; X64-NEXT:    movzbl -{{[0-9]+}}(%rsp), %eax
; X64-NEXT:    kmovw %eax, %k1
; X64-NEXT:    vmovddup {{.*#+}} ymm0 {%k1} = ymm1[0,0,2,2]
; X64-NEXT:    retq
  %trn1 = trunc i8 %a1 to i4
  %arg1 = bitcast i4 %trn1 to <4 x i1>
  %res0 = shufflevector <4 x double> %a2, <4 x double> undef, <4 x i32> <i32 0, i32 0, i32 2, i32 2>
  %res1 = select <4 x i1> %arg1, <4 x double> %res0, <4 x double> %a0
  ret <4 x double> %res1
}

define <4 x double> @test_mm256_maskz_movddup_pd(i8 %a0, <4 x double> %a1) {
; X32-LABEL: test_mm256_maskz_movddup_pd:
; X32:       # BB#0:
; X32-NEXT:    pushl %eax
; X32-NEXT:  .Ltmp3:
; X32-NEXT:    .cfi_def_cfa_offset 8
; X32-NEXT:    movb {{[0-9]+}}(%esp), %al
; X32-NEXT:    andb $15, %al
; X32-NEXT:    movb %al, (%esp)
; X32-NEXT:    movzbl (%esp), %eax
; X32-NEXT:    kmovw %eax, %k1
; X32-NEXT:    vmovddup {{.*#+}} ymm0 {%k1} {z} = ymm0[0,0,2,2]
; X32-NEXT:    popl %eax
; X32-NEXT:    retl
;
; X64-LABEL: test_mm256_maskz_movddup_pd:
; X64:       # BB#0:
; X64-NEXT:    andb $15, %dil
; X64-NEXT:    movb %dil, -{{[0-9]+}}(%rsp)
; X64-NEXT:    movzbl -{{[0-9]+}}(%rsp), %eax
; X64-NEXT:    kmovw %eax, %k1
; X64-NEXT:    vmovddup {{.*#+}} ymm0 {%k1} {z} = ymm0[0,0,2,2]
; X64-NEXT:    retq
  %trn1 = trunc i8 %a0 to i4
  %arg0 = bitcast i4 %trn1 to <4 x i1>
  %res0 = shufflevector <4 x double> %a1, <4 x double> undef, <4 x i32> <i32 0, i32 0, i32 2, i32 2>
  %res1 = select <4 x i1> %arg0, <4 x double> %res0, <4 x double> zeroinitializer
  ret <4 x double> %res1
}

define <4 x float> @test_mm_movehdup_ps(<4 x float> %a0) {
; X32-LABEL: test_mm_movehdup_ps:
; X32:       # BB#0:
; X32-NEXT:    vmovshdup {{.*#+}} xmm0 = xmm0[1,1,3,3]
; X32-NEXT:    retl
;
; X64-LABEL: test_mm_movehdup_ps:
; X64:       # BB#0:
; X64-NEXT:    vmovshdup {{.*#+}} xmm0 = xmm0[1,1,3,3]
; X64-NEXT:    retq
  %res = shufflevector <4 x float> %a0, <4 x float> undef, <4 x i32> <i32 1, i32 1, i32 3, i32 3>
  ret <4 x float> %res
}

define <4 x float> @test_mm_mask_movehdup_ps(<4 x float> %a0, i8 %a1, <4 x float> %a2) {
; X32-LABEL: test_mm_mask_movehdup_ps:
; X32:       # BB#0:
; X32-NEXT:    pushl %eax
; X32-NEXT:  .Ltmp4:
; X32-NEXT:    .cfi_def_cfa_offset 8
; X32-NEXT:    movb {{[0-9]+}}(%esp), %al
; X32-NEXT:    andb $15, %al
; X32-NEXT:    movb %al, (%esp)
; X32-NEXT:    movzbl (%esp), %eax
; X32-NEXT:    kmovw %eax, %k1
; X32-NEXT:    vmovshdup {{.*#+}} xmm0 {%k1} = xmm1[1,1,3,3]
; X32-NEXT:    popl %eax
; X32-NEXT:    retl
;
; X64-LABEL: test_mm_mask_movehdup_ps:
; X64:       # BB#0:
; X64-NEXT:    andb $15, %dil
; X64-NEXT:    movb %dil, -{{[0-9]+}}(%rsp)
; X64-NEXT:    movzbl -{{[0-9]+}}(%rsp), %eax
; X64-NEXT:    kmovw %eax, %k1
; X64-NEXT:    vmovshdup {{.*#+}} xmm0 {%k1} = xmm1[1,1,3,3]
; X64-NEXT:    retq
  %trn1 = trunc i8 %a1 to i4
  %arg1 = bitcast i4 %trn1 to <4 x i1>
  %res0 = shufflevector <4 x float> %a2, <4 x float> undef, <4 x i32> <i32 1, i32 1, i32 3, i32 3>
  %res1 = select <4 x i1> %arg1, <4 x float> %res0, <4 x float> %a0
  ret <4 x float> %res1
}

define <4 x float> @test_mm_maskz_movehdup_ps(i8 %a0, <4 x float> %a1) {
; X32-LABEL: test_mm_maskz_movehdup_ps:
; X32:       # BB#0:
; X32-NEXT:    pushl %eax
; X32-NEXT:  .Ltmp5:
; X32-NEXT:    .cfi_def_cfa_offset 8
; X32-NEXT:    movb {{[0-9]+}}(%esp), %al
; X32-NEXT:    andb $15, %al
; X32-NEXT:    movb %al, (%esp)
; X32-NEXT:    movzbl (%esp), %eax
; X32-NEXT:    kmovw %eax, %k1
; X32-NEXT:    vmovshdup {{.*#+}} xmm0 {%k1} {z} = xmm0[1,1,3,3]
; X32-NEXT:    popl %eax
; X32-NEXT:    retl
;
; X64-LABEL: test_mm_maskz_movehdup_ps:
; X64:       # BB#0:
; X64-NEXT:    andb $15, %dil
; X64-NEXT:    movb %dil, -{{[0-9]+}}(%rsp)
; X64-NEXT:    movzbl -{{[0-9]+}}(%rsp), %eax
; X64-NEXT:    kmovw %eax, %k1
; X64-NEXT:    vmovshdup {{.*#+}} xmm0 {%k1} {z} = xmm0[1,1,3,3]
; X64-NEXT:    retq
  %trn0 = trunc i8 %a0 to i4
  %arg0 = bitcast i4 %trn0 to <4 x i1>
  %res0 = shufflevector <4 x float> %a1, <4 x float> undef, <4 x i32> <i32 1, i32 1, i32 3, i32 3>
  %res1 = select <4 x i1> %arg0, <4 x float> %res0, <4 x float> zeroinitializer
  ret <4 x float> %res1
}

define <8 x float> @test_mm256_movehdup_ps(<8 x float> %a0) {
; X32-LABEL: test_mm256_movehdup_ps:
; X32:       # BB#0:
; X32-NEXT:    vmovshdup {{.*#+}} ymm0 = ymm0[1,1,3,3,5,5,7,7]
; X32-NEXT:    retl
;
; X64-LABEL: test_mm256_movehdup_ps:
; X64:       # BB#0:
; X64-NEXT:    vmovshdup {{.*#+}} ymm0 = ymm0[1,1,3,3,5,5,7,7]
; X64-NEXT:    retq
  %res = shufflevector <8 x float> %a0, <8 x float> undef, <8 x i32> <i32 1, i32 1, i32 3, i32 3, i32 5, i32 5, i32 7, i32 7>
  ret <8 x float> %res
}

define <8 x float> @test_mm256_mask_movehdup_ps(<8 x float> %a0, i8 %a1, <8 x float> %a2) {
; X32-LABEL: test_mm256_mask_movehdup_ps:
; X32:       # BB#0:
; X32-NEXT:    movb {{[0-9]+}}(%esp), %al
; X32-NEXT:    kmovw %eax, %k1
; X32-NEXT:    vmovshdup {{.*#+}} ymm0 {%k1} = ymm1[1,1,3,3,5,5,7,7]
; X32-NEXT:    retl
;
; X64-LABEL: test_mm256_mask_movehdup_ps:
; X64:       # BB#0:
; X64-NEXT:    kmovw %edi, %k1
; X64-NEXT:    vmovshdup {{.*#+}} ymm0 {%k1} = ymm1[1,1,3,3,5,5,7,7]
; X64-NEXT:    retq
  %arg1 = bitcast i8 %a1 to <8 x i1>
  %res0 = shufflevector <8 x float> %a2, <8 x float> undef, <8 x i32> <i32 1, i32 1, i32 3, i32 3, i32 5, i32 5, i32 7, i32 7>
  %res1 = select <8 x i1> %arg1, <8 x float> %res0, <8 x float> %a0
  ret <8 x float> %res1
}

define <8 x float> @test_mm256_maskz_movehdup_ps(i8 %a0, <8 x float> %a1) {
; X32-LABEL: test_mm256_maskz_movehdup_ps:
; X32:       # BB#0:
; X32-NEXT:    movb {{[0-9]+}}(%esp), %al
; X32-NEXT:    kmovw %eax, %k1
; X32-NEXT:    vmovshdup {{.*#+}} ymm0 {%k1} {z} = ymm0[1,1,3,3,5,5,7,7]
; X32-NEXT:    retl
;
; X64-LABEL: test_mm256_maskz_movehdup_ps:
; X64:       # BB#0:
; X64-NEXT:    kmovw %edi, %k1
; X64-NEXT:    vmovshdup {{.*#+}} ymm0 {%k1} {z} = ymm0[1,1,3,3,5,5,7,7]
; X64-NEXT:    retq
  %arg0 = bitcast i8 %a0 to <8 x i1>
  %res0 = shufflevector <8 x float> %a1, <8 x float> undef, <8 x i32> <i32 1, i32 1, i32 3, i32 3, i32 5, i32 5, i32 7, i32 7>
  %res1 = select <8 x i1> %arg0, <8 x float> %res0, <8 x float> zeroinitializer
  ret <8 x float> %res1
}

define <4 x float> @test_mm_moveldup_ps(<4 x float> %a0) {
; X32-LABEL: test_mm_moveldup_ps:
; X32:       # BB#0:
; X32-NEXT:    vmovsldup {{.*#+}} xmm0 = xmm0[0,0,2,2]
; X32-NEXT:    retl
;
; X64-LABEL: test_mm_moveldup_ps:
; X64:       # BB#0:
; X64-NEXT:    vmovsldup {{.*#+}} xmm0 = xmm0[0,0,2,2]
; X64-NEXT:    retq
  %res = shufflevector <4 x float> %a0, <4 x float> undef, <4 x i32> <i32 0, i32 0, i32 2, i32 2>
  ret <4 x float> %res
}

define <4 x float> @test_mm_mask_moveldup_ps(<4 x float> %a0, i8 %a1, <4 x float> %a2) {
; X32-LABEL: test_mm_mask_moveldup_ps:
; X32:       # BB#0:
; X32-NEXT:    pushl %eax
; X32-NEXT:  .Ltmp6:
; X32-NEXT:    .cfi_def_cfa_offset 8
; X32-NEXT:    movb {{[0-9]+}}(%esp), %al
; X32-NEXT:    andb $15, %al
; X32-NEXT:    movb %al, (%esp)
; X32-NEXT:    movzbl (%esp), %eax
; X32-NEXT:    kmovw %eax, %k1
; X32-NEXT:    vmovsldup {{.*#+}} xmm0 {%k1} = xmm1[0,0,2,2]
; X32-NEXT:    popl %eax
; X32-NEXT:    retl
;
; X64-LABEL: test_mm_mask_moveldup_ps:
; X64:       # BB#0:
; X64-NEXT:    andb $15, %dil
; X64-NEXT:    movb %dil, -{{[0-9]+}}(%rsp)
; X64-NEXT:    movzbl -{{[0-9]+}}(%rsp), %eax
; X64-NEXT:    kmovw %eax, %k1
; X64-NEXT:    vmovsldup {{.*#+}} xmm0 {%k1} = xmm1[0,0,2,2]
; X64-NEXT:    retq
  %trn1 = trunc i8 %a1 to i4
  %arg1 = bitcast i4 %trn1 to <4 x i1>
  %res0 = shufflevector <4 x float> %a2, <4 x float> undef, <4 x i32> <i32 0, i32 0, i32 2, i32 2>
  %res1 = select <4 x i1> %arg1, <4 x float> %res0, <4 x float> %a0
  ret <4 x float> %res1
}

define <4 x float> @test_mm_maskz_moveldup_ps(i8 %a0, <4 x float> %a1) {
; X32-LABEL: test_mm_maskz_moveldup_ps:
; X32:       # BB#0:
; X32-NEXT:    pushl %eax
; X32-NEXT:  .Ltmp7:
; X32-NEXT:    .cfi_def_cfa_offset 8
; X32-NEXT:    movb {{[0-9]+}}(%esp), %al
; X32-NEXT:    andb $15, %al
; X32-NEXT:    movb %al, (%esp)
; X32-NEXT:    movzbl (%esp), %eax
; X32-NEXT:    kmovw %eax, %k1
; X32-NEXT:    vmovsldup {{.*#+}} xmm0 {%k1} {z} = xmm0[0,0,2,2]
; X32-NEXT:    popl %eax
; X32-NEXT:    retl
;
; X64-LABEL: test_mm_maskz_moveldup_ps:
; X64:       # BB#0:
; X64-NEXT:    andb $15, %dil
; X64-NEXT:    movb %dil, -{{[0-9]+}}(%rsp)
; X64-NEXT:    movzbl -{{[0-9]+}}(%rsp), %eax
; X64-NEXT:    kmovw %eax, %k1
; X64-NEXT:    vmovsldup {{.*#+}} xmm0 {%k1} {z} = xmm0[0,0,2,2]
; X64-NEXT:    retq
  %trn0 = trunc i8 %a0 to i4
  %arg0 = bitcast i4 %trn0 to <4 x i1>
  %res0 = shufflevector <4 x float> %a1, <4 x float> undef, <4 x i32> <i32 0, i32 0, i32 2, i32 2>
  %res1 = select <4 x i1> %arg0, <4 x float> %res0, <4 x float> zeroinitializer
  ret <4 x float> %res1
}

define <8 x float> @test_mm256_moveldup_ps(<8 x float> %a0) {
; X32-LABEL: test_mm256_moveldup_ps:
; X32:       # BB#0:
; X32-NEXT:    vmovsldup {{.*#+}} ymm0 = ymm0[0,0,2,2,4,4,6,6]
; X32-NEXT:    retl
;
; X64-LABEL: test_mm256_moveldup_ps:
; X64:       # BB#0:
; X64-NEXT:    vmovsldup {{.*#+}} ymm0 = ymm0[0,0,2,2,4,4,6,6]
; X64-NEXT:    retq
  %res = shufflevector <8 x float> %a0, <8 x float> undef, <8 x i32> <i32 0, i32 0, i32 2, i32 2, i32 4, i32 4, i32 6, i32 6>
  ret <8 x float> %res
}

define <8 x float> @test_mm256_mask_moveldup_ps(<8 x float> %a0, i8 %a1, <8 x float> %a2) {
; X32-LABEL: test_mm256_mask_moveldup_ps:
; X32:       # BB#0:
; X32-NEXT:    movb {{[0-9]+}}(%esp), %al
; X32-NEXT:    kmovw %eax, %k1
; X32-NEXT:    vmovsldup {{.*#+}} ymm0 {%k1} = ymm1[0,0,2,2,4,4,6,6]
; X32-NEXT:    retl
;
; X64-LABEL: test_mm256_mask_moveldup_ps:
; X64:       # BB#0:
; X64-NEXT:    kmovw %edi, %k1
; X64-NEXT:    vmovsldup {{.*#+}} ymm0 {%k1} = ymm1[0,0,2,2,4,4,6,6]
; X64-NEXT:    retq
  %arg1 = bitcast i8 %a1 to <8 x i1>
  %res0 = shufflevector <8 x float> %a2, <8 x float> undef, <8 x i32> <i32 0, i32 0, i32 2, i32 2, i32 4, i32 4, i32 6, i32 6>
  %res1 = select <8 x i1> %arg1, <8 x float> %res0, <8 x float> %a0
  ret <8 x float> %res1
}

define <8 x float> @test_mm256_maskz_moveldup_ps(i8 %a0, <8 x float> %a1) {
; X32-LABEL: test_mm256_maskz_moveldup_ps:
; X32:       # BB#0:
; X32-NEXT:    movb {{[0-9]+}}(%esp), %al
; X32-NEXT:    kmovw %eax, %k1
; X32-NEXT:    vmovsldup {{.*#+}} ymm0 {%k1} {z} = ymm0[0,0,2,2,4,4,6,6]
; X32-NEXT:    retl
;
; X64-LABEL: test_mm256_maskz_moveldup_ps:
; X64:       # BB#0:
; X64-NEXT:    kmovw %edi, %k1
; X64-NEXT:    vmovsldup {{.*#+}} ymm0 {%k1} {z} = ymm0[0,0,2,2,4,4,6,6]
; X64-NEXT:    retq
  %arg0 = bitcast i8 %a0 to <8 x i1>
  %res0 = shufflevector <8 x float> %a1, <8 x float> undef, <8 x i32> <i32 0, i32 0, i32 2, i32 2, i32 4, i32 4, i32 6, i32 6>
  %res1 = select <8 x i1> %arg0, <8 x float> %res0, <8 x float> zeroinitializer
  ret <8 x float> %res1
}

define <4 x i64> @test_mm256_permutex_epi64(<4 x i64> %a0) {
; X32-LABEL: test_mm256_permutex_epi64:
; X32:       # BB#0:
; X32-NEXT:    vpermq {{.*#+}} ymm0 = ymm0[3,0,0,0]
; X32-NEXT:    retl
;
; X64-LABEL: test_mm256_permutex_epi64:
; X64:       # BB#0:
; X64-NEXT:    vpermq {{.*#+}} ymm0 = ymm0[3,0,0,0]
; X64-NEXT:    retq
  %res = shufflevector <4 x i64> %a0, <4 x i64> undef, <4 x i32> <i32 3, i32 0, i32 0, i32 0>
  ret <4 x i64> %res
}

define <4 x i64> @test_mm256_mask_permutex_epi64(<4 x i64> %a0, i8 %a1, <4 x i64> %a2) {
; X32-LABEL: test_mm256_mask_permutex_epi64:
; X32:       # BB#0:
; X32-NEXT:    pushl %eax
; X32-NEXT:  .Ltmp8:
; X32-NEXT:    .cfi_def_cfa_offset 8
; X32-NEXT:    movb {{[0-9]+}}(%esp), %al
; X32-NEXT:    andb $15, %al
; X32-NEXT:    movb %al, (%esp)
; X32-NEXT:    movzbl (%esp), %eax
; X32-NEXT:    kmovw %eax, %k1
; X32-NEXT:    vpermq {{.*#+}} ymm0 {%k1} = ymm1[1,0,0,0]
; X32-NEXT:    popl %eax
; X32-NEXT:    retl
;
; X64-LABEL: test_mm256_mask_permutex_epi64:
; X64:       # BB#0:
; X64-NEXT:    andb $15, %dil
; X64-NEXT:    movb %dil, -{{[0-9]+}}(%rsp)
; X64-NEXT:    movzbl -{{[0-9]+}}(%rsp), %eax
; X64-NEXT:    kmovw %eax, %k1
; X64-NEXT:    vpermq {{.*#+}} ymm0 {%k1} = ymm1[1,0,0,0]
; X64-NEXT:    retq
  %trn1 = trunc i8 %a1 to i4
  %arg1 = bitcast i4 %trn1 to <4 x i1>
  %res0 = shufflevector <4 x i64> %a2, <4 x i64> undef, <4 x i32> <i32 1, i32 0, i32 0, i32 0>
  %res1 = select <4 x i1> %arg1, <4 x i64> %res0, <4 x i64> %a0
  ret <4 x i64> %res1
}

define <4 x i64> @test_mm256_maskz_permutex_epi64(i8 %a0, <4 x i64> %a1) {
; X32-LABEL: test_mm256_maskz_permutex_epi64:
; X32:       # BB#0:
; X32-NEXT:    pushl %eax
; X32-NEXT:  .Ltmp9:
; X32-NEXT:    .cfi_def_cfa_offset 8
; X32-NEXT:    movb {{[0-9]+}}(%esp), %al
; X32-NEXT:    andb $15, %al
; X32-NEXT:    movb %al, (%esp)
; X32-NEXT:    movzbl (%esp), %eax
; X32-NEXT:    kmovw %eax, %k1
; X32-NEXT:    vpermq {{.*#+}} ymm0 {%k1} {z} = ymm0[1,0,0,0]
; X32-NEXT:    popl %eax
; X32-NEXT:    retl
;
; X64-LABEL: test_mm256_maskz_permutex_epi64:
; X64:       # BB#0:
; X64-NEXT:    andb $15, %dil
; X64-NEXT:    movb %dil, -{{[0-9]+}}(%rsp)
; X64-NEXT:    movzbl -{{[0-9]+}}(%rsp), %eax
; X64-NEXT:    kmovw %eax, %k1
; X64-NEXT:    vpermq {{.*#+}} ymm0 {%k1} {z} = ymm0[1,0,0,0]
; X64-NEXT:    retq
  %trn1 = trunc i8 %a0 to i4
  %arg0 = bitcast i4 %trn1 to <4 x i1>
  %res0 = shufflevector <4 x i64> %a1, <4 x i64> undef, <4 x i32> <i32 1, i32 0, i32 0, i32 0>
  %res1 = select <4 x i1> %arg0, <4 x i64> %res0, <4 x i64> zeroinitializer
  ret <4 x i64> %res1
}

define <4 x double> @test_mm256_permutex_pd(<4 x double> %a0) {
; X32-LABEL: test_mm256_permutex_pd:
; X32:       # BB#0:
; X32-NEXT:    vpermpd {{.*#+}} ymm0 = ymm0[3,0,0,0]
; X32-NEXT:    retl
;
; X64-LABEL: test_mm256_permutex_pd:
; X64:       # BB#0:
; X64-NEXT:    vpermpd {{.*#+}} ymm0 = ymm0[3,0,0,0]
; X64-NEXT:    retq
  %res = shufflevector <4 x double> %a0, <4 x double> undef, <4 x i32> <i32 3, i32 0, i32 0, i32 0>
  ret <4 x double> %res
}

define <4 x double> @test_mm256_mask_permutex_pd(<4 x double> %a0, i8 %a1, <4 x double> %a2) {
; X32-LABEL: test_mm256_mask_permutex_pd:
; X32:       # BB#0:
; X32-NEXT:    pushl %eax
; X32-NEXT:  .Ltmp10:
; X32-NEXT:    .cfi_def_cfa_offset 8
; X32-NEXT:    movb {{[0-9]+}}(%esp), %al
; X32-NEXT:    andb $15, %al
; X32-NEXT:    movb %al, (%esp)
; X32-NEXT:    movzbl (%esp), %eax
; X32-NEXT:    kmovw %eax, %k1
; X32-NEXT:    vpermpd {{.*#+}} ymm0 {%k1} = ymm1[1,0,0,0]
; X32-NEXT:    popl %eax
; X32-NEXT:    retl
;
; X64-LABEL: test_mm256_mask_permutex_pd:
; X64:       # BB#0:
; X64-NEXT:    andb $15, %dil
; X64-NEXT:    movb %dil, -{{[0-9]+}}(%rsp)
; X64-NEXT:    movzbl -{{[0-9]+}}(%rsp), %eax
; X64-NEXT:    kmovw %eax, %k1
; X64-NEXT:    vpermpd {{.*#+}} ymm0 {%k1} = ymm1[1,0,0,0]
; X64-NEXT:    retq
  %trn1 = trunc i8 %a1 to i4
  %arg1 = bitcast i4 %trn1 to <4 x i1>
  %res0 = shufflevector <4 x double> %a2, <4 x double> undef, <4 x i32> <i32 1, i32 0, i32 0, i32 0>
  %res1 = select <4 x i1> %arg1, <4 x double> %res0, <4 x double> %a0
  ret <4 x double> %res1
}

define <4 x double> @test_mm256_maskz_permutex_pd(i8 %a0, <4 x double> %a1) {
; X32-LABEL: test_mm256_maskz_permutex_pd:
; X32:       # BB#0:
; X32-NEXT:    pushl %eax
; X32-NEXT:  .Ltmp11:
; X32-NEXT:    .cfi_def_cfa_offset 8
; X32-NEXT:    movb {{[0-9]+}}(%esp), %al
; X32-NEXT:    andb $15, %al
; X32-NEXT:    movb %al, (%esp)
; X32-NEXT:    movzbl (%esp), %eax
; X32-NEXT:    kmovw %eax, %k1
; X32-NEXT:    vpermpd {{.*#+}} ymm0 {%k1} {z} = ymm0[1,0,0,0]
; X32-NEXT:    popl %eax
; X32-NEXT:    retl
;
; X64-LABEL: test_mm256_maskz_permutex_pd:
; X64:       # BB#0:
; X64-NEXT:    andb $15, %dil
; X64-NEXT:    movb %dil, -{{[0-9]+}}(%rsp)
; X64-NEXT:    movzbl -{{[0-9]+}}(%rsp), %eax
; X64-NEXT:    kmovw %eax, %k1
; X64-NEXT:    vpermpd {{.*#+}} ymm0 {%k1} {z} = ymm0[1,0,0,0]
; X64-NEXT:    retq
  %trn1 = trunc i8 %a0 to i4
  %arg0 = bitcast i4 %trn1 to <4 x i1>
  %res0 = shufflevector <4 x double> %a1, <4 x double> undef, <4 x i32> <i32 1, i32 0, i32 0, i32 0>
  %res1 = select <4 x i1> %arg0, <4 x double> %res0, <4 x double> zeroinitializer
  ret <4 x double> %res1
}

!0 = !{i32 1}

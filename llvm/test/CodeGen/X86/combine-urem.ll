; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+sse4.1 | FileCheck %s --check-prefix=SSE
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx  | FileCheck %s --check-prefix=AVX --check-prefix=AVX1
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx2 | FileCheck %s --check-prefix=AVX --check-prefix=AVX2

; fold (urem undef, x) -> 0
define <4 x i32> @combine_vec_urem_undef0(<4 x i32> %x) {
; SSE-LABEL: combine_vec_urem_undef0:
; SSE:       # BB#0:
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_vec_urem_undef0:
; AVX:       # BB#0:
; AVX-NEXT:    retq
  %1 = urem <4 x i32> undef, %x
  ret <4 x i32> %1
}

; fold (urem x, undef) -> undef
define <4 x i32> @combine_vec_urem_undef1(<4 x i32> %x) {
; SSE-LABEL: combine_vec_urem_undef1:
; SSE:       # BB#0:
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_vec_urem_undef1:
; AVX:       # BB#0:
; AVX-NEXT:    retq
  %1 = urem <4 x i32> %x, undef
  ret <4 x i32> %1
}

; fold (urem x, pow2) -> (and x, (pow2-1))
define <4 x i32> @combine_vec_urem_by_pow2a(<4 x i32> %x) {
; SSE-LABEL: combine_vec_urem_by_pow2a:
; SSE:       # BB#0:
; SSE-NEXT:    andps {{.*}}(%rip), %xmm0
; SSE-NEXT:    retq
;
; AVX1-LABEL: combine_vec_urem_by_pow2a:
; AVX1:       # BB#0:
; AVX1-NEXT:    vandps {{.*}}(%rip), %xmm0, %xmm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: combine_vec_urem_by_pow2a:
; AVX2:       # BB#0:
; AVX2-NEXT:    vbroadcastss {{.*#+}} xmm1 = [3,3,3,3]
; AVX2-NEXT:    vandps %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    retq
  %1 = urem <4 x i32> %x, <i32 4, i32 4, i32 4, i32 4>
  ret <4 x i32> %1
}

define <4 x i32> @combine_vec_urem_by_pow2b(<4 x i32> %x) {
; SSE-LABEL: combine_vec_urem_by_pow2b:
; SSE:       # BB#0:
; SSE-NEXT:    andps {{.*}}(%rip), %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_vec_urem_by_pow2b:
; AVX:       # BB#0:
; AVX-NEXT:    vandps {{.*}}(%rip), %xmm0, %xmm0
; AVX-NEXT:    retq
  %1 = urem <4 x i32> %x, <i32 1, i32 4, i32 8, i32 16>
  ret <4 x i32> %1
}

define <4 x i32> @combine_vec_urem_by_pow2c(<4 x i32> %x, <4 x i32> %y) {
; SSE-LABEL: combine_vec_urem_by_pow2c:
; SSE:       # BB#0:
; SSE-NEXT:    pslld $23, %xmm1
; SSE-NEXT:    paddd {{.*}}(%rip), %xmm1
; SSE-NEXT:    cvttps2dq %xmm1, %xmm1
; SSE-NEXT:    pcmpeqd %xmm2, %xmm2
; SSE-NEXT:    paddd %xmm1, %xmm2
; SSE-NEXT:    pand %xmm2, %xmm0
; SSE-NEXT:    retq
;
; AVX1-LABEL: combine_vec_urem_by_pow2c:
; AVX1:       # BB#0:
; AVX1-NEXT:    vpslld $23, %xmm1, %xmm1
; AVX1-NEXT:    vpaddd {{.*}}(%rip), %xmm1, %xmm1
; AVX1-NEXT:    vcvttps2dq %xmm1, %xmm1
; AVX1-NEXT:    vpcmpeqd %xmm2, %xmm2, %xmm2
; AVX1-NEXT:    vpaddd %xmm2, %xmm1, %xmm1
; AVX1-NEXT:    vpand %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: combine_vec_urem_by_pow2c:
; AVX2:       # BB#0:
; AVX2-NEXT:    vpbroadcastd {{.*#+}} xmm2 = [1,1,1,1]
; AVX2-NEXT:    vpsllvd %xmm1, %xmm2, %xmm1
; AVX2-NEXT:    vpcmpeqd %xmm2, %xmm2, %xmm2
; AVX2-NEXT:    vpaddd %xmm2, %xmm1, %xmm1
; AVX2-NEXT:    vpand %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    retq
  %1 = shl <4 x i32> <i32 1, i32 1, i32 1, i32 1>, %y
  %2 = urem <4 x i32> %x, %1
  ret <4 x i32> %2
}

define <4 x i32> @combine_vec_urem_by_pow2d(<4 x i32> %x, <4 x i32> %y) {
; SSE-LABEL: combine_vec_urem_by_pow2d:
; SSE:       # BB#0:
; SSE-NEXT:    movdqa %xmm1, %xmm2
; SSE-NEXT:    psrldq {{.*#+}} xmm2 = xmm2[12,13,14,15],zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero
; SSE-NEXT:    movdqa {{.*#+}} xmm3 = [2147483648,2147483648,2147483648,2147483648]
; SSE-NEXT:    movdqa %xmm3, %xmm4
; SSE-NEXT:    psrld %xmm2, %xmm4
; SSE-NEXT:    movdqa %xmm1, %xmm2
; SSE-NEXT:    psrlq $32, %xmm2
; SSE-NEXT:    movdqa %xmm3, %xmm5
; SSE-NEXT:    psrld %xmm2, %xmm5
; SSE-NEXT:    pblendw {{.*#+}} xmm5 = xmm5[0,1,2,3],xmm4[4,5,6,7]
; SSE-NEXT:    pxor %xmm2, %xmm2
; SSE-NEXT:    pmovzxdq {{.*#+}} xmm4 = xmm1[0],zero,xmm1[1],zero
; SSE-NEXT:    punpckhdq {{.*#+}} xmm1 = xmm1[2],xmm2[2],xmm1[3],xmm2[3]
; SSE-NEXT:    movdqa %xmm3, %xmm2
; SSE-NEXT:    psrld %xmm1, %xmm2
; SSE-NEXT:    psrld %xmm4, %xmm3
; SSE-NEXT:    pblendw {{.*#+}} xmm3 = xmm3[0,1,2,3],xmm2[4,5,6,7]
; SSE-NEXT:    pblendw {{.*#+}} xmm3 = xmm3[0,1],xmm5[2,3],xmm3[4,5],xmm5[6,7]
; SSE-NEXT:    pcmpeqd %xmm1, %xmm1
; SSE-NEXT:    paddd %xmm3, %xmm1
; SSE-NEXT:    pand %xmm1, %xmm0
; SSE-NEXT:    retq
;
; AVX1-LABEL: combine_vec_urem_by_pow2d:
; AVX1:       # BB#0:
; AVX1-NEXT:    vpsrldq {{.*#+}} xmm2 = xmm1[12,13,14,15],zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm3 = [2147483648,2147483648,2147483648,2147483648]
; AVX1-NEXT:    vpsrld %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpsrlq $32, %xmm1, %xmm4
; AVX1-NEXT:    vpsrld %xmm4, %xmm3, %xmm4
; AVX1-NEXT:    vpblendw {{.*#+}} xmm2 = xmm4[0,1,2,3],xmm2[4,5,6,7]
; AVX1-NEXT:    vpxor %xmm4, %xmm4, %xmm4
; AVX1-NEXT:    vpunpckhdq {{.*#+}} xmm4 = xmm1[2],xmm4[2],xmm1[3],xmm4[3]
; AVX1-NEXT:    vpsrld %xmm4, %xmm3, %xmm4
; AVX1-NEXT:    vpmovzxdq {{.*#+}} xmm1 = xmm1[0],zero,xmm1[1],zero
; AVX1-NEXT:    vpsrld %xmm1, %xmm3, %xmm1
; AVX1-NEXT:    vpblendw {{.*#+}} xmm1 = xmm1[0,1,2,3],xmm4[4,5,6,7]
; AVX1-NEXT:    vpblendw {{.*#+}} xmm1 = xmm1[0,1],xmm2[2,3],xmm1[4,5],xmm2[6,7]
; AVX1-NEXT:    vpcmpeqd %xmm2, %xmm2, %xmm2
; AVX1-NEXT:    vpaddd %xmm2, %xmm1, %xmm1
; AVX1-NEXT:    vpand %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: combine_vec_urem_by_pow2d:
; AVX2:       # BB#0:
; AVX2-NEXT:    vpbroadcastd {{.*#+}} xmm2 = [2147483648,2147483648,2147483648,2147483648]
; AVX2-NEXT:    vpsrlvd %xmm1, %xmm2, %xmm1
; AVX2-NEXT:    vpcmpeqd %xmm2, %xmm2, %xmm2
; AVX2-NEXT:    vpaddd %xmm2, %xmm1, %xmm1
; AVX2-NEXT:    vpand %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    retq
  %1 = lshr <4 x i32> <i32 -2147483648, i32 -2147483648, i32 -2147483648, i32 -2147483648>, %y
  %2 = urem <4 x i32> %x, %1
  ret <4 x i32> %2
}

; fold (urem x, (shl pow2, y)) -> (and x, (add (shl pow2, y), -1))
define <4 x i32> @combine_vec_urem_by_shl_pow2a(<4 x i32> %x, <4 x i32> %y) {
; SSE-LABEL: combine_vec_urem_by_shl_pow2a:
; SSE:       # BB#0:
; SSE-NEXT:    pslld $23, %xmm1
; SSE-NEXT:    paddd {{.*}}(%rip), %xmm1
; SSE-NEXT:    cvttps2dq %xmm1, %xmm1
; SSE-NEXT:    pslld $2, %xmm1
; SSE-NEXT:    pcmpeqd %xmm2, %xmm2
; SSE-NEXT:    paddd %xmm1, %xmm2
; SSE-NEXT:    pand %xmm2, %xmm0
; SSE-NEXT:    retq
;
; AVX1-LABEL: combine_vec_urem_by_shl_pow2a:
; AVX1:       # BB#0:
; AVX1-NEXT:    vpslld $23, %xmm1, %xmm1
; AVX1-NEXT:    vpaddd {{.*}}(%rip), %xmm1, %xmm1
; AVX1-NEXT:    vcvttps2dq %xmm1, %xmm1
; AVX1-NEXT:    vpslld $2, %xmm1, %xmm1
; AVX1-NEXT:    vpcmpeqd %xmm2, %xmm2, %xmm2
; AVX1-NEXT:    vpaddd %xmm2, %xmm1, %xmm1
; AVX1-NEXT:    vpand %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: combine_vec_urem_by_shl_pow2a:
; AVX2:       # BB#0:
; AVX2-NEXT:    vpbroadcastd {{.*#+}} xmm2 = [4,4,4,4]
; AVX2-NEXT:    vpsllvd %xmm1, %xmm2, %xmm1
; AVX2-NEXT:    vpcmpeqd %xmm2, %xmm2, %xmm2
; AVX2-NEXT:    vpaddd %xmm2, %xmm1, %xmm1
; AVX2-NEXT:    vpand %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    retq
  %1 = shl <4 x i32> <i32 4, i32 4, i32 4, i32 4>, %y
  %2 = urem <4 x i32> %x, %1
  ret <4 x i32> %2
}

define <4 x i32> @combine_vec_urem_by_shl_pow2b(<4 x i32> %x, <4 x i32> %y) {
; SSE-LABEL: combine_vec_urem_by_shl_pow2b:
; SSE:       # BB#0:
; SSE-NEXT:    pslld $23, %xmm1
; SSE-NEXT:    paddd {{.*}}(%rip), %xmm1
; SSE-NEXT:    cvttps2dq %xmm1, %xmm1
; SSE-NEXT:    pmulld {{.*}}(%rip), %xmm1
; SSE-NEXT:    pcmpeqd %xmm2, %xmm2
; SSE-NEXT:    paddd %xmm1, %xmm2
; SSE-NEXT:    pand %xmm2, %xmm0
; SSE-NEXT:    retq
;
; AVX1-LABEL: combine_vec_urem_by_shl_pow2b:
; AVX1:       # BB#0:
; AVX1-NEXT:    vpslld $23, %xmm1, %xmm1
; AVX1-NEXT:    vpaddd {{.*}}(%rip), %xmm1, %xmm1
; AVX1-NEXT:    vcvttps2dq %xmm1, %xmm1
; AVX1-NEXT:    vpmulld {{.*}}(%rip), %xmm1, %xmm1
; AVX1-NEXT:    vpcmpeqd %xmm2, %xmm2, %xmm2
; AVX1-NEXT:    vpaddd %xmm2, %xmm1, %xmm1
; AVX1-NEXT:    vpand %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: combine_vec_urem_by_shl_pow2b:
; AVX2:       # BB#0:
; AVX2-NEXT:    vmovdqa {{.*#+}} xmm2 = [1,4,8,16]
; AVX2-NEXT:    vpsllvd %xmm1, %xmm2, %xmm1
; AVX2-NEXT:    vpcmpeqd %xmm2, %xmm2, %xmm2
; AVX2-NEXT:    vpaddd %xmm2, %xmm1, %xmm1
; AVX2-NEXT:    vpand %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    retq
  %1 = shl <4 x i32> <i32 1, i32 4, i32 8, i32 16>, %y
  %2 = urem <4 x i32> %x, %1
  ret <4 x i32> %2
}

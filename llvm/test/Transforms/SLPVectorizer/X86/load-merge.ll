; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -slp-vectorizer -slp-vectorize-hor -slp-vectorize-hor-store -S < %s -mtriple=x86_64-apple-macosx -mcpu=haswell | FileCheck %s

;unsigned load_le32(unsigned char *data) {
;    unsigned le32 = (data[0]<<0) | (data[1]<<8) | (data[2]<<16) | (data[3]<<24);
;    return le32;
;}

define i32 @_Z9load_le32Ph(i8* nocapture readonly %data) {
; CHECK-LABEL: @_Z9load_le32Ph(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP0:%.*]] = load i8, i8* [[DATA:%.*]], align 1
; CHECK-NEXT:    [[CONV:%.*]] = zext i8 [[TMP0]] to i32
; CHECK-NEXT:    [[ARRAYIDX1:%.*]] = getelementptr inbounds i8, i8* [[DATA]], i64 1
; CHECK-NEXT:    [[TMP1:%.*]] = load i8, i8* [[ARRAYIDX1]], align 1
; CHECK-NEXT:    [[CONV2:%.*]] = zext i8 [[TMP1]] to i32
; CHECK-NEXT:    [[SHL3:%.*]] = shl nuw nsw i32 [[CONV2]], 8
; CHECK-NEXT:    [[OR:%.*]] = or i32 [[SHL3]], [[CONV]]
; CHECK-NEXT:    [[ARRAYIDX4:%.*]] = getelementptr inbounds i8, i8* [[DATA]], i64 2
; CHECK-NEXT:    [[TMP2:%.*]] = load i8, i8* [[ARRAYIDX4]], align 1
; CHECK-NEXT:    [[CONV5:%.*]] = zext i8 [[TMP2]] to i32
; CHECK-NEXT:    [[SHL6:%.*]] = shl nuw nsw i32 [[CONV5]], 16
; CHECK-NEXT:    [[OR7:%.*]] = or i32 [[OR]], [[SHL6]]
; CHECK-NEXT:    [[ARRAYIDX8:%.*]] = getelementptr inbounds i8, i8* [[DATA]], i64 3
; CHECK-NEXT:    [[TMP3:%.*]] = load i8, i8* [[ARRAYIDX8]], align 1
; CHECK-NEXT:    [[CONV9:%.*]] = zext i8 [[TMP3]] to i32
; CHECK-NEXT:    [[SHL10:%.*]] = shl nuw i32 [[CONV9]], 24
; CHECK-NEXT:    [[OR11:%.*]] = or i32 [[OR7]], [[SHL10]]
; CHECK-NEXT:    ret i32 [[OR11]]
;
entry:
  %0 = load i8, i8* %data, align 1
  %conv = zext i8 %0 to i32
  %arrayidx1 = getelementptr inbounds i8, i8* %data, i64 1
  %1 = load i8, i8* %arrayidx1, align 1
  %conv2 = zext i8 %1 to i32
  %shl3 = shl nuw nsw i32 %conv2, 8
  %or = or i32 %shl3, %conv
  %arrayidx4 = getelementptr inbounds i8, i8* %data, i64 2
  %2 = load i8, i8* %arrayidx4, align 1
  %conv5 = zext i8 %2 to i32
  %shl6 = shl nuw nsw i32 %conv5, 16
  %or7 = or i32 %or, %shl6
  %arrayidx8 = getelementptr inbounds i8, i8* %data, i64 3
  %3 = load i8, i8* %arrayidx8, align 1
  %conv9 = zext i8 %3 to i32
  %shl10 = shl nuw i32 %conv9, 24
  %or11 = or i32 %or7, %shl10
  ret i32 %or11
}

define <4 x float> @PR16739_byref(<4 x float>* nocapture readonly dereferenceable(16) %x) {
; CHECK-LABEL: @PR16739_byref(
; CHECK-NEXT:    [[GEP0:%.*]] = getelementptr inbounds <4 x float>, <4 x float>* [[X:%.*]], i64 0, i64 0
; CHECK-NEXT:    [[GEP1:%.*]] = getelementptr inbounds <4 x float>, <4 x float>* [[X]], i64 0, i64 1
; CHECK-NEXT:    [[GEP2:%.*]] = getelementptr inbounds <4 x float>, <4 x float>* [[X]], i64 0, i64 2
; CHECK-NEXT:    [[TMP1:%.*]] = bitcast float* [[GEP0]] to <2 x float>*
; CHECK-NEXT:    [[TMP2:%.*]] = load <2 x float>, <2 x float>* [[TMP1]], align 4
; CHECK-NEXT:    [[X2:%.*]] = load float, float* [[GEP2]], align 4
; CHECK-NEXT:    [[TMP3:%.*]] = extractelement <2 x float> [[TMP2]], i32 0
; CHECK-NEXT:    [[I0:%.*]] = insertelement <4 x float> undef, float [[TMP3]], i32 0
; CHECK-NEXT:    [[TMP4:%.*]] = extractelement <2 x float> [[TMP2]], i32 1
; CHECK-NEXT:    [[I1:%.*]] = insertelement <4 x float> [[I0]], float [[TMP4]], i32 1
; CHECK-NEXT:    [[I2:%.*]] = insertelement <4 x float> [[I1]], float [[X2]], i32 2
; CHECK-NEXT:    [[I3:%.*]] = insertelement <4 x float> [[I2]], float [[X2]], i32 3
; CHECK-NEXT:    ret <4 x float> [[I3]]
;
  %gep0 = getelementptr inbounds <4 x float>, <4 x float>* %x, i64 0, i64 0
  %gep1 = getelementptr inbounds <4 x float>, <4 x float>* %x, i64 0, i64 1
  %gep2 = getelementptr inbounds <4 x float>, <4 x float>* %x, i64 0, i64 2
  %x0 = load float, float* %gep0
  %x1 = load float, float* %gep1
  %x2 = load float, float* %gep2
  %i0 = insertelement <4 x float> undef, float %x0, i32 0
  %i1 = insertelement <4 x float> %i0, float %x1, i32 1
  %i2 = insertelement <4 x float> %i1, float %x2, i32 2
  %i3 = insertelement <4 x float> %i2, float %x2, i32 3
  ret <4 x float> %i3
}

define <4 x float> @PR16739_byref_alt(<4 x float>* nocapture readonly dereferenceable(16) %x) {
; CHECK-LABEL: @PR16739_byref_alt(
; CHECK-NEXT:    [[GEP0:%.*]] = getelementptr inbounds <4 x float>, <4 x float>* [[X:%.*]], i64 0, i64 0
; CHECK-NEXT:    [[GEP1:%.*]] = getelementptr inbounds <4 x float>, <4 x float>* [[X]], i64 0, i64 1
; CHECK-NEXT:    [[TMP1:%.*]] = bitcast float* [[GEP0]] to <2 x float>*
; CHECK-NEXT:    [[TMP2:%.*]] = load <2 x float>, <2 x float>* [[TMP1]], align 4
; CHECK-NEXT:    [[SHUFFLE:%.*]] = shufflevector <2 x float> [[TMP2]], <2 x float> undef, <4 x i32> <i32 0, i32 0, i32 1, i32 1>
; CHECK-NEXT:    [[TMP3:%.*]] = extractelement <4 x float> [[SHUFFLE]], i32 0
; CHECK-NEXT:    [[I0:%.*]] = insertelement <4 x float> undef, float [[TMP3]], i32 0
; CHECK-NEXT:    [[I1:%.*]] = insertelement <4 x float> [[I0]], float [[TMP3]], i32 1
; CHECK-NEXT:    [[TMP4:%.*]] = extractelement <4 x float> [[SHUFFLE]], i32 2
; CHECK-NEXT:    [[I2:%.*]] = insertelement <4 x float> [[I1]], float [[TMP4]], i32 2
; CHECK-NEXT:    [[I3:%.*]] = insertelement <4 x float> [[I2]], float [[TMP4]], i32 3
; CHECK-NEXT:    ret <4 x float> [[I3]]
;
  %gep0 = getelementptr inbounds <4 x float>, <4 x float>* %x, i64 0, i64 0
  %gep1 = getelementptr inbounds <4 x float>, <4 x float>* %x, i64 0, i64 1
  %x0 = load float, float* %gep0
  %x1 = load float, float* %gep1
  %i0 = insertelement <4 x float> undef, float %x0, i32 0
  %i1 = insertelement <4 x float> %i0, float %x0, i32 1
  %i2 = insertelement <4 x float> %i1, float %x1, i32 2
  %i3 = insertelement <4 x float> %i2, float %x1, i32 3
  ret <4 x float> %i3
}

define <4 x float> @PR16739_byval(<4 x float>* nocapture readonly dereferenceable(16) %x) {
; CHECK-LABEL: @PR16739_byval(
; CHECK-NEXT:    [[T0:%.*]] = bitcast <4 x float>* [[X:%.*]] to i64*
; CHECK-NEXT:    [[T1:%.*]] = load i64, i64* [[T0]], align 16
; CHECK-NEXT:    [[T2:%.*]] = getelementptr inbounds <4 x float>, <4 x float>* [[X]], i64 0, i64 2
; CHECK-NEXT:    [[T3:%.*]] = bitcast float* [[T2]] to i64*
; CHECK-NEXT:    [[T4:%.*]] = load i64, i64* [[T3]], align 8
; CHECK-NEXT:    [[T5:%.*]] = trunc i64 [[T1]] to i32
; CHECK-NEXT:    [[T6:%.*]] = bitcast i32 [[T5]] to float
; CHECK-NEXT:    [[T7:%.*]] = insertelement <4 x float> undef, float [[T6]], i32 0
; CHECK-NEXT:    [[T8:%.*]] = lshr i64 [[T1]], 32
; CHECK-NEXT:    [[T9:%.*]] = trunc i64 [[T8]] to i32
; CHECK-NEXT:    [[T10:%.*]] = bitcast i32 [[T9]] to float
; CHECK-NEXT:    [[T11:%.*]] = insertelement <4 x float> [[T7]], float [[T10]], i32 1
; CHECK-NEXT:    [[T12:%.*]] = trunc i64 [[T4]] to i32
; CHECK-NEXT:    [[T13:%.*]] = bitcast i32 [[T12]] to float
; CHECK-NEXT:    [[T14:%.*]] = insertelement <4 x float> [[T11]], float [[T13]], i32 2
; CHECK-NEXT:    [[T15:%.*]] = insertelement <4 x float> [[T14]], float [[T13]], i32 3
; CHECK-NEXT:    ret <4 x float> [[T15]]
;
  %t0 = bitcast <4 x float>* %x to i64*
  %t1 = load i64, i64* %t0, align 16
  %t2 = getelementptr inbounds <4 x float>, <4 x float>* %x, i64 0, i64 2
  %t3 = bitcast float* %t2 to i64*
  %t4 = load i64, i64* %t3, align 8
  %t5 = trunc i64 %t1 to i32
  %t6 = bitcast i32 %t5 to float
  %t7 = insertelement <4 x float> undef, float %t6, i32 0
  %t8 = lshr i64 %t1, 32
  %t9 = trunc i64 %t8 to i32
  %t10 = bitcast i32 %t9 to float
  %t11 = insertelement <4 x float> %t7, float %t10, i32 1
  %t12 = trunc i64 %t4 to i32
  %t13 = bitcast i32 %t12 to float
  %t14 = insertelement <4 x float> %t11, float %t13, i32 2
  %t15 = insertelement <4 x float> %t14, float %t13, i32 3
  ret <4 x float> %t15
}

define void @PR43578_prefer128(i32* %r, i64* %p, i64* %q) #0 {
; CHECK-LABEL: @PR43578_prefer128(
; CHECK-NEXT:    [[P0:%.*]] = getelementptr inbounds i64, i64* [[P:%.*]], i64 0
; CHECK-NEXT:    [[P1:%.*]] = getelementptr inbounds i64, i64* [[P]], i64 1
; CHECK-NEXT:    [[P2:%.*]] = getelementptr inbounds i64, i64* [[P]], i64 2
; CHECK-NEXT:    [[P3:%.*]] = getelementptr inbounds i64, i64* [[P]], i64 3
; CHECK-NEXT:    [[Q0:%.*]] = getelementptr inbounds i64, i64* [[Q:%.*]], i64 0
; CHECK-NEXT:    [[Q1:%.*]] = getelementptr inbounds i64, i64* [[Q]], i64 1
; CHECK-NEXT:    [[Q2:%.*]] = getelementptr inbounds i64, i64* [[Q]], i64 2
; CHECK-NEXT:    [[Q3:%.*]] = getelementptr inbounds i64, i64* [[Q]], i64 3
; CHECK-NEXT:    [[TMP1:%.*]] = bitcast i64* [[P0]] to <2 x i64>*
; CHECK-NEXT:    [[TMP2:%.*]] = load <2 x i64>, <2 x i64>* [[TMP1]], align 2
; CHECK-NEXT:    [[TMP3:%.*]] = bitcast i64* [[P2]] to <2 x i64>*
; CHECK-NEXT:    [[TMP4:%.*]] = load <2 x i64>, <2 x i64>* [[TMP3]], align 2
; CHECK-NEXT:    [[TMP5:%.*]] = bitcast i64* [[Q0]] to <2 x i64>*
; CHECK-NEXT:    [[TMP6:%.*]] = load <2 x i64>, <2 x i64>* [[TMP5]], align 2
; CHECK-NEXT:    [[TMP7:%.*]] = bitcast i64* [[Q2]] to <2 x i64>*
; CHECK-NEXT:    [[TMP8:%.*]] = load <2 x i64>, <2 x i64>* [[TMP7]], align 2
; CHECK-NEXT:    [[TMP9:%.*]] = sub nsw <2 x i64> [[TMP2]], [[TMP6]]
; CHECK-NEXT:    [[TMP10:%.*]] = sub nsw <2 x i64> [[TMP4]], [[TMP8]]
; CHECK-NEXT:    [[TMP11:%.*]] = extractelement <2 x i64> [[TMP9]], i32 0
; CHECK-NEXT:    [[G0:%.*]] = getelementptr inbounds i32, i32* [[R:%.*]], i64 [[TMP11]]
; CHECK-NEXT:    [[TMP12:%.*]] = extractelement <2 x i64> [[TMP9]], i32 1
; CHECK-NEXT:    [[G1:%.*]] = getelementptr inbounds i32, i32* [[R]], i64 [[TMP12]]
; CHECK-NEXT:    [[TMP13:%.*]] = extractelement <2 x i64> [[TMP10]], i32 0
; CHECK-NEXT:    [[G2:%.*]] = getelementptr inbounds i32, i32* [[R]], i64 [[TMP13]]
; CHECK-NEXT:    [[TMP14:%.*]] = extractelement <2 x i64> [[TMP10]], i32 1
; CHECK-NEXT:    [[G3:%.*]] = getelementptr inbounds i32, i32* [[R]], i64 [[TMP14]]
; CHECK-NEXT:    ret void
;
  %p0 = getelementptr inbounds i64, i64* %p, i64 0
  %p1 = getelementptr inbounds i64, i64* %p, i64 1
  %p2 = getelementptr inbounds i64, i64* %p, i64 2
  %p3 = getelementptr inbounds i64, i64* %p, i64 3

  %q0 = getelementptr inbounds i64, i64* %q, i64 0
  %q1 = getelementptr inbounds i64, i64* %q, i64 1
  %q2 = getelementptr inbounds i64, i64* %q, i64 2
  %q3 = getelementptr inbounds i64, i64* %q, i64 3

  %x0 = load i64, i64* %p0, align 2
  %x1 = load i64, i64* %p1, align 2
  %x2 = load i64, i64* %p2, align 2
  %x3 = load i64, i64* %p3, align 2

  %y0 = load i64, i64* %q0, align 2
  %y1 = load i64, i64* %q1, align 2
  %y2 = load i64, i64* %q2, align 2
  %y3 = load i64, i64* %q3, align 2

  %sub0 = sub nsw i64 %x0, %y0
  %sub1 = sub nsw i64 %x1, %y1
  %sub2 = sub nsw i64 %x2, %y2
  %sub3 = sub nsw i64 %x3, %y3

  %g0 = getelementptr inbounds i32, i32* %r, i64 %sub0
  %g1 = getelementptr inbounds i32, i32* %r, i64 %sub1
  %g2 = getelementptr inbounds i32, i32* %r, i64 %sub2
  %g3 = getelementptr inbounds i32, i32* %r, i64 %sub3
  ret void
}

attributes #0 = { "prefer-vector-width"="128" }

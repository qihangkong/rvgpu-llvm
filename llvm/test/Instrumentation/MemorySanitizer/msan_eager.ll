; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -msan-check-access-address=0 -msan-track-origins=1 -msan-eager-checks -S -passes='module(msan-module),function(msan)' 2>&1 | \
; RUN:   FileCheck -allow-deprecated-dag-overlap -check-prefixes=CHECK,CHECK-ORIGINS %s

target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

define noundef i32 @NormalRet() nounwind uwtable sanitize_memory {
; CHECK-LABEL: @NormalRet(
; CHECK-NEXT:    ret i32 123
;
  ret i32 123
}

define i32 @PartialRet() nounwind uwtable sanitize_memory {
; CHECK-LABEL: @PartialRet(
; CHECK-NEXT:    store i32 0, i32* bitcast ([100 x i64]* @__msan_retval_tls to i32*), align 8
; CHECK-NEXT:    store i32 0, i32* @__msan_retval_origin_tls, align 4
; CHECK-NEXT:    ret i32 123
;
  ret i32 123
}

define noundef i32 @LoadedRet() nounwind uwtable sanitize_memory {
; CHECK-LABEL: @LoadedRet(
; CHECK-NEXT:    [[P:%.*]] = inttoptr i64 0 to i32*
; CHECK-NEXT:    [[O:%.*]] = load i32, i32* [[P]], align 4
; CHECK-NEXT:    [[TMP1:%.*]] = ptrtoint i32* [[P]] to i64
; CHECK-NEXT:    [[TMP2:%.*]] = xor i64 [[TMP1]], 87960930222080
; CHECK-NEXT:    [[TMP3:%.*]] = inttoptr i64 [[TMP2]] to i32*
; CHECK-NEXT:    [[TMP4:%.*]] = add i64 [[TMP2]], 17592186044416
; CHECK-NEXT:    [[TMP5:%.*]] = inttoptr i64 [[TMP4]] to i32*
; CHECK-NEXT:    [[_MSLD:%.*]] = load i32, i32* [[TMP3]], align 4
; CHECK-NEXT:    [[TMP6:%.*]] = load i32, i32* [[TMP5]], align 4
; CHECK-NEXT:    [[_MSCMP:%.*]] = icmp ne i32 [[_MSLD]], 0
; CHECK-NEXT:    br i1 [[_MSCMP]], label [[TMP7:%.*]], label [[TMP8:%.*]], !prof !0
; CHECK:       7:
; CHECK-NEXT:    call void @__msan_warning_with_origin_noreturn(i32 [[TMP6]]) #1
; CHECK-NEXT:    unreachable
; CHECK:       8:
; CHECK-NEXT:    ret i32 [[O]]
;
  %p = inttoptr i64 0 to i32 *
  %o = load i32, i32 *%p
  ret i32 %o
}


define void @NormalArg(i32 noundef %a) nounwind uwtable sanitize_memory {
; CHECK-LABEL: @NormalArg(
; CHECK-NEXT:    [[P:%.*]] = inttoptr i64 0 to i32*
; CHECK-NEXT:    [[TMP1:%.*]] = ptrtoint i32* [[P]] to i64
; CHECK-NEXT:    [[TMP2:%.*]] = xor i64 [[TMP1]], 87960930222080
; CHECK-NEXT:    [[TMP3:%.*]] = inttoptr i64 [[TMP2]] to i32*
; CHECK-NEXT:    [[TMP4:%.*]] = add i64 [[TMP2]], 17592186044416
; CHECK-NEXT:    [[TMP5:%.*]] = inttoptr i64 [[TMP4]] to i32*
; CHECK-NEXT:    store i32 0, i32* [[TMP3]], align 4
; CHECK-NEXT:    store i32 [[A:%.*]], i32* [[P]], align 4
; CHECK-NEXT:    ret void
;
  %p = inttoptr i64 0 to i32 *
  store i32 %a, i32 *%p
  ret void
}

define void @PartialArg(i32 %a) nounwind uwtable sanitize_memory {
; CHECK-LABEL: @PartialArg(
; CHECK-NEXT:    [[TMP1:%.*]] = load i32, i32* bitcast ([100 x i64]* @__msan_param_tls to i32*), align 8
; CHECK-NEXT:    [[TMP2:%.*]] = load i32, i32* getelementptr inbounds ([200 x i32], [200 x i32]* @__msan_param_origin_tls, i32 0, i32 0), align 4
; CHECK-NEXT:    [[P:%.*]] = inttoptr i64 0 to i32*
; CHECK-NEXT:    [[TMP3:%.*]] = ptrtoint i32* [[P]] to i64
; CHECK-NEXT:    [[TMP4:%.*]] = xor i64 [[TMP3]], 87960930222080
; CHECK-NEXT:    [[TMP5:%.*]] = inttoptr i64 [[TMP4]] to i32*
; CHECK-NEXT:    [[TMP6:%.*]] = add i64 [[TMP4]], 17592186044416
; CHECK-NEXT:    [[TMP7:%.*]] = inttoptr i64 [[TMP6]] to i32*
; CHECK-NEXT:    store i32 [[TMP1]], i32* [[TMP5]], align 4
; CHECK-NEXT:    [[_MSCMP:%.*]] = icmp ne i32 [[TMP1]], 0
; CHECK-NEXT:    br i1 [[_MSCMP]], label [[TMP8:%.*]], label [[TMP9:%.*]], !prof !0
; CHECK:       8:
; CHECK-NEXT:    store i32 [[TMP2]], i32* [[TMP7]], align 4
; CHECK-NEXT:    br label [[TMP9]]
; CHECK:       9:
; CHECK-NEXT:    store i32 [[A:%.*]], i32* [[P]], align 4
; CHECK-NEXT:    ret void
;
  %p = inttoptr i64 0 to i32 *
  store i32 %a, i32 *%p
  ret void
}

define void @CallNormal() nounwind uwtable sanitize_memory {
; CHECK-LABEL: @CallNormal(
; CHECK-NEXT:    [[R:%.*]] = call i32 @NormalRet() #0
; CHECK-NEXT:    call void @NormalArg(i32 [[R]]) #0
; CHECK-NEXT:    ret void
;
  %r = call i32 @NormalRet() nounwind uwtable sanitize_memory
  call void @NormalArg(i32 %r) nounwind uwtable sanitize_memory
  ret void
}

define void @CallWithLoaded() nounwind uwtable sanitize_memory {
; CHECK-LABEL: @CallWithLoaded(
; CHECK-NEXT:    [[P:%.*]] = inttoptr i64 0 to i32*
; CHECK-NEXT:    [[O:%.*]] = load i32, i32* [[P]], align 4
; CHECK-NEXT:    [[TMP1:%.*]] = ptrtoint i32* [[P]] to i64
; CHECK-NEXT:    [[TMP2:%.*]] = xor i64 [[TMP1]], 87960930222080
; CHECK-NEXT:    [[TMP3:%.*]] = inttoptr i64 [[TMP2]] to i32*
; CHECK-NEXT:    [[TMP4:%.*]] = add i64 [[TMP2]], 17592186044416
; CHECK-NEXT:    [[TMP5:%.*]] = inttoptr i64 [[TMP4]] to i32*
; CHECK-NEXT:    [[_MSLD:%.*]] = load i32, i32* [[TMP3]], align 4
; CHECK-NEXT:    [[TMP6:%.*]] = load i32, i32* [[TMP5]], align 4
; CHECK-NEXT:    [[_MSCMP:%.*]] = icmp ne i32 [[_MSLD]], 0
; CHECK-NEXT:    br i1 [[_MSCMP]], label [[TMP7:%.*]], label [[TMP8:%.*]], !prof !0
; CHECK:       7:
; CHECK-NEXT:    call void @__msan_warning_with_origin_noreturn(i32 [[TMP6]]) #1
; CHECK-NEXT:    unreachable
; CHECK:       8:
; CHECK-NEXT:    call void @NormalArg(i32 [[O]]) #0
; CHECK-NEXT:    ret void
;
  %p = inttoptr i64 0 to i32 *
  %o = load i32, i32 *%p
  call void @NormalArg(i32 %o) nounwind uwtable sanitize_memory
  ret void
}

define void @CallPartial() nounwind uwtable sanitize_memory {
; CHECK-LABEL: @CallPartial(
; CHECK-NEXT:    store i32 0, i32* bitcast ([100 x i64]* @__msan_retval_tls to i32*), align 8
; CHECK-NEXT:    [[R:%.*]] = call i32 @PartialRet() #0
; CHECK-NEXT:    [[_MSRET:%.*]] = load i32, i32* bitcast ([100 x i64]* @__msan_retval_tls to i32*), align 8
; CHECK-NEXT:    [[TMP1:%.*]] = load i32, i32* @__msan_retval_origin_tls, align 4
; CHECK-NEXT:    store i32 [[_MSRET]], i32* bitcast ([100 x i64]* @__msan_param_tls to i32*), align 8
; CHECK-NEXT:    store i32 [[TMP1]], i32* getelementptr inbounds ([200 x i32], [200 x i32]* @__msan_param_origin_tls, i32 0, i32 0), align 4
; CHECK-NEXT:    call void @PartialArg(i32 [[R]]) #0
; CHECK-NEXT:    ret void
;
  %r = call i32 @PartialRet() nounwind uwtable sanitize_memory
  call void @PartialArg(i32 %r) nounwind uwtable sanitize_memory
  ret void
}

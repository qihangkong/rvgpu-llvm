; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --function-signature --scrub-attributes
; RUN: opt -S -passes='attributor' -aa-pipeline='basic-aa' -attributor-disable=false -attributor-max-iterations-verify -attributor-max-iterations=1 < %s | FileCheck %s

; Unused arguments from variadic functions cannot be eliminated as that changes
; their classiciation according to the SysV amd64 ABI. Clang and other frontends
; bake in the classification when they use things like byval, as in this test.

target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.tt0 = type { i64, i64 }
%struct.__va_list_tag = type { i32, i32, i8*, i8* }

@t45 = internal global %struct.tt0 { i64 1335139741, i64 438042995 }, align 8

; Function Attrs: nounwind uwtable
define i32 @main(i32 %argc, i8** nocapture readnone %argv) #0 {
; CHECK-LABEL: define {{[^@]+}}@main
; CHECK-SAME: (i32 [[ARGC:%.*]], i8** nocapture nofree readnone [[ARGV:%.*]])
; CHECK-NEXT:  entry:
; CHECK-NEXT:    tail call void (i8*, i8*, i8*, i8*, i8*, ...) @callee_t0f(i8* undef, i8* undef, i8* undef, i8* undef, i8* undef, %struct.tt0* nonnull byval align 8 dereferenceable(16) @t45)
; CHECK-NEXT:    ret i32 0
;
entry:
  tail call void (i8*, i8*, i8*, i8*, i8*, ...) @callee_t0f(i8* undef, i8* undef, i8* undef, i8* undef, i8* undef, %struct.tt0* byval align 8 @t45)
  ret i32 0
}

; Function Attrs: nounwind uwtable
define internal void @callee_t0f(i8* nocapture readnone %tp13, i8* nocapture readnone %tp14, i8* nocapture readnone %tp15, i8* nocapture readnone %tp16, i8* nocapture readnone %tp17, ...) {
; CHECK-LABEL: define {{[^@]+}}@callee_t0f
; CHECK-SAME: (i8* nocapture nofree nonnull readnone [[TP13:%.*]], i8* nocapture nofree nonnull readnone [[TP14:%.*]], i8* nocapture nofree nonnull readnone [[TP15:%.*]], i8* nocapture nofree nonnull readnone [[TP16:%.*]], i8* nocapture nofree nonnull readnone [[TP17:%.*]], ...)
; CHECK-NEXT:  entry:
; CHECK-NEXT:    ret void
;
entry:
  ret void
}

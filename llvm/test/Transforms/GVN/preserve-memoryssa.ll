; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt  -aa-pipeline=basic-aa -passes='require<memoryssa>,gvn' -S -verify-memoryssa %s | FileCheck %s

; REQUIRES: asserts

declare void @use(i32) readnone

define i32 @test(i32* %ptr.0, i32** %ptr.1, i1 %c) {
; CHECK-LABEL: @test(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[LV_0:%.*]] = load i32, i32* [[PTR_0:%.*]], align 8
; CHECK-NEXT:    call void @use(i32 [[LV_0]])
; CHECK-NEXT:    br i1 [[C:%.*]], label [[IF_THEN749:%.*]], label [[FOR_INC774:%.*]]
; CHECK:       if.then749:
; CHECK-NEXT:    [[LV_1:%.*]] = load i32*, i32** [[PTR_1:%.*]], align 8
; CHECK-NEXT:    store i32 10, i32* [[LV_1]], align 4
; CHECK-NEXT:    [[LV_2_PRE:%.*]] = load i32, i32* [[PTR_0]], align 8
; CHECK-NEXT:    br label [[FOR_INC774]]
; CHECK:       for.inc774:
; CHECK-NEXT:    [[LV_2:%.*]] = phi i32 [ [[LV_2_PRE]], [[IF_THEN749]] ], [ [[LV_0]], [[ENTRY:%.*]] ]
; CHECK-NEXT:    call void @use(i32 [[LV_2]])
; CHECK-NEXT:    ret i32 1
;
entry:
  br label %for.end435

for.end435:
  %lv.0 = load i32, i32* %ptr.0, align 8
  call void @use(i32 %lv.0)
  br label %if.end724

if.end724:
  br i1 %c, label %if.then749, label %for.inc774

if.then749:
  %lv.1 = load i32*, i32** %ptr.1, align 8
  %arrayidx772 = getelementptr inbounds i32, i32* %lv.1, i64 0
  store i32 10, i32* %arrayidx772, align 4
  br label %for.inc774

for.inc774:
  br label %for.body830

for.body830:
  %lv.2 = load i32, i32* %ptr.0, align 8
  call void @use(i32 %lv.2)
  br label %for.body.i22

for.body.i22:
  ret i32 1
}

define i32 @test_volatile(i32* %ptr.0, i32** %ptr.1, i1 %c) {
; CHECK-LABEL: @test_volatile(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[LV_0:%.*]] = load volatile i32, i32* [[PTR_0:%.*]], align 8
; CHECK-NEXT:    call void @use(i32 [[LV_0]])
; CHECK-NEXT:    br i1 [[C:%.*]], label [[IF_THEN749:%.*]], label [[FOR_INC774:%.*]]
; CHECK:       if.then749:
; CHECK-NEXT:    [[LV_1:%.*]] = load volatile i32*, i32** [[PTR_1:%.*]], align 8
; CHECK-NEXT:    store i32 10, i32* [[LV_1]], align 4
; CHECK-NEXT:    br label [[FOR_INC774]]
; CHECK:       for.inc774:
; CHECK-NEXT:    [[LV_2:%.*]] = load volatile i32, i32* [[PTR_0]], align 8
; CHECK-NEXT:    call void @use(i32 [[LV_2]])
; CHECK-NEXT:    ret i32 1
;
entry:
  br label %for.end435

for.end435:
  %lv.0 = load volatile i32, i32* %ptr.0, align 8
  call void @use(i32 %lv.0)
  br label %if.end724

if.end724:
  br i1 %c, label %if.then749, label %for.inc774

if.then749:
  %lv.1 = load volatile i32*, i32** %ptr.1, align 8
  %arrayidx772 = getelementptr inbounds i32, i32* %lv.1, i64 0
  store i32 10, i32* %arrayidx772, align 4
  br label %for.inc774

for.inc774:
  br label %for.body830

for.body830:
  %lv.2 = load volatile i32, i32* %ptr.0, align 8
  call void @use(i32 %lv.2)
  br label %for.body.i22

for.body.i22:
  ret i32 1
}

define void @test_assume_false_to_store_undef_1(i32* %ptr) {
; CHECK-LABEL: @test_assume_false_to_store_undef_1(
; CHECK-NEXT:    store i32 10, i32* [[PTR:%.*]], align 4
; CHECK-NEXT:    store i8 undef, i8* null, align 1
; CHECK-NEXT:    call void @f()
; CHECK-NEXT:    ret void
;
  store i32 10, i32* %ptr
  %tobool = icmp ne i16 1, 0
  %xor = xor i1 %tobool, true
  call void @llvm.assume(i1 %xor)
  call void @f()
  ret void
}

define i32 @test_assume_false_to_store_undef_2(i32* %ptr, i32* %ptr.2) {
; CHECK-LABEL: @test_assume_false_to_store_undef_2(
; CHECK-NEXT:    store i32 10, i32* [[PTR:%.*]], align 4
; CHECK-NEXT:    [[LV:%.*]] = load i32, i32* [[PTR_2:%.*]], align 4
; CHECK-NEXT:    store i8 undef, i8* null, align 1
; CHECK-NEXT:    call void @f()
; CHECK-NEXT:    ret i32 [[LV]]
;
  store i32 10, i32* %ptr
  %lv = load i32, i32* %ptr.2
  %tobool = icmp ne i16 1, 0
  %xor = xor i1 %tobool, true
  call void @llvm.assume(i1 %xor)
  call void @f()
  ret i32 %lv
}

define i32 @test_assume_false_to_store_undef_3(i32* %ptr, i32* %ptr.2) {
; CHECK-LABEL: @test_assume_false_to_store_undef_3(
; CHECK-NEXT:    store i32 10, i32* [[PTR:%.*]], align 4
; CHECK-NEXT:    [[LV:%.*]] = load i32, i32* [[PTR_2:%.*]], align 4
; CHECK-NEXT:    store i8 undef, i8* null, align 1
; CHECK-NEXT:    ret i32 [[LV]]
;
  store i32 10, i32* %ptr
  %lv = load i32, i32* %ptr.2
  %tobool = icmp ne i16 1, 0
  %xor = xor i1 %tobool, true
  call void @llvm.assume(i1 %xor)
  ret i32 %lv
}

declare void @f()

declare void @llvm.assume(i1 noundef) #0

attributes #0 = { nofree nosync nounwind willreturn }

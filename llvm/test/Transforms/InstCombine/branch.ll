; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -instcombine -S < %s | FileCheck %s
; RUN: opt -passes=instcombine -S < %s | FileCheck %s

; Check that we fold the condition of branches of the
; form: br <condition> dest1, dest2, where dest1 == dest2.
define i32 @test(i32 %x) {
; CHECK-LABEL: @test(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br i1 false, label [[MERGE:%.*]], label [[MERGE]]
; CHECK:       merge:
; CHECK-NEXT:    ret i32 [[X:%.*]]
;
entry:
  %cmp = icmp ult i32 %x, 7
  br i1 %cmp, label %merge, label %merge
merge:
  ret i32 %x
}

@global = global i8 0

define i32 @pat(i32 %x) {
; CHECK-LABEL: @pat(
; CHECK-NEXT:    br i1 false, label [[PATATINO:%.*]], label [[PATATINO]]
; CHECK:       patatino:
; CHECK-NEXT:    ret i32 [[X:%.*]]
;
  %y = icmp eq i32 27, ptrtoint(i8* @global to i32)
  br i1 %y, label %patatino, label %patatino
patatino:
  ret i32 %x
}

define i1 @test01(i1 %cond) {
; CHECK-LABEL: @test01(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br i1 [[COND:%.*]], label [[IF_TRUE_1:%.*]], label [[IF_FALSE_1:%.*]]
; CHECK:       if.true.1:
; CHECK-NEXT:    br label [[MERGE_1:%.*]]
; CHECK:       if.false.1:
; CHECK-NEXT:    br label [[MERGE_1]]
; CHECK:       merge.1:
; CHECK-NEXT:    br i1 [[COND]], label [[IF_TRUE_2:%.*]], label [[IF_FALSE_2:%.*]]
; CHECK:       if.true.2:
; CHECK-NEXT:    br label [[MERGE_2:%.*]]
; CHECK:       if.false.2:
; CHECK-NEXT:    br label [[MERGE_2]]
; CHECK:       merge.2:
; CHECK-NEXT:    ret i1 [[COND]]
;
entry:
  br i1 %cond, label %if.true.1, label %if.false.1

if.true.1:
  br label %merge.1

if.false.1:
  br label  %merge.1

merge.1:
  %merge.cond.1 = phi i1 [true, %if.true.1], [false, %if.false.1]
  br i1 %merge.cond.1, label %if.true.2, label %if.false.2

if.true.2:
  br label %merge.2

if.false.2:
  br label  %merge.2

merge.2:
  %merge.cond.2 = phi i1 [true, %if.true.2], [false, %if.false.2]
  ret i1 %merge.cond.2
}

define i1 @test02(i1 %cond) {
; CHECK-LABEL: @test02(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br i1 [[COND:%.*]], label [[IF_TRUE_1:%.*]], label [[IF_FALSE_1:%.*]]
; CHECK:       if.true.1:
; CHECK-NEXT:    br label [[MERGE_1:%.*]]
; CHECK:       if.false.1:
; CHECK-NEXT:    br label [[MERGE_1]]
; CHECK:       merge.1:
; CHECK-NEXT:    br i1 [[COND]], label [[IF_FALSE_2:%.*]], label [[IF_TRUE_2:%.*]]
; CHECK:       if.true.2:
; CHECK-NEXT:    br label [[MERGE_2:%.*]]
; CHECK:       if.false.2:
; CHECK-NEXT:    br label [[MERGE_2]]
; CHECK:       merge.2:
; CHECK-NEXT:    ret i1 [[COND]]
;
entry:
  br i1 %cond, label %if.true.1, label %if.false.1

if.true.1:
  br label %merge.1

if.false.1:
  br label  %merge.1

merge.1:
  %merge.cond.1 = phi i1 [false, %if.true.1], [true, %if.false.1]
  br i1 %merge.cond.1, label %if.true.2, label %if.false.2

if.true.2:
  br label %merge.2

if.false.2:
  br label  %merge.2

merge.2:
  %merge.cond.2 = phi i1 [false, %if.true.2], [true, %if.false.2]
  ret i1 %merge.cond.2
}

; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -S -ipsccp < %s | FileCheck %s
; RUN: opt -S -passes='ipsccp,function(verify<domtree>)' < %s | FileCheck %s

; DTU should not crash.

define i32 @test() {
; CHECK-LABEL: @test(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[FOR_BODY:%.*]]
; CHECK:       for.body:
; CHECK-NEXT:    br label [[IF_THEN2:%.*]]
; CHECK:       if.then2:
; CHECK-NEXT:    br label [[FOR_INC:%.*]]
; CHECK:       for.inc:
; CHECK-NEXT:    unreachable
;
entry:
  br label %for.body

for.body:                                         ; preds = %entry
  br i1 true, label %if.then2, label %if.else

if.then2:                                         ; preds = %for.body
  br label %for.inc

if.else:                                          ; preds = %for.body
  br i1 undef, label %lor.rhs, label %if.then19.critedge

lor.rhs:                                          ; preds = %if.else
  br i1 undef, label %if.then19, label %for.inc

if.then19.critedge:                               ; preds = %if.else
  br label %if.then19

if.then19:                                        ; preds = %if.then19.critedge, %lor.rhs
  unreachable

for.inc:                                          ; preds = %lor.rhs, %if.then2
  unreachable
}

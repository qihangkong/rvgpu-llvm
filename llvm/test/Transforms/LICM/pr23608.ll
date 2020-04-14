; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -S -licm %s | FileCheck %s --check-prefixes=CHECK,NO_ASSUME
; RUN: opt -S -licm --enable-knowledge-retention %s | FileCheck %s --check-prefixes=CHECK,USE_ASSUME
; ModuleID = '../pr23608.ll'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.PyFrameObject = type { i32 }

@a = common global %struct.PyFrameObject* null, align 8
@__msan_origin_tls = external thread_local(initialexec) global i32

define void @fn1() {
; NO_ASSUME-LABEL: @fn1(
; NO_ASSUME-NEXT:  entry:
; NO_ASSUME-NEXT:    br label [[INDIRECTGOTO:%.*]]
; NO_ASSUME:       while.cond:
; NO_ASSUME-NEXT:    [[TMP:%.*]] = load %struct.PyFrameObject*, %struct.PyFrameObject** @a, align 8
; NO_ASSUME-NEXT:    [[F_IBLOCK:%.*]] = getelementptr inbounds [[STRUCT_PYFRAMEOBJECT:%.*]], %struct.PyFrameObject* [[TMP]], i64 0, i32 0
; NO_ASSUME-NEXT:    br label [[BB2:%.*]]
; NO_ASSUME:       bb:
; NO_ASSUME-NEXT:    call void @__msan_warning_noreturn()
; NO_ASSUME-NEXT:    unreachable
; NO_ASSUME:       bb2:
; NO_ASSUME-NEXT:    [[TMP4:%.*]] = ptrtoint i32* [[F_IBLOCK]] to i64
; NO_ASSUME-NEXT:    [[TOBOOL:%.*]] = icmp eq i64 [[TMP4]], 0
; NO_ASSUME-NEXT:    br i1 [[TOBOOL]], label [[BB13:%.*]], label [[BB15:%.*]]
; NO_ASSUME:       bb13:
; NO_ASSUME-NEXT:    [[F_IBLOCK_LCSSA:%.*]] = phi i32* [ [[F_IBLOCK]], [[BB2]] ]
; NO_ASSUME-NEXT:    [[TMP4_LE:%.*]] = ptrtoint i32* [[F_IBLOCK_LCSSA]] to i64
; NO_ASSUME-NEXT:    [[TMP8_LE:%.*]] = inttoptr i64 [[TMP4_LE]] to i32*
; NO_ASSUME-NEXT:    call void @__msan_warning_noreturn()
; NO_ASSUME-NEXT:    unreachable
; NO_ASSUME:       bb15:
; NO_ASSUME-NEXT:    br i1 [[TOBOOL]], label [[WHILE_END:%.*]], label [[WHILE_COND:%.*]]
; NO_ASSUME:       while.end:
; NO_ASSUME-NEXT:    ret void
; NO_ASSUME:       indirectgoto:
; NO_ASSUME-NEXT:    indirectbr i8* null, [label [[INDIRECTGOTO]], label %while.cond]
;
; USE_ASSUME-LABEL: @fn1(
; USE_ASSUME-NEXT:  entry:
; USE_ASSUME-NEXT:    br label [[INDIRECTGOTO:%.*]]
; USE_ASSUME:       while.cond:
; USE_ASSUME-NEXT:    [[TMP:%.*]] = load %struct.PyFrameObject*, %struct.PyFrameObject** @a, align 8
; USE_ASSUME-NEXT:    call void @llvm.assume(i1 true) [ "align"(i64* inttoptr (i64 and (i64 ptrtoint (%struct.PyFrameObject** @a to i64), i64 -70368744177665) to i64*), i64 8), "dereferenceable"(i64* inttoptr (i64 and (i64 ptrtoint (%struct.PyFrameObject** @a to i64), i64 -70368744177665) to i64*), i64 8), "nonnull"(i64* inttoptr (i64 and (i64 ptrtoint (%struct.PyFrameObject** @a to i64), i64 -70368744177665) to i64*)) ]
; USE_ASSUME-NEXT:    call void @llvm.assume(i1 true) [ "align"(i32* inttoptr (i64 add (i64 and (i64 ptrtoint (%struct.PyFrameObject** @a to i64), i64 -70368744177665), i64 35184372088832) to i32*), i64 8), "dereferenceable"(i32* inttoptr (i64 add (i64 and (i64 ptrtoint (%struct.PyFrameObject** @a to i64), i64 -70368744177665), i64 35184372088832) to i32*), i64 4), "nonnull"(i32* inttoptr (i64 add (i64 and (i64 ptrtoint (%struct.PyFrameObject** @a to i64), i64 -70368744177665), i64 35184372088832) to i32*)) ]
; USE_ASSUME-NEXT:    [[F_IBLOCK:%.*]] = getelementptr inbounds [[STRUCT_PYFRAMEOBJECT:%.*]], %struct.PyFrameObject* [[TMP]], i64 0, i32 0
; USE_ASSUME-NEXT:    br label [[BB2:%.*]]
; USE_ASSUME:       bb:
; USE_ASSUME-NEXT:    call void @__msan_warning_noreturn()
; USE_ASSUME-NEXT:    unreachable
; USE_ASSUME:       bb2:
; USE_ASSUME-NEXT:    call void @llvm.assume(i1 true) [ "align"(i32* [[F_IBLOCK]], i64 4), "dereferenceable"(i32* [[F_IBLOCK]], i64 4), "nonnull"(i32* [[F_IBLOCK]]) ]
; USE_ASSUME-NEXT:    [[TMP4:%.*]] = ptrtoint i32* [[F_IBLOCK]] to i64
; USE_ASSUME-NEXT:    [[TOBOOL:%.*]] = icmp eq i64 [[TMP4]], 0
; USE_ASSUME-NEXT:    br i1 [[TOBOOL]], label [[BB13:%.*]], label [[BB15:%.*]]
; USE_ASSUME:       bb13:
; USE_ASSUME-NEXT:    [[F_IBLOCK_LCSSA:%.*]] = phi i32* [ [[F_IBLOCK]], [[BB2]] ]
; USE_ASSUME-NEXT:    [[TMP4_LE:%.*]] = ptrtoint i32* [[F_IBLOCK_LCSSA]] to i64
; USE_ASSUME-NEXT:    [[TMP8_LE:%.*]] = inttoptr i64 [[TMP4_LE]] to i32*
; USE_ASSUME-NEXT:    call void @__msan_warning_noreturn()
; USE_ASSUME-NEXT:    unreachable
; USE_ASSUME:       bb15:
; USE_ASSUME-NEXT:    br i1 [[TOBOOL]], label [[WHILE_END:%.*]], label [[WHILE_COND:%.*]]
; USE_ASSUME:       while.end:
; USE_ASSUME-NEXT:    ret void
; USE_ASSUME:       indirectgoto:
; USE_ASSUME-NEXT:    indirectbr i8* null, [label [[INDIRECTGOTO]], label %while.cond]
;
entry:
  br label %indirectgoto

while.cond:                                       ; preds = %indirectgoto, %bb15
  %tmp = load %struct.PyFrameObject*, %struct.PyFrameObject** @a, align 8
  %_msld = load i64, i64* inttoptr (i64 and (i64 ptrtoint (%struct.PyFrameObject** @a to i64), i64 -70368744177665) to i64*), align 8
  %tmp1 = load i32, i32* inttoptr (i64 add (i64 and (i64 ptrtoint (%struct.PyFrameObject** @a to i64), i64 -70368744177665), i64 35184372088832) to i32*), align 8
  %f_iblock = getelementptr inbounds %struct.PyFrameObject, %struct.PyFrameObject* %tmp, i64 0, i32 0
  br label %bb2

bb:                                               ; preds = %while.cond
  call void @__msan_warning_noreturn()
  unreachable

bb2:                                              ; preds = %while.cond
  %tmp3 = load i32, i32* %f_iblock, align 4
  %tmp4 = ptrtoint i32* %f_iblock to i64
  %tmp8 = inttoptr i64 %tmp4 to i32*
  %tobool = icmp eq i64 %tmp4, 0
  br i1 %tobool, label %bb13, label %bb15

bb13:                                             ; preds = %bb2
  %.lcssa7 = phi i32* [ %tmp8, %bb2 ]
  call void @__msan_warning_noreturn()
  unreachable

bb15:                                             ; preds = %bb2
  br i1 %tobool, label %while.end, label %while.cond

while.end:                                        ; preds = %bb15
  ret void

indirectgoto:                                     ; preds = %indirectgoto, %entry
  indirectbr i8* null, [label %indirectgoto, label %while.cond]
}

declare void @__msan_warning_noreturn()

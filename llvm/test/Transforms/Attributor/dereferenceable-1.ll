; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --function-signature --scrub-attributes
; RUN: opt -attributor -attributor-manifest-internal  -attributor-max-iterations-verify -attributor-annotate-decl-cs -attributor-max-iterations=12 -S < %s | FileCheck %s --check-prefixes=CHECK,NOT_CGSCC_NPM,NOT_CGSCC_OPM,NOT_TUNIT_NPM,IS__TUNIT____,IS________OPM,IS__TUNIT_OPM
; RUN: opt -aa-pipeline=basic-aa -passes=attributor -attributor-manifest-internal  -attributor-max-iterations-verify -attributor-annotate-decl-cs -attributor-max-iterations=12 -S < %s | FileCheck %s --check-prefixes=CHECK,NOT_CGSCC_OPM,NOT_CGSCC_NPM,NOT_TUNIT_OPM,IS__TUNIT____,IS________NPM,IS__TUNIT_NPM
; RUN: opt -attributor-cgscc -attributor-manifest-internal  -attributor-annotate-decl-cs -S < %s | FileCheck %s --check-prefixes=CHECK,NOT_TUNIT_NPM,NOT_TUNIT_OPM,NOT_CGSCC_NPM,IS__CGSCC____,IS________OPM,IS__CGSCC_OPM
; RUN: opt -aa-pipeline=basic-aa -passes=attributor-cgscc -attributor-manifest-internal  -attributor-annotate-decl-cs -S < %s | FileCheck %s --check-prefixes=CHECK,NOT_TUNIT_NPM,NOT_TUNIT_OPM,NOT_CGSCC_OPM,IS__CGSCC____,IS________NPM,IS__CGSCC_NPM
; FIXME: Figure out why we need 16 iterations here.

declare void @deref_phi_user(i32* %a);

; TEST 1
; take mininimum of return values
;
define i32* @test1(i32* dereferenceable(4) %0, double* dereferenceable(8) %1, i1 zeroext %2) local_unnamed_addr {
; CHECK-LABEL: define {{[^@]+}}@test1
; CHECK-SAME: (i32* nofree nonnull readnone dereferenceable(4) "no-capture-maybe-returned" [[TMP0:%.*]], double* nofree nonnull readnone dereferenceable(8) "no-capture-maybe-returned" [[TMP1:%.*]], i1 zeroext [[TMP2:%.*]]) local_unnamed_addr
; CHECK-NEXT:    [[TMP4:%.*]] = bitcast double* [[TMP1]] to i32*
; CHECK-NEXT:    [[TMP5:%.*]] = select i1 [[TMP2]], i32* [[TMP0]], i32* [[TMP4]]
; CHECK-NEXT:    ret i32* [[TMP5]]
;
  %4 = bitcast double* %1 to i32*
  %5 = select i1 %2, i32* %0, i32* %4
  ret i32* %5
}

; TEST 2
define i32* @test2(i32* dereferenceable_or_null(4) %0, double* dereferenceable(8) %1, i1 zeroext %2) local_unnamed_addr {
; CHECK-LABEL: define {{[^@]+}}@test2
; CHECK-SAME: (i32* nofree readnone dereferenceable_or_null(4) "no-capture-maybe-returned" [[TMP0:%.*]], double* nofree nonnull readnone dereferenceable(8) "no-capture-maybe-returned" [[TMP1:%.*]], i1 zeroext [[TMP2:%.*]]) local_unnamed_addr
; CHECK-NEXT:    [[TMP4:%.*]] = bitcast double* [[TMP1]] to i32*
; CHECK-NEXT:    [[TMP5:%.*]] = select i1 [[TMP2]], i32* [[TMP0]], i32* [[TMP4]]
; CHECK-NEXT:    ret i32* [[TMP5]]
;
  %4 = bitcast double* %1 to i32*
  %5 = select i1 %2, i32* %0, i32* %4
  ret i32* %5
}

; TEST 3
; GEP inbounds
define i32* @test3_1(i32* dereferenceable(8) %0) local_unnamed_addr {
; CHECK-LABEL: define {{[^@]+}}@test3_1
; CHECK-SAME: (i32* nofree nonnull readnone dereferenceable(8) "no-capture-maybe-returned" [[TMP0:%.*]]) local_unnamed_addr
; CHECK-NEXT:    [[RET:%.*]] = getelementptr inbounds i32, i32* [[TMP0]], i64 1
; CHECK-NEXT:    ret i32* [[RET]]
;
  %ret = getelementptr inbounds i32, i32* %0, i64 1
  ret i32* %ret
}

define i32* @test3_2(i32* dereferenceable_or_null(32) %0) local_unnamed_addr {
; CHECK-LABEL: define {{[^@]+}}@test3_2
; CHECK-SAME: (i32* nofree readnone dereferenceable_or_null(32) "no-capture-maybe-returned" [[TMP0:%.*]]) local_unnamed_addr
; CHECK-NEXT:    [[RET:%.*]] = getelementptr inbounds i32, i32* [[TMP0]], i64 4
; CHECK-NEXT:    ret i32* [[RET]]
;
  %ret = getelementptr inbounds i32, i32* %0, i64 4
  ret i32* %ret
}

define i32* @test3_3(i32* dereferenceable(8) %0, i32* dereferenceable(16) %1, i1 %2) local_unnamed_addr {
; CHECK-LABEL: define {{[^@]+}}@test3_3
; CHECK-SAME: (i32* nofree nonnull readnone dereferenceable(8) "no-capture-maybe-returned" [[TMP0:%.*]], i32* nofree nonnull readnone dereferenceable(16) "no-capture-maybe-returned" [[TMP1:%.*]], i1 [[TMP2:%.*]]) local_unnamed_addr
; CHECK-NEXT:    [[RET1:%.*]] = getelementptr inbounds i32, i32* [[TMP0]], i64 1
; CHECK-NEXT:    [[RET2:%.*]] = getelementptr inbounds i32, i32* [[TMP1]], i64 2
; CHECK-NEXT:    [[RET:%.*]] = select i1 [[TMP2]], i32* [[RET1]], i32* [[RET2]]
; CHECK-NEXT:    ret i32* [[RET]]
;
  %ret1 = getelementptr inbounds i32, i32* %0, i64 1
  %ret2 = getelementptr inbounds i32, i32* %1, i64 2
  %ret = select i1 %2, i32* %ret1, i32* %ret2
  ret i32* %ret
}

; TEST 4
; Better than known in IR.

define dereferenceable(4) i32* @test4(i32* dereferenceable(8) %0) local_unnamed_addr {
; CHECK-LABEL: define {{[^@]+}}@test4
; CHECK-SAME: (i32* nofree nonnull readnone returned dereferenceable(8) "no-capture-maybe-returned" [[TMP0:%.*]]) local_unnamed_addr
; CHECK-NEXT:    ret i32* [[TMP0]]
;
  ret i32* %0
}

; TEST 5
; loop in which dereferenceabily "grows"
define void @deref_phi_growing(i32* dereferenceable(4000) %a) {
; CHECK-LABEL: define {{[^@]+}}@deref_phi_growing
; CHECK-SAME: (i32* nonnull dereferenceable(4000) [[A:%.*]])
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[FOR_COND:%.*]]
; CHECK:       for.cond:
; CHECK-NEXT:    [[I_0:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[INC:%.*]], [[FOR_INC:%.*]] ]
; CHECK-NEXT:    [[A_ADDR_0:%.*]] = phi i32* [ [[A]], [[ENTRY]] ], [ [[INCDEC_PTR:%.*]], [[FOR_INC]] ]
; CHECK-NEXT:    call void @deref_phi_user(i32* nonnull dereferenceable(4000) [[A_ADDR_0]])
; CHECK-NEXT:    [[TMP:%.*]] = load i32, i32* [[A_ADDR_0]], align 4
; CHECK-NEXT:    [[CMP:%.*]] = icmp slt i32 [[I_0]], [[TMP]]
; CHECK-NEXT:    br i1 [[CMP]], label [[FOR_BODY:%.*]], label [[FOR_COND_CLEANUP:%.*]]
; CHECK:       for.cond.cleanup:
; CHECK-NEXT:    br label [[FOR_END:%.*]]
; CHECK:       for.body:
; CHECK-NEXT:    br label [[FOR_INC]]
; CHECK:       for.inc:
; CHECK-NEXT:    [[INCDEC_PTR]] = getelementptr inbounds i32, i32* [[A_ADDR_0]], i64 -1
; CHECK-NEXT:    [[INC]] = add nuw nsw i32 [[I_0]], 1
; CHECK-NEXT:    br label [[FOR_COND]]
; CHECK:       for.end:
; CHECK-NEXT:    ret void
;
entry:
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %i.0 = phi i32 [ 0, %entry ], [ %inc, %for.inc ]
  %a.addr.0 = phi i32* [ %a, %entry ], [ %incdec.ptr, %for.inc ]
  call void @deref_phi_user(i32* %a.addr.0)
  %tmp = load i32, i32* %a.addr.0, align 4
  %cmp = icmp slt i32 %i.0, %tmp
  br i1 %cmp, label %for.body, label %for.cond.cleanup

for.cond.cleanup:                                 ; preds = %for.cond
  br label %for.end

for.body:                                         ; preds = %for.cond
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %incdec.ptr = getelementptr inbounds i32, i32* %a.addr.0, i64 -1
  %inc = add nuw nsw i32 %i.0, 1
  br label %for.cond

for.end:                                          ; preds = %for.cond.cleanup
  ret void
}

; TEST 6
; loop in which dereferenceabily "shrinks"
define void @deref_phi_shrinking(i32* dereferenceable(4000) %a) {
; CHECK-LABEL: define {{[^@]+}}@deref_phi_shrinking
; CHECK-SAME: (i32* nonnull dereferenceable(4000) [[A:%.*]])
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[FOR_COND:%.*]]
; CHECK:       for.cond:
; CHECK-NEXT:    [[I_0:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[INC:%.*]], [[FOR_INC:%.*]] ]
; CHECK-NEXT:    [[A_ADDR_0:%.*]] = phi i32* [ [[A]], [[ENTRY]] ], [ [[INCDEC_PTR:%.*]], [[FOR_INC]] ]
; CHECK-NEXT:    call void @deref_phi_user(i32* nonnull [[A_ADDR_0]])
; CHECK-NEXT:    [[TMP:%.*]] = load i32, i32* [[A_ADDR_0]], align 4
; CHECK-NEXT:    [[CMP:%.*]] = icmp slt i32 [[I_0]], [[TMP]]
; CHECK-NEXT:    br i1 [[CMP]], label [[FOR_BODY:%.*]], label [[FOR_COND_CLEANUP:%.*]]
; CHECK:       for.cond.cleanup:
; CHECK-NEXT:    br label [[FOR_END:%.*]]
; CHECK:       for.body:
; CHECK-NEXT:    br label [[FOR_INC]]
; CHECK:       for.inc:
; CHECK-NEXT:    [[INCDEC_PTR]] = getelementptr inbounds i32, i32* [[A_ADDR_0]], i64 1
; CHECK-NEXT:    [[INC]] = add nuw nsw i32 [[I_0]], 1
; CHECK-NEXT:    br label [[FOR_COND]]
; CHECK:       for.end:
; CHECK-NEXT:    ret void
;
entry:
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %i.0 = phi i32 [ 0, %entry ], [ %inc, %for.inc ]
  %a.addr.0 = phi i32* [ %a, %entry ], [ %incdec.ptr, %for.inc ]
  call void @deref_phi_user(i32* %a.addr.0)
  %tmp = load i32, i32* %a.addr.0, align 4
  %cmp = icmp slt i32 %i.0, %tmp
  br i1 %cmp, label %for.body, label %for.cond.cleanup

for.cond.cleanup:                                 ; preds = %for.cond
  br label %for.end

for.body:                                         ; preds = %for.cond
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %incdec.ptr = getelementptr inbounds i32, i32* %a.addr.0, i64 1
  %inc = add nuw nsw i32 %i.0, 1
  br label %for.cond

for.end:                                          ; preds = %for.cond.cleanup
  ret void
}

; TEST 7
; share known infomation in must-be-executed-context
declare i32* @unkown_ptr() willreturn nounwind
declare i32 @unkown_f(i32*) willreturn nounwind
define i32* @f7_0(i32* %ptr) {
; CHECK-LABEL: define {{[^@]+}}@f7_0
; CHECK-SAME: (i32* nonnull returned dereferenceable(8) [[PTR:%.*]])
; CHECK-NEXT:    [[T:%.*]] = tail call i32 @unkown_f(i32* nonnull dereferenceable(8) [[PTR]])
; CHECK-NEXT:    ret i32* [[PTR]]
;
  %T = tail call i32 @unkown_f(i32* dereferenceable(8) %ptr)
  ret i32* %ptr
}

define void @f7_1(i32* %ptr, i1 %c) {
; CHECK-LABEL: define {{[^@]+}}@f7_1
; CHECK-SAME: (i32* nonnull align 4 dereferenceable(4) [[PTR:%.*]], i1 [[C:%.*]])
; CHECK-NEXT:    [[A:%.*]] = tail call i32 @unkown_f(i32* nonnull align 4 dereferenceable(4) [[PTR]])
; CHECK-NEXT:    [[B:%.*]] = tail call i32 @unkown_f(i32* nonnull align 4 dereferenceable(4) [[PTR]])
; CHECK-NEXT:    br i1 [[C]], label [[IF_TRUE:%.*]], label [[IF_FALSE:%.*]]
; CHECK:       if.true:
; CHECK-NEXT:    [[C:%.*]] = tail call i32 @unkown_f(i32* nonnull align 4 dereferenceable(8) [[PTR]])
; CHECK-NEXT:    [[D:%.*]] = tail call i32 @unkown_f(i32* nonnull align 4 dereferenceable(8) [[PTR]])
; CHECK-NEXT:    [[E:%.*]] = tail call i32 @unkown_f(i32* nonnull align 4 dereferenceable(8) [[PTR]])
; CHECK-NEXT:    ret void
; CHECK:       if.false:
; CHECK-NEXT:    ret void
;
  %A = tail call i32 @unkown_f(i32* %ptr)
  %ptr.0 = load i32, i32* %ptr
  ; deref 4 hold
; FIXME: this should be %B = tail call i32 @unkown_f(i32* nonnull dereferenceable(4) %ptr)
  %B = tail call i32 @unkown_f(i32* dereferenceable(1) %ptr)
  br i1%c, label %if.true, label %if.false
if.true:
  %C = tail call i32 @unkown_f(i32* %ptr)
  %D = tail call i32 @unkown_f(i32* dereferenceable(8) %ptr)
  %E = tail call i32 @unkown_f(i32* %ptr)
  ret void
if.false:
  ret void
}

define void @f7_2(i1 %c) {
; CHECK-LABEL: define {{[^@]+}}@f7_2
; CHECK-SAME: (i1 [[C:%.*]])
; CHECK-NEXT:    [[PTR:%.*]] = tail call nonnull align 4 dereferenceable(4) i32* @unkown_ptr()
; CHECK-NEXT:    [[A:%.*]] = tail call i32 @unkown_f(i32* nonnull align 4 dereferenceable(4) [[PTR]])
; CHECK-NEXT:    [[B:%.*]] = tail call i32 @unkown_f(i32* nonnull align 4 dereferenceable(4) [[PTR]])
; CHECK-NEXT:    br i1 [[C]], label [[IF_TRUE:%.*]], label [[IF_FALSE:%.*]]
; CHECK:       if.true:
; CHECK-NEXT:    [[C:%.*]] = tail call i32 @unkown_f(i32* nonnull align 4 dereferenceable(8) [[PTR]])
; CHECK-NEXT:    [[D:%.*]] = tail call i32 @unkown_f(i32* nonnull align 4 dereferenceable(8) [[PTR]])
; CHECK-NEXT:    [[E:%.*]] = tail call i32 @unkown_f(i32* nonnull align 4 dereferenceable(8) [[PTR]])
; CHECK-NEXT:    ret void
; CHECK:       if.false:
; CHECK-NEXT:    ret void
;
  %ptr =  tail call i32* @unkown_ptr()
  %A = tail call i32 @unkown_f(i32* %ptr)
  %arg_a.0 = load i32, i32* %ptr
  ; deref 4 hold
  %B = tail call i32 @unkown_f(i32* dereferenceable(1) %ptr)
  br i1%c, label %if.true, label %if.false
if.true:
  %C = tail call i32 @unkown_f(i32* %ptr)
  %D = tail call i32 @unkown_f(i32* dereferenceable(8) %ptr)
  %E = tail call i32 @unkown_f(i32* %ptr)
  ret void
if.false:
  ret void
}

define i32* @f7_3() {
; CHECK-LABEL: define {{[^@]+}}@f7_3()
; CHECK-NEXT:    [[PTR:%.*]] = tail call nonnull align 16 dereferenceable(4) i32* @unkown_ptr()
; CHECK-NEXT:    store i32 10, i32* [[PTR]], align 16
; CHECK-NEXT:    ret i32* [[PTR]]
;
  %ptr = tail call i32* @unkown_ptr()
  store i32 10, i32* %ptr, align 16
  ret i32* %ptr
}

; FIXME: This should have a return dereferenceable(8) but we need to make sure it will work in loops as well.
define i32* @test_for_minus_index(i32* %p) {
; CHECK-LABEL: define {{[^@]+}}@test_for_minus_index
; CHECK-SAME: (i32* nofree nonnull writeonly align 4 "no-capture-maybe-returned" [[P:%.*]])
; CHECK-NEXT:    [[Q:%.*]] = getelementptr inbounds i32, i32* [[P]], i32 -2
; CHECK-NEXT:    store i32 1, i32* [[Q]], align 4
; CHECK-NEXT:    ret i32* [[Q]]
;
  %q = getelementptr inbounds i32, i32* %p, i32 -2
  store i32 1, i32* %q
  ret i32* %q
}

define void @deref_or_null_and_nonnull(i32* dereferenceable_or_null(100) %0) {
; CHECK-LABEL: define {{[^@]+}}@deref_or_null_and_nonnull
; CHECK-SAME: (i32* nocapture nofree nonnull writeonly align 4 dereferenceable(100) [[TMP0:%.*]])
; CHECK-NEXT:    store i32 1, i32* [[TMP0]], align 4
; CHECK-NEXT:    ret void
;
  store i32 1, i32* %0
  ret void
}

; TEST 8
; Use Constant range in deereferenceable
; void g(int *p, long long int *range){
;   int r = *range ; // [10, 99]
;   fill_range(p, *range);
; }

; void fill_range(int* p, long long int start){
;   for(long long int i = start;i<start+10;i++){
;     // If p[i] is inbounds, p is dereferenceable(40) at least.
;     p[i] = i;
;   }
; }

; NOTE: %p should not be dereferenceable
define internal void @fill_range_not_inbounds(i32* %p, i64 %start){
; CHECK-LABEL: define {{[^@]+}}@fill_range_not_inbounds
; CHECK-SAME: (i32* nocapture nofree writeonly [[P:%.*]], i64 [[START:%.*]])
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP0:%.*]] = add nsw i64 [[START]], 9
; CHECK-NEXT:    br label [[FOR_BODY:%.*]]
; CHECK:       for.cond.cleanup:
; CHECK-NEXT:    ret void
; CHECK:       for.body:
; CHECK-NEXT:    [[I_06:%.*]] = phi i64 [ [[START]], [[ENTRY:%.*]] ], [ [[INC:%.*]], [[FOR_BODY]] ]
; CHECK-NEXT:    [[CONV:%.*]] = trunc i64 [[I_06]] to i32
; CHECK-NEXT:    [[ARRAYIDX:%.*]] = getelementptr i32, i32* [[P]], i64 [[I_06]]
; CHECK-NEXT:    store i32 [[CONV]], i32* [[ARRAYIDX]], align 4
; CHECK-NEXT:    [[INC]] = add nsw i64 [[I_06]], 1
; CHECK-NEXT:    [[CMP:%.*]] = icmp slt i64 [[I_06]], [[TMP0]]
; CHECK-NEXT:    br i1 [[CMP]], label [[FOR_BODY]], label [[FOR_COND_CLEANUP:%.*]]
;
entry:
  %0 = add nsw i64 %start, 9
  br label %for.body

for.cond.cleanup:                                 ; preds = %for.body
  ret void

for.body:                                         ; preds = %entry, %for.body
  %i.06 = phi i64 [ %start, %entry ], [ %inc, %for.body ]
  %conv = trunc i64 %i.06 to i32
  %arrayidx = getelementptr i32, i32* %p, i64 %i.06
  store i32 %conv, i32* %arrayidx, align 4
  %inc = add nsw i64 %i.06, 1
  %cmp = icmp slt i64 %i.06, %0
  br i1 %cmp, label %for.body, label %for.cond.cleanup
}

; FIXME: %p should be dereferenceable(40)
define internal void @fill_range_inbounds(i32* %p, i64 %start){
; CHECK-LABEL: define {{[^@]+}}@fill_range_inbounds
; CHECK-SAME: (i32* nocapture nofree writeonly [[P:%.*]], i64 [[START:%.*]])
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP0:%.*]] = add nsw i64 [[START]], 9
; CHECK-NEXT:    br label [[FOR_BODY:%.*]]
; CHECK:       for.cond.cleanup:
; CHECK-NEXT:    ret void
; CHECK:       for.body:
; CHECK-NEXT:    [[I_06:%.*]] = phi i64 [ [[START]], [[ENTRY:%.*]] ], [ [[INC:%.*]], [[FOR_BODY]] ]
; CHECK-NEXT:    [[CONV:%.*]] = trunc i64 [[I_06]] to i32
; CHECK-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds i32, i32* [[P]], i64 [[I_06]]
; CHECK-NEXT:    store i32 [[CONV]], i32* [[ARRAYIDX]], align 4
; CHECK-NEXT:    [[INC]] = add nsw i64 [[I_06]], 1
; CHECK-NEXT:    [[CMP:%.*]] = icmp slt i64 [[I_06]], [[TMP0]]
; CHECK-NEXT:    br i1 [[CMP]], label [[FOR_BODY]], label [[FOR_COND_CLEANUP:%.*]]
;
entry:
  %0 = add nsw i64 %start, 9
  br label %for.body

for.cond.cleanup:                                 ; preds = %for.body
  ret void

for.body:                                         ; preds = %entry, %for.body
  %i.06 = phi i64 [ %start, %entry ], [ %inc, %for.body ]
  %conv = trunc i64 %i.06 to i32
  %arrayidx = getelementptr inbounds i32, i32* %p, i64 %i.06
  store i32 %conv, i32* %arrayidx, align 4
  %inc = add nsw i64 %i.06, 1
  %cmp = icmp slt i64 %i.06, %0
  br i1 %cmp, label %for.body, label %for.cond.cleanup
}

define void @call_fill_range(i32* nocapture %p, i64* nocapture readonly %range) {
; CHECK-LABEL: define {{[^@]+}}@call_fill_range
; CHECK-SAME: (i32* nocapture nofree writeonly [[P:%.*]], i64* nocapture nofree nonnull readonly align 8 dereferenceable(8) [[RANGE:%.*]])
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP0:%.*]] = load i64, i64* [[RANGE]], align 8, !range !0
; CHECK-NEXT:    tail call void @fill_range_inbounds(i32* nocapture nofree writeonly [[P]], i64 [[TMP0]])
; CHECK-NEXT:    tail call void @fill_range_not_inbounds(i32* nocapture nofree writeonly [[P]], i64 [[TMP0]])
; CHECK-NEXT:    ret void
;
entry:
  %0 = load i64, i64* %range, align 8, !range !0
  tail call void @fill_range_inbounds(i32* %p, i64 %0)
  tail call void @fill_range_not_inbounds(i32* %p, i64 %0)
  ret void
}

declare void @use0() willreturn nounwind
declare void @use1(i8*) willreturn nounwind
declare void @use2(i8*, i8*) willreturn nounwind
declare void @use3(i8*, i8*, i8*) willreturn nounwind

; simple path test
; if(..)
;   fun2(dereferenceable(8) %a, dereferenceable(8) %b)
; else
;   fun2(dereferenceable(4) %a, %b)
; We can say that %a is dereferenceable(4) but %b is not.
define void @simple-path(i8* %a, i8 * %b, i8 %c) {
; CHECK-LABEL: define {{[^@]+}}@simple-path
; CHECK-SAME: (i8* nonnull dereferenceable(4) [[A:%.*]], i8* [[B:%.*]], i8 [[C:%.*]])
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i8 [[C]], 0
; CHECK-NEXT:    br i1 [[CMP]], label [[IF_THEN:%.*]], label [[IF_ELSE:%.*]]
; CHECK:       if.then:
; CHECK-NEXT:    tail call void @use2(i8* nonnull dereferenceable(8) [[A]], i8* nonnull dereferenceable(8) [[B]])
; CHECK-NEXT:    ret void
; CHECK:       if.else:
; CHECK-NEXT:    tail call void @use2(i8* nonnull dereferenceable(4) [[A]], i8* [[B]])
; CHECK-NEXT:    ret void
;
  %cmp = icmp eq i8 %c, 0
  br i1 %cmp, label %if.then, label %if.else
if.then:
  tail call void @use2(i8* dereferenceable(8) %a, i8* dereferenceable(8) %b)
  ret void
if.else:
  tail call void @use2(i8* dereferenceable(4) %a, i8* %b)
  ret void
}

; More complex test
; {
; fun1(dereferenceable(4) %a)
; if(..)
;    ... (willreturn & nounwind)
;    fun1(dereferenceable(12) %a)
; else
;    ... (willreturn & nounwind)
;    fun1(dereferenceable(16) %a)
; fun1(dereferenceable(8) %a)
; }
; %a is dereferenceable(12)
define void @complex-path(i8* %a, i8* %b, i8 %c) {
; CHECK-LABEL: define {{[^@]+}}@complex-path
; CHECK-SAME: (i8* nonnull dereferenceable(12) [[A:%.*]], i8* nocapture nofree readnone [[B:%.*]], i8 [[C:%.*]])
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i8 [[C]], 0
; CHECK-NEXT:    tail call void @use1(i8* nonnull dereferenceable(12) [[A]])
; CHECK-NEXT:    br i1 [[CMP]], label [[CONT_THEN:%.*]], label [[CONT_ELSE:%.*]]
; CHECK:       cont.then:
; CHECK-NEXT:    tail call void @use1(i8* nonnull dereferenceable(12) [[A]])
; CHECK-NEXT:    br label [[CONT2:%.*]]
; CHECK:       cont.else:
; CHECK-NEXT:    tail call void @use1(i8* nonnull dereferenceable(16) [[A]])
; CHECK-NEXT:    br label [[CONT2]]
; CHECK:       cont2:
; CHECK-NEXT:    tail call void @use1(i8* nonnull dereferenceable(12) [[A]])
; CHECK-NEXT:    ret void
;
  %cmp = icmp eq i8 %c, 0
  tail call void @use1(i8* dereferenceable(4) %a)
  br i1 %cmp, label %cont.then, label %cont.else
cont.then:
  tail call void @use1(i8* dereferenceable(12) %a)
  br label %cont2
cont.else:
  tail call void @use1(i8* dereferenceable(16) %a)
  br label %cont2
cont2:
  tail call void @use1(i8* dereferenceable(8) %a)
  ret void
}

;  void rec-branch-1(int a, int b, int c, int *ptr) {
;    if (a) {
;      if (b)
;        *ptr = 1;
;      else
;        *ptr = 2;
;    } else {
;      if (c)
;        *ptr = 3;
;      else
;        *ptr = 4;
;    }
;  }
;
; FIXME: %ptr should be dereferenceable(4)
define dso_local void @rec-branch-1(i32 %a, i32 %b, i32 %c, i32* %ptr) {
; CHECK-LABEL: define {{[^@]+}}@rec-branch-1
; CHECK-SAME: (i32 [[A:%.*]], i32 [[B:%.*]], i32 [[C:%.*]], i32* nocapture nofree writeonly [[PTR:%.*]])
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TOBOOL:%.*]] = icmp eq i32 [[A]], 0
; CHECK-NEXT:    br i1 [[TOBOOL]], label [[IF_ELSE3:%.*]], label [[IF_THEN:%.*]]
; CHECK:       if.then:
; CHECK-NEXT:    [[TOBOOL1:%.*]] = icmp eq i32 [[B]], 0
; CHECK-NEXT:    br i1 [[TOBOOL1]], label [[IF_ELSE:%.*]], label [[IF_THEN2:%.*]]
; CHECK:       if.then2:
; CHECK-NEXT:    store i32 1, i32* [[PTR]], align 4
; CHECK-NEXT:    br label [[IF_END8:%.*]]
; CHECK:       if.else:
; CHECK-NEXT:    store i32 2, i32* [[PTR]], align 4
; CHECK-NEXT:    br label [[IF_END8]]
; CHECK:       if.else3:
; CHECK-NEXT:    [[TOBOOL4:%.*]] = icmp eq i32 [[C]], 0
; CHECK-NEXT:    br i1 [[TOBOOL4]], label [[IF_ELSE6:%.*]], label [[IF_THEN5:%.*]]
; CHECK:       if.then5:
; CHECK-NEXT:    store i32 3, i32* [[PTR]], align 4
; CHECK-NEXT:    br label [[IF_END8]]
; CHECK:       if.else6:
; CHECK-NEXT:    store i32 4, i32* [[PTR]], align 4
; CHECK-NEXT:    br label [[IF_END8]]
; CHECK:       if.end8:
; CHECK-NEXT:    ret void
;
entry:
  %tobool = icmp eq i32 %a, 0
  br i1 %tobool, label %if.else3, label %if.then

if.then:                                          ; preds = %entry
  %tobool1 = icmp eq i32 %b, 0
  br i1 %tobool1, label %if.else, label %if.then2

if.then2:                                         ; preds = %if.then
  store i32 1, i32* %ptr, align 4
  br label %if.end8

if.else:                                          ; preds = %if.then
  store i32 2, i32* %ptr, align 4
  br label %if.end8

if.else3:                                         ; preds = %entry
  %tobool4 = icmp eq i32 %c, 0
  br i1 %tobool4, label %if.else6, label %if.then5

if.then5:                                         ; preds = %if.else3
  store i32 3, i32* %ptr, align 4
  br label %if.end8

if.else6:                                         ; preds = %if.else3
  store i32 4, i32* %ptr, align 4
  br label %if.end8

if.end8:                                          ; preds = %if.then5, %if.else6, %if.then2, %if.else
  ret void
}

;  void rec-branch-2(int a, int b, int c, int *ptr) {
;    if (a) {
;      if (b)
;        *ptr = 1;
;      else
;        *ptr = 2;
;    } else {
;      if (c)
;        *ptr = 3;
;      else
;        rec-branch-2(1, 1, 1, ptr);
;    }
;  }
; FIXME: %ptr should be dereferenceable(4)
define dso_local void @rec-branch-2(i32 %a, i32 %b, i32 %c, i32* %ptr) {
; CHECK-LABEL: define {{[^@]+}}@rec-branch-2
; CHECK-SAME: (i32 [[A:%.*]], i32 [[B:%.*]], i32 [[C:%.*]], i32* nocapture nofree writeonly [[PTR:%.*]])
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TOBOOL:%.*]] = icmp eq i32 [[A]], 0
; CHECK-NEXT:    br i1 [[TOBOOL]], label [[IF_ELSE3:%.*]], label [[IF_THEN:%.*]]
; CHECK:       if.then:
; CHECK-NEXT:    [[TOBOOL1:%.*]] = icmp eq i32 [[B]], 0
; CHECK-NEXT:    br i1 [[TOBOOL1]], label [[IF_ELSE:%.*]], label [[IF_THEN2:%.*]]
; CHECK:       if.then2:
; CHECK-NEXT:    store i32 1, i32* [[PTR]], align 4
; CHECK-NEXT:    br label [[IF_END8:%.*]]
; CHECK:       if.else:
; CHECK-NEXT:    store i32 2, i32* [[PTR]], align 4
; CHECK-NEXT:    br label [[IF_END8]]
; CHECK:       if.else3:
; CHECK-NEXT:    [[TOBOOL4:%.*]] = icmp eq i32 [[C]], 0
; CHECK-NEXT:    br i1 [[TOBOOL4]], label [[IF_ELSE6:%.*]], label [[IF_THEN5:%.*]]
; CHECK:       if.then5:
; CHECK-NEXT:    store i32 3, i32* [[PTR]], align 4
; CHECK-NEXT:    br label [[IF_END8]]
; CHECK:       if.else6:
; CHECK-NEXT:    tail call void @rec-branch-2(i32 1, i32 1, i32 1, i32* nocapture nofree writeonly [[PTR]])
; CHECK-NEXT:    br label [[IF_END8]]
; CHECK:       if.end8:
; CHECK-NEXT:    ret void
;
entry:
  %tobool = icmp eq i32 %a, 0
  br i1 %tobool, label %if.else3, label %if.then

if.then:                                          ; preds = %entry
  %tobool1 = icmp eq i32 %b, 0
  br i1 %tobool1, label %if.else, label %if.then2

if.then2:                                         ; preds = %if.then
  store i32 1, i32* %ptr, align 4
  br label %if.end8

if.else:                                          ; preds = %if.then
  store i32 2, i32* %ptr, align 4
  br label %if.end8

if.else3:                                         ; preds = %entry
  %tobool4 = icmp eq i32 %c, 0
  br i1 %tobool4, label %if.else6, label %if.then5

if.then5:                                         ; preds = %if.else3
  store i32 3, i32* %ptr, align 4
  br label %if.end8

if.else6:                                         ; preds = %if.else3
  tail call void @rec-branch-2(i32 1, i32 1, i32 1, i32* %ptr)
  br label %if.end8

if.end8:                                          ; preds = %if.then5, %if.else6, %if.then2, %if.else
  ret void
}

declare void @unknown()
define void @nonnull_assume_pos(i8* %arg1, i8* %arg2, i8* %arg3, i8* %arg4) {
; ATTRIBUTOR-LABEL: define {{[^@]+}}@nonnull_assume_pos
; ATTRIBUTOR-SAME: (i8* nocapture nofree nonnull readnone dereferenceable(101) [[ARG1:%.*]], i8* nocapture nofree readnone dereferenceable_or_null(31) [[ARG2:%.*]], i8* nocapture nofree nonnull readnone [[ARG3:%.*]], i8* nocapture nofree readnone dereferenceable_or_null(42) [[ARG4:%.*]])
; ATTRIBUTOR-NEXT:    call void @llvm.assume(i1 true) #6 [ "nonnull"(i8* undef), "dereferenceable"(i8* undef, i64 1), "dereferenceable"(i8* undef, i64 2), "dereferenceable"(i8* undef, i64 101), "dereferenceable_or_null"(i8* undef, i64 31), "dereferenceable_or_null"(i8* undef, i64 42) ]
; ATTRIBUTOR-NEXT:    call void @unknown()
; ATTRIBUTOR-NEXT:    ret void
;
; IS__TUNIT_OPM-LABEL: define {{[^@]+}}@nonnull_assume_pos
; IS__TUNIT_OPM-SAME: (i8* nocapture nofree nonnull readnone dereferenceable(101) [[ARG1:%.*]], i8* nocapture nofree readnone dereferenceable_or_null(31) [[ARG2:%.*]], i8* nocapture nofree nonnull readnone [[ARG3:%.*]], i8* nocapture nofree readnone dereferenceable_or_null(42) [[ARG4:%.*]])
; IS__TUNIT_OPM-NEXT:    call void @llvm.assume(i1 true) #6 [ "nonnull"(i8* [[ARG3]]), "dereferenceable"(i8* [[ARG1]], i64 1), "dereferenceable"(i8* [[ARG1]], i64 2), "dereferenceable"(i8* [[ARG1]], i64 101), "dereferenceable_or_null"(i8* [[ARG2]], i64 31), "dereferenceable_or_null"(i8* [[ARG4]], i64 42) ]
; IS__TUNIT_OPM-NEXT:    call void @unknown()
; IS__TUNIT_OPM-NEXT:    ret void
;
; IS________NPM-LABEL: define {{[^@]+}}@nonnull_assume_pos
; IS________NPM-SAME: (i8* nocapture nofree nonnull readnone dereferenceable(101) [[ARG1:%.*]], i8* nocapture nofree readnone dereferenceable_or_null(31) [[ARG2:%.*]], i8* nocapture nofree nonnull readnone [[ARG3:%.*]], i8* nocapture nofree readnone dereferenceable_or_null(42) [[ARG4:%.*]])
; IS________NPM-NEXT:    call void @llvm.assume(i1 true) #7 [ "nonnull"(i8* [[ARG3]]), "dereferenceable"(i8* [[ARG1]], i64 1), "dereferenceable"(i8* [[ARG1]], i64 2), "dereferenceable"(i8* [[ARG1]], i64 101), "dereferenceable_or_null"(i8* [[ARG2]], i64 31), "dereferenceable_or_null"(i8* [[ARG4]], i64 42) ]
; IS________NPM-NEXT:    call void @unknown()
; IS________NPM-NEXT:    ret void
;
; IS__CGSCC_OPM-LABEL: define {{[^@]+}}@nonnull_assume_pos
; IS__CGSCC_OPM-SAME: (i8* nocapture nofree nonnull readnone dereferenceable(101) [[ARG1:%.*]], i8* nocapture nofree readnone dereferenceable_or_null(31) [[ARG2:%.*]], i8* nocapture nofree nonnull readnone [[ARG3:%.*]], i8* nocapture nofree readnone dereferenceable_or_null(42) [[ARG4:%.*]])
; IS__CGSCC_OPM-NEXT:    call void @llvm.assume(i1 true) #8 [ "nonnull"(i8* [[ARG3]]), "dereferenceable"(i8* [[ARG1]], i64 1), "dereferenceable"(i8* [[ARG1]], i64 2), "dereferenceable"(i8* [[ARG1]], i64 101), "dereferenceable_or_null"(i8* [[ARG2]], i64 31), "dereferenceable_or_null"(i8* [[ARG4]], i64 42) ]
; IS__CGSCC_OPM-NEXT:    call void @unknown()
; IS__CGSCC_OPM-NEXT:    ret void
;
  call void @llvm.assume(i1 true) [ "nonnull"(i8* %arg3), "dereferenceable"(i8* %arg1, i64 1), "dereferenceable"(i8* %arg1, i64 2), "dereferenceable"(i8* %arg1, i64 101), "dereferenceable_or_null"(i8* %arg2, i64 31), "dereferenceable_or_null"(i8* %arg4, i64 42)]
  call void @unknown()
  ret void
}
define void @nonnull_assume_neg(i8* %arg1, i8* %arg2, i8* %arg3) {
; ATTRIBUTOR-LABEL: define {{[^@]+}}@nonnull_assume_neg
; ATTRIBUTOR-SAME: (i8* nocapture nofree readnone [[ARG1:%.*]], i8* nocapture nofree readnone [[ARG2:%.*]], i8* nocapture nofree readnone [[ARG3:%.*]])
; ATTRIBUTOR-NEXT:    call void @unknown()
; ATTRIBUTOR-NEXT:    call void @llvm.assume(i1 true) [ "dereferenceable"(i8* undef, i64 101), "dereferenceable"(i8* undef, i64 -2), "dereferenceable_or_null"(i8* undef, i64 31) ]
; ATTRIBUTOR-NEXT:    ret void
;
; CHECK-LABEL: define {{[^@]+}}@nonnull_assume_neg
; CHECK-SAME: (i8* nocapture nofree readnone [[ARG1:%.*]], i8* nocapture nofree readnone [[ARG2:%.*]], i8* nocapture nofree readnone [[ARG3:%.*]])
; CHECK-NEXT:    call void @unknown()
; CHECK-NEXT:    call void @llvm.assume(i1 true) [ "dereferenceable"(i8* [[ARG1]], i64 101), "dereferenceable"(i8* [[ARG2]], i64 -2), "dereferenceable_or_null"(i8* [[ARG3]], i64 31) ]
; CHECK-NEXT:    ret void
;
  call void @unknown()
  call void @llvm.assume(i1 true) ["dereferenceable"(i8* %arg1, i64 101), "dereferenceable"(i8* %arg2, i64 -2), "dereferenceable_or_null"(i8* %arg3, i64 31)]
  ret void
}
define void @nonnull_assume_call(i8* %arg1, i8* %arg2, i8* %arg3, i8* %arg4) {
; ATTRIBUTOR-LABEL: define {{[^@]+}}@nonnull_assume_call
; ATTRIBUTOR-SAME: (i8* [[ARG1:%.*]], i8* [[ARG2:%.*]], i8* [[ARG3:%.*]], i8* [[ARG4:%.*]])
; ATTRIBUTOR-NEXT:    call void @unknown()
; ATTRIBUTOR-NEXT:    [[P:%.*]] = call nonnull dereferenceable(101) i32* @unkown_ptr()
; ATTRIBUTOR-NEXT:    call void @unknown_use32(i32* nonnull dereferenceable(101) [[P]])
; ATTRIBUTOR-NEXT:    call void @unknown_use8(i8* nonnull dereferenceable(42) [[ARG4]])
; ATTRIBUTOR-NEXT:    call void @unknown_use8(i8* nonnull [[ARG3]])
; ATTRIBUTOR-NEXT:    call void @unknown_use8(i8* nonnull dereferenceable(31) [[ARG2]])
; ATTRIBUTOR-NEXT:    call void @unknown_use8(i8* nonnull dereferenceable(2) [[ARG1]])
; ATTRIBUTOR-NEXT:    call void @llvm.assume(i1 true) [ "nonnull"(i8* [[ARG3]]), "dereferenceable"(i8* [[ARG1]], i64 1), "dereferenceable"(i8* [[ARG1]], i64 2), "dereferenceable"(i32* [[P]], i64 101), "dereferenceable_or_null"(i8* [[ARG2]], i64 31), "dereferenceable_or_null"(i8* [[ARG4]], i64 42) ]
; ATTRIBUTOR-NEXT:    call void @unknown_use8(i8* nonnull dereferenceable(2) [[ARG1]])
; ATTRIBUTOR-NEXT:    call void @unknown_use8(i8* nonnull dereferenceable(31) [[ARG2]])
; ATTRIBUTOR-NEXT:    call void @unknown_use8(i8* nonnull [[ARG3]])
; ATTRIBUTOR-NEXT:    call void @unknown_use8(i8* nonnull dereferenceable(42) [[ARG4]])
; ATTRIBUTOR-NEXT:    call void @unknown_use32(i32* nonnull dereferenceable(101) [[P]])
; ATTRIBUTOR-NEXT:    call void @unknown()
; ATTRIBUTOR-NEXT:    ret void
;
; CHECK-LABEL: define {{[^@]+}}@nonnull_assume_call
; CHECK-SAME: (i8* [[ARG1:%.*]], i8* [[ARG2:%.*]], i8* [[ARG3:%.*]], i8* [[ARG4:%.*]])
; CHECK-NEXT:    call void @unknown()
; CHECK-NEXT:    [[P:%.*]] = call nonnull dereferenceable(101) i32* @unkown_ptr()
; CHECK-NEXT:    call void @unknown_use32(i32* nonnull dereferenceable(101) [[P]])
; CHECK-NEXT:    call void @unknown_use8(i8* nonnull dereferenceable(42) [[ARG4]])
; CHECK-NEXT:    call void @unknown_use8(i8* nonnull [[ARG3]])
; CHECK-NEXT:    call void @unknown_use8(i8* nonnull dereferenceable(31) [[ARG2]])
; CHECK-NEXT:    call void @unknown_use8(i8* nonnull dereferenceable(2) [[ARG1]])
; CHECK-NEXT:    call void @llvm.assume(i1 true) [ "nonnull"(i8* [[ARG3]]), "dereferenceable"(i8* [[ARG1]], i64 1), "dereferenceable"(i8* [[ARG1]], i64 2), "dereferenceable"(i32* [[P]], i64 101), "dereferenceable_or_null"(i8* [[ARG2]], i64 31), "dereferenceable_or_null"(i8* [[ARG4]], i64 42) ]
; CHECK-NEXT:    call void @unknown_use8(i8* nonnull dereferenceable(2) [[ARG1]])
; CHECK-NEXT:    call void @unknown_use8(i8* nonnull dereferenceable(31) [[ARG2]])
; CHECK-NEXT:    call void @unknown_use8(i8* nonnull [[ARG3]])
; CHECK-NEXT:    call void @unknown_use8(i8* nonnull dereferenceable(42) [[ARG4]])
; CHECK-NEXT:    call void @unknown_use32(i32* nonnull dereferenceable(101) [[P]])
; CHECK-NEXT:    call void @unknown()
; CHECK-NEXT:    ret void
;
  call void @unknown()
  %p = call i32* @unkown_ptr()
  call void @unknown_use32(i32* %p)
  call void @unknown_use8(i8* %arg4)
  call void @unknown_use8(i8* %arg3)
  call void @unknown_use8(i8* %arg2)
  call void @unknown_use8(i8* %arg1)
  call void @llvm.assume(i1 true) [ "nonnull"(i8* %arg3), "dereferenceable"(i8* %arg1, i64 1), "dereferenceable"(i8* %arg1, i64 2), "dereferenceable"(i32* %p, i64 101), "dereferenceable_or_null"(i8* %arg2, i64 31), "dereferenceable_or_null"(i8* %arg4, i64 42)]
  call void @unknown_use8(i8* %arg1)
  call void @unknown_use8(i8* %arg2)
  call void @unknown_use8(i8* %arg3)
  call void @unknown_use8(i8* %arg4)
  call void @unknown_use32(i32* %p)
  call void @unknown()
  ret void
}
declare void @unknown_use8(i8*) willreturn nounwind
declare void @unknown_use32(i32*) willreturn nounwind
declare void @llvm.assume(i1)

!0 = !{i64 10, i64 100}


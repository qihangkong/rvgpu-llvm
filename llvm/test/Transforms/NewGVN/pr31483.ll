; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -basic-aa -newgvn -S | FileCheck %s
target datalayout = "E-m:e-i64:64-n32:64"

@global = external hidden unnamed_addr constant [11 x i8], align 1
;; Ensure we do not believe the indexing increments are unreachable due to incorrect memory
;; equivalence detection.  In PR31483, we were deleting those blocks as unreachable
; Function Attrs: nounwind
define signext i32 @ham(i8* %arg, i8* %arg1) #0 {
; CHECK-LABEL: @ham(
; CHECK-NEXT:  bb:
; CHECK-NEXT:    [[TMP:%.*]] = alloca i8*, align 8
; CHECK-NEXT:    store i8* %arg1, i8** [[TMP]], align 8
; CHECK-NEXT:    br label %bb2
; CHECK:       bb2:
; CHECK-NEXT:    [[TMP3:%.*]] = phi i8* [ %arg, %bb ], [ %tmp7, %bb22 ]
; CHECK-NEXT:    [[TMP4:%.*]] = load i8, i8* [[TMP3]], align 1
; CHECK-NEXT:    [[TMP5:%.*]] = icmp ne i8 [[TMP4]], 0
; CHECK-NEXT:    br i1 [[TMP5]], label %bb6, label %bb23
; CHECK:       bb6:
; CHECK-NEXT:    [[TMP7:%.*]] = getelementptr inbounds i8, i8* [[TMP3]], i32 1
; CHECK-NEXT:    [[TMP9:%.*]] = zext i8 [[TMP4]] to i32
; CHECK-NEXT:    switch i32 [[TMP9]], label %bb22 [
; CHECK-NEXT:    i32 115, label %bb10
; CHECK-NEXT:    i32 105, label %bb16
; CHECK-NEXT:    i32 99, label %bb16
; CHECK-NEXT:    ]
; CHECK:       bb10:
; CHECK-NEXT:    [[TMP11:%.*]] = load i8*, i8** [[TMP]], align 8
; CHECK-NEXT:    [[TMP12:%.*]] = getelementptr inbounds i8, i8* [[TMP11]], i64 8
; CHECK-NEXT:    store i8* [[TMP12]], i8** [[TMP]], align 8
; CHECK-NEXT:    [[TMP13:%.*]] = bitcast i8* [[TMP11]] to i8**
; CHECK-NEXT:    [[TMP14:%.*]] = load i8*, i8** [[TMP13]], align 8
; CHECK-NEXT:    [[TMP15:%.*]] = call signext i32 (i8*, ...) @zot(i8* getelementptr inbounds ([11 x i8], [11 x i8]* @global, i32 0, i32 0), i8* [[TMP14]])
; CHECK-NEXT:    br label %bb22
; CHECK:       bb16:
; CHECK-NEXT:    [[TMP17:%.*]] = load i8*, i8** [[TMP]], align 8
; CHECK-NEXT:    [[TMP18:%.*]] = getelementptr inbounds i8, i8* [[TMP17]], i64 8
; CHECK-NEXT:    store i8* [[TMP18]], i8** [[TMP]], align 8
; CHECK-NEXT:    [[TMP19:%.*]] = getelementptr inbounds i8, i8* [[TMP17]], i64 4
; CHECK-NEXT:    [[TMP20:%.*]] = bitcast i8* [[TMP19]] to i32*
; CHECK-NEXT:    br label %bb22
; CHECK:       bb22:
; CHECK-NEXT:    br label %bb2
; CHECK:       bb23:
; CHECK-NEXT:    [[TMP24:%.*]] = bitcast i8** [[TMP]] to i8*
; CHECK-NEXT:    call void @llvm.va_end(i8* [[TMP24]])
; CHECK-NEXT:    ret i32 undef
;
bb:
  %tmp = alloca i8*, align 8
  store i8* %arg1, i8** %tmp, align 8
  br label %bb2

bb2:                                              ; preds = %bb22, %bb
  %tmp3 = phi i8* [ %arg, %bb ], [ %tmp7, %bb22 ]
  %tmp4 = load i8, i8* %tmp3, align 1
  %tmp5 = icmp ne i8 %tmp4, 0
  br i1 %tmp5, label %bb6, label %bb23

bb6:                                              ; preds = %bb2
  %tmp7 = getelementptr inbounds i8, i8* %tmp3, i32 1
  %tmp8 = load i8, i8* %tmp3, align 1
  %tmp9 = zext i8 %tmp8 to i32
  switch i32 %tmp9, label %bb22 [
  i32 115, label %bb10
  i32 105, label %bb16
  i32 99, label %bb16
  ]

bb10:                                             ; preds = %bb6
  %tmp11 = load i8*, i8** %tmp, align 8
  %tmp12 = getelementptr inbounds i8, i8* %tmp11, i64 8
  store i8* %tmp12, i8** %tmp, align 8
  %tmp13 = bitcast i8* %tmp11 to i8**
  %tmp14 = load i8*, i8** %tmp13, align 8
  %tmp15 = call signext i32 (i8*, ...) @zot(i8* getelementptr inbounds ([11 x i8], [11 x i8]* @global, i32 0, i32 0), i8* %tmp14)
  br label %bb22

bb16:                                             ; preds = %bb6, %bb6
  %tmp17 = load i8*, i8** %tmp, align 8
  %tmp18 = getelementptr inbounds i8, i8* %tmp17, i64 8
  store i8* %tmp18, i8** %tmp, align 8
  %tmp19 = getelementptr inbounds i8, i8* %tmp17, i64 4
  %tmp20 = bitcast i8* %tmp19 to i32*
  %tmp21 = load i32, i32* %tmp20, align 4
  br label %bb22

bb22:                                             ; preds = %bb16, %bb10, %bb6
  br label %bb2

bb23:                                             ; preds = %bb2
  %tmp24 = bitcast i8** %tmp to i8*
  call void @llvm.va_end(i8* %tmp24)
  ret i32 undef
}

declare signext i32 @zot(i8*, ...) #1

; Function Attrs: nounwind
declare void @llvm.va_end(i8*) #2

attributes #0 = { nounwind "disable-tail-calls"="false" "less-precise-fpmad"="false" "frame-pointer"="all" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="ppc64" "target-features"="+altivec,-bpermd,-crypto,-direct-move,-extdiv,-power8-vector,-qpx,-vsx" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "disable-tail-calls"="false" "less-precise-fpmad"="false" "frame-pointer"="all" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="ppc64" "target-features"="+altivec,-bpermd,-crypto,-direct-move,-extdiv,-power8-vector,-qpx,-vsx" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nounwind }


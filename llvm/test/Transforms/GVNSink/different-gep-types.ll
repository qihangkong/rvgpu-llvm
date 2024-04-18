; RUN: opt -passes=gvn-sink -S %s | FileCheck %s

target datalayout = "e-m:e-p:32:32-Fi8-i64:64-v128:64:128-a:0:32-n32-S64"
target triple = "thumbv7em-none-unknown-eabi"

%"struct.std::pair" = type <{ i32, %struct.substruct, [2 x i8] }>
%struct.substruct = type { i8, i8 }
%"struct.std::random_access_iterator_tag" = type { i8 }

; CHECK: if.end6
; CHECK: %incdec.ptr.sink = phi ptr [ %incdec.ptr, %if.then ], [ %incdec.ptr4, %if.then3 ], [ %add.ptr, %if.else5 ]
; CHECK-NEXT: store ptr %incdec.ptr.sink, ptr %__i, align 4

define linkonce_odr dso_local void @__advance(ptr noundef nonnull align 4 dereferenceable(4) %__i, i32 noundef %__n) local_unnamed_addr {
entry:
  %0 = call i1 @llvm.is.constant.i32(i32 %__n)
  %cmp = icmp eq i32 %__n, 1
  %or.cond = and i1 %0, %cmp
  br i1 %or.cond, label %if.then, label %if.else

if.then:                                          ; preds = %entry
  %1 = load ptr, ptr %__i, align 4
  %incdec.ptr = getelementptr inbounds i8, ptr %1, i32 8
  store ptr %incdec.ptr, ptr %__i, align 4
  br label %if.end6

if.else:                                          ; preds = %entry
  %2 = call i1 @llvm.is.constant.i32(i32 %__n)
  %cmp2 = icmp eq i32 %__n, -1
  %or.cond7 = and i1 %2, %cmp2
  br i1 %or.cond7, label %if.then3, label %if.else5

if.then3:                                         ; preds = %if.else
  %3 = load ptr, ptr %__i, align 4
  %incdec.ptr4 = getelementptr inbounds i8, ptr %3, i32 -8
  store ptr %incdec.ptr4, ptr %__i, align 4
  br label %if.end6

if.else5:                                         ; preds = %if.else
  %4 = load ptr, ptr %__i, align 4
  %add.ptr = getelementptr inbounds %"struct.std::pair", ptr %4, i32 %__n
  store ptr %add.ptr, ptr %__i, align 4
  br label %if.end6

if.end6:                                          ; preds = %if.then3, %if.else5, %if.then
  ret void
}

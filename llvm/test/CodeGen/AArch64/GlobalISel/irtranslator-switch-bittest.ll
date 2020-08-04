; NOTE: Assertions have been autogenerated by utils/update_mir_test_checks.py
; RUN: llc -mtriple aarch64 -aarch64-enable-atomic-cfg-tidy=0 -stop-after=irtranslator -global-isel -verify-machineinstrs %s -o - 2>&1 | FileCheck %s

define i32 @test_bittest(i16 %p) {
  ; CHECK-LABEL: name: test_bittest
  ; CHECK: bb.1 (%ir-block.0):
  ; CHECK:   successors: %bb.4(0x40000000), %bb.5(0x40000000)
  ; CHECK:   liveins: $w0
  ; CHECK:   [[COPY:%[0-9]+]]:_(s32) = COPY $w0
  ; CHECK:   [[TRUNC:%[0-9]+]]:_(s16) = G_TRUNC [[COPY]](s32)
  ; CHECK:   [[C:%[0-9]+]]:_(s32) = G_CONSTANT i32 114
  ; CHECK:   [[C1:%[0-9]+]]:_(s32) = G_CONSTANT i32 42
  ; CHECK:   [[C2:%[0-9]+]]:_(s32) = G_CONSTANT i32 0
  ; CHECK:   [[ZEXT:%[0-9]+]]:_(s32) = G_ZEXT [[TRUNC]](s16)
  ; CHECK:   [[C3:%[0-9]+]]:_(s32) = G_CONSTANT i32 0
  ; CHECK:   [[SUB:%[0-9]+]]:_(s32) = G_SUB [[ZEXT]], [[C3]]
  ; CHECK:   [[ZEXT1:%[0-9]+]]:_(s64) = G_ZEXT [[SUB]](s32)
  ; CHECK:   [[C4:%[0-9]+]]:_(s32) = G_CONSTANT i32 59
  ; CHECK:   [[ICMP:%[0-9]+]]:_(s1) = G_ICMP intpred(ugt), [[SUB]](s32), [[C4]]
  ; CHECK:   G_BRCOND [[ICMP]](s1), %bb.4
  ; CHECK:   G_BR %bb.5
  ; CHECK: bb.4 (%ir-block.0):
  ; CHECK:   successors: %bb.3(0x40000000), %bb.2(0x40000000)
  ; CHECK:   [[ICMP1:%[0-9]+]]:_(s1) = G_ICMP intpred(eq), [[ZEXT]](s32), [[C]]
  ; CHECK:   G_BRCOND [[ICMP1]](s1), %bb.3
  ; CHECK:   G_BR %bb.2
  ; CHECK: bb.5 (%ir-block.0):
  ; CHECK:   successors: %bb.3(0x40000000), %bb.4(0x40000000)
  ; CHECK:   [[C5:%[0-9]+]]:_(s64) = G_CONSTANT i64 1
  ; CHECK:   [[SHL:%[0-9]+]]:_(s64) = G_SHL [[C5]], [[ZEXT1]](s64)
  ; CHECK:   [[C6:%[0-9]+]]:_(s64) = G_CONSTANT i64 866239240827043840
  ; CHECK:   [[AND:%[0-9]+]]:_(s64) = G_AND [[SHL]], [[C6]]
  ; CHECK:   [[C7:%[0-9]+]]:_(s64) = G_CONSTANT i64 0
  ; CHECK:   [[ICMP2:%[0-9]+]]:_(s1) = G_ICMP intpred(ne), [[AND]](s64), [[C7]]
  ; CHECK:   G_BRCOND [[ICMP2]](s1), %bb.3
  ; CHECK:   G_BR %bb.4
  ; CHECK: bb.2.sw.epilog:
  ; CHECK:   $w0 = COPY [[C2]](s32)
  ; CHECK:   RET_ReallyLR implicit $w0
  ; CHECK: bb.3.cb1:
  ; CHECK:   $w0 = COPY [[C1]](s32)
  ; CHECK:   RET_ReallyLR implicit $w0
  switch i16 %p, label %sw.epilog [
    i16 58, label %cb1
    i16 59, label %cb1
    i16 47, label %cb1
    i16 48, label %cb1
    i16 50, label %cb1
    i16 114, label %cb1
  ]
sw.epilog:
  ret i32 0

cb1:
  ret i32 42
}


declare void @callee()

define void @test_bittest_2_bt(i32 %p) {
  ; CHECK-LABEL: name: test_bittest_2_bt
  ; CHECK: bb.1.entry:
  ; CHECK:   successors: %bb.5(0x40000000), %bb.6(0x40000000)
  ; CHECK:   liveins: $w0
  ; CHECK:   [[COPY:%[0-9]+]]:_(s32) = COPY $w0
  ; CHECK:   [[C:%[0-9]+]]:_(s32) = G_CONSTANT i32 176
  ; CHECK:   [[SUB:%[0-9]+]]:_(s32) = G_SUB [[COPY]], [[C]]
  ; CHECK:   [[C1:%[0-9]+]]:_(s32) = G_CONSTANT i32 15
  ; CHECK:   [[ICMP:%[0-9]+]]:_(s1) = G_ICMP intpred(ugt), [[SUB]](s32), [[C1]]
  ; CHECK:   G_BRCOND [[ICMP]](s1), %bb.5
  ; CHECK:   G_BR %bb.6
  ; CHECK: bb.5.entry:
  ; CHECK:   successors: %bb.4(0x40000000), %bb.7(0x40000000)
  ; CHECK:   [[C2:%[0-9]+]]:_(s32) = G_CONSTANT i32 0
  ; CHECK:   [[SUB1:%[0-9]+]]:_(s32) = G_SUB [[COPY]], [[C2]]
  ; CHECK:   [[ZEXT:%[0-9]+]]:_(s64) = G_ZEXT [[SUB1]](s32)
  ; CHECK:   [[C3:%[0-9]+]]:_(s32) = G_CONSTANT i32 38
  ; CHECK:   [[ICMP1:%[0-9]+]]:_(s1) = G_ICMP intpred(ugt), [[SUB1]](s32), [[C3]]
  ; CHECK:   G_BRCOND [[ICMP1]](s1), %bb.4
  ; CHECK:   G_BR %bb.7
  ; CHECK: bb.6.entry:
  ; CHECK:   successors: %bb.2(0x40000000), %bb.5(0x40000000)
  ; CHECK:   [[C4:%[0-9]+]]:_(s32) = G_CONSTANT i32 1
  ; CHECK:   [[SHL:%[0-9]+]]:_(s32) = G_SHL [[C4]], [[SUB]](s32)
  ; CHECK:   [[C5:%[0-9]+]]:_(s32) = G_CONSTANT i32 57351
  ; CHECK:   [[AND:%[0-9]+]]:_(s32) = G_AND [[SHL]], [[C5]]
  ; CHECK:   [[C6:%[0-9]+]]:_(s32) = G_CONSTANT i32 0
  ; CHECK:   [[ICMP2:%[0-9]+]]:_(s1) = G_ICMP intpred(ne), [[AND]](s32), [[C6]]
  ; CHECK:   G_BRCOND [[ICMP2]](s1), %bb.2
  ; CHECK:   G_BR %bb.5
  ; CHECK: bb.7.entry:
  ; CHECK:   successors: %bb.3(0x40000000), %bb.4(0x40000000)
  ; CHECK:   [[C7:%[0-9]+]]:_(s64) = G_CONSTANT i64 1
  ; CHECK:   [[SHL1:%[0-9]+]]:_(s64) = G_SHL [[C7]], [[ZEXT]](s64)
  ; CHECK:   [[C8:%[0-9]+]]:_(s64) = G_CONSTANT i64 365072220160
  ; CHECK:   [[AND1:%[0-9]+]]:_(s64) = G_AND [[SHL1]], [[C8]]
  ; CHECK:   [[C9:%[0-9]+]]:_(s64) = G_CONSTANT i64 0
  ; CHECK:   [[ICMP3:%[0-9]+]]:_(s1) = G_ICMP intpred(ne), [[AND1]](s64), [[C9]]
  ; CHECK:   G_BRCOND [[ICMP3]](s1), %bb.3
  ; CHECK:   G_BR %bb.4
  ; CHECK: bb.2.sw.bb37:
  ; CHECK:   TCRETURNdi @callee, 0, csr_aarch64_aapcs, implicit $sp
  ; CHECK: bb.3.sw.bb55:
  ; CHECK:   TCRETURNdi @callee, 0, csr_aarch64_aapcs, implicit $sp
  ; CHECK: bb.4.sw.default:
  ; CHECK:   RET_ReallyLR
entry:
  switch i32 %p, label %sw.default [
    i32 32, label %sw.bb55
    i32 34, label %sw.bb55
    i32 36, label %sw.bb55
    i32 191, label %sw.bb37
    i32 190, label %sw.bb37
    i32 189, label %sw.bb37
    i32 178, label %sw.bb37
    i32 177, label %sw.bb37
    i32 176, label %sw.bb37
    i32 38, label %sw.bb55
  ]

sw.bb37:                                          ; preds = %entry, %entry, %entry, %entry, %entry, %entry
  tail call void @callee()
  ret void

sw.bb55:                                          ; preds = %entry, %entry, %entry, %entry
  tail call void @callee()
  ret void

sw.default:                                       ; preds = %entry
  ret void
}

define i32 @test_bittest_single_bt_only_with_fallthrough(i16 %p) {
  ; CHECK-LABEL: name: test_bittest_single_bt_only_with_fallthrough
  ; CHECK: bb.1 (%ir-block.0):
  ; CHECK:   successors: %bb.2(0x40000000), %bb.4(0x40000000)
  ; CHECK:   liveins: $w0
  ; CHECK:   [[COPY:%[0-9]+]]:_(s32) = COPY $w0
  ; CHECK:   [[TRUNC:%[0-9]+]]:_(s16) = G_TRUNC [[COPY]](s32)
  ; CHECK:   [[C:%[0-9]+]]:_(s32) = G_CONSTANT i32 42
  ; CHECK:   [[C1:%[0-9]+]]:_(s32) = G_CONSTANT i32 0
  ; CHECK:   [[ZEXT:%[0-9]+]]:_(s32) = G_ZEXT [[TRUNC]](s16)
  ; CHECK:   [[C2:%[0-9]+]]:_(s32) = G_CONSTANT i32 0
  ; CHECK:   [[SUB:%[0-9]+]]:_(s32) = G_SUB [[ZEXT]], [[C2]]
  ; CHECK:   [[ZEXT1:%[0-9]+]]:_(s64) = G_ZEXT [[SUB]](s32)
  ; CHECK:   [[C3:%[0-9]+]]:_(s32) = G_CONSTANT i32 59
  ; CHECK:   [[ICMP:%[0-9]+]]:_(s1) = G_ICMP intpred(ugt), [[SUB]](s32), [[C3]]
  ; CHECK:   G_BRCOND [[ICMP]](s1), %bb.2
  ; CHECK: bb.4 (%ir-block.0):
  ; CHECK:   successors: %bb.3(0x40000000), %bb.2(0x40000000)
  ; CHECK:   [[C4:%[0-9]+]]:_(s64) = G_CONSTANT i64 1
  ; CHECK:   [[SHL:%[0-9]+]]:_(s64) = G_SHL [[C4]], [[ZEXT1]](s64)
  ; CHECK:   [[C5:%[0-9]+]]:_(s64) = G_CONSTANT i64 866239240827043840
  ; CHECK:   [[AND:%[0-9]+]]:_(s64) = G_AND [[SHL]], [[C5]]
  ; CHECK:   [[C6:%[0-9]+]]:_(s64) = G_CONSTANT i64 0
  ; CHECK:   [[ICMP1:%[0-9]+]]:_(s1) = G_ICMP intpred(ne), [[AND]](s64), [[C6]]
  ; CHECK:   G_BRCOND [[ICMP1]](s1), %bb.3
  ; CHECK: bb.2.sw.epilog:
  ; CHECK:   $w0 = COPY [[C1]](s32)
  ; CHECK:   RET_ReallyLR implicit $w0
  ; CHECK: bb.3.cb1:
  ; CHECK:   $w0 = COPY [[C]](s32)
  ; CHECK:   RET_ReallyLR implicit $w0
  switch i16 %p, label %sw.epilog [
    i16 58, label %cb1
    i16 59, label %cb1
    i16 47, label %cb1
    i16 48, label %cb1
    i16 50, label %cb1
  ]
sw.epilog:
  ret i32 0

cb1:
  ret i32 42
}

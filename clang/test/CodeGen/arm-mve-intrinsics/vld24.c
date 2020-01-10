// NOTE: Assertions have been autogenerated by utils/update_cc_test_checks.py
// RUN: %clang_cc1 -triple thumbv8.1m.main-arm-none-eabi -target-feature +mve.fp -mfloat-abi hard -fallow-half-arguments-and-returns -O0 -disable-O0-optnone -S -emit-llvm -o - %s | opt -S -mem2reg -sroa -early-cse | FileCheck %s
// RUN: %clang_cc1 -triple thumbv8.1m.main-arm-none-eabi -target-feature +mve.fp -mfloat-abi hard -fallow-half-arguments-and-returns -O0 -disable-O0-optnone -DPOLYMORPHIC -S -emit-llvm -o - %s | opt -S -mem2reg -sroa -early-cse | FileCheck %s

#include <arm_mve.h>

// CHECK-LABEL: @test_vld2q_f16(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = call { <8 x half>, <8 x half> } @llvm.arm.mve.vld2q.v8f16.p0f16(half* [[ADDR:%.*]])
// CHECK-NEXT:    [[TMP1:%.*]] = extractvalue { <8 x half>, <8 x half> } [[TMP0]], 0
// CHECK-NEXT:    [[TMP2:%.*]] = insertvalue [[STRUCT_FLOAT16X8X2_T:%.*]] undef, <8 x half> [[TMP1]], 0, 0
// CHECK-NEXT:    [[TMP3:%.*]] = extractvalue { <8 x half>, <8 x half> } [[TMP0]], 1
// CHECK-NEXT:    [[TMP4:%.*]] = insertvalue [[STRUCT_FLOAT16X8X2_T]] %2, <8 x half> [[TMP3]], 0, 1
// CHECK-NEXT:    ret [[STRUCT_FLOAT16X8X2_T]] %4
//
float16x8x2_t test_vld2q_f16(const float16_t *addr)
{
#ifdef POLYMORPHIC
    return vld2q(addr);
#else /* POLYMORPHIC */
    return vld2q_f16(addr);
#endif /* POLYMORPHIC */
}

// CHECK-LABEL: @test_vld4q_u8(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = call { <16 x i8>, <16 x i8>, <16 x i8>, <16 x i8> } @llvm.arm.mve.vld4q.v16i8.p0i8(i8* [[ADDR:%.*]])
// CHECK-NEXT:    [[TMP1:%.*]] = extractvalue { <16 x i8>, <16 x i8>, <16 x i8>, <16 x i8> } [[TMP0]], 0
// CHECK-NEXT:    [[TMP2:%.*]] = insertvalue [[STRUCT_UINT8X16X4_T:%.*]] undef, <16 x i8> [[TMP1]], 0, 0
// CHECK-NEXT:    [[TMP3:%.*]] = extractvalue { <16 x i8>, <16 x i8>, <16 x i8>, <16 x i8> } [[TMP0]], 1
// CHECK-NEXT:    [[TMP4:%.*]] = insertvalue [[STRUCT_UINT8X16X4_T]] %2, <16 x i8> [[TMP3]], 0, 1
// CHECK-NEXT:    [[TMP5:%.*]] = extractvalue { <16 x i8>, <16 x i8>, <16 x i8>, <16 x i8> } [[TMP0]], 2
// CHECK-NEXT:    [[TMP6:%.*]] = insertvalue [[STRUCT_UINT8X16X4_T]] %4, <16 x i8> [[TMP5]], 0, 2
// CHECK-NEXT:    [[TMP7:%.*]] = extractvalue { <16 x i8>, <16 x i8>, <16 x i8>, <16 x i8> } [[TMP0]], 3
// CHECK-NEXT:    [[TMP8:%.*]] = insertvalue [[STRUCT_UINT8X16X4_T]] %6, <16 x i8> [[TMP7]], 0, 3
// CHECK-NEXT:    ret [[STRUCT_UINT8X16X4_T]] %8
//
uint8x16x4_t test_vld4q_u8(const uint8_t *addr)
{
#ifdef POLYMORPHIC
    return vld4q(addr);
#else /* POLYMORPHIC */
    return vld4q_u8(addr);
#endif /* POLYMORPHIC */
}

// CHECK-LABEL: @test_vst2q_u32(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[VALUE_COERCE_FCA_0_0_EXTRACT:%.*]] = extractvalue [[STRUCT_UINT32X4X2_T:%.*]] %value.coerce, 0, 0
// CHECK-NEXT:    [[VALUE_COERCE_FCA_0_1_EXTRACT:%.*]] = extractvalue [[STRUCT_UINT32X4X2_T]] %value.coerce, 0, 1
// CHECK-NEXT:    call void @llvm.arm.mve.vst2q.p0i32.v4i32(i32* [[ADDR:%.*]], <4 x i32> [[VALUE_COERCE_FCA_0_0_EXTRACT]], <4 x i32> [[VALUE_COERCE_FCA_0_1_EXTRACT]], i32 0)
// CHECK-NEXT:    call void @llvm.arm.mve.vst2q.p0i32.v4i32(i32* [[ADDR]], <4 x i32> [[VALUE_COERCE_FCA_0_0_EXTRACT]], <4 x i32> [[VALUE_COERCE_FCA_0_1_EXTRACT]], i32 1)
// CHECK-NEXT:    ret void
//
void test_vst2q_u32(uint32_t *addr, uint32x4x2_t value)
{
#ifdef POLYMORPHIC
    vst2q(addr, value);
#else /* POLYMORPHIC */
    vst2q_u32(addr, value);
#endif /* POLYMORPHIC */
}

// CHECK-LABEL: @test_vst4q_s8(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[VALUE_COERCE_FCA_0_0_EXTRACT:%.*]] = extractvalue [[STRUCT_INT8X16X4_T:%.*]] %value.coerce, 0, 0
// CHECK-NEXT:    [[VALUE_COERCE_FCA_0_1_EXTRACT:%.*]] = extractvalue [[STRUCT_INT8X16X4_T]] %value.coerce, 0, 1
// CHECK-NEXT:    [[VALUE_COERCE_FCA_0_2_EXTRACT:%.*]] = extractvalue [[STRUCT_INT8X16X4_T]] %value.coerce, 0, 2
// CHECK-NEXT:    [[VALUE_COERCE_FCA_0_3_EXTRACT:%.*]] = extractvalue [[STRUCT_INT8X16X4_T]] %value.coerce, 0, 3
// CHECK-NEXT:    call void @llvm.arm.mve.vst4q.p0i8.v16i8(i8* [[ADDR:%.*]], <16 x i8> [[VALUE_COERCE_FCA_0_0_EXTRACT]], <16 x i8> [[VALUE_COERCE_FCA_0_1_EXTRACT]], <16 x i8> [[VALUE_COERCE_FCA_0_2_EXTRACT]], <16 x i8> [[VALUE_COERCE_FCA_0_3_EXTRACT]], i32 0)
// CHECK-NEXT:    call void @llvm.arm.mve.vst4q.p0i8.v16i8(i8* [[ADDR]], <16 x i8> [[VALUE_COERCE_FCA_0_0_EXTRACT]], <16 x i8> [[VALUE_COERCE_FCA_0_1_EXTRACT]], <16 x i8> [[VALUE_COERCE_FCA_0_2_EXTRACT]], <16 x i8> [[VALUE_COERCE_FCA_0_3_EXTRACT]], i32 1)
// CHECK-NEXT:    call void @llvm.arm.mve.vst4q.p0i8.v16i8(i8* [[ADDR]], <16 x i8> [[VALUE_COERCE_FCA_0_0_EXTRACT]], <16 x i8> [[VALUE_COERCE_FCA_0_1_EXTRACT]], <16 x i8> [[VALUE_COERCE_FCA_0_2_EXTRACT]], <16 x i8> [[VALUE_COERCE_FCA_0_3_EXTRACT]], i32 2)
// CHECK-NEXT:    call void @llvm.arm.mve.vst4q.p0i8.v16i8(i8* [[ADDR]], <16 x i8> [[VALUE_COERCE_FCA_0_0_EXTRACT]], <16 x i8> [[VALUE_COERCE_FCA_0_1_EXTRACT]], <16 x i8> [[VALUE_COERCE_FCA_0_2_EXTRACT]], <16 x i8> [[VALUE_COERCE_FCA_0_3_EXTRACT]], i32 3)
// CHECK-NEXT:    ret void
//
void test_vst4q_s8(int8_t *addr, int8x16x4_t value)
{
#ifdef POLYMORPHIC
    vst4q(addr, value);
#else /* POLYMORPHIC */
    vst4q_s8(addr, value);
#endif /* POLYMORPHIC */
}

// CHECK-LABEL: @test_vst2q_f16(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[VALUE_COERCE_FCA_0_0_EXTRACT:%.*]] = extractvalue [[STRUCT_FLOAT16X8X2_T:%.*]] %value.coerce, 0, 0
// CHECK-NEXT:    [[VALUE_COERCE_FCA_0_1_EXTRACT:%.*]] = extractvalue [[STRUCT_FLOAT16X8X2_T]] %value.coerce, 0, 1
// CHECK-NEXT:    call void @llvm.arm.mve.vst2q.p0f16.v8f16(half* [[ADDR:%.*]], <8 x half> [[VALUE_COERCE_FCA_0_0_EXTRACT]], <8 x half> [[VALUE_COERCE_FCA_0_1_EXTRACT]], i32 0)
// CHECK-NEXT:    call void @llvm.arm.mve.vst2q.p0f16.v8f16(half* [[ADDR]], <8 x half> [[VALUE_COERCE_FCA_0_0_EXTRACT]], <8 x half> [[VALUE_COERCE_FCA_0_1_EXTRACT]], i32 1)
// CHECK-NEXT:    ret void
//
void test_vst2q_f16(float16_t *addr, float16x8x2_t value)
{
#ifdef POLYMORPHIC
    vst2q(addr, value);
#else /* POLYMORPHIC */
    vst2q_f16(addr, value);
#endif /* POLYMORPHIC */
}

// CHECK-LABEL: @load_into_variable(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = call { <8 x i16>, <8 x i16> } @llvm.arm.mve.vld2q.v8i16.p0i16(i16* [[ADDR:%.*]])
// CHECK-NEXT:    [[TMP1:%.*]] = extractvalue { <8 x i16>, <8 x i16> } [[TMP0]], 0
// CHECK-NEXT:    [[TMP2:%.*]] = insertvalue [[STRUCT_UINT16X8X2_T:%.*]] undef, <8 x i16> [[TMP1]], 0, 0
// CHECK-NEXT:    [[TMP3:%.*]] = extractvalue { <8 x i16>, <8 x i16> } [[TMP0]], 1
// CHECK-NEXT:    [[TMP4:%.*]] = insertvalue [[STRUCT_UINT16X8X2_T]] [[TMP2]], <8 x i16> [[TMP3]], 0, 1
// CHECK-NEXT:    store <8 x i16> [[TMP1]], <8 x i16>* [[VALUES:%.*]], align 8
// CHECK-NEXT:    [[ARRAYIDX4:%.*]] = getelementptr inbounds <8 x i16>, <8 x i16>* [[VALUES]], i32 1
// CHECK-NEXT:    store <8 x i16> [[TMP3]], <8 x i16>* [[ARRAYIDX4]], align 8
// CHECK-NEXT:    ret void
//
void load_into_variable(const uint16_t *addr, uint16x8_t *values)
{
    uint16x8x2_t v;
#ifdef POLYMORPHIC
    v = vld2q(addr);
#else /* POLYMORPHIC */
    v = vld2q_u16(addr);
#endif /* POLYMORPHIC */
    values[0] = v.val[0];
    values[1] = v.val[1];
}

// CHECK-LABEL: @extract_one_vector(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = call { <4 x i32>, <4 x i32> } @llvm.arm.mve.vld2q.v4i32.p0i32(i32* [[ADDR:%.*]])
// CHECK-NEXT:    [[TMP1:%.*]] = extractvalue { <4 x i32>, <4 x i32> } [[TMP0]], 0
// CHECK-NEXT:    [[TMP2:%.*]] = insertvalue [[STRUCT_INT32X4X2_T:%.*]] undef, <4 x i32> [[TMP1]], 0, 0
// CHECK-NEXT:    [[TMP3:%.*]] = extractvalue { <4 x i32>, <4 x i32> } [[TMP0]], 1
// CHECK-NEXT:    [[TMP4:%.*]] = insertvalue [[STRUCT_INT32X4X2_T]] [[TMP2]], <4 x i32> [[TMP3]], 0, 1
// CHECK-NEXT:    ret <4 x i32> [[TMP1]]
//
int32x4_t extract_one_vector(const int32_t *addr)
{
#ifdef POLYMORPHIC
    return vld2q(addr).val[0];
#else /* POLYMORPHIC */
    return vld2q_s32(addr).val[0];
#endif /* POLYMORPHIC */
}

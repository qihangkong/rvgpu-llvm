//===- ArithToEmitC.cpp - Arith to EmitC Patterns ---------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements patterns to convert the Arith dialect to the EmitC
// dialect.
//
//===----------------------------------------------------------------------===//

#include "mlir/Conversion/ArithToEmitC/ArithToEmitC.h"

#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/EmitC/IR/EmitC.h"
#include "mlir/Transforms/DialectConversion.h"

using namespace mlir;

//===----------------------------------------------------------------------===//
// Conversion Patterns
//===----------------------------------------------------------------------===//

namespace {
class ArithConstantOpConversionPattern
    : public OpConversionPattern<arith::ConstantOp> {
public:
  using OpConversionPattern::OpConversionPattern;

  LogicalResult
  matchAndRewrite(arith::ConstantOp arithConst,
                  arith::ConstantOp::Adaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    rewriter.replaceOpWithNewOp<emitc::ConstantOp>(
        arithConst, arithConst.getType(), adaptor.getValue());
    return success();
  }
};

template <typename ArithOp, typename EmitCOp>
class ArithOpConversion final : public OpConversionPattern<ArithOp> {
public:
  using OpConversionPattern<ArithOp>::OpConversionPattern;

  LogicalResult
  matchAndRewrite(ArithOp arithOp, typename ArithOp::Adaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {

    rewriter.template replaceOpWithNewOp<EmitCOp>(arithOp, arithOp.getType(),
                                                  adaptor.getOperands());

    return success();
  }
};

template <typename ArithOp, typename EmitCOp>
class IntegerOpConversion final : public OpConversionPattern<ArithOp> {
public:
  using OpConversionPattern<ArithOp>::OpConversionPattern;

  LogicalResult
  matchAndRewrite(ArithOp op, typename ArithOp::Adaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {

    Type type = this->getTypeConverter()->convertType(op.getType());
    if (!isa_and_nonnull<IntegerType, IndexType>(type)) {
      return rewriter.notifyMatchFailure(op, "expected integer type");
    }

    if (type.isInteger(1)) {
      // arith expects wrap-around arithmethic, which doesn't happen on `bool`.
      return rewriter.notifyMatchFailure(op, "i1 type is not implemented");
    }

    Value lhs = adaptor.getLhs();
    Value rhs = adaptor.getRhs();
    Type arithmeticType = type;
    if ((type.isSignlessInteger() || type.isSignedInteger()) &&
        !bitEnumContainsAll(op.getOverflowFlags(),
                            arith::IntegerOverflowFlags::nsw)) {
      // If the C type is signed and the op doesn't guarantee "No Signed Wrap",
      // we compute in unsigned integers to avoid UB.
      arithmeticType = rewriter.getIntegerType(type.getIntOrFloatBitWidth(),
                                               /*isSigned=*/false);
    }
    if (arithmeticType != type) {
      lhs = rewriter.template create<emitc::CastOp>(op.getLoc(), arithmeticType,
                                                    lhs);
      rhs = rewriter.template create<emitc::CastOp>(op.getLoc(), arithmeticType,
                                                    rhs);
    }

    Value result = rewriter.template create<EmitCOp>(op.getLoc(),
                                                     arithmeticType, lhs, rhs);

    if (arithmeticType != type) {
      result =
          rewriter.template create<emitc::CastOp>(op.getLoc(), type, result);
    }
    rewriter.replaceOp(op, result);
    return success();
  }
};

class SelectOpConversion : public OpConversionPattern<arith::SelectOp> {
public:
  using OpConversionPattern<arith::SelectOp>::OpConversionPattern;

  LogicalResult
  matchAndRewrite(arith::SelectOp selectOp, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {

    Type dstType = getTypeConverter()->convertType(selectOp.getType());
    if (!dstType)
      return rewriter.notifyMatchFailure(selectOp, "type conversion failed");

    if (!adaptor.getCondition().getType().isInteger(1))
      return rewriter.notifyMatchFailure(
          selectOp,
          "can only be converted if condition is a scalar of type i1");

    rewriter.replaceOpWithNewOp<emitc::ConditionalOp>(selectOp, dstType,
                                                      adaptor.getOperands());

    return success();
  }
};

// Floating-point to integer conversions.
template <typename CastOp>
class FtoICastOpConversion : public OpConversionPattern<CastOp> {
private:
  bool floatToIntTruncates;

public:
  FtoICastOpConversion(const TypeConverter &typeConverter, MLIRContext *context,
                       bool optionFloatToIntTruncates)
      : OpConversionPattern<CastOp>(typeConverter, context),
        floatToIntTruncates(optionFloatToIntTruncates) {}

  LogicalResult
  matchAndRewrite(CastOp castOp, typename CastOp::Adaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {

    Type operandType = adaptor.getIn().getType();
    if (!emitc::isSupportedFloatType(operandType))
      return rewriter.notifyMatchFailure(castOp,
                                         "unsupported cast source type");

    if (!floatToIntTruncates)
      return rewriter.notifyMatchFailure(
          castOp, "conversion currently requires EmitC casts to use truncation "
                  "as rounding mode");

    Type dstType = this->getTypeConverter()->convertType(castOp.getType());
    if (!dstType)
      return rewriter.notifyMatchFailure(castOp, "type conversion failed");

    if (!emitc::isSupportedIntegerType(dstType))
      return rewriter.notifyMatchFailure(castOp,
                                         "unsupported cast destination type");

    // Convert to unsigned if it's the "ui" variant
    // Signless is interpreted as signed, so no need to cast for "si"
    Type actualResultType = dstType;
    if (isa<arith::FPToUIOp>(castOp)) {
      actualResultType =
          rewriter.getIntegerType(operandType.getIntOrFloatBitWidth(),
                                  /*isSigned=*/false);
    }

    Value result = rewriter.create<emitc::CastOp>(
        castOp.getLoc(), actualResultType, adaptor.getOperands());

    if (isa<arith::FPToUIOp>(castOp)) {
      result = rewriter.create<emitc::CastOp>(castOp.getLoc(), dstType, result);
    }
    rewriter.replaceOp(castOp, result);

    return success();
  }
};

// Integer to floating-point conversions.
template <typename CastOp>
class ItoFCastOpConversion : public OpConversionPattern<CastOp> {
public:
  ItoFCastOpConversion(const TypeConverter &typeConverter, MLIRContext *context)
      : OpConversionPattern<CastOp>(typeConverter, context) {}

  LogicalResult
  matchAndRewrite(CastOp castOp, typename CastOp::Adaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    // Vectors in particular are not supported
    Type operandType = adaptor.getIn().getType();
    if (!emitc::isSupportedIntegerType(operandType))
      return rewriter.notifyMatchFailure(castOp,
                                         "unsupported cast source type");

    Type dstType = this->getTypeConverter()->convertType(castOp.getType());
    if (!dstType)
      return rewriter.notifyMatchFailure(castOp, "type conversion failed");

    if (!emitc::isSupportedFloatType(dstType))
      return rewriter.notifyMatchFailure(castOp,
                                         "unsupported cast destination type");

    // Convert to unsigned if it's the "ui" variant
    // Signless is interpreted as signed, so no need to cast for "si"
    Type actualOperandType = operandType;
    if (isa<arith::UIToFPOp>(castOp)) {
      actualOperandType =
          rewriter.getIntegerType(operandType.getIntOrFloatBitWidth(),
                                  /*isSigned=*/false);
    }
    Value fpCastOperand = adaptor.getIn();
    if (actualOperandType != operandType) {
      fpCastOperand = rewriter.template create<emitc::CastOp>(
          castOp.getLoc(), actualOperandType, fpCastOperand);
    }
    rewriter.replaceOpWithNewOp<emitc::CastOp>(castOp, dstType, fpCastOperand);

    return success();
  }
};

} // namespace

//===----------------------------------------------------------------------===//
// Pattern population
//===----------------------------------------------------------------------===//

void mlir::populateArithToEmitCPatterns(TypeConverter &typeConverter,
                                        RewritePatternSet &patterns,
                                        bool optionFloatToIntTruncates) {
  MLIRContext *ctx = patterns.getContext();

  // clang-format off
  patterns.add<
    ArithConstantOpConversionPattern,
    ArithOpConversion<arith::AddFOp, emitc::AddOp>,
    ArithOpConversion<arith::DivFOp, emitc::DivOp>,
    ArithOpConversion<arith::MulFOp, emitc::MulOp>,
    ArithOpConversion<arith::SubFOp, emitc::SubOp>,
    IntegerOpConversion<arith::AddIOp, emitc::AddOp>,
    IntegerOpConversion<arith::MulIOp, emitc::MulOp>,
    IntegerOpConversion<arith::SubIOp, emitc::SubOp>,
    SelectOpConversion,
    ItoFCastOpConversion<arith::SIToFPOp>,
    ItoFCastOpConversion<arith::UIToFPOp>
  >(typeConverter, ctx)
  .add<
    FtoICastOpConversion<arith::FPToSIOp>,
    FtoICastOpConversion<arith::FPToUIOp>
  >(typeConverter, ctx, optionFloatToIntTruncates);
  // clang-format on
}

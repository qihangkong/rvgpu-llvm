//===- X86LegalizerInfo.cpp --------------------------------------*- C++ -*-==//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
/// \file
/// This file implements the targeting of the Machinelegalizer class for X86.
/// \todo This should be generated by TableGen.
//===----------------------------------------------------------------------===//

#include "X86LegalizerInfo.h"
#include "X86Subtarget.h"
#include "X86TargetMachine.h"
#include "llvm/CodeGen/ValueTypes.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/Type.h"
#include "llvm/Target/TargetOpcodes.h"

using namespace llvm;
using namespace TargetOpcode;

X86LegalizerInfo::X86LegalizerInfo(const X86Subtarget &STI,
                                   const X86TargetMachine &TM)
    : Subtarget(STI), TM(TM) {

  setLegalizerInfo32bit();
  setLegalizerInfo64bit();
  setLegalizerInfoSSE1();
  setLegalizerInfoSSE2();
  setLegalizerInfoSSE41();
  setLegalizerInfoAVX();
  setLegalizerInfoAVX2();
  setLegalizerInfoAVX512();
  setLegalizerInfoAVX512DQ();
  setLegalizerInfoAVX512BW();

  computeTables();
}

void X86LegalizerInfo::setLegalizerInfo32bit() {

  if (Subtarget.is64Bit())
    return;

  const LLT p0 = LLT::pointer(0, 32);
  const LLT s1 = LLT::scalar(1);
  const LLT s8 = LLT::scalar(8);
  const LLT s16 = LLT::scalar(16);
  const LLT s32 = LLT::scalar(32);
  const LLT s64 = LLT::scalar(64);

  for (unsigned BinOp : {G_ADD, G_SUB, G_MUL, G_AND, G_OR, G_XOR})
    for (auto Ty : {s8, s16, s32})
      setAction({BinOp, Ty}, Legal);

  for (unsigned Op : {G_UADDE}) {
    setAction({Op, s32}, Legal);
    setAction({Op, 1, s1}, Legal);
  }

  for (unsigned MemOp : {G_LOAD, G_STORE}) {
    for (auto Ty : {s8, s16, s32, p0})
      setAction({MemOp, Ty}, Legal);

    setAction({MemOp, s1}, WidenScalar);
    // And everything's fine in addrspace 0.
    setAction({MemOp, 1, p0}, Legal);
  }

  // Pointer-handling
  setAction({G_FRAME_INDEX, p0}, Legal);
  setAction({G_GLOBAL_VALUE, p0}, Legal);

  setAction({G_GEP, p0}, Legal);
  setAction({G_GEP, 1, s32}, Legal);

  for (auto Ty : {s1, s8, s16})
    setAction({G_GEP, 1, Ty}, WidenScalar);

  // Constants
  for (auto Ty : {s8, s16, s32, p0})
    setAction({TargetOpcode::G_CONSTANT, Ty}, Legal);

  setAction({TargetOpcode::G_CONSTANT, s1}, WidenScalar);
  setAction({TargetOpcode::G_CONSTANT, s64}, NarrowScalar);

  // Extensions
  for (auto Ty : {s8, s16, s32}) {
    setAction({G_ZEXT, Ty}, Legal);
    setAction({G_SEXT, Ty}, Legal);
  }

  for (auto Ty : {s1, s8, s16}) {
    setAction({G_ZEXT, 1, Ty}, Legal);
    setAction({G_SEXT, 1, Ty}, Legal);
  }

  // Comparison
  setAction({G_ICMP, s1}, Legal);

  for (auto Ty : {s8, s16, s32, p0})
    setAction({G_ICMP, 1, Ty}, Legal);
}

void X86LegalizerInfo::setLegalizerInfo64bit() {

  if (!Subtarget.is64Bit())
    return;

  const LLT p0 = LLT::pointer(0, TM.getPointerSize() * 8);
  const LLT s1 = LLT::scalar(1);
  const LLT s8 = LLT::scalar(8);
  const LLT s16 = LLT::scalar(16);
  const LLT s32 = LLT::scalar(32);
  const LLT s64 = LLT::scalar(64);

  for (unsigned BinOp : {G_ADD, G_SUB, G_MUL, G_AND, G_OR, G_XOR})
    for (auto Ty : {s8, s16, s32, s64})
      setAction({BinOp, Ty}, Legal);

  for (unsigned MemOp : {G_LOAD, G_STORE}) {
    for (auto Ty : {s8, s16, s32, s64, p0})
      setAction({MemOp, Ty}, Legal);

    setAction({MemOp, s1}, WidenScalar);
    // And everything's fine in addrspace 0.
    setAction({MemOp, 1, p0}, Legal);
  }

  // Pointer-handling
  setAction({G_FRAME_INDEX, p0}, Legal);
  setAction({G_GLOBAL_VALUE, p0}, Legal);

  setAction({G_GEP, p0}, Legal);
  setAction({G_GEP, 1, s32}, Legal);
  setAction({G_GEP, 1, s64}, Legal);

  for (auto Ty : {s1, s8, s16})
    setAction({G_GEP, 1, Ty}, WidenScalar);

  // Constants
  for (auto Ty : {s8, s16, s32, s64, p0})
    setAction({TargetOpcode::G_CONSTANT, Ty}, Legal);

  setAction({TargetOpcode::G_CONSTANT, s1}, WidenScalar);

  // Extensions
  for (auto Ty : {s8, s16, s32, s64}) {
    setAction({G_ZEXT, Ty}, Legal);
    setAction({G_SEXT, Ty}, Legal);
  }

  for (auto Ty : {s1, s8, s16, s32}) {
    setAction({G_ZEXT, 1, Ty}, Legal);
    setAction({G_SEXT, 1, Ty}, Legal);
  }

  // Comparison
  setAction({G_ICMP, s1}, Legal);

  for (auto Ty : {s8, s16, s32, s64, p0})
    setAction({G_ICMP, 1, Ty}, Legal);
}

void X86LegalizerInfo::setLegalizerInfoSSE1() {
  if (!Subtarget.hasSSE1())
    return;

  const LLT s32 = LLT::scalar(32);
  const LLT v4s32 = LLT::vector(4, 32);
  const LLT v2s64 = LLT::vector(2, 64);

  for (unsigned BinOp : {G_FADD, G_FSUB, G_FMUL, G_FDIV})
    for (auto Ty : {s32, v4s32})
      setAction({BinOp, Ty}, Legal);

  for (unsigned MemOp : {G_LOAD, G_STORE})
    for (auto Ty : {v4s32, v2s64})
      setAction({MemOp, Ty}, Legal);
}

void X86LegalizerInfo::setLegalizerInfoSSE2() {
  if (!Subtarget.hasSSE2())
    return;

  const LLT s64 = LLT::scalar(64);
  const LLT v16s8 = LLT::vector(16, 8);
  const LLT v8s16 = LLT::vector(8, 16);
  const LLT v4s32 = LLT::vector(4, 32);
  const LLT v2s64 = LLT::vector(2, 64);

  for (unsigned BinOp : {G_FADD, G_FSUB, G_FMUL, G_FDIV})
    for (auto Ty : {s64, v2s64})
      setAction({BinOp, Ty}, Legal);

  for (unsigned BinOp : {G_ADD, G_SUB})
    for (auto Ty : {v16s8, v8s16, v4s32, v2s64})
      setAction({BinOp, Ty}, Legal);

  setAction({G_MUL, v8s16}, Legal);
}

void X86LegalizerInfo::setLegalizerInfoSSE41() {
  if (!Subtarget.hasSSE41())
    return;

  const LLT v4s32 = LLT::vector(4, 32);

  setAction({G_MUL, v4s32}, Legal);
}

void X86LegalizerInfo::setLegalizerInfoAVX() {
  if (!Subtarget.hasAVX())
    return;

  const LLT v16s8 = LLT::vector(16, 8);
  const LLT v8s16 = LLT::vector(8, 16);
  const LLT v4s32 = LLT::vector(4, 32);
  const LLT v2s64 = LLT::vector(2, 64);

  const LLT v32s8 = LLT::vector(32, 8);
  const LLT v16s16 = LLT::vector(16, 16);
  const LLT v8s32 = LLT::vector(8, 32);
  const LLT v4s64 = LLT::vector(4, 64);

  for (unsigned MemOp : {G_LOAD, G_STORE})
    for (auto Ty : {v8s32, v4s64})
      setAction({MemOp, Ty}, Legal);

  for (auto Ty : {v32s8, v16s16, v8s32, v4s64}) {
    setAction({G_INSERT, Ty}, Legal);
    setAction({G_EXTRACT, 1, Ty}, Legal);
  }
  for (auto Ty : {v16s8, v8s16, v4s32, v2s64}) {
    setAction({G_INSERT, 1, Ty}, Legal);
    setAction({G_EXTRACT, Ty}, Legal);
  }
}

void X86LegalizerInfo::setLegalizerInfoAVX2() {
  if (!Subtarget.hasAVX2())
    return;

  const LLT v32s8 = LLT::vector(32, 8);
  const LLT v16s16 = LLT::vector(16, 16);
  const LLT v8s32 = LLT::vector(8, 32);
  const LLT v4s64 = LLT::vector(4, 64);

  for (unsigned BinOp : {G_ADD, G_SUB})
    for (auto Ty : {v32s8, v16s16, v8s32, v4s64})
      setAction({BinOp, Ty}, Legal);

  for (auto Ty : {v16s16, v8s32})
    setAction({G_MUL, Ty}, Legal);
}

void X86LegalizerInfo::setLegalizerInfoAVX512() {
  if (!Subtarget.hasAVX512())
    return;

  const LLT v16s8 = LLT::vector(16, 8);
  const LLT v8s16 = LLT::vector(8, 16);
  const LLT v4s32 = LLT::vector(4, 32);
  const LLT v2s64 = LLT::vector(2, 64);

  const LLT v32s8 = LLT::vector(32, 8);
  const LLT v16s16 = LLT::vector(16, 16);
  const LLT v8s32 = LLT::vector(8, 32);
  const LLT v4s64 = LLT::vector(4, 64);

  const LLT v64s8 = LLT::vector(64, 8);
  const LLT v32s16 = LLT::vector(32, 16);
  const LLT v16s32 = LLT::vector(16, 32);
  const LLT v8s64 = LLT::vector(8, 64);

  for (unsigned BinOp : {G_ADD, G_SUB})
    for (auto Ty : {v16s32, v8s64})
      setAction({BinOp, Ty}, Legal);

  setAction({G_MUL, v16s32}, Legal);

  for (unsigned MemOp : {G_LOAD, G_STORE})
    for (auto Ty : {v16s32, v8s64})
      setAction({MemOp, Ty}, Legal);

  for (auto Ty : {v64s8, v32s16, v16s32, v8s64}) {
    setAction({G_INSERT, Ty}, Legal);
    setAction({G_EXTRACT, 1, Ty}, Legal);
  }
  for (auto Ty : {v32s8, v16s16, v8s32, v4s64, v16s8, v8s16, v4s32, v2s64}) {
    setAction({G_INSERT, 1, Ty}, Legal);
    setAction({G_EXTRACT, Ty}, Legal);
  }

  /************ VLX *******************/
  if (!Subtarget.hasVLX())
    return;

  for (auto Ty : {v4s32, v8s32})
    setAction({G_MUL, Ty}, Legal);
}

void X86LegalizerInfo::setLegalizerInfoAVX512DQ() {
  if (!(Subtarget.hasAVX512() && Subtarget.hasDQI()))
    return;

  const LLT v8s64 = LLT::vector(8, 64);

  setAction({G_MUL, v8s64}, Legal);

  /************ VLX *******************/
  if (!Subtarget.hasVLX())
    return;

  const LLT v2s64 = LLT::vector(2, 64);
  const LLT v4s64 = LLT::vector(4, 64);

  for (auto Ty : {v2s64, v4s64})
    setAction({G_MUL, Ty}, Legal);
}

void X86LegalizerInfo::setLegalizerInfoAVX512BW() {
  if (!(Subtarget.hasAVX512() && Subtarget.hasBWI()))
    return;

  const LLT v64s8 = LLT::vector(64, 8);
  const LLT v32s16 = LLT::vector(32, 16);

  for (unsigned BinOp : {G_ADD, G_SUB})
    for (auto Ty : {v64s8, v32s16})
      setAction({BinOp, Ty}, Legal);

  setAction({G_MUL, v32s16}, Legal);

  /************ VLX *******************/
  if (!Subtarget.hasVLX())
    return;

  const LLT v8s16 = LLT::vector(8, 16);
  const LLT v16s16 = LLT::vector(16, 16);

  for (auto Ty : {v8s16, v16s16})
    setAction({G_MUL, Ty}, Legal);
}

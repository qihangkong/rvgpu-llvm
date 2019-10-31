//===- XtensaRegisterInfo.cpp - Xtensa Register Information ---------------===//
//
//                     The LLVM Compiler Infrastructure
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file contains the Xtensa implementation of the TargetRegisterInfo class.
//
//===----------------------------------------------------------------------===//

#include "XtensaRegisterInfo.h"
#include "XtensaInstrInfo.h"
#include "XtensaSubtarget.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/raw_ostream.h"

#define DEBUG_TYPE "xtensa-reg-info"

#define GET_REGINFO_TARGET_DESC
#include "XtensaGenRegisterInfo.inc"

using namespace llvm;

XtensaRegisterInfo::XtensaRegisterInfo(const XtensaSubtarget &STI)
    : XtensaGenRegisterInfo(Xtensa::A0), Subtarget(STI) {}

const uint16_t *
XtensaRegisterInfo::getCalleeSavedRegs(const MachineFunction *MF) const {
  return CSR_Xtensa_SaveList;
}

const uint32_t *
XtensaRegisterInfo::getCallPreservedMask(const MachineFunction &MF,
                                         CallingConv::ID) const {
  return CSR_Xtensa_RegMask;
}

BitVector XtensaRegisterInfo::getReservedRegs(const MachineFunction &MF) const {
  BitVector Reserved(getNumRegs());
  const TargetFrameLowering *TFI = MF.getSubtarget().getFrameLowering();

  Reserved.set(Xtensa::A0);
  if (TFI->hasFP(MF)) {
    // fp is the frame pointer.  Reserve all aliases.
    Reserved.set(Xtensa::A15);
  }

  // sp is the stack pointer.  Reserve all aliases.
  Reserved.set(Xtensa::SP);
  Reserved.set(Xtensa::A7);
  return Reserved;
}

void XtensaRegisterInfo::eliminateFrameIndex(MachineBasicBlock::iterator II,
                                             int SPAdj, unsigned FIOperandNum,
                                             RegScavenger *RS) const {
  report_fatal_error("Eliminate frame index not supported yet");
}

Register XtensaRegisterInfo::getFrameRegister(const MachineFunction &MF) const {
  const TargetFrameLowering *TFI = MF.getSubtarget().getFrameLowering();
  return TFI->hasFP(MF) ? (Xtensa::A15) : Xtensa::SP;
}

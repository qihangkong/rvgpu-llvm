//===-- SILowerControlFlow.cpp - Use predicates for control flow ----------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
/// \file
/// \brief This pass lowers the pseudo control flow instructions to real
/// machine instructions.
///
/// All control flow is handled using predicated instructions and
/// a predicate stack.  Each Scalar ALU controls the operations of 64 Vector
/// ALUs.  The Scalar ALU can update the predicate for any of the Vector ALUs
/// by writting to the 64-bit EXEC register (each bit corresponds to a
/// single vector ALU).  Typically, for predicates, a vector ALU will write
/// to its bit of the VCC register (like EXEC VCC is 64-bits, one for each
/// Vector ALU) and then the ScalarALU will AND the VCC register with the
/// EXEC to update the predicates.
///
/// For example:
/// %VCC = V_CMP_GT_F32 %VGPR1, %VGPR2
/// %SGPR0 = SI_IF %VCC
///   %VGPR0 = V_ADD_F32 %VGPR0, %VGPR0
/// %SGPR0 = SI_ELSE %SGPR0
///   %VGPR0 = V_SUB_F32 %VGPR0, %VGPR0
/// SI_END_CF %SGPR0
///
/// becomes:
///
/// %SGPR0 = S_AND_SAVEEXEC_B64 %VCC  // Save and update the exec mask
/// %SGPR0 = S_XOR_B64 %SGPR0, %EXEC  // Clear live bits from saved exec mask
/// S_CBRANCH_EXECZ label0            // This instruction is an optional
///                                   // optimization which allows us to
///                                   // branch if all the bits of
///                                   // EXEC are zero.
/// %VGPR0 = V_ADD_F32 %VGPR0, %VGPR0 // Do the IF block of the branch
///
/// label0:
/// %SGPR0 = S_OR_SAVEEXEC_B64 %EXEC   // Restore the exec mask for the Then block
/// %EXEC = S_XOR_B64 %SGPR0, %EXEC    // Clear live bits from saved exec mask
/// S_BRANCH_EXECZ label1              // Use our branch optimization
///                                    // instruction again.
/// %VGPR0 = V_SUB_F32 %VGPR0, %VGPR   // Do the THEN block
/// label1:
/// %EXEC = S_OR_B64 %EXEC, %SGPR0     // Re-enable saved exec mask bits
//===----------------------------------------------------------------------===//

#include "AMDGPU.h"
#include "AMDGPUSubtarget.h"
#include "SIInstrInfo.h"
#include "SIMachineFunctionInfo.h"
#include "llvm/CodeGen/LivePhysRegs.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"

using namespace llvm;

#define DEBUG_TYPE "si-lower-control-flow"

namespace {

class SILowerControlFlow : public MachineFunctionPass {
private:
  const SIRegisterInfo *TRI;
  const SIInstrInfo *TII;
  LiveIntervals *LIS;
  MachineRegisterInfo *MRI;

  void emitIf(MachineInstr &MI);
  void emitElse(MachineInstr &MI);
  void emitBreak(MachineInstr &MI);
  void emitIfBreak(MachineInstr &MI);
  void emitElseBreak(MachineInstr &MI);
  void emitLoop(MachineInstr &MI);
  void emitEndCf(MachineInstr &MI);

public:
  static char ID;

  SILowerControlFlow() :
    MachineFunctionPass(ID),
    TRI(nullptr),
    TII(nullptr),
    LIS(nullptr),
    MRI(nullptr) {}

  bool runOnMachineFunction(MachineFunction &MF) override;

  StringRef getPassName() const override {
    return "SI Lower control flow pseudo instructions";
  }

  void getAnalysisUsage(AnalysisUsage &AU) const override {
    // Should preserve the same set that TwoAddressInstructions does.
    AU.addPreserved<SlotIndexes>();
    AU.addPreserved<LiveIntervals>();
    AU.addPreservedID(LiveVariablesID);
    AU.addPreservedID(MachineLoopInfoID);
    AU.addPreservedID(MachineDominatorsID);
    AU.setPreservesCFG();
    MachineFunctionPass::getAnalysisUsage(AU);
  }
};

} // End anonymous namespace

char SILowerControlFlow::ID = 0;

INITIALIZE_PASS(SILowerControlFlow, DEBUG_TYPE,
               "SI lower control flow", false, false)

static void setImpSCCDefDead(MachineInstr &MI, bool IsDead) {
  MachineOperand &ImpDefSCC = MI.getOperand(3);
  assert(ImpDefSCC.getReg() == AMDGPU::SCC && ImpDefSCC.isDef());

  ImpDefSCC.setIsDead(IsDead);
}

char &llvm::SILowerControlFlowID = SILowerControlFlow::ID;

void SILowerControlFlow::emitIf(MachineInstr &MI) {
  MachineBasicBlock &MBB = *MI.getParent();
  const DebugLoc &DL = MI.getDebugLoc();
  MachineBasicBlock::iterator I(&MI);

  MachineOperand &SaveExec = MI.getOperand(0);
  MachineOperand &Cond = MI.getOperand(1);
  assert(SaveExec.getSubReg() == AMDGPU::NoSubRegister &&
         Cond.getSubReg() == AMDGPU::NoSubRegister);

  unsigned SaveExecReg = SaveExec.getReg();

  MachineOperand &ImpDefSCC = MI.getOperand(4);
  assert(ImpDefSCC.getReg() == AMDGPU::SCC && ImpDefSCC.isDef());

  // Add an implicit def of exec to discourage scheduling VALU after this which
  // will interfere with trying to form s_and_saveexec_b64 later.
  MachineInstr *CopyExec =
    BuildMI(MBB, I, DL, TII->get(AMDGPU::COPY), SaveExecReg)
    .addReg(AMDGPU::EXEC)
    .addReg(AMDGPU::EXEC, RegState::ImplicitDefine);

  unsigned Tmp = MRI->createVirtualRegister(&AMDGPU::SReg_64RegClass);

  MachineInstr *And =
    BuildMI(MBB, I, DL, TII->get(AMDGPU::S_AND_B64), Tmp)
    .addReg(SaveExecReg)
    //.addReg(AMDGPU::EXEC)
    .addReg(Cond.getReg());
  setImpSCCDefDead(*And, true);

  MachineInstr *Xor =
    BuildMI(MBB, I, DL, TII->get(AMDGPU::S_XOR_B64), SaveExecReg)
    .addReg(Tmp)
    .addReg(SaveExecReg);
  setImpSCCDefDead(*Xor, ImpDefSCC.isDead());

  // Use a copy that is a terminator to get correct spill code placement it with
  // fast regalloc.
  MachineInstr *SetExec =
    BuildMI(MBB, I, DL, TII->get(AMDGPU::S_MOV_B64_term), AMDGPU::EXEC)
    .addReg(Tmp, RegState::Kill);

  // Insert a pseudo terminator to help keep the verifier happy. This will also
  // be used later when inserting skips.
  MachineInstr *NewBr =
    BuildMI(MBB, I, DL, TII->get(AMDGPU::SI_MASK_BRANCH))
    .addOperand(MI.getOperand(2));

  if (!LIS) {
    MI.eraseFromParent();
    return;
  }

  LIS->InsertMachineInstrInMaps(*CopyExec);

  // Replace with and so we don't need to fix the live interval for condition
  // register.
  LIS->ReplaceMachineInstrInMaps(MI, *And);

  LIS->InsertMachineInstrInMaps(*Xor);
  LIS->InsertMachineInstrInMaps(*SetExec);
  LIS->InsertMachineInstrInMaps(*NewBr);

  LIS->removeRegUnit(*MCRegUnitIterator(AMDGPU::EXEC, TRI));
  MI.eraseFromParent();

  // FIXME: Is there a better way of adjusting the liveness? It shouldn't be
  // hard to add another def here but I'm not sure how to correctly update the
  // valno.
  LIS->removeInterval(SaveExecReg);
  LIS->createAndComputeVirtRegInterval(SaveExecReg);
  LIS->createAndComputeVirtRegInterval(Tmp);
}

void SILowerControlFlow::emitElse(MachineInstr &MI) {
  MachineBasicBlock &MBB = *MI.getParent();
  const DebugLoc &DL = MI.getDebugLoc();

  unsigned DstReg = MI.getOperand(0).getReg();
  assert(MI.getOperand(0).getSubReg() == AMDGPU::NoSubRegister);

  bool ExecModified = MI.getOperand(3).getImm() != 0;
  MachineBasicBlock::iterator Start = MBB.begin();

  // We are running before TwoAddressInstructions, and si_else's operands are
  // tied. In order to correctly tie the registers, split this into a copy of
  // the src like it does.
  BuildMI(MBB, Start, DL, TII->get(AMDGPU::COPY), DstReg)
    .addOperand(MI.getOperand(1)); // Saved EXEC

  // This must be inserted before phis and any spill code inserted before the
  // else.
  MachineInstr *OrSaveExec =
    BuildMI(MBB, Start, DL, TII->get(AMDGPU::S_OR_SAVEEXEC_B64), DstReg)
    .addReg(DstReg);

  MachineBasicBlock *DestBB = MI.getOperand(2).getMBB();

  MachineBasicBlock::iterator ElsePt(MI);

  if (ExecModified) {
    MachineInstr *And =
      BuildMI(MBB, ElsePt, DL, TII->get(AMDGPU::S_AND_B64), DstReg)
      .addReg(AMDGPU::EXEC)
      .addReg(DstReg);

    if (LIS)
      LIS->InsertMachineInstrInMaps(*And);
  }

  MachineInstr *Xor =
    BuildMI(MBB, ElsePt, DL, TII->get(AMDGPU::S_XOR_B64_term), AMDGPU::EXEC)
    .addReg(AMDGPU::EXEC)
    .addReg(DstReg);

  MachineInstr *Branch =
    BuildMI(MBB, ElsePt, DL, TII->get(AMDGPU::SI_MASK_BRANCH))
    .addMBB(DestBB);

  if (!LIS) {
    MI.eraseFromParent();
    return;
  }

  LIS->RemoveMachineInstrFromMaps(MI);
  MI.eraseFromParent();

  LIS->InsertMachineInstrInMaps(*OrSaveExec);

  LIS->InsertMachineInstrInMaps(*Xor);
  LIS->InsertMachineInstrInMaps(*Branch);

  // src reg is tied to dst reg.
  LIS->removeInterval(DstReg);
  LIS->createAndComputeVirtRegInterval(DstReg);

  // Let this be recomputed.
  LIS->removeRegUnit(*MCRegUnitIterator(AMDGPU::EXEC, TRI));
}

void SILowerControlFlow::emitBreak(MachineInstr &MI) {
  MachineBasicBlock &MBB = *MI.getParent();
  const DebugLoc &DL = MI.getDebugLoc();
  unsigned Dst = MI.getOperand(0).getReg();

  MachineInstr *Or =
    BuildMI(MBB, &MI, DL, TII->get(AMDGPU::S_OR_B64), Dst)
    .addReg(AMDGPU::EXEC)
    .addOperand(MI.getOperand(1));

  if (LIS)
    LIS->ReplaceMachineInstrInMaps(MI, *Or);
  MI.eraseFromParent();
}

void SILowerControlFlow::emitIfBreak(MachineInstr &MI) {
  MI.setDesc(TII->get(AMDGPU::S_OR_B64));
}

void SILowerControlFlow::emitElseBreak(MachineInstr &MI) {
  MI.setDesc(TII->get(AMDGPU::S_OR_B64));
}

void SILowerControlFlow::emitLoop(MachineInstr &MI) {
  MachineBasicBlock &MBB = *MI.getParent();
  const DebugLoc &DL = MI.getDebugLoc();

  MachineInstr *AndN2 =
    BuildMI(MBB, &MI, DL, TII->get(AMDGPU::S_ANDN2_B64_term), AMDGPU::EXEC)
    .addReg(AMDGPU::EXEC)
    .addOperand(MI.getOperand(0));

  MachineInstr *Branch =
    BuildMI(MBB, &MI, DL, TII->get(AMDGPU::S_CBRANCH_EXECNZ))
    .addOperand(MI.getOperand(1));

  if (LIS) {
    LIS->ReplaceMachineInstrInMaps(MI, *AndN2);
    LIS->InsertMachineInstrInMaps(*Branch);
  }

  MI.eraseFromParent();
}

void SILowerControlFlow::emitEndCf(MachineInstr &MI) {
  MachineBasicBlock &MBB = *MI.getParent();
  const DebugLoc &DL = MI.getDebugLoc();

  MachineBasicBlock::iterator InsPt = MBB.begin();
  MachineInstr *NewMI =
    BuildMI(MBB, InsPt, DL, TII->get(AMDGPU::S_OR_B64), AMDGPU::EXEC)
    .addReg(AMDGPU::EXEC)
    .addOperand(MI.getOperand(0));

  if (LIS)
    LIS->ReplaceMachineInstrInMaps(MI, *NewMI);

  MI.eraseFromParent();

  if (LIS)
    LIS->handleMove(*NewMI);
}

bool SILowerControlFlow::runOnMachineFunction(MachineFunction &MF) {
  const SISubtarget &ST = MF.getSubtarget<SISubtarget>();
  TII = ST.getInstrInfo();
  TRI = &TII->getRegisterInfo();

  // This doesn't actually need LiveIntervals, but we can preserve them.
  LIS = getAnalysisIfAvailable<LiveIntervals>();
  MRI = &MF.getRegInfo();

  MachineFunction::iterator NextBB;
  for (MachineFunction::iterator BI = MF.begin(), BE = MF.end();
       BI != BE; BI = NextBB) {
    NextBB = std::next(BI);
    MachineBasicBlock &MBB = *BI;

    MachineBasicBlock::iterator I, Next;

    for (I = MBB.begin(); I != MBB.end(); I = Next) {
      Next = std::next(I);
      MachineInstr &MI = *I;

      switch (MI.getOpcode()) {
      case AMDGPU::SI_IF:
        emitIf(MI);
        break;

      case AMDGPU::SI_ELSE:
        emitElse(MI);
        break;

      case AMDGPU::SI_BREAK:
        emitBreak(MI);
        break;

      case AMDGPU::SI_IF_BREAK:
        emitIfBreak(MI);
        break;

      case AMDGPU::SI_ELSE_BREAK:
        emitElseBreak(MI);
        break;

      case AMDGPU::SI_LOOP:
        emitLoop(MI);
        break;

      case AMDGPU::SI_END_CF:
        emitEndCf(MI);
        break;

      default:
        break;
      }
    }
  }

  return true;
}

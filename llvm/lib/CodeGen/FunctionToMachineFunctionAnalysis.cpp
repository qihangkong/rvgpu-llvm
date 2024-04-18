//===- FunctionToMachineFunctionAnalysis.cpp ------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file contains the definitions of the FunctionToMachineFunctionAnalysis
// members.
//
//===----------------------------------------------------------------------===//

#include "llvm/CodeGen/FunctionToMachineFunctionAnalysis.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineModuleInfo.h"
#include "llvm/Target/TargetMachine.h"

using namespace llvm;

AnalysisKey FunctionToMachineFunctionAnalysis::Key;

bool FunctionToMachineFunctionAnalysis::Result::invalidate(
    Function &, const PreservedAnalyses &PA,
    FunctionAnalysisManager::Invalidator &) {
  // Unless it is invalidated explicitly, it should remain preserved.
  auto PAC = PA.getChecker<FunctionToMachineFunctionAnalysis>();
  return !PAC.preservedWhenStateless();
}

FunctionToMachineFunctionAnalysis::Result
FunctionToMachineFunctionAnalysis::run(Function &F,
                                       FunctionAnalysisManager &FAM) {
  auto &Context = F.getContext();
  const TargetSubtargetInfo &STI = *TM->getSubtargetImpl(F);
  auto &MMI = FAM.getResult<ModuleAnalysisManagerFunctionProxy>(F)
                  .getCachedResult<MachineModuleAnalysis>(*F.getParent())
                  ->getMMI();
  auto MF = std::make_unique<MachineFunction>(
      F, *TM, STI, Context.generateMachineFunctionNum(F), MMI);
  MF->initTargetMachineFunctionInfo(STI);

  // MRI callback for target specific initializations.
  TM->registerMachineRegisterInfoCallback(*MF);

  return Result(std::move(MF));
}

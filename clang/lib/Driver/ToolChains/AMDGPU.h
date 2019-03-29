//===--- AMDGPU.h - AMDGPU ToolChain Implementations ----------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_CLANG_LIB_DRIVER_TOOLCHAINS_AMDGPU_H
#define LLVM_CLANG_LIB_DRIVER_TOOLCHAINS_AMDGPU_H

#include "Gnu.h"
#include "clang/Driver/Options.h"
#include "clang/Driver/Tool.h"
#include "clang/Driver/ToolChain.h"
#include <map>

namespace clang {
namespace driver {
namespace tools {
namespace amdgpu {

class LLVM_LIBRARY_VISIBILITY Linker : public GnuTool {
public:
  Linker(const ToolChain &TC) : GnuTool("amdgpu::Linker", "ld.lld", TC) {}
  bool isLinkJob() const override { return true; }
  bool hasIntegratedCPP() const override { return false; }
  void ConstructJob(Compilation &C, const JobAction &JA,
                    const InputInfo &Output, const InputInfoList &Inputs,
                    const llvm::opt::ArgList &TCArgs,
                    const char *LinkingOutput) const override;
};

void getAMDGPUTargetFeatures(const Driver &D, const llvm::opt::ArgList &Args,
                             std::vector<StringRef> &Features);

} // end namespace amdgpu
} // end namespace tools

namespace toolchains {

class LLVM_LIBRARY_VISIBILITY AMDGPUToolChain : public Generic_ELF {

private:
  const std::map<options::ID, const StringRef> OptionsDefault;

protected:
  Tool *buildLinker() const override;
  const StringRef getOptionDefault(options::ID OptID) const {
    auto opt = OptionsDefault.find(OptID);
    assert(opt != OptionsDefault.end() && "No Default for Option");
    return opt->second;
  }

public:
  AMDGPUToolChain(const Driver &D, const llvm::Triple &Triple,
                  const llvm::opt::ArgList &Args);
  unsigned GetDefaultDwarfVersion() const override { return 5; }
  bool IsIntegratedAssemblerDefault() const override { return true; }
  llvm::opt::DerivedArgList *
  TranslateArgs(const llvm::opt::DerivedArgList &Args, StringRef BoundArch,
                Action::OffloadKind DeviceOffloadKind) const override;

  void addClangTargetOptions(const llvm::opt::ArgList &DriverArgs,
                             llvm::opt::ArgStringList &CC1Args,
                             Action::OffloadKind DeviceOffloadKind) const override;
};

} // end namespace toolchains
} // end namespace driver
} // end namespace clang

#endif // LLVM_CLANG_LIB_DRIVER_TOOLCHAINS_AMDGPU_H

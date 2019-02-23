//===- SelectionDAGAddressAnalysis.h - DAG Address Analysis -----*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_CODEGEN_SELECTIONDAGADDRESSANALYSIS_H
#define LLVM_CODEGEN_SELECTIONDAGADDRESSANALYSIS_H

#include "llvm/CodeGen/SelectionDAGNodes.h"
#include <cstdint>

namespace llvm {

class SelectionDAG;

/// Helper struct to parse and store a memory address as base + index + offset.
/// We ignore sign extensions when it is safe to do so.
/// The following two expressions are not equivalent. To differentiate we need
/// to store whether there was a sign extension involved in the index
/// computation.
///  (load (i64 add (i64 copyfromreg %c)
///                 (i64 signextend (add (i8 load %index)
///                                      (i8 1))))
/// vs
///
/// (load (i64 add (i64 copyfromreg %c)
///                (i64 signextend (i32 add (i32 signextend (i8 load %index))
///                                         (i32 1)))))
class BaseIndexOffset {
private:
  SDValue Base;
  SDValue Index;
  int64_t Offset = 0;
  bool IsIndexSignExt = false;

public:
  BaseIndexOffset() = default;
  BaseIndexOffset(SDValue Base, SDValue Index, int64_t Offset,
                  bool IsIndexSignExt)
      : Base(Base), Index(Index), Offset(Offset),
        IsIndexSignExt(IsIndexSignExt) {}

  SDValue getBase() { return Base; }
  SDValue getBase() const { return Base; }
  SDValue getIndex() { return Index; }
  SDValue getIndex() const { return Index; }

  // Returns true if `Other` and `*this` are both some offset from the same base
  // pointer. In that case, `Off` is set to the offset between `*this` and
  // `Other` (negative if `Other` is before `*this`).
  bool equalBaseIndex(const BaseIndexOffset &Other, const SelectionDAG &DAG,
                      int64_t &Off) const;

  bool equalBaseIndex(const BaseIndexOffset &Other,
                      const SelectionDAG &DAG) const {
    int64_t Off;
    return equalBaseIndex(Other, DAG, Off);
  }

  // Returns true if `Other` (with size `OtherSize`) can be proven to be fully
  // contained in `*this` (with size `Size`).
  bool contains(int64_t Size, const BaseIndexOffset &Other, int64_t OtherSize,
                const SelectionDAG &DAG) const {
    int64_t Offset;
    return contains(Size, Other, OtherSize, DAG, Offset);
  }

  bool contains(int64_t Size, const BaseIndexOffset &Other, int64_t OtherSize,
                const SelectionDAG &DAG, int64_t &Offset) const;

  // Returns true `BasePtr0` and `BasePtr1` can be proven to alias/not alias, in
  // which case `IsAlias` is set to true/false.
  static bool computeAliasing(const BaseIndexOffset &BasePtr0,
                              const int64_t NumBytes0,
                              const BaseIndexOffset &BasePtr1,
                              const int64_t NumBytes1, const SelectionDAG &DAG,
                              bool &IsAlias);

  /// Parses tree in Ptr for base, index, offset addresses.
  static BaseIndexOffset match(const LSBaseSDNode *N, const SelectionDAG &DAG);

  void print(raw_ostream& OS) const;
  void dump() const;
};

} // end namespace llvm

#endif // LLVM_CODEGEN_SELECTIONDAGADDRESSANALYSIS_H

//===--- MoveForwardingReferenceCheck.h - clang-tidy ----------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_CLANG_TOOLS_EXTRA_CLANG_TIDY_MISC_MOVEFORWARDINGREFERENCECHECK_H
#define LLVM_CLANG_TOOLS_EXTRA_CLANG_TIDY_MISC_MOVEFORWARDINGREFERENCECHECK_H

#include "../ClangTidy.h"

namespace clang {
namespace tidy {
namespace misc {

/// The check warns if std::move is applied to a forwarding reference (i.e. an
/// rvalue reference of a function template argument type).
///
/// If a developer is unaware of the special rules for template argument
/// deduction on forwarding references, it will seem reasonable to apply
/// std::move to the forwarding reference, in the same way that this would be
/// done for a "normal" rvalue reference.
///
/// This has a consequence that is usually unwanted and possibly surprising: if
/// the function that takes the forwarding reference as its parameter is called
/// with an lvalue, that lvalue will be moved from (and hence placed into an
/// indeterminate state) even though no std::move was applied to the lvalue at
/// the call site.
//
/// The check suggests replacing the std::move with a std::forward.
///
/// For the user-facing documentation see:
/// http://clang.llvm.org/extra/clang-tidy/checks/misc-move-forwarding-reference.html
class MoveForwardingReferenceCheck : public ClangTidyCheck {
public:
  MoveForwardingReferenceCheck(StringRef Name, ClangTidyContext *Context)
      : ClangTidyCheck(Name, Context) {}
  void registerMatchers(ast_matchers::MatchFinder *Finder) override;
  void check(const ast_matchers::MatchFinder::MatchResult &Result) override;
};

} // namespace misc
} // namespace tidy
} // namespace clang

#endif // LLVM_CLANG_TOOLS_EXTRA_CLANG_TIDY_MISC_MOVEFORWARDINGREFERENCECHECK_H

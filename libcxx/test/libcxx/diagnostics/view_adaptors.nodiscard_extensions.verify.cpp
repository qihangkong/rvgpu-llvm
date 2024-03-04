//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

// Check that view adaptors are marked [[nodiscard]] as a conforming extension

// UNSUPPORTED: c++03, c++11, c++14, c++17, c++20

#include <ranges>
#include <vector>

#include "test_macros.h"

void func() {
  std::vector<int> range;

  auto rvalue_view = std::views::as_rvalue(range);
  std::views::as_rvalue(range);
  // expected-warning@-1 {{ignoring return value of function declared with 'nodiscard' attribute}}
  std::views::as_rvalue(rvalue_view);
  // expected-warning@-1 {{ignoring return value of function declared with 'nodiscard' attribute}}

#if TEST_STD_VER >= 23
  auto enumerate_view = std::views::enumerate(range);
  std::views::enumerate(range);
  // expected-warning@-1 {{ignoring return value of function declared with 'nodiscard' attribute}}
  std::views::enumerate(enumerate_view);
  // expected-warning@-1 {{ignoring return value of function declared with 'nodiscard' attribute}}
#endif
}

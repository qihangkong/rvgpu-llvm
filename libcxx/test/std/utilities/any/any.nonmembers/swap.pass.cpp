//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

// UNSUPPORTED: c++03, c++11, c++14

// Throwing bad_any_cast is supported starting in macosx10.13
// XFAIL: with_system_cxx_lib=macosx10.12 && !no-exceptions
// XFAIL: with_system_cxx_lib=macosx10.11 && !no-exceptions
// XFAIL: with_system_cxx_lib=macosx10.10 && !no-exceptions
// XFAIL: with_system_cxx_lib=macosx10.9 && !no-exceptions

// <any>

// void swap(any &, any &) noexcept

// swap(...) just wraps any::swap(...). That function is tested elsewhere.

#include <any>
#include <cassert>

#include "test_macros.h"

using std::any;
using std::any_cast;

int main(int, char**)
{

    { // test noexcept
        any a;
        static_assert(noexcept(swap(a, a)), "swap(any&, any&) must be noexcept");
    }
    {
        any a1(1);
        any a2(2);

        swap(a1, a2);

        assert(any_cast<int>(a1) == 2);
        assert(any_cast<int>(a2) == 1);
    }

  return 0;
}

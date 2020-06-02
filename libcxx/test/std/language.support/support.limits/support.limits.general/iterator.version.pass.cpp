//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// WARNING: This test was generated by generate_feature_test_macro_components.py
// and should not be edited manually.

// <iterator>

// Test the feature test macros defined by <iterator>

/*  Constant                                Value
    __cpp_lib_array_constexpr               201603L [C++17]
                                            201811L [C++2a]
    __cpp_lib_constexpr_misc                201811L [C++2a]
    __cpp_lib_make_reverse_iterator         201402L [C++14]
    __cpp_lib_nonmember_container_access    201411L [C++17]
    __cpp_lib_null_iterators                201304L [C++14]
    __cpp_lib_ranges                        201811L [C++2a]
*/

#include <iterator>
#include "test_macros.h"

#if TEST_STD_VER < 14

# ifdef __cpp_lib_array_constexpr
#   error "__cpp_lib_array_constexpr should not be defined before c++17"
# endif

# ifdef __cpp_lib_constexpr_misc
#   error "__cpp_lib_constexpr_misc should not be defined before c++2a"
# endif

# ifdef __cpp_lib_make_reverse_iterator
#   error "__cpp_lib_make_reverse_iterator should not be defined before c++14"
# endif

# ifdef __cpp_lib_nonmember_container_access
#   error "__cpp_lib_nonmember_container_access should not be defined before c++17"
# endif

# ifdef __cpp_lib_null_iterators
#   error "__cpp_lib_null_iterators should not be defined before c++14"
# endif

# ifdef __cpp_lib_ranges
#   error "__cpp_lib_ranges should not be defined before c++2a"
# endif

#elif TEST_STD_VER == 14

# ifdef __cpp_lib_array_constexpr
#   error "__cpp_lib_array_constexpr should not be defined before c++17"
# endif

# ifdef __cpp_lib_constexpr_misc
#   error "__cpp_lib_constexpr_misc should not be defined before c++2a"
# endif

# ifndef __cpp_lib_make_reverse_iterator
#   error "__cpp_lib_make_reverse_iterator should be defined in c++14"
# endif
# if __cpp_lib_make_reverse_iterator != 201402L
#   error "__cpp_lib_make_reverse_iterator should have the value 201402L in c++14"
# endif

# ifdef __cpp_lib_nonmember_container_access
#   error "__cpp_lib_nonmember_container_access should not be defined before c++17"
# endif

# ifndef __cpp_lib_null_iterators
#   error "__cpp_lib_null_iterators should be defined in c++14"
# endif
# if __cpp_lib_null_iterators != 201304L
#   error "__cpp_lib_null_iterators should have the value 201304L in c++14"
# endif

# ifdef __cpp_lib_ranges
#   error "__cpp_lib_ranges should not be defined before c++2a"
# endif

#elif TEST_STD_VER == 17

# ifndef __cpp_lib_array_constexpr
#   error "__cpp_lib_array_constexpr should be defined in c++17"
# endif
# if __cpp_lib_array_constexpr != 201603L
#   error "__cpp_lib_array_constexpr should have the value 201603L in c++17"
# endif

# ifdef __cpp_lib_constexpr_misc
#   error "__cpp_lib_constexpr_misc should not be defined before c++2a"
# endif

# ifndef __cpp_lib_make_reverse_iterator
#   error "__cpp_lib_make_reverse_iterator should be defined in c++17"
# endif
# if __cpp_lib_make_reverse_iterator != 201402L
#   error "__cpp_lib_make_reverse_iterator should have the value 201402L in c++17"
# endif

# ifndef __cpp_lib_nonmember_container_access
#   error "__cpp_lib_nonmember_container_access should be defined in c++17"
# endif
# if __cpp_lib_nonmember_container_access != 201411L
#   error "__cpp_lib_nonmember_container_access should have the value 201411L in c++17"
# endif

# ifndef __cpp_lib_null_iterators
#   error "__cpp_lib_null_iterators should be defined in c++17"
# endif
# if __cpp_lib_null_iterators != 201304L
#   error "__cpp_lib_null_iterators should have the value 201304L in c++17"
# endif

# ifdef __cpp_lib_ranges
#   error "__cpp_lib_ranges should not be defined before c++2a"
# endif

#elif TEST_STD_VER > 17

# ifndef __cpp_lib_array_constexpr
#   error "__cpp_lib_array_constexpr should be defined in c++2a"
# endif
# if __cpp_lib_array_constexpr != 201811L
#   error "__cpp_lib_array_constexpr should have the value 201811L in c++2a"
# endif

# if !defined(_LIBCPP_VERSION)
#   ifndef __cpp_lib_constexpr_misc
#     error "__cpp_lib_constexpr_misc should be defined in c++2a"
#   endif
#   if __cpp_lib_constexpr_misc != 201811L
#     error "__cpp_lib_constexpr_misc should have the value 201811L in c++2a"
#   endif
# else // _LIBCPP_VERSION
#   ifdef __cpp_lib_constexpr_misc
#     error "__cpp_lib_constexpr_misc should not be defined because it is unimplemented in libc++!"
#   endif
# endif

# ifndef __cpp_lib_make_reverse_iterator
#   error "__cpp_lib_make_reverse_iterator should be defined in c++2a"
# endif
# if __cpp_lib_make_reverse_iterator != 201402L
#   error "__cpp_lib_make_reverse_iterator should have the value 201402L in c++2a"
# endif

# ifndef __cpp_lib_nonmember_container_access
#   error "__cpp_lib_nonmember_container_access should be defined in c++2a"
# endif
# if __cpp_lib_nonmember_container_access != 201411L
#   error "__cpp_lib_nonmember_container_access should have the value 201411L in c++2a"
# endif

# ifndef __cpp_lib_null_iterators
#   error "__cpp_lib_null_iterators should be defined in c++2a"
# endif
# if __cpp_lib_null_iterators != 201304L
#   error "__cpp_lib_null_iterators should have the value 201304L in c++2a"
# endif

# if !defined(_LIBCPP_VERSION)
#   ifndef __cpp_lib_ranges
#     error "__cpp_lib_ranges should be defined in c++2a"
#   endif
#   if __cpp_lib_ranges != 201811L
#     error "__cpp_lib_ranges should have the value 201811L in c++2a"
#   endif
# else // _LIBCPP_VERSION
#   ifdef __cpp_lib_ranges
#     error "__cpp_lib_ranges should not be defined because it is unimplemented in libc++!"
#   endif
# endif

#endif // TEST_STD_VER > 17

int main(int, char**) { return 0; }

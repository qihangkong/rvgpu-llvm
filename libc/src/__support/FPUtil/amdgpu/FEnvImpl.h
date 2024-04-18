//===-- amdgpu floating point env manipulation functions --------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIBC_SRC___SUPPORT_FPUTIL_AMDGPU_FENVIMPL_H
#define LLVM_LIBC_SRC___SUPPORT_FPUTIL_AMDGPU_FENVIMPL_H

#include "src/__support/GPU/utils.h"
#include "src/__support/macros/attributes.h"
#include "src/__support/macros/properties/architectures.h"

#if !defined(LIBC_TARGET_ARCH_IS_AMDGPU)
#error "Invalid include"
#endif

#include <fenv.h>
#include <stdint.h>

namespace LIBC_NAMESPACE {
namespace fputil {

namespace internal {
// Retuns the current status of the AMDGPU floating point environment. In
// practice this is simply a 64-bit concatenation of the mode register and the
// trap status register.
//
// The mode register controls the floating point behaviour of the device. It
// can be read or written to by the kernel during runtime It is laid out as a
// bit field with the following offsets and sizes listed for the relevant
// entries.
//
// ┌─────┬─────────────┬─────┬─────────┬──────────┬─────────────┬────────────┐
// │ ... │ EXCP[20:12] │ ... │ IEEE[9] │ CLAMP[8] │ DENORM[7:4] │ ROUND[3:0] │
// └─────┴─────────────┴─────┴─────────┴──────────┴─────────────┴────────────┘
//
// The rounding mode and denormal modes both control f64/f16 and f32 precision
// operations separately with two bits. The accepted values for the rounding
// mode are nearest, upward, downward, and toward given 0, 1, 2, and 3
// respectively.
//
// The CLAMP bit indicates that DirectX 10 handling of NaNs is enabled in the
// vector ALU. When set this will clamp NaN values to zero and pass them
// otherwise. A hardware bug causes this bit to prevent floating exceptions
// from being recorded if this bit is set on all generations before GFX12.
//
// The IEEE bit controls whether or not floating point operations supporting
// exception gathering are IEEE 754-2008 compliant.
//
// The EXCP field indicates which exceptions will cause the instruction to
// take a trap if traps are enabled, see the status register. The bit layout
// is identical to that in the trap status register. We are only concerned
// with the first six bits and ignore the other three.
//
// The trap status register contains information about the status of the
// exceptions. These bits are accumulated regarless of trap handling statuss
// and are sticky until cleared.
//
// 5         4           3          2                1          0
// ┌─────────┬───────────┬──────────┬────────────────┬──────────┬─────────┐
// │ Inexact │ Underflow │ Overflow │ Divide by zero │ Denormal │ Invalid │
// └─────────┴───────────┴──────────┴────────────────┴──────────┴─────────┘
//
// These exceptions indicate that at least one lane in the current wavefront
// signalled an floating point exception. There is no way to increase the
// granularity.
//
// The returned value has the following layout.
//
// ┌────────────────────┬─────────────────────┐
// │ Trap Status[38:32] │ Mode Register[31:0] │
// └────────────────────┴─────────────────────┘
LIBC_INLINE uint64_t get_fpenv() { return __builtin_amdgcn_get_fpenv(); }

// Set the floating point environment using the same layout as above.
LIBC_INLINE void set_fpenv(uint64_t env) { __builtin_amdgcn_set_fpenv(env); }

// The six bits used to encode the standard floating point exceptions in the
// trap status register.
enum ExceptionFlags : uint32_t {
  EXCP_INVALID_F = 0x1,
  EXCP_DENORMAL_F = 0x2,
  EXCP_DIV_BY_ZERO_F = 0x4,
  EXCP_OVERFLOW_F = 0x8,
  EXCP_UNDERFLOW_F = 0x10,
  EXCP_INEXACT_F = 0x20,
};

// The two bit encoded rounding modes used in the mode register.
enum RoundingFlags : uint32_t {
  ROUND_TO_NEAREST = 0x0,
  ROUND_UPWARD = 0x1,
  ROUND_DOWNWARD = 0x2,
  ROUND_TOWARD_ZERO = 0x3,
};

// Exception flags are individual bits in the corresponding hardware register.
// This converts between the exported C standard values and the hardware values.
LIBC_INLINE uint32_t get_status_value_for_except(uint32_t excepts) {
  return (excepts & FE_INVALID ? EXCP_INVALID_F : 0) |
#ifdef __FE_DENORM
         (excepts & __FE_DENORM ? EXCP_DENORMAL_F : 0) |
#endif // __FE_DENORM
         (excepts & FE_DIVBYZERO ? EXCP_DIV_BY_ZERO_F : 0) |
         (excepts & FE_OVERFLOW ? EXCP_OVERFLOW_F : 0) |
         (excepts & FE_UNDERFLOW ? EXCP_UNDERFLOW_F : 0) |
         (excepts & FE_INEXACT ? EXCP_INEXACT_F : 0);
}

LIBC_INLINE uint32_t get_except_value_for_status(uint32_t status) {
  return (status & EXCP_INVALID_F ? FE_INVALID : 0) |
#ifdef __FE_DENORM
         (status & EXCP_DENORMAL_F ? __FE_DENORM : 0) |
#endif // __FE_DENORM
         (status & EXCP_DIV_BY_ZERO_F ? FE_DIVBYZERO : 0) |
         (status & EXCP_OVERFLOW_F ? FE_OVERFLOW : 0) |
         (status & EXCP_UNDERFLOW_F ? FE_UNDERFLOW : 0) |
         (status & EXCP_INEXACT_F ? FE_INEXACT : 0);
}

// Access the four bits in the mode register's ROUND[3:0] field. The hardware
// supports setting the f64/f16 and f32 precision rounding modes separately but
// we will assume that these always match.
LIBC_INLINE void set_rounding_mode(uint32_t flags) {
  uint64_t old = get_fpenv() & 0xfffffffffffffff0;
  set_fpenv(old | flags << 2 | flags);
}

// The control register can modify f32/f64 rounding modes individually. For our
// purposes we assume that these always match as we do not expose this through
// the C interface.
LIBC_INLINE uint32_t get_rounding_mode() { return get_fpenv() & 0x3; }

} // namespace internal

// TODO: Not implemented yet.
LIBC_INLINE int clear_except(int) { return 0; }

// TODO: Not implemented yet.
LIBC_INLINE int test_except(int) { return 0; }

// TODO: Not implemented yet.
LIBC_INLINE int get_except() { return 0; }

// TODO: Not implemented yet.
LIBC_INLINE int set_except(int) { return 0; }

// TODO: Not implemented yet.
LIBC_INLINE int enable_except(int) { return 0; }

// TODO: Not implemented yet.
LIBC_INLINE int disable_except(int) { return 0; }

// TODO: Not implemented yet.
LIBC_INLINE int raise_except(int) { return 0; }

LIBC_INLINE int get_round() {
  switch (internal::get_rounding_mode()) {
  case internal::ROUND_TO_NEAREST:
    return FE_TONEAREST;
  case internal::ROUND_UPWARD:
    return FE_UPWARD;
  case internal::ROUND_DOWNWARD:
    return FE_DOWNWARD;
  case internal::ROUND_TOWARD_ZERO:
    return FE_TOWARDZERO;
  }
  __builtin_unreachable();
}

LIBC_INLINE int set_round(int rounding_mode) {
  switch (rounding_mode) {
  case FE_TONEAREST:
    internal::set_rounding_mode(internal::ROUND_TO_NEAREST);
    break;
  case FE_UPWARD:
    internal::set_rounding_mode(internal::ROUND_UPWARD);
    break;
  case FE_DOWNWARD:
    internal::set_rounding_mode(internal::ROUND_DOWNWARD);
    break;
  case FE_TOWARDZERO:
    internal::set_rounding_mode(internal::ROUND_TOWARD_ZERO);
    break;
  default:
    return 1;
  }
  return 0;
}

LIBC_INLINE int get_env(fenv_t *env) {
  if (!env)
    return 1;

  env->__fpc = internal::get_fpenv();
  return 0;
}

LIBC_INLINE int set_env(const fenv_t *env) {
  if (!env)
    return 1;

  internal::set_fpenv(env->__fpc);
  return 0;
}

} // namespace fputil
} // namespace LIBC_NAMESPACE

#endif // LLVM_LIBC_SRC___SUPPORT_FPUTIL_AMDGPU_FENVIMPL_H

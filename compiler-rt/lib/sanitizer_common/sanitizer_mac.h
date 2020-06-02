//===-- sanitizer_mac.h -----------------------------------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file is shared between various sanitizers' runtime libraries and
// provides definitions for OSX-specific functions.
//===----------------------------------------------------------------------===//
#ifndef SANITIZER_MAC_H
#define SANITIZER_MAC_H

#include "sanitizer_common.h"
#include "sanitizer_platform.h"
#if SANITIZER_MAC
#include "sanitizer_posix.h"

namespace __sanitizer {

struct MemoryMappingLayoutData {
  int current_image;
  u32 current_magic;
  u32 current_filetype;
  ModuleArch current_arch;
  u8 current_uuid[kModuleUUIDSize];
  int current_load_cmd_count;
  const char *current_load_cmd_addr;
  bool current_instrumented;
};

enum MacosVersion {
  MACOS_VERSION_UNINITIALIZED = 0,
  MACOS_VERSION_UNKNOWN,
  MACOS_VERSION_LION,  // macOS 10.7; oldest currently supported
  MACOS_VERSION_MOUNTAIN_LION,
  MACOS_VERSION_MAVERICKS,
  MACOS_VERSION_YOSEMITE,
  MACOS_VERSION_EL_CAPITAN,
  MACOS_VERSION_SIERRA,
  MACOS_VERSION_HIGH_SIERRA,
  MACOS_VERSION_MOJAVE,
  MACOS_VERSION_CATALINA,
  MACOS_VERSION_UNKNOWN_NEWER
};

struct DarwinKernelVersion {
  u16 major;
  u16 minor;

  DarwinKernelVersion(u16 major, u16 minor) : major(major), minor(minor) {}

  bool operator==(const DarwinKernelVersion &other) const {
    return major == other.major && minor == other.minor;
  }
  bool operator>=(const DarwinKernelVersion &other) const {
    return major >= other.major ||
           (major == other.major && minor >= other.minor);
  }
};

MacosVersion GetMacosVersion();
DarwinKernelVersion GetDarwinKernelVersion();

char **GetEnviron();

void RestrictMemoryToMaxAddress(uptr max_address);

}  // namespace __sanitizer

extern "C" {
static char __crashreporter_info_buff__[__sanitizer::kErrorMessageBufferSize] =
  {};
static const char *__crashreporter_info__ __attribute__((__used__)) =
  &__crashreporter_info_buff__[0];
asm(".desc ___crashreporter_info__, 0x10");
} // extern "C"

namespace __sanitizer {
static BlockingMutex crashreporter_info_mutex(LINKER_INITIALIZED);

INLINE void CRAppendCrashLogMessage(const char *msg) {
  BlockingMutexLock l(&crashreporter_info_mutex);
  internal_strlcat(__crashreporter_info_buff__, msg,
                   sizeof(__crashreporter_info_buff__)); }
}  // namespace __sanitizer

#endif  // SANITIZER_MAC
#endif  // SANITIZER_MAC_H

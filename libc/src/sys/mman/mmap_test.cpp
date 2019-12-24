//===------------------ Unittests for mmap and munmap ---------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "src/errno/llvmlibc_errno.h"
#include "src/sys/mman/mmap.h"
#include "src/sys/mman/munmap.h"

#include "gtest/gtest.h"

#include "errno.h"
#include "sys/mman.h"

TEST(MMapTest, NoError) {
  size_t alloc_size = 128;
  llvmlibc_errno = 0;
  void *addr = __llvm_libc::mmap(nullptr, alloc_size, PROT_READ,
                                 MAP_ANONYMOUS | MAP_PRIVATE, -1, 0);
  EXPECT_EQ(0, llvmlibc_errno);
  EXPECT_NE(addr, MAP_FAILED);

  int *array = reinterpret_cast<int *>(addr);
  // Reading from the memory should not crash the test.
  // Since we used the MAP_ANONYMOUS flag, the contents of the newly
  // allocated memory should be initialized to zero.
  EXPECT_EQ(array[0], 0);

  int ret_val = __llvm_libc::munmap(addr, alloc_size);
  EXPECT_EQ(0, ret_val);
  EXPECT_EQ(0, llvmlibc_errno);
}

TEST(MMapTest, Error_InvalidSize) {
  llvmlibc_errno = 0;
  void *addr = __llvm_libc::mmap(nullptr, 0, PROT_READ,
                                 MAP_ANONYMOUS | MAP_PRIVATE, -1, 0);
  EXPECT_EQ(EINVAL, llvmlibc_errno);
  EXPECT_EQ(addr, MAP_FAILED);

  llvmlibc_errno = 0;
  int ret_val = __llvm_libc::munmap(0, 0);
  EXPECT_EQ(-1, ret_val);
  EXPECT_EQ(EINVAL, llvmlibc_errno);
}

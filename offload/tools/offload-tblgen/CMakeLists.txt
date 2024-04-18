##===----------------------------------------------------------------------===##
#
# Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
# See https://llvm.org/LICENSE.txt for license information.
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
#
##===----------------------------------------------------------------------===##

set(LLVM_LINK_COMPONENTS
  Demangle
  Support
  TableGen
)

add_tablegen(offload-tblgen Offload
  EXPORT Offload
  APIGen.cpp
  offload-tblgen.cpp
  ValidationGen.cpp
  )

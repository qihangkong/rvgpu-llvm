RUN: llvm-exegesis -mode=latency --benchmark-phase=assemble-measured-code -opcode-name=LB -mtriple=riscv64-unknown-linux-gnu

CHECK: Warning: Pre-assigned register prevented usage of self-aliasing strategy.


# RUN: llvm-mc -triple bpfel -show-encoding < %s | FileCheck %s

dst:

# CHECK: gotol_or_nop dst                        # encoding: [0x06'A',0x10'A',A,A,0x00,0x00,0x00,0x00]
# CHECK-NEXT:                                    #   fixup A - offset: 0, value: dst, kind: FK_BPF_PCRel_4
gotol_or_nop dst

# CHECK: nop_or_gotol dst                        # encoding: [0x06'A',0x30'A',A,A,0x00,0x00,0x00,0x00]
# CHECK-NEXT:                                    #   fixup A - offset: 0, value: dst, kind: FK_BPF_PCRel_4
nop_or_gotol dst

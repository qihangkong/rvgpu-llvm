// REQUIRES: x86-registered-target
// RUN: llvm-mc -filetype=obj -triple x86_64-pc-linux-gnu %s -o %t.o

// RUN: llvm-readobj --notes %t.o | FileCheck %s --check-prefix=LLVM
// RUN: llvm-readelf --notes %t.o | FileCheck %s --check-prefix=GNU

// GNU:      Displaying notes found in: .note.no.desc
// GNU-NEXT:   Owner                Data size        Description
// GNU-NEXT:   AMD                  0x00000000       NT_AMD_HSA_METADATA (AMD HSA Metadata)
// GNU-NEXT:     AMD HSA Metadata:
// GNU-NEXT:         Invalid AMD HSA Metadata
// GNU-NEXT:   AMD                  0x00000000       NT_AMD_HSA_ISA_NAME (AMD HSA ISA Name)
// GNU-NEXT:     AMD HSA ISA Name:
// GNU-NEXT:         Invalid AMD HSA ISA Name
// GNU-NEXT: Displaying notes found in: .note.desc
// GNU-NEXT:   Owner                Data size        Description
// GNU-NEXT:   AMD                  0x0000000a       NT_AMD_HSA_METADATA (AMD HSA Metadata)
// GNU-NEXT:     AMD HSA Metadata:
// GNU-NEXT:         meta_blah
// GNU-NEXT:   AMD                  0x00000009       NT_AMD_HSA_ISA_NAME (AMD HSA ISA Name)
// GNU-NEXT:     AMD HSA ISA Name:
// GNU-NEXT:         isa_blah
// GNU-NEXT: Displaying notes found in: .note.other
// GNU-NEXT:   Owner                Data size        Description
// GNU-NEXT:   AMD                  0x00000000       NT_AMD_PAL_METADATA (AMD PAL Metadata)
// GNI-NEXT:     AMD PAL Metadata:

// LLVM:      Notes [
// LLVM-NEXT:   NoteSection {
// LLVM-NEXT:     Name: .note.no.desc
// LLVM-NEXT:     Offset:
// LLVM-NEXT:     Size:
// LLVM-NEXT:     Note {
// LLVM-NEXT:       Owner: AMD
// LLVM-NEXT:       Data size: 0x0
// LLVM-NEXT:       Type: NT_AMD_HSA_METADATA (AMD HSA Metadata)
// LLVM-NEXT:       AMD HSA Metadata:
// LLVM-NEXT:     }
// LLVM-NEXT:     Note {
// LLVM-NEXT:       Owner: AMD
// LLVM-NEXT:       Data size: 0x0
// LLVM-NEXT:       Type: NT_AMD_HSA_ISA_NAME (AMD HSA ISA Name)
// LLVM-NEXT:       AMD HSA ISA Name:
// LLVM-NEXT:     }
// LLVM-NEXT:   }
// LLVM-NEXT:   NoteSection {
// LLVM-NEXT:     Name: .note.desc
// LLVM-NEXT:     Offset:
// LLVM-NEXT:     Size:
// LLVM-NEXT:     Note {
// LLVM-NEXT:       Owner: AMD
// LLVM-NEXT:       Data size: 0xA
// LLVM-NEXT:       Type: NT_AMD_HSA_METADATA (AMD HSA Metadata)
// LLVM-NEXT:       AMD HSA Metadata: meta_blah
// LLVM-NEXT:     }
// LLVM-NEXT:     Note {
// LLVM-NEXT:       Owner: AMD
// LLVM-NEXT:       Data size: 0x9
// LLVM-NEXT:       Type: NT_AMD_HSA_ISA_NAME (AMD HSA ISA Name)
// LLVM-NEXT:       AMD HSA ISA Name: isa_blah
// LLVM-NEXT:     }
// LLVM-NEXT:   }
// LLVM-NEXT:   NoteSection {
// LLVM-NEXT:     Name: .note.other
// LLVM-NEXT:     Offset:
// LLVM-NEXT:     Size:
// LLVM-NEXT:     Note {
// LLVM-NEXT:       Owner: AMD
// LLVM-NEXT:       Data size: 0x0
// LLVM-NEXT:       Type: NT_AMD_PAL_METADATA (AMD PAL Metadata)
// LLVM-NEXT:       AMD PAL Metadata:
// LLVM-NEXT:     }
// LLVM-NEXT:   }
// LLVM-NEXT: ]

.section ".note.no.desc", "a"
	.align 4
	.long 4 /* namesz */
	.long 0 /* descsz */
	.long 10 /* type = NT_AMD_HSA_METADATA */
	.asciz "AMD"
	.long 4 /* namesz */
	.long 0 /* descsz */
	.long 11 /* type = NT_AMD_HSA_ISA_NAME */
	.asciz "AMD"
.section ".note.desc", "a"
	.align 4
	.long 4 /* namesz */
	.long end.meta - begin.meta /* descsz */
	.long 10 /* type = NT_AMD_HSA_METADATA */
	.asciz "AMD"
begin.meta:
	.asciz "meta_blah"
end.meta:
	.align 4
	.long 4 /* namesz */
	.long end.isa - begin.isa /* descsz */
	.long 11 /* type = NT_AMD_HSA_ISA_NAME */
	.asciz "AMD"
begin.isa:
	.asciz "isa_blah"
end.isa:
	.align 4
.section ".note.other", "a"
	.align 4
	.long 4 /* namesz */
	.long 0 /* descsz */
	.long 12 /* type = NT_AMD_PAL_METADATA */
	.asciz "AMD"

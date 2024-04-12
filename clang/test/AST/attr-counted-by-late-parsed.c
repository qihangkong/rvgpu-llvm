// RUN: %clang_cc1 -fexperimental-late-parse-attributes %s -ast-dump | FileCheck %s

#define __counted_by(f)  __attribute__((counted_by(f)))

struct size_known;

struct at_decl {
  struct size_known *buf __counted_by(count);
  int count;
};
// CHECK-LABEL: struct at_decl definition
// CHECK-NEXT: |-FieldDecl {{.*}} buf 'struct size_known * __counted_by(count)':'struct size_known *'
// CHECK-NEXT: `-FieldDecl {{.*}} referenced count 'int'

struct at_decl_anon_count {
  struct size_known *buf __counted_by(count);
  struct {
    int count;
  };
};

// CHECK-LABEL: struct at_decl_anon_count definition
// CHECK-NEXT:  |-FieldDecl {{.*}} buf 'struct size_known * __counted_by(count)':'struct size_known *'
// CHECK-NEXT:  |-RecordDecl {{.*}} struct definition
// CHECK-NEXT:  | `-FieldDecl {{.*}} count 'int'
// CHECK-NEXT:  |-FieldDecl {{.*}} implicit 'struct at_decl_anon_count::(anonymous at {{.*}})'
// CHECK-NEXT:  `-IndirectFieldDecl {{.*}} implicit referenced count 'int'
// CHECK-NEXT:    |-Field {{.*}} '' 'struct at_decl_anon_count::(anonymous at {{.*}})'
// CHECK-NEXT:    `-Field {{.*}} 'count' 'int'

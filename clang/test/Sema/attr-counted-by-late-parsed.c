// RUN: %clang_cc1 -fexperimental-late-parse-attributes -fsyntax-only -verify %s

#define __counted_by(f)  __attribute__((counted_by(f)))

struct size_unknown;

struct at_pointer {
  int count;
  struct size_unknown *__counted_by(count) buf; // expected-error{{'counted_by' cannot be applied to an sized type}}
};

struct size_known { int dummy; };

struct at_nested_pointer {
  // FIXME
  struct size_known *__counted_by(count) *buf; // expected-error{{use of undeclared identifier 'count'}}
  int count;
};

struct at_decl {
  struct size_known *buf __counted_by(count);
  int count;
};

struct at_pointer_anon_buf {
  struct {
    // FIXME
    struct size_known *__counted_by(count) buf; // expected-error{{use of undeclared identifier 'count'}}
  };
  int count;
};

struct at_decl_anon_buf {
  struct {
    // FIXME
    struct size_known *buf __counted_by(count); // expected-error{{use of undeclared identifier 'count'}}
  };
  int count;
};

struct at_pointer_anon_count {
  // FIXME
  struct size_known *__counted_by(count) buf; // expected-error{{use of undeclared identifier 'count'}}
  struct {
    int count;
  };
};

struct at_decl_anon_count {
  struct size_known *buf __counted_by(count);
  struct {
    int count;
  };
};

.. title:: clang-tidy - modernize-min-max-use-initializer-list

modernize-min-max-use-initializer-list
======================================

Replaces nested ``std::min`` and ``std::max`` calls with an initializer list where applicable.

For instance, consider the following code:

.. code-block:: cpp

   int a = std::max(std::max(i, j), k);

The check will transform the above code to:

.. code-block:: cpp

   int a = std::max({i, j, k});

Options
=======

.. option:: IncludeStyle

   A string specifying which include-style is used, `llvm` or `google`. Default
   is `llvm`.
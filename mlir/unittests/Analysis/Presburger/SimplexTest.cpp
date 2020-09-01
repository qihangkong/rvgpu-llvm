//===- SimplexTest.cpp - Tests for Simplex --------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "mlir/Analysis/Presburger/Simplex.h"

#include <gmock/gmock.h>
#include <gtest/gtest.h>

namespace mlir {

/// Take a snapshot, add constraints making the set empty, and rollback.
/// The set should not be empty after rolling back.
TEST(SimplexTest, emptyRollback) {
  Simplex simplex(2);
  // (u - v) >= 0
  simplex.addInequality({1, -1, 0});
  EXPECT_FALSE(simplex.isEmpty());

  unsigned snapshot = simplex.getSnapshot();
  // (u - v) <= -1
  simplex.addInequality({-1, 1, -1});
  EXPECT_TRUE(simplex.isEmpty());
  simplex.rollback(snapshot);
  EXPECT_FALSE(simplex.isEmpty());
}

/// Check that the set gets marked as empty when we add contradictory
/// constraints.
TEST(SimplexTest, addEquality_separate) {
  Simplex simplex(1);
  simplex.addInequality({1, -1}); // x >= 1.
  ASSERT_FALSE(simplex.isEmpty());
  simplex.addEquality({1, 0}); // x == 0.
  EXPECT_TRUE(simplex.isEmpty());
}

void expectInequalityMakesSetEmpty(Simplex &simplex, ArrayRef<int64_t> coeffs,
                                   bool expect) {
  ASSERT_FALSE(simplex.isEmpty());
  unsigned snapshot = simplex.getSnapshot();
  simplex.addInequality(coeffs);
  EXPECT_EQ(simplex.isEmpty(), expect);
  simplex.rollback(snapshot);
}

TEST(SimplexTest, addInequality_rollback) {
  Simplex simplex(3);
  SmallVector<int64_t, 4> coeffs[]{{1, 0, 0, 0},   // u >= 0.
                                   {-1, 0, 0, 0},  // u <= 0.
                                   {1, -1, 1, 0},  // u - v + w >= 0.
                                   {1, 1, -1, 0}}; // u + v - w >= 0.
  // The above constraints force u = 0 and v = w.
  // The constraints below violate v = w.
  SmallVector<int64_t, 4> checkCoeffs[]{{0, 1, -1, -1},  // v - w >= 1.
                                        {0, -1, 1, -1}}; // v - w <= -1.

  for (int run = 0; run < 4; run++) {
    unsigned snapshot = simplex.getSnapshot();

    expectInequalityMakesSetEmpty(simplex, checkCoeffs[0], false);
    expectInequalityMakesSetEmpty(simplex, checkCoeffs[1], false);

    for (int i = 0; i < 4; i++)
      simplex.addInequality(coeffs[(run + i) % 4]);

    expectInequalityMakesSetEmpty(simplex, checkCoeffs[0], true);
    expectInequalityMakesSetEmpty(simplex, checkCoeffs[1], true);

    simplex.rollback(snapshot);
    EXPECT_EQ(simplex.numConstraints(), 0u);

    expectInequalityMakesSetEmpty(simplex, checkCoeffs[0], false);
    expectInequalityMakesSetEmpty(simplex, checkCoeffs[1], false);
  }
}

Simplex simplexFromConstraints(unsigned nDim,
                               SmallVector<SmallVector<int64_t, 8>, 8> ineqs,
                               SmallVector<SmallVector<int64_t, 8>, 8> eqs) {
  Simplex simplex(nDim);
  for (const auto &ineq : ineqs)
    simplex.addInequality(ineq);
  for (const auto &eq : eqs)
    simplex.addEquality(eq);
  return simplex;
}

TEST(SimplexTest, isUnbounded) {
  EXPECT_FALSE(simplexFromConstraints(
                   2, {{1, 1, 0}, {-1, -1, 0}, {1, -1, 5}, {-1, 1, -5}}, {})
                   .isUnbounded());

  EXPECT_TRUE(
      simplexFromConstraints(2, {{1, 1, 0}, {1, -1, 5}, {-1, 1, -5}}, {})
          .isUnbounded());

  EXPECT_TRUE(
      simplexFromConstraints(2, {{-1, -1, 0}, {1, -1, 5}, {-1, 1, -5}}, {})
          .isUnbounded());

  EXPECT_TRUE(simplexFromConstraints(2, {}, {}).isUnbounded());

  EXPECT_FALSE(simplexFromConstraints(3,
                                      {
                                          {2, 0, 0, -1},
                                          {-2, 0, 0, 1},
                                          {0, 2, 0, -1},
                                          {0, -2, 0, 1},
                                          {0, 0, 2, -1},
                                          {0, 0, -2, 1},
                                      },
                                      {})
                   .isUnbounded());

  EXPECT_TRUE(simplexFromConstraints(3,
                                     {
                                         {2, 0, 0, -1},
                                         {-2, 0, 0, 1},
                                         {0, 2, 0, -1},
                                         {0, -2, 0, 1},
                                         {0, 0, -2, 1},
                                     },
                                     {})
                  .isUnbounded());

  EXPECT_TRUE(simplexFromConstraints(3,
                                     {
                                         {2, 0, 0, -1},
                                         {-2, 0, 0, 1},
                                         {0, 2, 0, -1},
                                         {0, -2, 0, 1},
                                         {0, 0, 2, -1},
                                     },
                                     {})
                  .isUnbounded());

  // Bounded set with equalities.
  EXPECT_FALSE(simplexFromConstraints(2,
                                      {{1, 1, 1},    // x + y >= -1.
                                       {-1, -1, 1}}, // x + y <=  1.
                                      {{1, -1, 0}}   // x = y.
                                      )
                   .isUnbounded());

  // Unbounded set with equalities.
  EXPECT_TRUE(simplexFromConstraints(3,
                                     {{1, 1, 1, 1},     // x + y + z >= -1.
                                      {-1, -1, -1, 1}}, // x + y + z <=  1.
                                     {{1, -1, -1, 0}}   // x = y + z.
                                     )
                  .isUnbounded());

  // Rational empty set.
  EXPECT_FALSE(simplexFromConstraints(3,
                                      {
                                          {2, 0, 0, -1},
                                          {-2, 0, 0, 1},
                                          {0, 2, 2, -1},
                                          {0, -2, -2, 1},
                                          {3, 3, 3, -4},
                                      },
                                      {})
                   .isUnbounded());
}

TEST(SimplexTest, getSamplePointIfIntegral) {
  // Empty set.
  EXPECT_FALSE(simplexFromConstraints(3,
                                      {
                                          {2, 0, 0, -1},
                                          {-2, 0, 0, 1},
                                          {0, 2, 2, -1},
                                          {0, -2, -2, 1},
                                          {3, 3, 3, -4},
                                      },
                                      {})
                   .getSamplePointIfIntegral()
                   .hasValue());

  auto maybeSample = simplexFromConstraints(2,
                                            {// x = y - 2.
                                             {1, -1, 2},
                                             {-1, 1, -2},
                                             // x + y = 2.
                                             {1, 1, -2},
                                             {-1, -1, 2}},
                                            {})
                         .getSamplePointIfIntegral();

  EXPECT_TRUE(maybeSample.hasValue());
  EXPECT_THAT(*maybeSample, testing::ElementsAre(0, 2));

  auto maybeSample2 = simplexFromConstraints(2,
                                             {
                                                 {1, 0, 0},  // x >= 0.
                                                 {-1, 0, 0}, // x <= 0.
                                             },
                                             {
                                                 {0, 1, -2} // y = 2.
                                             })
                          .getSamplePointIfIntegral();
  EXPECT_TRUE(maybeSample2.hasValue());
  EXPECT_THAT(*maybeSample2, testing::ElementsAre(0, 2));

  EXPECT_FALSE(simplexFromConstraints(1,
                                      {// 2x = 1. (no integer solutions)
                                       {2, -1},
                                       {-2, +1}},
                                      {})
                   .getSamplePointIfIntegral()
                   .hasValue());
}

/// Some basic sanity checks involving zero or one variables.
TEST(SimplexTest, isMarkedRedundant_no_var_ge_zero) {
  Simplex simplex(0);
  simplex.addInequality({0}); // 0 >= 0.

  simplex.detectRedundant();
  ASSERT_FALSE(simplex.isEmpty());
  EXPECT_TRUE(simplex.isMarkedRedundant(0));
}

TEST(SimplexTest, isMarkedRedundant_no_var_eq) {
  Simplex simplex(0);
  simplex.addEquality({0}); // 0 == 0.
  simplex.detectRedundant();
  ASSERT_FALSE(simplex.isEmpty());
  EXPECT_TRUE(simplex.isMarkedRedundant(0));
}

TEST(SimplexTest, isMarkedRedundant_pos_var_eq) {
  Simplex simplex(1);
  simplex.addEquality({1, 0}); // x == 0.

  simplex.detectRedundant();
  ASSERT_FALSE(simplex.isEmpty());
  EXPECT_FALSE(simplex.isMarkedRedundant(0));
}

TEST(SimplexTest, isMarkedRedundant_zero_var_eq) {
  Simplex simplex(1);
  simplex.addEquality({0, 0}); // 0x == 0.
  simplex.detectRedundant();
  ASSERT_FALSE(simplex.isEmpty());
  EXPECT_TRUE(simplex.isMarkedRedundant(0));
}

TEST(SimplexTest, isMarkedRedundant_neg_var_eq) {
  Simplex simplex(1);
  simplex.addEquality({-1, 0}); // -x == 0.
  simplex.detectRedundant();
  ASSERT_FALSE(simplex.isEmpty());
  EXPECT_FALSE(simplex.isMarkedRedundant(0));
}

TEST(SimplexTest, isMarkedRedundant_pos_var_ge) {
  Simplex simplex(1);
  simplex.addInequality({1, 0}); // x >= 0.
  simplex.detectRedundant();
  ASSERT_FALSE(simplex.isEmpty());
  EXPECT_FALSE(simplex.isMarkedRedundant(0));
}

TEST(SimplexTest, isMarkedRedundant_zero_var_ge) {
  Simplex simplex(1);
  simplex.addInequality({0, 0}); // 0x >= 0.
  simplex.detectRedundant();
  ASSERT_FALSE(simplex.isEmpty());
  EXPECT_TRUE(simplex.isMarkedRedundant(0));
}

TEST(SimplexTest, isMarkedRedundant_neg_var_ge) {
  Simplex simplex(1);
  simplex.addInequality({-1, 0}); // x <= 0.
  simplex.detectRedundant();
  ASSERT_FALSE(simplex.isEmpty());
  EXPECT_FALSE(simplex.isMarkedRedundant(0));
}

/// None of the constraints are redundant. Slightly more complicated test
/// involving an equality.
TEST(SimplexTest, isMarkedRedundant_no_redundant) {
  Simplex simplex(3);

  simplex.addEquality({-1, 0, 1, 0});     // u = w.
  simplex.addInequality({-1, 16, 0, 15}); // 15 - (u - 16v) >= 0.
  simplex.addInequality({1, -16, 0, 0});  //      (u - 16v) >= 0.

  simplex.detectRedundant();
  ASSERT_FALSE(simplex.isEmpty());

  for (unsigned i = 0; i < simplex.numConstraints(); ++i)
    EXPECT_FALSE(simplex.isMarkedRedundant(i)) << "i = " << i << "\n";
}

TEST(SimplexTest, isMarkedRedundant_repeated_constraints) {
  Simplex simplex(3);

  // [4] to [7] are repeats of [0] to [3].
  simplex.addInequality({0, -1, 0, 1}); // [0]: y <= 1.
  simplex.addInequality({-1, 0, 8, 7}); // [1]: 8z >= x - 7.
  simplex.addInequality({1, 0, -8, 0}); // [2]: 8z <= x.
  simplex.addInequality({0, 1, 0, 0});  // [3]: y >= 0.
  simplex.addInequality({-1, 0, 8, 7}); // [4]: 8z >= 7 - x.
  simplex.addInequality({1, 0, -8, 0}); // [5]: 8z <= x.
  simplex.addInequality({0, 1, 0, 0});  // [6]: y >= 0.
  simplex.addInequality({0, -1, 0, 1}); // [7]: y <= 1.

  simplex.detectRedundant();
  ASSERT_FALSE(simplex.isEmpty());

  EXPECT_EQ(simplex.isMarkedRedundant(0), true);
  EXPECT_EQ(simplex.isMarkedRedundant(1), true);
  EXPECT_EQ(simplex.isMarkedRedundant(2), true);
  EXPECT_EQ(simplex.isMarkedRedundant(3), true);
  EXPECT_EQ(simplex.isMarkedRedundant(4), false);
  EXPECT_EQ(simplex.isMarkedRedundant(5), false);
  EXPECT_EQ(simplex.isMarkedRedundant(6), false);
  EXPECT_EQ(simplex.isMarkedRedundant(7), false);
}

TEST(SimplexTest, isMarkedRedundant) {
  Simplex simplex(3);
  simplex.addInequality({0, -1, 0, 1}); // [0]: y <= 1.
  simplex.addInequality({1, 0, 0, -1}); // [1]: x >= 1.
  simplex.addInequality({-1, 0, 0, 2}); // [2]: x <= 2.
  simplex.addInequality({-1, 0, 2, 7}); // [3]: 2z >= x - 7.
  simplex.addInequality({1, 0, -2, 0}); // [4]: 2z <= x.
  simplex.addInequality({0, 1, 0, 0});  // [5]: y >= 0.
  simplex.addInequality({0, 1, -2, 1}); // [6]: y >= 2z - 1.
  simplex.addInequality({-1, 1, 0, 1}); // [7]: y >= x - 1.

  simplex.detectRedundant();
  ASSERT_FALSE(simplex.isEmpty());

  // [0], [1], [3], [4], [7] together imply [2], [5], [6] must hold.
  //
  // From [7], [0]: x <= y + 1 <= 2, so we have [2].
  // From [7], [1]: y >= x - 1 >= 0, so we have [5].
  // From [4], [7]: 2z - 1 <= x - 1 <= y, so we have [6].
  EXPECT_FALSE(simplex.isMarkedRedundant(0));
  EXPECT_FALSE(simplex.isMarkedRedundant(1));
  EXPECT_TRUE(simplex.isMarkedRedundant(2));
  EXPECT_FALSE(simplex.isMarkedRedundant(3));
  EXPECT_FALSE(simplex.isMarkedRedundant(4));
  EXPECT_TRUE(simplex.isMarkedRedundant(5));
  EXPECT_TRUE(simplex.isMarkedRedundant(6));
  EXPECT_FALSE(simplex.isMarkedRedundant(7));
}

TEST(SimplexTest, isMarkedRedundantTiledLoopNestConstraints) {
  Simplex simplex(3);                     // Variables are x, y, N.
  simplex.addInequality({1, 0, 0, 0});    // [0]: x >= 0.
  simplex.addInequality({-32, 0, 1, -1}); // [1]: 32x <= N - 1.
  simplex.addInequality({0, 1, 0, 0});    // [2]: y >= 0.
  simplex.addInequality({-32, 1, 0, 0});  // [3]: y >= 32x.
  simplex.addInequality({32, -1, 0, 31}); // [4]: y <= 32x + 31.
  simplex.addInequality({0, -1, 1, -1});  // [5]: y <= N - 1.
  // [3] and [0] imply [2], as we have y >= 32x >= 0.
  // [3] and [5] imply [1], as we have 32x <= y <= N - 1.
  simplex.detectRedundant();
  EXPECT_FALSE(simplex.isMarkedRedundant(0));
  EXPECT_TRUE(simplex.isMarkedRedundant(1));
  EXPECT_TRUE(simplex.isMarkedRedundant(2));
  EXPECT_FALSE(simplex.isMarkedRedundant(3));
  EXPECT_FALSE(simplex.isMarkedRedundant(4));
  EXPECT_FALSE(simplex.isMarkedRedundant(5));
}

TEST(SimplexTest, addInequality_already_redundant) {
  Simplex simplex(1);
  simplex.addInequality({1, -1}); // x >= 1.
  simplex.addInequality({1, 0});  // x >= 0.
  simplex.detectRedundant();
  ASSERT_FALSE(simplex.isEmpty());
  EXPECT_FALSE(simplex.isMarkedRedundant(0));
  EXPECT_TRUE(simplex.isMarkedRedundant(1));
}

} // namespace mlir

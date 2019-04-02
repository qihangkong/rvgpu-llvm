# TestSwiftHashedContainerEnum.py

"""
Test combinations of hashed swift containers with enums as keys/values
"""

import lldb
from lldbsuite.test.lldbtest import *
from lldbsuite.test.decorators import *
import lldbsuite.test.lldbutil as lldbutil
import os
import unittest2

class TestSwiftHashedContainerEnum(TestBase):

    mydir = TestBase.compute_mydir(__file__)

    def setUp(self):
        TestBase.setUp(self)

    @swiftTest
    @add_test_categories(["swiftpr"])
    def test_any_object_type(self):
        """Test combinations of hashed swift containers with enums"""
        self.build()
        lldbutil.run_to_source_breakpoint(
            self, '// break here', lldb.SBFileSpec('main.swift'))

        self.expect(
            'frame variable -d run -- testA',
            substrs=[
                'key = c',
                'value = 1',
                'key = b',
                'value = 2'])
        self.expect(
            'expr -d run -- testA',
            substrs=[
                'key = c',
                'value = 1',
                'key = b',
                'value = 2'])

        self.expect(
            'frame variable -d run -- testB',
            substrs=[
                'key = "a", value = 1',
                'key = "b", value = 2'])
        self.expect(
            'expr -d run -- testB',
            substrs=[
                'key = "a", value = 1',
                'key = "b", value = 2'])

        self.expect(
            'frame variable -d run -- testC',
            substrs=['key = b', 'value = 2'])
        self.expect(
            'expr -d run -- testC',
            substrs=['key = b', 'value = 2'])

        self.expect(
            'frame variable -d run -- testD',
            substrs=['[0] = c'])
        self.expect(
            'expr -d run -- testD',
            substrs=['[0] = c'])

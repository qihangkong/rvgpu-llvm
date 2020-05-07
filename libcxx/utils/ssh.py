#===----------------------------------------------------------------------===##
#
# Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
# See https://llvm.org/LICENSE.txt for license information.
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
#
#===----------------------------------------------------------------------===##

"""
Runs an executable on a remote host.

This is meant to be used as an executor when running the C++ Standard Library
conformance test suite.
"""

import argparse
import os
import posixpath
import subprocess
import sys
import tarfile
import tempfile


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--host', type=str, required=True)
    parser.add_argument('--codesign_identity', type=str, required=False, default=None)
    parser.add_argument('--dependencies', type=str, nargs='*', required=False, default=[])
    parser.add_argument('--env', type=str, nargs='*', required=False, default=dict())
    (args, remaining) = parser.parse_known_args(sys.argv[1:])

    if len(remaining) < 2:
        sys.stderr.write('Missing actual commands to run')
        return 1

    commandLine = remaining[1:] # Skip the '--'

    ssh = lambda command: ['ssh', '-oBatchMode=yes', args.host, command]
    scp = lambda src, dst: ['scp', '-q', '-oBatchMode=yes', src, '{}:{}'.format(args.host, dst)]

    # Create a temporary directory where the test will be run.
    tmp = subprocess.check_output(ssh('mktemp -d /tmp/libcxx.XXXXXXXXXX'), universal_newlines=True).strip()

    # HACK:
    # If an argument is a file that ends in `.tmp.exe`, assume it is the name
    # of an executable generated by a test file. We call these test-executables
    # below. This allows us to do custom processing like codesigning test-executables
    # and changing their path when running on the remote host. It's also possible
    # for there to be no such executable, for example in the case of a .sh.cpp
    # test.
    isTestExe = lambda exe: exe.endswith('.tmp.exe') and os.path.exists(exe)
    pathOnRemote = lambda file: posixpath.join(tmp, os.path.basename(file))

    try:
        # Do any necessary codesigning of test-executables found in the command line.
        if args.codesign_identity:
            for exe in filter(isTestExe, commandLine):
                subprocess.check_call(['xcrun', 'codesign', '-f', '-s', args.codesign_identity, exe], env={})

        # Ensure the test dependencies exist, tar them up and copy the tarball
        # over to the remote host.
        try:
            tmpTar = tempfile.NamedTemporaryFile(suffix='.tar', delete=False)
            with tarfile.open(fileobj=tmpTar, mode='w') as tarball:
                for dep in args.dependencies:
                    if not os.path.exists(dep):
                        sys.stderr.write('Missing file or directory "{}" marked as a dependency of a test'.format(dep))
                        return 1
                    tarball.add(dep, arcname=os.path.basename(dep))

            # Make sure we close the file before we scp it, because accessing
            # the temporary file while still open doesn't work on Windows.
            tmpTar.close()
            remoteTarball = pathOnRemote(tmpTar.name)
            subprocess.check_call(scp(tmpTar.name, remoteTarball))
        finally:
            # Make sure we close the file in case an exception happens before
            # we've closed it above -- otherwise close() is idempotent.
            tmpTar.close()
            os.remove(tmpTar.name)

        # Untar the dependencies in the temporary directory and remove the tarball.
        remoteCommands = [
            'tar -xf {} -C {}'.format(remoteTarball, tmp),
            'rm {}'.format(remoteTarball)
        ]

        # Make sure all test-executables in the remote command line have 'execute'
        # permissions on the remote host. The host that compiled the test-executable
        # might not have a notion of 'executable' permissions.
        for exe in map(pathOnRemote, filter(isTestExe, commandLine)):
            remoteCommands.append('chmod +x {}'.format(exe))

        # Execute the command through SSH in the temporary directory, with the
        # correct environment. We tweak the command line to run it on the remote
        # host by transforming the path of test-executables to their path in the
        # temporary directory, where we know they have been copied when we handled
        # test dependencies above.
        commandLine = (pathOnRemote(x) if isTestExe(x) else x for x in commandLine)
        remoteCommands.append('cd {}'.format(tmp))
        if args.env:
            remoteCommands.append('export {}'.format(' '.join(args.env)))
        remoteCommands.append(subprocess.list2cmdline(commandLine))

        # Finally, SSH to the remote host and execute all the commands.
        rc = subprocess.call(ssh(' && '.join(remoteCommands)))
        return rc

    finally:
        # Make sure the temporary directory is removed when we're done.
        subprocess.check_call(ssh('rm -r {}'.format(tmp)))


if __name__ == '__main__':
    exit(main())

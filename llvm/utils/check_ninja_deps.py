#!/usr/bin/env python3
#
# ======- check-ninja-deps - build debugging script ----*- python -*--========#
#
# Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
# See https://llvm.org/LICENSE.txt for license information.
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
#
# ==------------------------------------------------------------------------==#

"""Script to find missing formal dependencies in a build.ninja file.

Suppose you have a header file that's autogenerated by (for example) Tablegen.
If a C++ compilation step needs to include that header, then it must be
executed after the Tablegen build step that generates the header. So the
dependency graph in build.ninja should have the Tablegen build step as an
ancestor of the C++ one. If it does not, then there's a latent build-failure
bug, because depending on the order that ninja chooses to schedule its build
steps, the C++ build step could run first, and fail because the header it needs
does not exist yet.

But because that kind of bug can easily be latent or intermittent, you might
not notice, if your local test build happens to succeed. What you'd like is a
way to detect problems of this kind reliably, even if they _didn't_ cause a
failure on your first test.

This script tries to do that. It's specific to the 'ninja' build tool, because
ninja has useful auxiliary output modes that produce the necessary data:

 - 'ninja -t graph' emits the full DAG of formal dependencies derived from
   build.ninja (in Graphviz format)

 - 'ninja -t deps' dumps the database of dependencies discovered at build time
   by finding out which headers each source file actually included

By cross-checking these two sources of data against each other, you can find
true dependencies shown by 'deps' that are not reflected as formal dependencies
in 'graph', i.e. a generated header that is required by a given source file but
not forced to be built first.

To run it:

 - set up a build directory using ninja as the build tool (cmake -G Ninja)

 - in that build directory, run ninja to perform an actual build (populating
   the dependency database)

 - then, in the same build directory, run this script. No arguments are needed
   (but -C and -f are accepted, and propagated to ninja for convenience).

Requirements outside core Python: the 'pygraphviz' module, available via pip or
as the 'python3-pygraphviz' package in Debian and Ubuntu.

"""

import sys
import argparse
import subprocess
import pygraphviz

def toposort(g):
    """Topologically sort a graph.

    The input g is a pygraphviz graph object representing a DAG. The function
    yields the vertices of g in an arbitrary order consistent with the edges,
    so that for any edge v->w, v is output before w."""

    # Count the number of immediate predecessors *not yet output* for each
    # vertex. Initially this is simply their in-degrees.
    ideg = {v: g.in_degree(v) for v in g.nodes_iter()}

    # Set of vertices which can be output next, which is true if they have no
    # immediate predecessor that has not already been output.
    ready = {v for v, d in ideg.items() if d == 0}

    # Keep outputting vertices while we have any to output.
    while len(ready) > 0:
        v = next(iter(ready))
        yield v
        ready.remove(v)

        # Having output v, find each immediate successor w, and decrement its
        # 'ideg' value by 1, to indicate that one more of its predecessors has
        # now been output.
        for w in g.out_neighbors(v):
            ideg[w] -= 1
            if ideg[w] == 0:
                # If that counter reaches zero, w is ready to output.
                ready.add(w)

def ancestors(g, translate = lambda x: x):
    """Form the set of ancestors for each vertex of a graph.

    The input g is a pygraphviz graph object representing a DAG. The function
    yields a sequence of pairs (vertex, set of proper ancestors).

    The vertex names are all mapped through 'translate' before output. This
    allows us to produce output referring to the label rather than the
    identifier of every vertex.
    """

    # Store the set of (translated) ancestors for each vertex so far. a[v]
    # includes (the translation of) v itself.
    a = {}

    for v in toposort(g):
        vm = translate(v)

        # Make up a[v], based on a[predecessors of v].
        a[v] = {vm} # include v itself
        for w in g.in_neighbors(v):
            a[v].update(a[w])

        # Remove v itself from the set before yielding it, so that the caller
        # doesn't get the trivial dependency of v on itself.
        yield vm, a[v].difference({vm})

def main():
    parser = argparse.ArgumentParser(
        description='Find missing formal dependencies on generated include '
        'files in a build.ninja file.')
    parser.add_argument("-C", "--build-dir",
                        help="Build directory (default cwd)")
    parser.add_argument("-f", "--build-file",
                        help="Build directory (default build.ninja)")
    args = parser.parse_args()

    errs = 0

    ninja_prefix = ["ninja"]
    if args.build_dir is not None:
        ninja_prefix.extend(["-C", args.build_dir])
    if args.build_file is not None:
        ninja_prefix.extend(["-f", args.build_file])

    # Get the formal dependency graph and decode it using pygraphviz.
    g = pygraphviz.AGraph(subprocess.check_output(
        ninja_prefix + ["-t", "graph"]).decode("UTF-8"))

    # Helper function to ask for the label of a vertex, which is where ninja's
    # Graphviz output keeps the actual file name of the target.
    label = lambda v: g.get_node(v).attr["label"]

    # Start by making a list of build targets, i.e. generated files. These are
    # just any graph vertex with at least one predecessor.
    targets = set(label(v) for v in g.nodes_iter() if g.in_degree(v) > 0)

    # Find the set of ancestors of each graph vertex. We pass in 'label' as a
    # translation function, so that this gives us the set of ancestor _files_
    # for a given _file_ rather than arbitrary numeric vertex ids.
    deps = dict(ancestors(g, label))

    # Fetch the cached dependency data and check it against our formal ancestry
    # data.
    currtarget = None
    for line in (subprocess.check_output(ninja_prefix + ["-t", "deps"])
                 .decode("UTF-8").splitlines()):
        # ninja -t deps output consists of stanzas of the following form,
        # separated by a blank line:
        #
        # target: [other information we don't need]
        #     some_file.cpp
        #     some_header.h
        #     other_header.h
        #
        # We parse this ad-hoc by detecting the four leading spaces in a
        # source-file line, and the colon in a target line. 'currtarget' stores
        # the last target name we saw.
        if line.startswith("    "):
            dep = line[4:]
            assert currtarget is not None, "Source file appeared before target"

            # We're only interested in this dependency if it's a *generated*
            # file, i.e. it is in our set of targets. Also, we must check that
            # currtarget is actually a target we know about: the dependency
            # cache is not cleared when build.ninja changes, so it can contain
            # stale data from targets that existed only in past builds in the
            # same directory.
            if (dep in targets and currtarget in deps and
                dep not in deps[currtarget]):
                print("error:", currtarget, "requires", dep,
                      "but has no dependency on it", file=sys.stderr)
                errs += 1
        elif ":" in line:
            currtarget = line.split(":", 1)[0]

    if errs:
        sys.exit("{:d} errors found".format(errs))

if __name__ == '__main__':
    main()

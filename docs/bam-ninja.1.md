% BAM-NINJA(1) | Bam Manual

# NAME

bam-ninja - Build a target or list of targets using Ninja

# SYNOPSIS

**bam** **ninja** [**-h**|**--help**] [**-f** \<file\>] [**-j** \<N\>] [**-k** \<N\>] [**-l** \<N\>] [**-n**]\
\  \  \  \  \  [**-v**] [**-d** \<mode\>] [**-t** \<tool\>] [**-w** \<flag\>] [\<targets...\>]

# DESCRIPTION
  Build targets using the Ninja build system. If targets are unspecified,
  builds the 'default' target.

# OPTIONS
-h, --help
:   Display this help and exit.

-f \<file\>
:   Specify input build file [default=build.ninja]

-j \<N\>
:   Run N jobs in parallel. The default is derived from the number of CPUs
    available.

-k \<N\>
:   Keep going until N jobs fail [default=1]

-l \<N\>
:   Do not start new jobs if the load average is greater than N

-n
:   Dry run (don't run commands but act like they succeeded)

-v
:   Show all command lines while building

-d \<mode\>
:   Enable debugging (use -d list to list modes)

-t \<tool\>
:   Run a subtool (use -t list to list subtools)

-w \<flag\>
:   Adjust warnings (use -w list to list warnings)

# INTRODUCTION

Ninja is yet another build system. It takes as input the interdependencies of
files (typically source code and output executables) and orchestrates building
them, quickly.

Ninja joins a sea of other build systems. Its distinguishing goal is to be fast.
It is born from my work on the Chromium browser project, which has over 30,000
source files and whose other build systems (including one built from custom
non-recursive Makefiles) would take ten seconds to start building after changing
one file. Ninja is under a second.

# PHILOSOPHICAL OVERVIEW

Where other build systems are high-level languages, Ninja aims to be an
assembler.

Build systems get slow when they need to make decisions. When you are in a
edit-compile cycle you want it to be as fast as possible — you want the build
system to do the minimum work necessary to figure out what needs to be built
immediately.

Ninja contains the barest functionality necessary to describe arbitrary
dependency graphs. Its lack of syntax makes it impossible to express complex
decisions.

Instead, Ninja is intended to be used with a separate program generating its
input files. The generator program (like the ./configure found in autotools
projects) can analyze system dependencies and make as many decisions as possible
up front so that incremental builds stay fast. Going beyond autotools, even
build-time decisions like "which compiler flags should I use?" or "should I
build a debug or release-mode binary?" belong in the .ninja file generator.

## DESIGN GOALS

Here are the design goals of Ninja:

  * very fast (i.e., instant) incremental builds, even for very large projects.
  * very little policy about how code is built. Different projects and
    higher-level build systems have different opinions about how code should be
    built; for example, should built objects live alongside the sources or
    should all build output go into a separate directory? Is there a "package"
    rule that builds a distributable package of the project? Sidestep these
    decisions by trying to allow either to be implemented, rather than choosing,
    even if that results in more verbosity.
  * get dependencies correct, and in particular situations that are difficult to
    get right with Makefiles (e.g. outputs need an implicit dependency on the
    command line used to generate them; to build C source code you need to use
    gcc’s -M flags for header dependencies).
  * when convenience and speed are in conflict, prefer speed.

Some explicit non-goals:

  * convenient syntax for writing build files by hand. You should generate your
    ninja files using another program. This is how we can sidestep many policy
    decisions.
  * built-in rules. Out of the box, Ninja has no rules for e.g. compiling C
    code.
  * build-time customization of the build. Options belong in the program that
    generates the ninja files.
  * build-time decision-making ability such as conditionals or search paths.
    Making decisions is slow.

To restate, Ninja is faster than other build systems because it is painfully simple. You must tell Ninja exactly what to do when you create your project’s .ninja files.

## COMPARISON TO MAKE

Ninja is closest in spirit and functionality to Make, relying on simple
dependencies between file timestamps.

But fundamentally, make has a lot of features: suffix rules, functions, built-in
rules that e.g. search for RCS files when building source. Make’s language was
designed to be written by humans. Many projects find make alone adequate for
their build problems.

In contrast, Ninja has almost no features; just those necessary to get builds
correct while punting most complexity to generation of the ninja input files.
Ninja by itself is unlikely to be useful for most projects.

Here are some of the features Ninja adds to Make. (These sorts of features can
often be implemented using more complicated Makefiles, but they are not part of
make itself.)

  * Ninja has special support for discovering extra dependencies at build time,
    making it easy to get header dependencies correct for C/C++ code.
  * A build edge may have multiple outputs.
  * Outputs implicitly depend on the command line that was used to generate
    them, which means that changing e.g. compilation flags will cause the
    outputs to rebuild.
  * Output directories are always implicitly created before running the command
    that relies on them.
  * Rules can provide shorter descriptions of the command being run, so you can
    print e.g. CC foo.o instead of a long command line while building.
  * Builds are always run in parallel, based by default on the number of CPUs
    your system has. Underspecified build dependencies will result in incorrect
    builds.
  * Command output is always buffered. This means commands running in parallel
    don’t interleave their output, and when a command fails we can print its
    failure output next to the full command line that produced the failure.

# Using Ninja for your project

Ninja currently works on Unix-like systems and Windows. It’s seen the most
testing on Linux (and has the best performance there) but it runs fine on Mac
OS X and FreeBSD.

If your project is small, Ninja’s speed impact is likely unnoticeable. (However,
even for small projects it sometimes turns out that Ninja’s limited syntax
forces simpler build rules that result in faster builds.) Another way to say
this is that if you’re happy with the edit-compile cycle time of your project
already then Ninja won’t help.

There are many other build systems that are more user-friendly or featureful
than Ninja itself. For some recommendations: the Ninja author found the tup
build system influential in Ninja’s design, and thinks redo's design is quite
clever.

Ninja’s benefit comes from using it in conjunction with a smarter meta-build
system.

gyp
:   The meta-build system used to generate build files for Google Chrome and
    related projects (v8, node.js). gyp can generate Ninja files for all
    platforms supported by Chrome. See the Chromium Ninja documentation for
    more details.

CMake
:   A widely used meta-build system that can generate Ninja files on Linux as of
    CMake version 2.8.8. Newer versions of CMake support generating Ninja files
    on Windows and Mac OS X too.

others
:   Ninja ought to fit perfectly into other meta-build software like premake. If
    you do this work, please let us know!

## Running Ninja

Run ninja. By default, it looks for a file named build.ninja in the current
directory and builds all out-of-date targets. You can specify which targets
(files) to build as command line arguments.

There is also a special syntax target^ for specifying a target as the first
output of some rule containing the source you put in the command line, if one
exists. For example, if you specify target as foo.c^ then foo.o will get built
(assuming you have those targets in your build files).

**ninja -h** prints help output. Many of Ninja’s flags intentionally match those
of Make; e.g **ninja -C build -j 20** changes into the build directory and runs
20 build commands in parallel. (Note that Ninja defaults to running commands in
parallel anyway, so typically you don’t need to pass -j.)

## Environment variables

Ninja supports one environment variable to control its behavior:
**NINJA_STATUS**, the progress status printed before the rule being run.

Several placeholders are available:

%s
:   The number of started edges.

%t
:   The total number of edges that must be run to complete the build.

%p
:   The percentage of finished edges.

%r
:   The number of currently running edges.

%u
:   The number of remaining edges to start.

%f
:   The number of finished edges.

%o
:   Overall rate of finished edges per second

%c
:   Current rate of finished edges per second (average over builds specified by
    -j or its default)

%e
:   Elapsed time in seconds. (Available since Ninja 1.2.)

%%
:   A plain % character.

The default progress status is **"[%f/%t] "** (note the trailing space to
separate from the build rule). Another example of possible progress status
could be **"[%u/%r/%f] "**.

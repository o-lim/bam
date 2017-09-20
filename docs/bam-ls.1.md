% BAM-LS(1) | Bam Manual

# NAME

bam-ls - List matching targets

# SYNOPSIS

**bam** **ls** [**-h**|**--help**] [**--args**=\<args\>] [**--[no]color**] [**--markdown**]\
\  \  \  \ [**--dotfile**=\<filename\>] [**--root**=\<root-dir\>]\
\  \  \  \ [**--runtime-deps-list-file**=\<filename\>] [**--threads**=\<N\>]\
\  \  \  \ [**--time**] [**--tracelog**=\<logfile\>] [**-v**]\
\  \  \  \ [\<label-pattern\>] [**--all-toolchains**] [**--as**=...]\
\  \  \  \ [**--type**=...] [**--testonly**=...]

# DESCRIPTION
  Lists all targets matching the given pattern for the given build
  directory. By default, only targets in the default toolchain will
  be matched unless a toolchain is explicitly supplied.

  If the label pattern is unspecified, list all targets. The label
  pattern is not a general regular expression (see
  "gn help label_pattern"). If you need more complex expressions,
  pipe the result through grep.

# OPTIONS
-h, --help
:   Display this help and exit.

--args=\<args\>
:   Specifies build argument overrides.

--color
:   Force colored output.

--dotfile=\<filename\>
:   Override the name of the ".gn" file.

--markdown
:   Write the output in the Markdown format.

--nocolor
:   Force non-colored output.

--root=\<root-dir\>
:   Explicitly specify source root.

--runtime-deps-list-file=\<filename\>
:   Save runtime dependencies for targets to file.

--threads=\<N\>
:   Specify number of worker threads.

--time
:   Outputs a summary of how long everything took.

--tracelog=\<logfile\>
:   Writes a Chrome-compatible trace log to the given file.

-v
:   Verbose logging.

--as=(buildfile|label|output)
:   How to print targets.

    buildfile
    :   Prints the build files where the given target was declared as
        file names.

    label  (default)
    :   Prints the label of the target.

    output
    :   Prints the first output file for the target relative to the
        root build directory.

--all-toolchains
:   Matches all toolchains. When set, if the label pattern does not
    specify an explicit toolchain, labels from all toolchains will be
    matched. When unset, only targets in the default toolchain will
    be matched unless an explicit toolchain in the label is set.

--testonly=(true|false)
:   Restrict outputs to targets with the testonly flag set
    accordingly. When unspecified, the target's testonly flags are
    ignored.

--type=(action|copy|executable|group|loadable_module|shared_library|source_set|static_library)
:   Restrict outputs to targets matching the given type. If
    unspecified, no filtering will be performed.

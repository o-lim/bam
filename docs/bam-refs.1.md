% BAM-REFS(1) | Bam Manual

# NAME

bam-refs - Find stuff referencing a target or file

# SYNOPSIS

**bam** **refs** [**-h**|**--help**] [**--args**=\<args\>] [**--[no]color**] [**--markdown**] [**-q**]\
\  \  \  \  \ [**--dotfile**=\<filename\>] [**--root**=\<root-dir\>]\
\  \  \  \  \ [**--runtime-deps-list-file**=\<filename\>] [**--threads**=\<N\>]\
\  \  \  \  \ [**--time**] [**--tracelog**=\<logfile\>] [**-v**]\
\  \  \  \  \ (\<label-pattern\>|\<label\>|\<file\>|@\<response-file\>)* [**--all**]\
\  \  \  \  \ [**--all-toolchains**] [**--as**=...] [**--testonly**=...] [**--type**=...]

# DESCRIPTION
Finds reverse dependencies (which targets reference something). The
input is a list containing:

- Target label: The result will be which targets depend on it.

- Config label: The result will be which targets list the given
  config in its "configs" or "public_configs" list.

- Label pattern: The result will be which targets depend on any
  target matching the given pattern. Patterns will not match
  configs. These are not general regular expressions, see
  "gn help label_pattern" for details.

- File name: The result will be which targets list the given file in
  its "inputs", "sources", "public", "data", or "outputs".
  Any input that does not contain wildcards and does not match a
  target or a config will be treated as a file.

- Response file: If the input starts with an "@", it will be
  interpreted as a path to a file containing a list of labels or
  file names, one per line. This allows us to handle long lists
  of inputs without worrying about command line limits.

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

--all
:   When used without **--tree**, will recurse and display all unique
    dependencies of the given targets. For example, if the input is
    a target, this will output all targets that depend directly or
    indirectly on the input. If the input is a file, this will output
    all targets that depend directly or indirectly on that file.

    When used with --tree, turns off eliding to show a complete tree.

--all-toolchains
:   Normally only inputs in the default toolchain will be included.
    This switch will turn on matching all toolchains.

    For example, a file is in a target might be compiled twice:
    once in the default toolchain and once in a secondary one. Without
    this flag, only the default toolchain one will be matched and
    printed (potentially with its recursive dependencies, depending on
    the other options). With this flag, both will be printed
    (potentially with both of their recursive dependencies).

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

-q
:   Quiet. If nothing matches, don't print any output. Without this
    option, if there are no matches there will be an informational
    message printed which might interfere with scripts processing the
    output.

--testonly=(true|false)
:   Restrict outputs to targets with the testonly flag set
    accordingly. When unspecified, the target's testonly flags are
    ignored.

--tree
:   Outputs a reverse dependency tree from the given target.
    Duplicates will be elided. Combine with --all to see a full
    dependency tree.

    Tree output can not be used with the filtering or output flags:
    **--as**, **--type**, **--testonly**.

--type=(action|copy|executable|group|loadable_module|shared_library|source_set|static_library)
:   Restrict outputs to targets matching the given type. If
    unspecified, no filtering will be performed.

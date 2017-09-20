% BAM-ARGS(1) | Bam Manual

# NAME

bam-args - Display or configure arguments declared by the build

# SYNOPSIS

**bam** **args** [**-h**|**--help**] [**--args**=\<args\>] [**--[no]color**] [**--markdown**]\
\  \  \  \  \ [**--dotfile**=\<filename\>] [**--root**=\<root-dir\>]\
\  \  \  \  \ [**--runtime-deps-list-file**=\<filename\>] [**--threads**=\<N\>]\
\  \  \  \  \ [**--time**] [**--tracelog**=\<logfile\>] [**-v**]\
**bam** **args** **--list**[=\<arg\>] [**--short**] [**--args**=\<args\>]

# DESCRIPTION

When specified without --list, opens the arguments for the build directory
in an editor (as specified by the EDITOR environment variable). If the build
directory does not exist, it will be created and an empty args file will be
opened in the editor.

If **--list** is specified, lists all build arguments available in the current
configuration, or, if \<arg\> is specified, just that one build argument.

The output will list the declaration location, default value, and comment
preceeding the declaration. If **--short** is specified, only the names and
values will be printed.

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

--list[=\<arg\>]
:   Prints information about the specified argument. If no argument is
    provided, prints a list of all arguments with their default values.

--short
:   Prints only the names and values.

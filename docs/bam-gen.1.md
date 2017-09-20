% BAM-GEN(1) | Bam Manual

# NAME

bam-gen - Generate ninja build files using 'gn gen'

# SYNOPSIS

**bam** **gen** [**-h**|**--help**] [**--args**=\<args\>] [**--[no]color**] [**--markdown**] [**-q**]\
\  \  \  \  [**--dotfile**=\<filename\>] [**--root**=\<root-dir\>]\
\  \  \  \  [**--runtime-deps-list-file**=\<filename\>] [**--threads**=\<N\>]\
\  \  \  \  [**--time**] [**--tracelog**=\<logfile\>] [**-v**]

# DESCRIPTION

Generates ninja files from the current tree and puts them in the given output
directory.

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

-q
:   Quiet mode. Don't print output on success.

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

% BAM-PATH(1) | Bam Manual

# NAME

bam-path - Find paths between two targets

# SYNOPSIS

**bam** **path** [**-h**|**--help**] [**--args**=\<args\>] [**--[no]color**] [**--markdown**]\
\  \  \  \  \ [**--dotfile**=\<filename\>] [**--root**=\<root-dir\>]\
\  \  \  \  \ [**--runtime-deps-list-file**=\<filename\>] [**--threads**=\<N\>]\
\  \  \  \  \ [**--time**] [**--tracelog**=\<logfile\>] [**-v**]\
\  \  \  \  \ [**--all**] [**--public**|**--with-data**] \<target-one\> \<target-two\>

# DESCRIPTION
  Finds paths of dependencies between two targets. Each unique path
  will be printed in one group, and groups will be separate by newlines.
  The two targets can appear in either order: paths will be found going
  in either direction.

  By default, a single path will be printed. If there is a path with
  only public dependencies, the shortest public path will be printed.
  Otherwise, the shortest path using either public or private
  dependencies will be printed. If **--with-data** is specified, data deps
  will also be considered. If there are multiple shortest paths, an
  arbitrary one will be selected.

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
:   Prints all paths found rather than just the first one. Public paths
    will be printed first in order of increasing length, followed by
    non-public paths in order of increasing length.

--public
:   Considers only public paths. Can't be used with --with-data.

--with-data
:   Additionally follows data deps. Without this flag, only public and
    private linked deps will be followed. Can't be used with **--public**.

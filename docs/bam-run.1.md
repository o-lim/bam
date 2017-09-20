% BAM-RUN(1) | Bam Manual

# NAME

bam-run - Build and run a single target

# SYNOPSIS

**bam** **run** [**-h**|**--help**] [**-j** \<N\>|**--jobs** \<N\>] [**-l** \<N\>|**--load-average** \<N\>]\
\  \  \  \  [**-k**|**--[no-]keep-going**|**-S**|**--stop**] [**-n**|**--dry-run**]\
\  \  \  \  [**--run-under** \<command-prefix\>] [**-v**|**--verbose**]\
\  \  \  \  (\<target\>|\<target-label\>) [target-args...]

# DESCRIPTION
  The *bam run* command is similar to *bam build*, except it is used to build
  and run a single target.

# OPTIONS
-h, --help
:   Display this help and exit.

-j \<N\>, --jobs \<N\>
:   Run N jobs in parallel. The default is derived from the number of CPUs
    available.

-k, --keep-going
:   Continue as much as possible after an error. While a target that failed,
    and those that depend on it, cannot be remade, the other dependencies of
    these targets can be processed all the same.

-l \<N\>, --load-average \<N\>
:   Do not start new jobs if the load average is greater than N.

-n, --dry-run
:   Dry run (don't run commands but act like they succeeded).

--run-under \<command-prefix\>
:   This specifies a prefix that the target runner will insert in front of the
    command being executed. The \<command-prefix\> is split into words using
    Bourne shell tokenization rules, and then the list of words is prepended
    to the command that will be executed.

-S, --no-keep-going, --stop
:   Cancel the effect of the **-k** option.

-v, --verbose
:   Show all command lines while building.

\<target\>
:   The executable target to build and run.

\<target-label\>
:   The target label to build and run.

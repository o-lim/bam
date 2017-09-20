% BAM-BUILD(1) | Bam Manual

# NAME

bam-build - Build a target or list of targets

# SYNOPSIS

**bam** **build** [**-h**|**--help**] [**-j** \<N\>|**--jobs** \<N\>] [**-l** \<N\>|**--load-average** \<N\>]\
\  \  \  \  \  [**-k**|**--[no-]keep-going**|**-S**|**--stop**] [**-n**|**--dry-run**]\
\  \  \  \  \  [**--check-up-to-date**] [**-v**|**--verbose**]\
\  \  \  \  \  [\<targets...\>|\<target-patterns...\>]

# DESCRIPTION
  Build/Make the specified targets. If no targets are specified, builds the
  'default' target.

# OPTIONS
-h, --help
:   Display this help and exit.

--check-up-to-date
:   Do not perform a build, but merely check whether all specified targets are
    up-to-date. If so, the build completes successfully, as usual. However, if
    any files are out-of-date, instead of being built, an error is reported and
    the build fails. This option may be useful to determine whether a build has
    been performed more recently than a source edit without incurring the cost
    of a build.

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

-S, --no-keep-going, --stop
:   Cancel the effect of the **-k** option.

-v, --verbose
:   Show all command lines while building.

\<targets\>
:   List of targets to build.

\<target-patterns\>
:   List of target label patterns to build.

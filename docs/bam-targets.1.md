% BAM-TARGETS(1) | Bam Manual

# NAME

bam-targets - List targets by their rule or depth in the DAG

# SYNOPSIS

**bam** **targets** (**-h**|**--help**)\
**bam** **targets** rule [\<name\>]\
**bam** **targets** depth [\<N\>]\
**bam** **targets** all

# DESCRIPTION
  Output a list of targets either by rule or by depth. If no arguments are
  provided depth 1 is assumed.

# OPTIONS
-h, --help
:   Display this help and exit.

rule [\<name\>]
:   Prints the list of targets using the given rule to be built. If no rule
    is given, it prints the source files (the leaves of the graph).

depth [\<N\>]
:   Prints the list of targets in a depth-first manner by the root targets
    (the ones with no outputs). Indentation is used to mark dependencies. If
    the depth is zero it prints all targets.

all
:   Prints all the targets available without indentation and it is faster than
    the \<depth\> mode.

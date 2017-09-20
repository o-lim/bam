% BAM-CLEAN(1) | Bam Manual

# NAME

bam-clean - Cleans the output directory

# SYNOPSIS

**bam** **clean** [**-h**|**--help**] [-v|--verbose] [-n|--dry-run]\
\  \  \  \  \  [\<targets...\>|\<target-patterns...\>]\
**bam** **clean** **-r** \<rules...\>

# DESCRIPTION
When specified without any arguments, deletes the contents of the output
directory except for args.gn and creates a Ninja build environment sufficient
to regenerate the build.

If \<targets\> is specified, removes the given targets and recursively all files
built for them.

If \<target-patterns\> is specified, removes targets based on the given target
label pattern and recursively all files built for them.

# OPTIONS
-h, --help
:   Display this help and exit.

-r \<rules\>
:   Removes all files built using the given rules.

\<targets\>
:   List of targets to clean.

\<target-patterns\>
:   List of target label patterns to clean.

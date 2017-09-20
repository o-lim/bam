% BAM-FORMAT(1) | Bam Manual

# NAME

bam-format - Format .gn file

# SYNOPSIS

**bam** **format** [**-h**|**--help**] [**--dry-run**] [**--dump-tree**] (**--stdin** | \<file\>)

# DESCRIPTION

Formats .gn file to a standard format.

# OPTIONS
-h, --help
:   Display this help and exit.

--dry-run
:   Does not change or output anything, but sets the process exit code
    based on whether output would be different than what's on disk.
    This is useful for presubmit/lint-type checks.

    - Exit code 0: successful format, matches on disk.
    - Exit code 1: general failure (parse error, etc.)
    - Exit code 2: successful format, but differs from on disk.

--dump-tree
:   For debugging only, dumps the parse tree to stdout and does not update
    the file or print formatted output.

--stdin
:   Read input from stdin and write to stdout rather than update a file
    in-place.

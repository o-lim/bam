% BAM-STATUS(1) | Bam Manual

# NAME

bam-status - Show the build status

# SYNOPSIS

**bam** **status** [**-h**|**--help**] [**--[no-]show-out-dir**]\
\  \  \  \  \  \ [**--[no-]show-source-root**] [\<target-patterns...\>]

# DESCRIPTION
  Displays whether or not the build is up-to-date. If one or more target
  patterns are specified, then only display the build status of the matching
  targets.

  This command exits with an error if the build is not up-to-date. The exit
  codes are:

  0. The build is up-to-date.

  1. The build is out-of-date.

  2. Ninja files are out-of-date.

  3. Ninja files are out-of-date due to the build environment changing.

  4. There is no previously generated build.

# OPTIONS
-h, --help
:   Display this help and exit.

--show-out-dir
:   Show $BAM_OUTPUT_DIR if defined. Otherwise show the build output
    directory. The build output directory is always relative to the top-level
    directory, unless an absolute path is given.

--no-show-out-dir
:   Do not show the build output directory.

--show-source-root
:   Show the absolute path to the source root directory.

--no-show-source-root
:   Do not show the source root directory.

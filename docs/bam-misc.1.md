% BAM-MISC(1) | Bam Manual

# NAME

bam-misc - Show miscellaneous build information

# SYNOPSIS

**bam** **misc** [**-h**|**--help**] [**--show-top-level**] [**--show-bam-dir**]\
\  \  \  \  \ [**--show-out-dir**] [**--show-source-root**]\
\  \  \  \  \ [**--show-cdup**] [**--show-prefix**]

# DESCRIPTION
  Displays miscellaneous information about the build.

# OPTIONS
-h, --help
:   Display this help and exit.

--show-bam-dir
:   Show $BAM_DIR if defined. Otherwise show the path to the .bam directory.

--show-cdup
:   When the command is invoked from a subdirectory, show the path to the
    top-level directory relative to the current directory (typically a sequence
    of "../", or an empty string)

--show-out-dir
:   Show $BAM_OUTPUT_DIR if defined. Otherwise show the build output directory.
    The build output directory may be a source absolute, system absolute, or
    relative path.

--show-prefix
:   When the command is invoked from a subdirectory, show the path of the
    current directory relative to the top-level directory.

--show-source-root
:   Show the absolute path to the source root directory.

--show-top-level
:   Show the absolute path to the top-level directory.

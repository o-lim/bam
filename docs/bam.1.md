% BAM(1) | Bam Manual

# NAME

bam - the program builder

# SYNOPSIS

**bam** [**--version**] [**-h**|**--help**] [**-C** \<path\>] [**--core-path** [\<path\>]]\
\  \  [**--exec-path** [\<path\>]] [**-o** \<path\>|**--out-dir** \<path\>]\
\  \  [**--source-root** \<path\>|**--root** \<path\>] [**--top-level** \<path\>]\
\  \  [**--bam-dir** \<path\>] \<command\> [\<args\>]

# DESCRIPTION

A build system wrapper for **gn** (Generate Ninja) and **ninja**.

# OPTIONS
--version
:   Prints the Bam suite version that the _bam_ program came from.

-h, --help
:   Prints the synopsis and a list of bam commands. If a bam command is
    named, this option will bring up the help for that command.

-C \<path\>
:   Run as if bam were started in \<path\> instead of the current working
    directory. When multiple **-C** options are specified, each subsequent
    non-absolute **-C** \<path\> is interpreted relative to the preceding
    **-C** \<path\>.

--core-path [\<path\>]
:   Path to wherever your core _bam_ configuration files are installed. This
    can also be controlled by setting the BAM_CORE_PATH environment variable.
    If no path is specified, _bam_ will print the current setting and then exit.

--exec-path [\<path\>]
:   Path to wherever your core _bam_ programs are installed. This can also be
    controlled by setting the BAM_EXEC_PATH environment variable. If no path
    is specified, _bam_ will print the current setting and then exit.

-o \<path\>, --out-dir \<path\>
:   Set the path to the output directory. This can also be controlled by
    setting the BAM_OUTPUT_DIR environment variable. It can be an absolute
    path or relative path to the current working directory.

--bam-dir \<path\>
:   Set the path to the project configuration directory. This can also be
    controlled by setting the BAM_DIR environment variable. It can be an
    absolute path or relative path to the current working directory.

--source-root \<path\>, --root \<path\>
:   Set the path to the source root directory. The source root directory
    specifies the meaning of "//" at the beginning of a path, and the
    BUILD.gn file in that directory will be the first thing loaded. This
    can also be controlled by setting the BAM_SOURCE_ROOT environment
    variable. It can be an absolute path or relative path to the current
    working directory.

--top-level \<path\>
:   Set the path to the base directory of the bam project. This can also be
    controlled by setting the BAM_TOP_LEVEL environment variable. It can be
    an absolute path or relative path to the current working directory.

# ENVIRONMENT VARIABLES

Various _bam_ commands use the following environment variables:

*BAM_OUTPUT_DIR*
:   If the *BAM_OUTPUT_DIR* environment variable is set then it specifies the
    path to use for the bam output directory. The default is to use the
    current working directory. This is where Ninja build files will be created,
    as well as any build outputs such as generated files, object files,
    executables, etc. The **--out-dir** command-line option also sets this
    value.

*BAM_CORE_PATH*
:   This specifies the path to wherever your core _bam_ configuration files are
    installed. If this environment variable is not set the default setting is
    used.

*BAM_EXEC_PATH*
:   This specifies the path to wherever your core _bam_ programs are installed.
    If this environment variable is not set the default setting is used.

*BAM_DIR*
:   If the *BAM_DIR* environment variable is set then it specifies a path to
    use instead of the default .bam located at the base of the project. The
    *--bam-dir* command-line option also sets this value.

*BAM_SOURCE_ROOT*
:   If the *BAM_SOURCE_ROOT* environment variable is set then it specifies a
    path to use instead searching for the source root directory. The
    *--source-root* command-line option also sets this value.

*BAM_TOP_LEVEL*
:   If the *BAM_TOP_LEVEL* environment variable is set then it specifies a
    path to use as the base directory of the project. The *--top-level*
    command-line option also sets this value.

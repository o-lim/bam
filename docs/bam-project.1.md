% BAM-PROJECT(1) | Bam Manual

# NAME

bam-project - Generate project files for an IDE (i.e. Eclipse)

# SYNOPSIS

**bam** **project** [**-h**|**--help**] [**-g** \<generator\>|**--generator** \<generator\>]\
\  \  \  \  \  \  [**-n** \<name\>|**--name** \<name\>] [**--all-toolchains**]\
\  \  \  \  \  \  [**-t** \<toolchain\>|**--toolchain** \<toolchain\>] [\<directory\>]

# DESCRIPTION
This command generates an IDE project for use with the 'bam' tool. If
\<directory\> is specified, the command is run inside it, otherwise the current
working directory is used. If this directory does not exist, it will be
created.

# OPTIONS
-h, --help
:   Display this help and exit.

-g \<generator\>, --generator \<generator\>
:   Specifies a project generator (use -g list to list available generators).
    If a generator is not specified, defaults to eclipse.

-n \<name\>, --name \<name\>
:   Sets the name for the project. The default project name is the name of
    the directory where this command is run.

-t \<toolchain\>, --toolchain \<toolchain\>
:   Sets the toolchain for the project. The default project toolchain is
    dependent on the generator.

--all-toolchains
:   Generates a single project for all toolchains. This is not supported
    by all generators.

\<directory\>
:   The name of the directory in which to create the IDE project. If specified,
    the command is run inside this directory, otherwise the current working
    directory is used.

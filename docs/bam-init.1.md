% BAM-INIT(1) | Bam Manual

# NAME

bam-init - Create an empty project or reinitialize an existing one

# SYNOPSIS

**bam** **init** [**-h**|**--help**] [**-p** \<platforms\>|**--platforms** \<platforms\>]\
\  \  \  \  \  [**--config** \<path\>] [**-n** \<name\>|**--name** \<name\>] [\<directory\>]

# DESCRIPTION

This command creates an empty bam project or reinitializes an existing one.
If \<directory\> is specified, the command is run inside it, otherwise the
current working directory is used. If the directory does not exist, it will be
created.

# OPTIONS
-h, --help
:   Display this help and exit.

--config \<path\>
:   Set the path to the build configuration directory. It must be a path
    relative to \<directory\>. This defaults to "build".

-n \<name\>, --name \<name\>
:   Sets the name for the project in the top level BUILD.gn file. The default
    project name is the name of the directory where this command is run.

-p \<platforms\>, --platforms \<platforms\>
:   Specifies the list of platforms to support for the project. \<platforms\>
    will be interpreted as a comma separated list of platforms (use -p list
    to list available platforms).

\<directory\>
:   The name of the directory in which to create the project. If specified,
    the command is run inside this directory, otherwise the current working
    directory is used.

# TEMPLATE DIRECTORY

The template directory contains files and directories that are used to generate
an empty bam project.

The template directory used will be (in order):

  -   The contents of the $BAM_TEMPLATE_DIR environment variable.

  -   The default template directory:\
      \  \  @prefix@/share/bam-core/templates

The default template directory includes some directory structure, suggested
build configuration, and copies of common pre-configured toolchains.

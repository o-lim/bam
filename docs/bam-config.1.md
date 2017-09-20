% BAM-CONFIG(1) | Bam Manual

# NAME

bam-config - Get and set project or global options

# SYNOPSIS

**bam** **config** [\<file-option\>] \<name\> [\<value\>]\
**bam** **config** [\<file-option\>] **--add** \<name\> \<value\>\
**bam** **config** [\<file-option\>] **--replace-all** \<name\> \<value\>\
**bam** **config** [\<file-option\>] **--get** \<name\>\
**bam** **config** [\<file-option\>] **--get-all** \<name\>\
**bam** **config** [\<file-option\>] **--unset** \<name\>\
**bam** **config** [\<file-option\>] **--unset-all** \<name\>\
**bam** **config** [\<file-option\>] **--rename-section** \<old-name\> \<new-name\>\
**bam** **config** [\<file-option\>] **--remove-section** \<name\>\
**bam** **config** [\<file-option\>] **-l** | **--list**\
**bam** **config** **-h** | **--help**

# DESCRIPTION
  You can query/set/replace/unset options with this command. The name is
  actually the section and the key separated by a dot, and the value will be
  escaped.

  When reading, the values are read from the global and project local
  configuration files by default, and options *--global*, *--local* and
  *--file \<file\>* can be used to tell the command to read from only that
  location.

  When writing, the new value is written to the project local configuration file
  by default, and options *--global*, *--file \<file\>* can be used to tell the
  command to write to that location (you can say *--local*, but that is the
  default).

  The command will fail with non-zero status upon error.

# OPTIONS
-h, --help
:   Display this help and exit.

--replace-all \<name\> \<value\>
:   Default behavior is to replace at most one line. This replaces all lines
    matching the key.

--add \<name\> \<value\>
:   Adds a new line to the option without altering any existing values.

--get \<name\>
:   Get the value for the given key. Returns error code 1 if the key was not
    found and the last value if multiple keys were found.

--get-all \<name\>
:   Like **--get**, but gets all values matching the given key.

--global
:   For writing options: write to global ~/.bamconfig file rather than the
    project .bam/config.

    For reading options: read only from global ~/.bamconfig rather than from all
    available files.

--local
:   For writing options: write to the project .bam/config file. This is the
    default behavior.

    For reading options: read only from the project .bam/config rather than from
    all available files.

-f \<config-file\>, --file \<config-file\>
:   Use the given config file instead of the one specified by BAM_CONFIG.

--remove-section \<name\>
:   Remove the given section from the configuration file.

--rename-section \<old-name\> \<new-name\>
:   Rename the given section to a new name.

--unset \<name\>
:   Remove the line matching the key from the config file.

--unset-all \<name\>
:   Remove all lines matching the key from the config file.

# FILES

  If not set explicitly with **--file**, there are two files where _bam_
  _config_ will search for configuration options:

  ~/.bamconfig
  :  User-specific configuration file. Also called "global" configuration file.

  $BAM_DIR/config
  :  Project specific configuration file.

  If no further options are given, all reading options will read all of these
  files that are available. If the global configuration file is not available
  it will be ignored. If the project configuration file is not available or
  readable, _bam_ _config_ will exit with a non-zero error code. However,
  in neither case will an error message be issued.

  All writing options will per default write to the project specific
  configuration file. _bam_ _config_ will only ever change one file at a
  time.

  You can override these rules either by command line options or by
  environment variables. The *--global* option will limit the file used to
  the global file. The BAM_CONFIG environment variable has a similar effect,
  but you can specify any filename you want.

# ENVIRONMENT

BAM_CONFIG
:   Take the configuration from the given file instead of .bam/config. Using
    the *--global* option forces this to ~/.bamconfig.

# CONFIGURATION FILE
  The bam configuration file contains a number of variables that affect the
  bam commands' behavior. The .bam/config file in each project is used to
  store the configuration for that project, and the $HOME/.bamconfig is used to
  store a per-user configuration as fallback values for the .bam/config file.

  Configuration variables are divided into sections, wherein the fully qualified
  variable name of the variable itself is the last dot-separated segment, and
  the section name is everything before the last dot. The variable names are
  case-sensitive, allow only alphanumeric characters and -, and must start with
  an alphabetic character. Some variables may appear multiple times.

## Variables

  Note that this list is non-comprehensive and not necessarily complete. For
  command-specific variables, you will find a more detailed description in the
  appropriate manual page.

  core.outdir
  :   Set the path to the build output directory. This can be overridden by the
      BAM_OUTPUT_DIR environment variable and the *--out-dir* command-line
      option. The value can be a source absolute path, system absolute path, or
      relative to the path to the '.bam' directory, which is either specified by
      *--bam-dir* or BAM_DIR, or automatically discovered. If *--bam-dir* or 
      BAM_DIR is specified, but none of *--out-dir*, BAM_OUTPUT_DIR, and
      core.outdir is specified, the source root directory is regarded as the
      output directory.

  core.sourceroot
  :   Set the path to the source root directory. This can be overridden by the
      BAM_SOURCE_ROOT environment variable and the *--source-root* command-line
      option. The value can be a system absolute path, or relative to the path
      to the '.bam' directory, which is either specified by *--bam-dir* or
      BAM_DIR, or automatically discovered. If *--bam-dir* or BAM_DIR is
      specified, but none of *--source-root*, BAM_SOURCE_ROOT, core.sourceroot,
      *--out-dir*, BAM_OUTPUT_DIR, core.outdir is specified, the source root
      directory is automatically discovered by walking up the directory tree
      until a .gn file is found. If one of *--out-dir*, BAM_OUTPUT_DIR,
      core.outdir is specified as a system absolute or relative path and
      contains a previously generated build, the source root directory is
      automatically determined from the previously generated build.

  core.toplevel
  :   Set the path to the project base directory. This can be overridden by the
      BAM_TOP_LEVEL environment variable and the *--top-level* command-line
      option. The value can be a system absolute path, or relative to the path
      to the '.bam' directory, which is either specified by *--bam-dir* or
      BAM_DIR, or automatically discovered. If *--bam-dir* or BAM_DIR is
      specified, but none of *--top-level*, BAM_TOP_LEVEL, and core.toplevel
      is specified, the current working directory is regarded
      as the top level directory.

  alias.\*
  :   Command aliases for the **bam** command wrapper (e.g. after defining
      "alias.all = build all", the invocation "bam all" is equivalent to "bam
      build all"). To avoid confusion and troubles with script usage, aliases
      that hide existing bam commands are ignored. Arguments are split by
      spaces, the usual shell quoting and escaping is supported.

      If the alias expansion is prefixed with an exclamation point, it will
      be treated as a shell command. For example, defining "alias.touch = 
      !touch .gn", the invocation "bam touch" is equivalent to running the
      shell command "touch .gn". Note that shell commands will be executed from
      the top-level directory of the project, which may not necessarily be the
      current directory. *BAM_PREFIX* is set as returned by running *bam misc
      --show-prefix* from the original current directory. See **bam-misc**.

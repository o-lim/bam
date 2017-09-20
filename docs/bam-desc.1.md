% BAM-DESC(1) | Bam Manual

# NAME

bam-desc - Show lots of insightful information about a target

# SYNOPSIS

**bam** **desc** [**-h**|**--help**] [**--args**=\<args\>] [**--[no]color**] [**--markdown**]\
\  \  \  \  \ [**--dotfile**=\<filename\>] [**--root**=\<root-dir\>]\
\  \  \  \  \ [**--runtime-deps-list-file**=\<filename\>] [**--threads**=\<N\>]\
\  \  \  \  \ [**--time**] [**--tracelog**=\<logfile\>] [**-v**]\
\  \  \  \  \ \<target-pattern\> [**--show**=\<what-to-show\>] [**--blame**] [**--all**]\
\  \  \  \  \ [**--as**=...] [**--testonly**=...] [**--type**=...] [**--all-toolchains**]\
\  \  \  \  \ [**--format**=json]

# DESCRIPTION

Displays information about a given target or config. The build parameters will
be taken for the build in the given output directory.

The target pattern can be a target label, a config label, or a label pattern
(see "gn help label_pattern"). A label pattern will only match targets.

# OPTIONS
-h, --help
:   Display this help and exit.

--args=\<args\>
:   Specifies build argument overrides.

--color
:   Force colored output.

--dotfile=\<filename\>
:   Override the name of the ".gn" file.

--markdown
:   Write the output in the Markdown format.

--nocolor
:   Force non-colored output.

--root=\<root-dir\>
:   Explicitly specify source root.

--runtime-deps-list-file=\<filename\>
:   Save runtime dependencies for targets to file.

--threads=\<N\>
:   Specify number of worker threads.

--time
:   Outputs a summary of how long everything took.

--tracelog=\<logfile\>
:   Writes a Chrome-compatible trace log to the given file.

-v
:   Verbose logging.

--show=\<what-to-show\>
:     Display only the specified information about the given target or config.

      Possibilities for \<what-to-show\>:

      (If unspecified an overall summary will be displayed.)

      **all_dependent_configs**\
      **allow_circular_includes_from**\
      **arflags [--blame]**\
      **args**\
      **asmflags [--blame]**\
      **asmppflags [--blame]**\
      **cflags [--blame]**\
      **cflags_c [--blame]**\
      **cflags_cc [--blame]**\
      **cflags_objc [--blame]**\
      **cflags_objcc [--blame]**\
      **check_includes**\
      **configs [--tree] (see below)**\
      **cppflags [--blame]**\
      **cppflags_c [--blame]**\
      **cppflags_cc [--blame]**\
      **cppflags_objc [--blame]**\
      **cppflags_objcc [--blame]**\
      **defines [--blame]**\
      **depfile**\
      **deps [--all] [--tree] (see below)**\
      **include_dirs [--blame]**\
      **inputs**\
      **ldflags [--blame]**\
      **lib_dirs**\
      **libs**\
      **outputs**\
      **public_configs**\
      **public**\
      **script**\
      **sources**\
      **sys_include_dirs [--blame]**\
      **testonly**\
      **visibility**


      runtime_deps
      :   Compute all runtime deps for the given target. This is a
          computed list and does not correspond to any GN variable, unlike
          most other values here.

          The output is a list of file names relative to the build
          directory. See "gn help runtime_deps" for how this is computed.
          This also works with "--blame" to see the source of the
          dependency.

# SHARED FLAGS

--all-toolchains
:     Normally only inputs in the default toolchain will be included.
      This switch will turn on matching all toolchains.

      For example, a file is in a target might be compiled twice:
      once in the default toolchain and once in a secondary one. Without
      this flag, only the default toolchain one will be matched by
      wildcards. With this flag, both will be matched.

--format=json
:     Format the output as JSON instead of text.

# TARGET FLAGS

--blame
:     Used with any value specified by a config, this will name
      the config that specified the value. This doesn't currently work
      for **libs** and **lib_dirs** because those are inherited and are more
      complicated to figure out the blame (patches welcome).

# CONFIGS

The "configs" section will list all configs that apply. For targets
this will include configs specified in the "configs" variable of
the target, and also configs pushed onto this target via public
or "all dependent" configs.

Configs can have child configs. Specifying --tree will show the
hierarchy.

#PRINTING OUTPUTS

The "outputs" section will list all outputs that apply, including the outputs
computed from the tool definition (e.g. for "executable", "static_library", ...
targets).

# PRINTING DEPS

Deps will include all public, private, and data deps (TODO this could
be clarified and enhanced) sorted in order applying. The following
may be used:

--all
:     Collects all recursive dependencies and prints a sorted flat list.
      Also usable with **--tree** (see below).

--as=(buildfile|label|output)
:     How to print targets.

      buildfile
      :   Prints the build files where the given target was declared as
          file names.

      label  (default)
      :   Prints the label of the target.

      output
      :   Prints the first output file for the target relative to the
          root build directory.

--testonly=(true|false)
:     Restrict outputs to targets with the testonly flag set
      accordingly. When unspecified, the target's testonly flags are
      ignored.

--tree
:     Print a dependency tree. By default, duplicates will be elided
      with "..." but when **--all** and **-tree** are used together, no
      eliding will be performed.

      The "deps", "public_deps", and "data_deps" will all be
      included in the tree.

      Tree output can not be used with the filtering or output flags:\
      **--as**, **--type**, **--testonly**.

--type=(action|copy|executable|group|loadable_module|shared_library|source_set|static_library)
:     Restrict outputs to targets matching the given type. If
      unspecified, no filtering will be performed.

# NOTE

This command will show the full name of directories and source files,
but when directories and source paths are written to the build file,
they will be adjusted to be relative to the build directory. So the
values for paths displayed by this command won't match (but should
mean the same thing).

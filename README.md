# Bam Build System Reference

[![travis-ci status](https://travis-ci.org/o-lim/bam.svg?branch=master)](https://travis-ci.org/o-lim/bam/builds)

[TOC]

The Bam build system provides wrapper scripts facilitating the use of Generate
Ninja (GN) and Ninja, where GN is a meta-build system used to generate Ninja
files for the Ninja build system. Bam wrapper scripts consist of the **bam**
command followed by a **bam** sub-command. Some of the most common **bam**
sub-commands are:
```
    clean   Cleans the output directory
    help    Displays help information about a build command
    gen     Generate ninja build files
    build    Build a target or list of targets
    status  Show the build status
```

Running `bam help` will display a list of available sub-commands. Use
`bam help <command>` to read more about a specific **bam** sub-command.

Bam also provides several \*.gni files (GN include files) in order to facilitate
the creation of build targets. These \*.gni files provide several useful GN
templates to help you perform common tasks such as:

  - Create binary targets (i.e. C/C++ libraries, and executables) across
    multiple toolchains
  - Automatically generate unit test executables
  - Perform style checking
  - Perform static analysis (i.e. LINT)
  - Define custom C/C++ toolchains
  - Define external libraries

For more information on GN and Ninja, please refer to the following links:

  - [GN Quick Start Guide](http://git.rsp/shared/generate-ninja.git/about/tools/gn/docs/quick_start.md)
  - [GN FAQ](http://git.rsp/shared/generate-ninja.git/about/tools/gn/docs/faq.md)
  - [GN Language and Operation Details](http://git.rsp/shared/generate-ninja.git/about/tools/gn/docs/language.md)
  - [GN Reference](http://git.rsp/shared/generate-ninja.git/about/tools/gn/docs/reference.md)
  - [GN Standalone](http://git.rsp/shared/generate-ninja.git/about/tools/gn/docs/standalone.md)
  - [Ninja Manual](https://ninja-build.org/manual.html)

## Binary Target Templates

The Bam build system extends GN's built-in binary targets with a set of
analogous GN templates that provide rules for compiling with multiple
toolchains, unit testing, style checking, and static analysis.

### Executable: Declare an executable target
An extension of GN's `executable` target.

#### Variable Extensions
```
  Deps: external_deps, public_external_deps
  General: filter_platforms, is_codegen, sources_assignment_filter
  Lint: enable_lint, filter_lint_platforms
  Style: enable_style, style_depth, style_dirs, style_mode, style_regex,
         style_root_dir
  Test: is_one_test_exe_per_file, pre_test, test_args, test_console, test_deps,
        test_dir, test_extension, test_name, test_runner, test_runner_args,
        unittests
```

### LoadableModule: Declare a loadable module target
An extension of GN's `loadable_module` target.

#### Variable Extensions
```
  Deps: external_deps, public_external_deps
  General: filter_platforms, is_codegen, sources_assignment_filter
  Lint: enable_lint, filter_lint_platforms
  Style: enable_style, style_depth, style_dirs, style_mode, style_regex,
         style_root_dir
  Test: is_one_test_exe_per_file, pre_test, test_args, test_console, test_deps,
        test_dir, test_extension, test_name, test_runner, test_runner_args,
        unittests
```

### SharedLibrary: Declare a shared library target
An extension of GN's `shared_library` target.

#### Variable Extensions
```
  Deps: external_deps, public_external_deps
  General: filter_platforms, is_codegen, sources_assignment_filter
  Lint: enable_lint, filter_lint_platforms
  Style: enable_style, style_depth, style_dirs, style_mode, style_regex,
         style_root_dir
  Test: is_one_test_exe_per_file, pre_test, test_args, test_console, test_deps,
        test_dir, test_extension, test_name, test_runner, test_runner_args,
        unittests
```

### SourceSet: Declare a source set target
An extension of GN's `source_set` target.

#### Variable Extensions
```
  Deps: external_deps, public_external_deps
  General: filter_platforms, is_codegen, sources_assignment_filter
  Lint: enable_lint, filter_lint_platforms
  Style: enable_style, style_depth, style_dirs, style_mode, style_regex,
         style_root_dir
  Test: is_one_test_exe_per_file, pre_test, test_args, test_console, test_deps,
        test_dir, test_extension, test_name, test_runner, test_runner_args,
        unittests
```

### StaticLibrary: Declare a static library target
An extension of GN's `static_library` target.

#### Variable Extensions
```
  Deps: external_deps, public_external_deps
  General: filter_platforms, is_codegen, sources_assignment_filter
  Lint: enable_lint, filter_lint_platforms
  Style: enable_style, style_depth, style_dirs, style_mode, style_regex,
         style_root_dir
  Test: is_one_test_exe_per_file, pre_test, test_args, test_console, test_deps,
        test_dir, test_extension, test_name, test_runner, test_runner_args,
        unittests
```

## Non-Binary Target Templates

### Action: Delcare a target that runs a script a single time
A GN template wrapper for `action` targets.

### ActionForEach: Delcare a target that runs a script over a set of files
A GN template wrapper for `action_foreach` targets.

### Copy: Declare a target that copies files
A GN template wrapper for `copy` targets.

### Group: Declare a named group of targets
A GN template wrapper for `group` targets.

#### Group Variables
```
  testgroup [boolean] (optional)
      When set to true, signifies this is a group of test targets.
```

#### Variable Extensions
```
  General: testgroup
```

### Lint: Declare a LINT target
A GN template to declare a lint target to perform static analysis on a set of
source files. Source files can be listed manually by using the `sources`
variable, or auto-discovered in the directory tree if `sources` is omitted. The
auto-discovery depth and file name pattern can be controlled with the `depth`
and `regex` variables, respectively.

#### LINT Variables
```
  enable_lint [boolean]
      When set to true, enables static analysis

  depth
      Specifies the tree depth to search for source files to analyze.

      A depth of 0 (the default) signifies an unlimited depth.

  regex
      A regular expression pattern used to filter which source files are
      analyzed. (default: ".*\.(h|hpp|c|cpp)$")

  sources [list of strings] (optional)
      A list of files to analyze. Unknown file types and headers will be
      skipped.

  source_dirs [list of strings] (optional)
      A list of directories to search for files to analyze. Only the specified
      directories will be searched. This is only used when sources is omitted.

      Defaults to the current directory.
```

#### Variables
```
  General: depth, regex, sources, sources_assignment_filter, source_dirs
```

### Style: Declare a style target
A GN template to declare a style target to run the style checker on a set of
source files. Source files can be listed manually by using the `sources`
variable, or auto-discovered in the directory tree if `sources` is omitted. The
auto-discovery depth and file name pattern can be controlled with the `depth`
and `regex` variables, respectively.

#### Style Variables
```
  enable_style [boolean]
      When set to true, enables style checking

  depth [integer] (optional)
      Specifies the tree depth to search for source files to style check.

      A depth of 0 (the default) signifies an unlimited depth.

  regex [string] (optional)
      A regular expression pattern used to filter which source files are style
      checked. (default: ".*\.(h|hpp|c|cpp)$")

  root_dir [string] (optional)
      The root directory used for deriving the header guard. By default, the
      header guard is calculated as the path of the directory as specified on
      the command line to the style checker.

  sources [list of strings] (optional)
      A list of files to style check. Unknown file types and headers will be
      skipped.

  source_dirs [list of strings] (optional)
      A list of directories to search for files to style check. Only the
      specified directories will be searched. This is only used when sources is
      omitted.

      Defaults to the current directory.
```

#### Variables
```
  General: depth, regex, root_dir, sources, sources_assignment_filter,
           source_dirs
```

### Test: Declare a test target
A GN template to declare test targets.

Test targets automatically set the `testonly` flag to `true`, so there is no
need to set this flag for a test target. In addition, test targets define both
an executable target and an action to run the test.

#### Variables
```
  Flags: asmflags, cflags, cflags_c, cflags_cc, cflags_objc, cflags_objcc,
         cppflags, cppflags_c, cppflags_cc, cppflags_objc, cppflags_objcc,
         defines, include_dirs, ldflags, lib_dirs, libs,
         precompiled_header, precompiled_source
  Deps: data_deps, external_deps, deps, public_deps, public_external_deps
  Dependent configs: all_dependent_configs, public_configs
  General: check_includes, configs, data, inputs, output_dir, output_extension,
           output_name, pre_test, public, sources, test_args, test_console,
           test_runner, test_runner_args, visibility
```

## Toolchain Templates
The Bam build system provides several GN templates to make it easier to create a
C/C++ toolchain.

The following vendor specfic toolchain templates are provided:

  - gcc_toolchain
  - ghs_toolchain
  - ti_toolchain

The following lint toolchain templates are provided to facilitate the creation
of vendor specific lint toolchains:

  - lint_toolchain
  - lint_wrapper

The following vendor specific lint toolchain templates are provided:

  - gcc_lint
  - ghs_lint
  - ti_lint

In addition, the following generic toolchain wrappers are provided:

  - Toolchain
  - LintToolchain
  - ToolchainWithLint

### Toolchain
This is the generic toolchain template wrapper used to create generic C/C++
toolchains.

#### Toolchain Variables
```
  cc [string] (required)
      Specifies the C compiler executable.

  cxx [string] (required)
      Specifies the C++ compiler executable.

  ar [string] (required)
      Specifies the library archive executable.

  ld [string] (required)
      Specifies the linker executable.

  toolchain_args [scope] (required)
      Overrides for build arguments to pass to the toolchain when invoking it.
      This is a variable of type "scope" where the variable names correspond
      to variables in declare_args() blocks.

      When you specify a target using an alternate toolchain, the master build
      configuration file is re-interpreted in the context of that toolchain.
      toolchain_args allows you to control the arguments passed into this
      alternate invocation of the build.

      Any default system arugments or arguments passed in via `bam args` will
      also be passed to the alternate invocation unless explicitly overridden by
      toolchain_args.

      The toolchain_args will be ignored when the toolchain being defined is the
      default. In this case, it's expected you want the default argument values.

  toolchain_cpu [string] (deprecated)
      What "current_cpu" should be set to when invoking a build using this
      toolchain. This is deprecated, use toolchain_args.current_cpu instead.

  toolchain_os [string] (deprecated)
      What "current_os" should be set to when invoking a build using this
      toolchain. This is deprecated, use toolchain_args.current_os instead.

  toolchain_platform [string] (deprecated)
      What "current_platform" should be set to when invoking a build using
      this toolchain. This is deprecated, use toolchain_args.current_platform
      instead.

  toolchain_type [string] (required)
      The type of toolchain to load (i.e. gcc, ghs, ti)

  is_builtin [boolean] (optional)
      Specifies whether or not the "toolchain_type" is a built-in toolchain that
      is included as part of the Bam build system. Templates for built-in
      toolchains are automatically imported. If this is set to false, you must
      manually import your toolchain templates.

  extra_asmflags [string] (optional)
      Extra flags to be appended when assembling files.

  extra_asmppflags [string] (optional)
      Extra flags to be appended when assembling files. "ASMPP" stands for
      "ASM PreProcessor" in this context, although it can be used for non-
      preprocessor flags as well.

  extra_cflags [string] (optional)
      Extra flags to be appended when compiling C files (but not C++ files).

  extra_cppflags [string] (optional)
      Extra flags to be appended when compiling both C and C++ files. "CPP"
      stands for "C PreProcessor" in this context, although it can be
      used for non-preprocessor flags as well. Not to be confused with
      "CXX" (which follows).

  extra_cxxflags [string] (optional)
      Extra flags to be appended when compiling C++ files (but not C files).

  extra_objcflags [string] (optional)
      Extra flags to be appended when compiling Objective C files.

  extra_objcxxflags [string] (optional)
      Extra flags to be appended when compiling Objective C++ files.

  extra_ldflags [string] (optional)
      Extra flags to be appended when linking.

  libs_section_prefix [string] (optional)
  libs_section_postfix [string] (optional)
      The contents of these strings, if specified, will be placed around the
      libs section of the linker line. It allows one to inject libraries at the
      beginning and end for all targets in a toolchain.

  solink_libs_section_prefix [string] (optional)
  solink_libs_section_postfix [string] (optional)
      Same as libs_section_{pre,post}fix except used for solink instead of link.

  link_outputs [string] (optional)
      The content of this array, if specified, will be added to the list of
      outputs from the link command. This can be useful in conjunction with
      the post_link parameter.

  pool [label] (optional)
      Just forwarded to the toolchain definition.

  post_link [string] (optional)
      The content of this string, if specified, will be run as a separate
      command following the the link command.

  deps [list of strings] (optional)
      Just forwarded to the toolchain definition.

  executable_extension [string] (optional)
      If this string is specified it will be used for the file extension for an
      executable, rather than using no extension; targets will still be able to
      override the extension using the output_extension variable.

  loadable_module_extension [string] (optional)
      If this string is specified it will be used for the file extension for a
      loadable module, rather than the shlib_extension.

  object_extensions [string] (optional)
      List of extensions for object files that are passed straight to the
      linker.

  rebuild_define [string] (optional)
      The contents of this string, if specified, will be passed as a #define to
      the toolchain. It can be used to force recompiles whenever a toolchain is
      updated.

  shlib_extension [string] (optional)
      If this string is specified it will be used for the file extension for a
      shared library, rather than default value specified in
      toolchain_defaults.gni

  source_extensions_asm [list of strings] (optional)
      List of source file extensions for assembly files.

  source_extensions_cc [list of strings] (optional)
      List of source file extensions for C files.

  source_extensions_cxx [list of strings] (optional)
      List of source file extensions for C++ files.

  source_extensions_ld [list of strings] (optional)
      List of source file extensions for linker tools.
      (i.e. linker script files)

  source_extensions_objc [list of strings] (optional)
      List of source file extensions for Objective C files.

  source_extensions_objcxx [list of strings] (optional)
      List of source file extensions for Objective C++ files.

  strip [string] (optional)
      Location of the strip executable. When specified, strip will be run on
      all shared libraries and executables as they are built. The pre-stripped
      artifacts will be put in lib.stripped/ and exe.stripped/.

  toolchain_forwards [list of strings] (optional)
      List of additional variable names to forward to the toolchain.

  use_ccache [boolean] (optional)
      Enable the use of ccache.
```

### LintToolchain
This is the generic lint toolchain template wrapper used to create generic LINT
C/C++ toolchains.

#### LintToolchain Variables
```
  cc [string] (required)
      Specifies the C compiler executable.

  cxx [string] (required)
      Specifies the C++ compiler executable.

  toolchain_cpu [string] (required)
      What "current_cpu" should be set to when invoking a build using this
      toolchain.

  toolchain_platform [string] (required)
      What "current_platform" should be set to when invoking a build using
      this toolchain.

  toolchain_os [string] (required)
      What "current_os" should be set to when invoking a build using this
      toolchain.

  toolchain_type [string] (required)
      The type of toolchain to load (i.e. gcc, ghs, ti)

  is_builtin [boolean] (optional)
      Specifies whether or not the "toolchain_type" is a built-in toolchain that
      is included as part of the Bam build system. Templates for built-in
      toolchains are automatically imported. If this is set to false, you must
      manually import your toolchain templates.

  lintasm [string] (optional)
      The lint executable to run for assembly source files.

      Defaults to "flint".

  lintcc [string] (optional)
      The lint executable to run for C source files.

      Defaults to "flint".

  lintcxx [string] (optional)
      The lint executable to run for C++ source files.

      Defaults to "flint".

  lint_forwards [list of strings] (optional)
      List of additional variable names to forward to the lint toolchain.

  deps [list of strings] (optional)
      Just forwarded to the toolchain definition.

  post_link [string] (optional)
      The content of this string, if specified, will be run as a separate
      command following the the link command.

  executable_extension [string] (optional)
      If this string is specified it will be used for the file extension for an
      executable, rather than using no extension; targets will still be able to
      override the extension using the output_extension variable.

  loadable_module_extension [string] (optional)
      If this string is specified it will be used for the file extension for a
      loadable module, rather than the shlib_extension.

  object_extensions [string] (optional)
      List of extensions for object files that are passed straight to the
      linker.

  rebuild_define [string] (optional)
      The contents of this string, if specified, will be passed as a #define to
      the toolchain. It can be used to force recompiles whenever a toolchain is
      updated.

  shlib_extension [string] (optional)
      If this string is specified it will be used for the file extension for a
      shared library, rather than default value specified in
      toolchain_defaults.gni

  source_extensions_asm [list of strings] (optional)
      List of source file extensions for assembly files.

  source_extensions_cc [list of strings] (optional)
      List of source file extensions for C files.

  source_extensions_cxx [list of strings] (optional)
      List of source file extensions for C++ files.

  source_extensions_ld [list of strings] (optional)
      List of source file extensions for linker tools.
      (i.e. linker script files)

  source_extensions_objc [list of strings] (optional)
      List of source file extensions for Objective C files.

  source_extensions_objcxx [list of strings] (optional)
      List of source file extensions for Objective C++ files.
```

### ToolchainWithLint
This is the generic toolchain template wrapper used to create generic C/C++
toolchains with LINT support.

#### ToolchainWithLint Variables
```
  cc [string] (required)
      Specifies the C compiler executable.

  cxx [string] (required)
      Specifies the C++ compiler executable.

  ar [string] (required)
      Specifies the library archive executable.

  ld [string] (required)
      Specifies the linker executable.

  toolchain_cpu [string] (required)
      What "current_cpu" should be set to when invoking a build using this
      toolchain.

  toolchain_platform [string] (required)
      What "current_platform" should be set to when invoking a build using
      this toolchain.

  toolchain_os [string] (required)
      What "current_os" should be set to when invoking a build using this
      toolchain.

  toolchain_type [string] (required)
      The type of toolchain to load (i.e. gcc, ghs, ti)

  is_builtin [boolean] (optional)
      Specifies whether or not the "toolchain_type" is a built-in toolchain that
      is included as part of the Bam build system. Templates for built-in
      toolchains are automatically imported. If this is set to false, you must
      manually import your toolchain templates.

  lintasm [string] (optional)
      The lint executable to run for assembly source files.

      Defaults to "flint".

  lintcc [string] (optional)
      The lint executable to run for C source files.

      Defaults to "flint".

  lintcxx [string] (optional)
      The lint executable to run for C++ source files.

      Defaults to "flint".

  lint_forwards [list of strings] (optional)
      List of additional variable names to forward to the lint toolchain.

  libs_section_prefix [string] (optional)
  libs_section_postfix [string] (optional)
      The contents of these strings, if specified, will be placed around the
      libs section of the linker line. It allows one to inject libraries at the
      beginning and end for all targets in a toolchain.

  solink_libs_section_prefix [string] (optional)
  solink_libs_section_postfix [string] (optional)
      Same as libs_section_{pre,post}fix except used for solink instead of link.

  link_outputs [string] (optional)
      The content of this array, if specified, will be added to the list of
      outputs from the link command. This can be useful in conjunction with
      the post_link parameter.

  pool [label] (optional)
      Just forwarded to the toolchain definition.

  post_link [string] (optional)
      The content of this string, if specified, will be run as a separate
      command following the the link command.

  deps [list of strings] (optional)
      Just forwarded to the toolchain definition.

  loadable_module_extension [string] (optional)
      If this string is specified it will be used for the file extension
      for a loadable module, rather than the shlib_extension.

  executable_extension [string] (optional)
      If this string is specified it will be used for the file extension for an
      executable, rather than using no extension; targets will still be able to
      override the extension using the output_extension variable.

  loadable_module_extension [string] (optional)
      If this string is specified it will be used for the file extension for a
      loadable module, rather than the shlib_extension.

  object_extensions [string] (optional)
      List of extensions for object files that are passed straight to the
      linker.

  rebuild_define [string] (optional)
      The contents of this string, if specified, will be passed as a #define to
      the toolchain. It can be used to force recompiles whenever a toolchain is
      updated.

  shlib_extension [string] (optional)
      If this string is specified it will be used for the file extension for a
      shared library, rather than default value specified in
      toolchain_defaults.gni

  source_extensions_asm [list of strings] (optional)
      List of source file extensions for assembly files.

  source_extensions_cc [list of strings] (optional)
      List of source file extensions for C files.

  source_extensions_cxx [list of strings] (optional)
      List of source file extensions for C++ files.

  source_extensions_ld [list of strings] (optional)
      List of source file extensions for linker tools.
      (i.e. linker script files)

  source_extensions_objc [list of strings] (optional)
      List of source file extensions for Objective C files.

  source_extensions_objcxx [list of strings] (optional)
      List of source file extensions for Objective C++ files.

  strip [string] (optional)
      Location of the strip executable. When specified, strip will be run on
      all shared libraries and executables as they are built. The pre-stripped
      artifacts will be put in lib.stripped/ and exe.stripped/.

  toolchain_forwards [list of strings] (optional)
      List of additional variable names to forward to the toolchain.

  use_ccache [boolean] (optional)
      Enable the use of ccache.
```

## Other GN Templates

### external_dep: Declare an external dependency
A GN template to define an external dependency. This template uses pkg-config to
search for external libraries and resolves to a GN `config` which can be used to
compile/link with external static/shared libraries.

#### External Dependency Variables
```
  cflags [list of strings] (optional)
      A list of cflags to include as part of the resulting config.

  defines [list of strings] (optional)
      A list of defines to include as part of the resulting config.

  include_dirs [list of strings] (optional)
      A list of include directories to include as part of the resulting config.

  ldflags [list of strings] (optional)
      A list of ldflags to include as part of the resulting config.

  libs [list of strings] (optional)
      A list of libraries to include as part of the resulting config.

  lib_dirs [list of strings] (optional)
      A list of lib directories to include as part of the resulting config.

  extra_args [list of strings] (optional)
      Additional arguments to pass to pkg-config.

  extra_defines [list of strings] (optional)
      A list of defines to append to the resulting config.

  extra_include_dirs [list of strings] (optional)
      A list of include directories to append to the resulting config.

  extra_ldflags [list of strings] (optional)
      A list of ldflags to append to the resulting config.

  extra_libs [list of strings] (optional)
      A list of libraries to append to the resulting config.

  extra_lib_dirs [list of strings] (optional)
      A list of lib directories to append to the resulting config.

  ignore_libs [boolean] (optional)
      When set to true, ignore all libraries.

  packages [list of strings]
      A list of external libraries/packages to search for.

  static [boolean] (optional)
      When set to true, retrieves cflags appropriate for static linking.
```

#### Variables
```
  General: cflags, defines, include_dirs, ldflags, libs, lib_dirs, extra_args,
           extra_cflags, extra_defines, extra_include_dirs, extra_ldflags,
           extra_libs, extra_lib_dirs, ignore_libs, packages, static, visibility
```

## Project Defined Variables

The following variables are project defined variables that are provided to the
Bam build system.

```
  all_platforms [list of strings] (required)
      A list of all valid target platforms for the current project.

  all_lint_platforms [list of strings] (optional)
      A list of all valid LINT platforms for the current project.

      Defaults to [].

  host_platform [string] (required)
      A string identifying the host platform.

  test_platform [string] (required)
      A string identifying the platform used to make Test targets.

  style_toolchain [string] (required)
      A string identifying which toolchain to use for style checking.

  config_path [string] (required)
      Specifies the path to the build configuration files for the current
      project.

  toolchain_path [string] (required)
      Specifies the path to the toolchain configuration file for the current
      project.

  external_deps_path [string] (optional)
      Specifies the path to the external dependency configuration file for the
      current project.

      Defaults to "${config_path}/external".

  bam_core_path [string] (optional)
      Specifies the path to wherever your core Bam configuration files are
      installed.

      Defaults to the value of the $BAM_CORE_PATH environment variable.
```

## Built-in Variables

The Bam build system automatically initializes and provides the following
variables:

```
  bam_version.major [integer]
      The major version number of the Bam build system.

  bam_version.minor [integer]
      The minor version number of the Bam build system.

  bam_version.patch [integer]
      The patch level number for the current version of the Bam build system.

  bam_version.suffix [string]
      A string suffix appended to the Bam build system version number used to
      form the version string.

  bam_version.string [string]
      The Bam build system version string.

  current_platform [string]
      Identifies the current platform for the target being built.

  disabled_platforms [list of strings]
      A list of platforms that are currently disabled and will not be built.

  host_toolchain [string]
      Identifies the host toolchain. The value of this variable is
      derived from the host_platform variable.

  is_host [boolean]
      This variable is set to true when the current platform is the host
      platform.

  is_lint [boolean]
      This variable is set to true when the current toolchain is a LINT
      toolchain.

  is_linux [boolean]
      This variable is set to true when the current OS is Linux.

  is_mingw [boolean]
      This variable is set to true when the current OS is MinGW.

  is_posix [boolean]
      This variable is set to true when the current OS is a POSIX compatible OS.

  is_style [boolean]
      This variable is set to true when the current toolchain is the style
      toolchain.

  is_test [boolean]
      This variable is set to true when the current toolchain is the test
      toolchain.

  is_tx [boolean]
      This variable is set to true when the current OS is ThreadX.

  is_win [boolean]
      This variable is set to true when the current OS is Windows.

  lint_toolchain [string]
      Identifies the LINT toolchain for the current target platform.

  test_toolchain [string]
      Identifies the test toolchain. The value of this variable is derived from
      the test_platform variable.
```

## Build Arguments
When generating a build using `build gen`, build arguments can be passed on the
command line via the `--args` option, which can be used to set global build
variables. Furthermore, build arguments can be overridden by any non-default
toolchain.

See also "gn help buildargs" for an overview.

The following build arguments are defined:
```
  current_platform [string]
      Identifies the platform to use for the default toolchain when
      target_platform is not set.

      Defaults to host_platform.

  enable_lint [boolean]
      When set to true, enables static analysis via a LINT tool. Setting this
      to false will disable LINT globally for all targets.

  enable_style [boolean]
      When set to true, enables style checking. Setting this to false will
      disable style checking globally for all targets.

  enable_valgrind [boolean]
      When set to true, sets the default test runner to valgrind.

  is_debug [boolean]
      Identifies whether or not the current build is a debug build.

  is_one_test_exe_per_file [boolean]
      When set to true, creates one test executable per unit test source file.

  lint_platforms [list of strings]
      List of platforms to LINT.

  pkg_config [string]
      Sets the pkg-config wrapper to call instead of the default pkg-config.
      Wrappers like this are common in cross-compilation environments.

      Defaults to the 'pkg-config' in the PATH.

  pkg_config_lib_switch [string]
      The switch used to identify system libraries in the pkg-config output.
      This may be different for various cross-compilation environments. This
      value is used to parse the pkg-config output to identify system libraries
      to pass to the 'libs' config variable.

      Defaults to "-l".

  pkg_config_lib_dir_switch [string]
      The switch used to identify system library paths in the pkg-config output.
      This may be different for various cross-compilation environments. This
      value is used to parse the pkg-config output to identify system library
      directory paths to pass to the 'lib_dirs' config variable.

      Defaults to "-L".

  platforms [list of strings]
      List of platforms to build.

  pre_test [string]
      Command to run before executing a test.

  style_mode = [string]
      Sets the default style mode.

  style_depth = [integer]
      Sets the default style depth.

  style_regex = [string]
      Sets the default style regular expression source file matcher.

  style_root_dir = [string]
      Sets the default style root directory.

  target_platform [string]
      Identifies the platform to use for the default toolchain.

      Defaults to host_platform.

  test_args [list of strings]
      Sets the default flags or options to use for unit test execution.

  test_console [boolean]
      When set to true, tests will be run in the built-in ninja "console" pool,
      unless specified otherwise by the target/test.

  test_runner [string]
      Sets the default test runner.

  test_runner_args [list of strings]
      Sets the default command line flags for the test runner.

  test_group_suffix [string]
      Sets the string suffix for the name used to define a test group. A test
      group defines a set of tasks to complete in order to determine if a test
      succedded, whereas the test itself is the executable test file only.

  test_suffix [string]
      Sets the string suffix to use when setting the name for a test executable.

      Only valid when is_one_test_exe_per_file is false.
```

## Target Variables
```
  enable_style [boolean] (optional)
      Enable style checking. When set to true, enables style checking for the
      current target.

  enable_lint [boolean] (optional)
      Enable static analysis. When set to true, enables static analysis for the
      current target.

  external_deps [list of strings] (optional)
      Private external dependencies. Specifies private external dependencies of
      a target.

  filter_platforms [list of strings] (optional)
      List of valid platforms for the current target. A list of platforms for
      which the current target is valid.

  filter_lint_platforms [list of strings] (optional)
      List of platforms to analyze for the current target. A list of platforms
      for the current target for which static analysis will be performed.

  is_codegen [boolean] (optional)
      Declares the current target as a codegen target. Set to true to declare
      the current target to be a a codegen target. Codegen targets are treated
      specially, in that they are always built for the host platform even if
      "filter_platforms" does not list the host platform. When "is_codegen" is
      true, this signifies that the current target may be specified somewhere in
      the build as a dependency of an action target that is used to generate
      source code.

  is_one_test_exe_per_file [boolean] (optional)
      Generate one test executable per test file. Set to true to create one test
      executable per unit test source file.

  lint_platforms [list of strings] (optional)
      List of platforms to analyze. A list of platforms to statically analyze
      with the LINT tool.

  platforms [list of strings] (optional)
      List of platforms to build. A list of platforms to build.

      Defaults to all defined platforms.

  pre_test [string] (optional)
      Command to run before running a test.

  public_external_deps [list of strings] (optional)
      Declare public external dependencies. Public external dependencies are
      like private external dependencies, but additionally express that the
      current target exposes the listed dependencies as part of its public API.

  sources_assignment_filter [list of strings] (optional)
      The sources assignment filter is a list of patterns that removes files
      from the list implicitly whenever the "sources" variable is assigned to.

  style_depth [integer] (optional)
      Sets the directory depth to search for source files to style check.

      This variable is only valid when style_mode = "discover".

      Use 0 for unlimited depth.

  style_dirs [list of strings] (optional)
      A list of directories to search for source files to style check. Only the
      specified directories will be searched.

      This variable is only valid when style_mode = "discover".

  style_mode [string] (optional)
      Sets the source file discovery mode for for style checking.

      Possible values:
          discover
              Auto-discover source files to style check based on "style_depth",
              "style_dirs", and "style_regex".

          list
              Only style check the files listed on "sources" and "unittests".

      When the style mode is set to "discover", the `sources" variable is
      ignored. Similarly, when set to `list`, the "style_depth", "style_dirs",
      and "style_regex" variables are ignored.

  style_regex [string] (optional)
      Sets the regular expression used to search for source files to style
      check.

      This variable is only valid when style_mode = "discover".

  style_root_dir [string] (optional)
      Set the root directory used by the style checker for deriving the header
      guard. By default, the header guard is calculated as the path of the
      directory as specified on the command line to the style checker.

  test_args [list of strings] (optional)
      Flags or options to use for unit test execution.

  test_console [boolean] (optional)
      Run unit test in the console pool. Targets marked "test_console = true"
      will have their tests run in the built-in ninja "console" pool. They will
      have access to real stdin and stdout. Only one console pool target can run
      at any one time in Ninja.

  test_deps [list of string] (optional)
      A list of target labels specifying dependencies that are only required in
      order to build the test executable. Test dependencies are not propagated
      up the dependency tree, and are only linked to the test executable.

  test_dir [string] (optional)
      Overrides the output directory used for test executables. This must be in
      the root_build_dir or a child thereof.

      This should generally be in the root_out_dir or a subdirectory thereof
      (the root_out_dir will be the same as the root_build_dir for the default
      toolchain, and will be a subdirectory for other toolchains). Not putting
      the output in a subdirectory of root_out_dir can result in collisions
      between different toolchains, so you will need to take steps to ensure
      that your test target is only present in one toolchain.

      If undefined or empty, the output_dir variable will be used (see
      "gn help output_dir").

  test_extension [string] (optional)
      Normally the file extension for a test target is based on the operating
      system, but in rare cases you may need to override the name.

      This value should not include a leading dot. If undefined or empty, the
      output_extension variable will be used (see "gn help output_extension").

  test_name [string] (optional)
      Normally the output name for a test is based on the target name, so the
      target "//foo/bar:bar" will generate a test output such as "bar_UT.exe"
      (using Windows as an example).

      Sometimes you will want an alternate name to avoid collisions or if the
      internal name isn't appropriate for public distribution.

      The test output name should have no extension or prefixes, these will be
      added using the default system rules.

  test_runner [string] (optional)
      A test runner to call to wrap unit test execution in another executable or
      script (i.e. valgrind, strace)

  test_runner_args [list of strings] (optional)
      Flags for options to pass to the test runner.

  unittests [strings] (optional)
    A list of unit test files.
```

## Further Documentation
For more information on a specific build command, please refer to the follwing
links:

  - [build-args(1)](docs/build-args.1.md)
  - [build-browse(1)](docs/build-browse.1.md)
  - [build-clean(1)](docs/build-clean.1.md)
  - [build-commands(1)](docs/build-commands.1.md)
  - [build-config(1)](docs/build-config.1.md)
  - [build-desc(1)](docs/build-desc.1.md)
  - [build-format(1)](docs/build-format.1.md)
  - [build-gen(1)](docs/build-gen.1.md)
  - [build-gn(1)](docs/build-gn.1.md)
  - [build-graph(1)](docs/build-graph.1.md)
  - [build-help(1)](docs/build-help.1.md)
  - [build-init(1)](docs/build-init.1.md)
  - [build-ls(1)](docs/build-ls.1.md)
  - [build-make(1)](docs/build-make.1.md)
  - [build-misc(1)](docs/build-misc.1.md)
  - [build-ninja(1)](docs/build-ninja.1.md)
  - [build-path(1)](docs/build-path.1.md)
  - [build-project(1)](docs/build-project.1.md)
  - [build-query(1)](docs/build-query.1.md)
  - [build-refs(1)](docs/build-refs.1.md)
  - [build-run(1)](docs/build-run.1.md)
  - [build-status(1)](docs/build-status.1.md)
  - [build-targets(1)](docs/build-targets.1.md)
  - [build-test(1)](docs/build-test.1.md)
  - [build-version(1)](docs/build-version.1.md)

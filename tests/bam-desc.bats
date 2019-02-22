#!/usr/bin/env bats

set -o pipefail

setup() {
  source bam-sh-test-setup
  export MANWIDTH=80
  cd foobar
}

teardown() {
  cd ..
}

before_each() {
  export BAM_OUTPUT_DIR="out"
  rm -rf out .tmp*
}

after_each() {
  rm -rf out .tmp*
}

function print_result() {
  for line in "${lines[@]}"; do
    echo "$line"
  done
}

@test "'bam desc --help' displays help" {
  function expected() {
    cat << EOF
BAM-DESC(1)                       Bam Manual                       BAM-DESC(1)



NAME
       bam-desc - Show lots of insightful information about a target

EOF
    build_gn_synopsis "desc"
    cat << EOF
                  <target-pattern> [--show=<what-to-show>] [--blame] [--all]
                  [--as=...] [--testonly=...] [--type=...] [--all-toolchains]
                  [--format=json]

DESCRIPTION
       Displays information about a given target or config. The build parame-
       ters will be taken for the build in the given output directory.

       The target pattern can be a target label, a config label, or a label
       pattern (see "gn help label_pattern"). A label pattern will only match
       targets.

EOF
    build_gn_options_common
    cat << EOF

       --show=<what-to-show>
              Display only the specified information about the given target or
              config.

              Possibilities for <what-to-show>:

              (If unspecified an overall summary will be displayed.)

              all_dependent_configs
              allow_circular_includes_from
              arflags [--blame]
              args
              asmflags [--blame]
              asmppflags [--blame]
              cflags [--blame]
              cflags_c [--blame]
              cflags_cc [--blame]
              cflags_objc [--blame]
              cflags_objcc [--blame]
              check_includes
              configs [--tree] (see below)
              cppflags [--blame]
              cppflags_c [--blame]
              cppflags_cc [--blame]
              cppflags_objc [--blame]
              cppflags_objcc [--blame]
              defines [--blame]
              depfile
              deps [--all] [--tree] (see below)
              include_dirs [--blame]
              inputs
              ldflags [--blame]
              lib_dirs
              libs
              outputs
              public_configs
              public
              script
              sources
              sys_include_dirs [--blame]
              testonly
              visibility

              runtime_deps
                     Compute all runtime deps for the given target.  This is a
                     computed list and does not correspond to any GN variable,
                     unlike most other values here.

                     The output is a list of file names relative to the  build
                     directory.   See  "gn  help runtime_deps" for how this is
                     computed.  This also works  with  "--blame"  to  see  the
                     source of the dependency.

SHARED FLAGS
       --all-toolchains
              Normally only inputs in the default toolchain will be included.
              This switch will turn on matching all toolchains.

              For example, a file is in a target might be compiled twice: once
              in the default toolchain and once in a secondary one. Without
              this flag, only the default toolchain one will be matched by
              wildcards. With this flag, both will be matched.

       --format=json
              Format the output as JSON instead of text.

TARGET FLAGS
       --blame
              Used with any value specified by a config, this will name the
              config that specified the value. This doesn't currently work
              for libs and lib_dirs because those are inherited and are more
              complicated to figure out the blame (patches welcome).

CONFIGS
       The  "configs"  section  will list all configs that apply.  For targets
       this will include configs specified in the "configs"  variable  of  the
       target, and also configs pushed onto this target via public or "all de-
       pendent" configs.

       Configs can have child configs.  Specifying --tree will show the  hier-
       archy.

PRINTING OUTPUTS
       The "outputs" section will list all outputs that apply, including the
       outputs computed from the tool definition (e.g. for "executable",
       "static_library", ... targets).

PRINTING DEPS
       Deps  will  include all public, private, and data deps (TODO this could
       be clarified and enhanced) sorted in order applying.  The following may
       be used:

       --all  Collects all recursive dependencies and prints a sorted flat
              list. Also usable with --tree (see below).

       --as=(buildfile|label|output)
              How to print targets.

              buildfile
                     Prints the build files where the given target was de-
                     clared as file names.

              label (default)
                     Prints the label of the target.

              output Prints the first output file for the target relative to
                     the root build directory.

       --testonly=(true|false)
              Restrict outputs to targets with the testonly flag set accord-
              ingly. When unspecified, the target's testonly flags are ig-
              nored.

       --tree Print a dependency tree. By default, duplicates will be elided
              with "..." but when --all and -tree are used together, no elid-
              ing will be performed.

              The "deps", "public_deps", and "data_deps" will all be included
              in the tree.

              Tree output can not be used with the filtering or output flags:
              --as, --type, --testonly.

       --type=(action|copy|executable|group|loadable_module|shared_li-
       brary|source_set|static_library)
              Restrict outputs to targets matching the given type. If unspec-
              ified, no filtering will be performed.

NOTE
       This command will show the full name of directories and source files,
       but when directories and source paths are written to the build file,
       they will be adjusted to be relative to the build directory. So the
       values for paths displayed by this command won't match (but should mean
       the same thing).



Bam $BAM_VERSION                                                   BAM-DESC(1)
EOF
  }
  LC_ALL=C bam desc --help | col -bx | diff -Bbu <(expected) -
}

@test "'bam desc -h' is the same as 'bam desc --help'" {
  bam desc -h | diff -u <(bam desc --help) -
}

@test "'bam help desc' is the same as 'bam desc --help'" {
  bam help desc | diff -u <(bam desc --help) -
}

@test "'bam desc' forwards to gn desc" {
  function expected() {
    echo "//:style-headers"
    echo "//src:foobar(//build/toolchain:style)"
  }
  gn gen out
  run bam desc ':style' --show=deps

  diff -u <(expected) <(print_result)
  [ "$status" -eq 0 ]
}

@test "'bam desc' works outside source" {
  function expected() {
    echo "//:style-headers"
    echo "//src:foobar(//build/toolchain:style)"
  }
  gn gen out
  run bam -C .. --source-root foobar -o foobar/out desc '//:style' --show=deps

  diff -u <(expected) <(print_result)
  [ "$status" -eq 0 ]
}


@test "'bam -o <path> desc' changes output dir" {
  run bam -o .tmp1 desc ':style'
  print_result | grep '\.tmp1'
  [ "$status" -eq 1 ]
}

@test "'bam desc' uses BAM_OUTPUT_DIR as default output dir" {
  export BAM_OUTPUT_DIR=".tmp2"
  run bam desc ':style'
  print_result | grep '\.tmp2'
  [ "$status" -eq 1 ]
}

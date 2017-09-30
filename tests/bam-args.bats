#!/usr/bin/env bats

set -o pipefail

setup() {
  export MANWIDTH=80
  cd foobar
}

teardown() {
  cd ..
}

before_each() {
  export BAM_OUTPUT_DIR="out"
  source ../bam-sh-test-setup
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

@test "'bam args --help' displays help" {
  function expected() {
    cat << EOF
BAM-ARGS(1)                       Bam Manual                       BAM-ARGS(1)



NAME
       bam-args - Display or configure arguments declared by the build

EOF
    build_gn_synopsis "args"
    cat << EOF
       bam args --list[=<arg>] [--short] [--args=<args>]

DESCRIPTION
       When specified without --list, opens the arguments for the build direc-
       tory in an editor (as specified by the EDITOR environment variable).
       If the build directory does not exist, it will be created and an empty
       args file will be opened in the editor.

       If --list is specified, lists all build arguments available in the cur-
       rent configuration, or, if <arg> is specified, just that one build ar-
       gument.

       The output will list the declaration location, default value, and com-
       ment preceeding the declaration. If --short is specified, only the
       names and values will be printed.

EOF
    build_gn_options_common
    cat << EOF

       --list[=<arg>]
              Prints information about the specified argument. If no argument
              is provided, prints a list of all arguments with their default
              values.

       --short
              Prints only the names and values.



Bam $BAM_VERSION                                                   BAM-ARGS(1)
EOF
  }
  LC_ALL=C bam args --help | col -bx | diff -Bbu <(expected) -
}

@test "'bam args -h' is the same as 'bam args --help'" {
  bam args -h | diff -u <(bam args --help) -
}

@test "'bam help args' is the same as 'bam args --help'" {
  bam help args | diff -u <(bam args --help) -
}

@test "'bam args' forwards to gn args" {
  function expected() {
    local host_cpu=
    local host_os=
    case "$(uname -m)" in
      i[3456]86) host_cpu="x86" ;;
      x86_64|amd64) host_cpu="x64" ;;
      *) host_cpu="$(uname -m)" ;;
    esac
    case "$(uname -s | tr A-Z a-z)" in
      darwin) host_os="mac" ;;
      linux) host_os="linux" ;;
      windows*|mingw*|*cygwin*) host_os="win" ;;
      *) host_cpu="$(uname -s | tr A-Z a-z)" ;;
    esac
    cat << EOF
color_console = false
config = "debug"
current_cpu = ""
current_os = ""
current_platform = "x86"
enable_lint = true
enable_style = true
enable_valgrind = false
host_cpu = "$host_cpu"
host_os = "$host_os"
is_debug = true
is_one_test_exe_per_file = false
lint_platforms = ["x86", "mingw32", "mingw64", "arm"]
pkg_config = ""
pkg_config_args = []
pkg_config_lib_dir_switch = ""
pkg_config_lib_switch = ""
platforms = ["ut", "x86", "mingw32", "mingw64", "arm"]
pre_test = ""
show_version = false
style_depth = 0
style_mode = "discover"
style_regex = ".*\.(h|hh|hpp|hxx|H|c|cc|cpp|cxx|c\+\+|C)\\$"
style_root_dir = "."
target_cpu = ""
target_os = ""
target_platform = "x86"
test_args = ["--gtest_print_time=1", "--gtest_repeat=1", "--gtest_shuffle"]
test_console = true
test_group_suffix = "_Test"
test_runner = ""
test_runner_args = []
test_suffix = "_UT"
test_toolchain = "//build/toolchain:ut"
valgrind = "valgrind"
valgrind_args = ["-q", "--leak-check=full", "--error-exitcode=5", "--gen-suppressions=all"]
EOF
  }
  gn gen out
  bam args --list --short | sed '/deployment_target/d' | diff -u <(expected) -
}

@test "'bam -o <path> args' changes output dir" {
  run bam -o .tmp1 args --list
  print_result | grep '\.tmp1'
  [ "$status" -eq 1 ]
}

@test "'bam args' uses BAM_OUTPUT_DIR as default output dir" {
  export BAM_OUTPUT_DIR=".tmp2"
  run bam args --list
  print_result | grep '\.tmp2'
  [ "$status" -eq 1 ]
}

@test "'bam args' works outside of source" {
  function expected() {
    echo 'config = "debug"'
  }
  gn gen out
  bam -C .. --source-root foobar -o foobar/out args --list=config --short | diff -u <(expected) -
}

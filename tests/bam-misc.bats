#!/usr/bin/env bats

set -o pipefail

setup() {
  export MANWIDTH=80
  export HOME="$(pwd)"
  cd foobar
}

teardown() {
  cd ..
}

before_each() {
  rm -rf out
}

after_each() {
  rm -rf out
}

function print_result() {
  for line in "${lines[@]}"; do
    echo "$line"
  done
}

@test "'bam misc --help' displays help" {
  function expected() {
    cat << EOF
BAM-MISC(1)                       Bam Manual                       BAM-MISC(1)



NAME
       bam-misc - Show miscellaneous build information

SYNOPSIS
       bam misc [-h|--help] [--show-top-level] [--show-bam-dir]
                [--show-out-dir] [--show-source-root]
                [--show-cdup] [--show-prefix]

DESCRIPTION
       Displays miscellaneous information about the build.

OPTIONS
       -h, --help
              Display this help and exit.

       --show-bam-dir
              Show \$BAM_DIR if defined. Otherwise show the path to the .bam
              directory.

       --show-cdup
              When the command is invoked from a subdirectory, show the path
              to the top-level directory relative to the current directory
              (typically a sequence of "../", or an empty string)

       --show-out-dir
              Show \$BAM_OUTPUT_DIR if defined. Otherwise show the build out-
              put directory. The build output directory may be a source abso-
              lute, system absolute, or relative path.

       --show-prefix
              When the command is invoked from a subdirectory, show the path
              of the current directory relative to the top-level directory.

       --show-source-root
              Show the absolute path to the source root directory.

       --show-top-level
              Show the absolute path to the top-level directory.



Bam $BAM_VERSION                                                   BAM-MISC(1)
EOF
  }
  LC_ALL=C bam misc --help | col -bx | diff -Bbu <(expected) -
}

@test "'bam misc -h' is the same as 'bam misc --help'" {
  bam misc -h | diff -u <(bam misc --help) -
}

@test "'bam help misc' is the same as 'bam misc --help'" {
  bam help misc | diff -u <(bam misc --help) -
}

@test "'bam misc' without args shows usage" {
  function expected() {
    cat << EOF
Usage: bam misc [options]

Options:
    --show-bam-dir        show path to .bam directory
    --show-cdup           show relative path to top-level directory
    --show-out-dir        show path of output directory relative to top-level
    --show-prefix         show path of current directory relative to top-level
    --show-source-root    show absolutepath of source root directory
    --show-top-level      show absolutepath of top-level directory

EOF
  }
  BAM_OUTPUT_DIR=//out run bam misc

  diff -u <(expected) <(bam misc)
  [ "$status" -eq 1 ]
}

@test "'bam misc --show-top-level' shows top-level directory" {
  bam misc --show-top-level | diff -u <(echo "$(pwd)") -
  BAM_TOP_LEVEL="/tmp/dir" bam misc --show-top-level | diff -u <(echo "/tmp/dir") -
  bam --top-level "/home/foo" misc --show-top-level | diff -u <(echo "/home/foo") -
  bam --top-level="/foo/bar" misc --show-top-level | diff -u <(echo "/foo/bar") -
}

@test "'bam misc --show-bam-dir' shows path to .bam dir" {
  bam misc --show-bam-dir | diff -u <(echo ".bam") -
  BAM_DIR="mybam" bam misc --show-bam-dir | diff -u <(echo "mybam") -
  bam -C src misc --show-bam-dir | diff -u <(echo "../.bam") -
  BAM_DIR="foo" bam misc --show-bam-dir | diff -u <(echo "foo") -
  bam --bam-dir "bar" misc --show-bam-dir | diff -u <(echo "bar") -
  bam --bam-dir="baz" misc --show-bam-dir | diff -u <(echo "baz") -
}

@test "'bam misc --show-root' shows source root" {
  local root="$(pwd)"
  bam misc --show-source-root | diff -u <(echo "$root") -
  bam -C src misc --show-source-root | diff -u <(echo "$root") -
  BAM_SOURCE_ROOT="/foo" bam misc --show-source-root | diff -u <(echo "/foo") -
  bam --source-root "/tmp/src" misc --show-source-root | diff -u <(echo "/tmp/src") -
  bam --source-root="/home/user" misc --show-source-root | diff -u <(echo "/home/user") -
  bam --root "/home/bar" misc --show-source-root | diff -u <(echo "/home/bar") -
  bam --root="/home/baz" misc --show-source-root | diff -u <(echo "/home/baz") -
}

@test "'bam misc --show-out-dir' shows output dir" {
  bam misc --show-out-dir | diff -u <(echo "//out/Release") -
  BAM_OUTPUT_DIR="//output" bam misc --show-out-dir | diff -u <(echo "//output") -
  bam -o "out/Debug" misc --show-out-dir | diff -u <(echo "//out/Debug") -
  bam --out-dir "/tmp/out/foo" misc --show-out-dir | diff -u <(echo "/tmp/out/foo") -
  bam -C src misc --show-out-dir | diff -u <(echo "//out/Release") -
  BAM_DIR="xxx" bam misc --show-out-dir | diff -u <(echo "//out") -
}

@test "'bam misc --show-cdup' shows top-level dir relative to current dir" {
  bam misc --show-cdup | diff -u <(echo ".") -
  bam -C src misc --show-cdup | diff -u <(echo "..") -
}

@test "'bam misc -show--prefix' shows current dir relative to top-level" {
  bam misc --show-prefix | diff -u <(echo ".") -
  bam -C src misc --show-prefix | diff -u <(echo "src") -
}

@test "'bam misc <multiple-options>' shows results of each option" {
  function expected() {
    echo "$(pwd)"
    echo "//out/Release"
    echo "../.bam"
    echo "src"
    echo ".."
    echo "$(pwd)"
  }
  run bam -C src misc --show-top-level --show-out-dir --show-bam-dir --show-prefix --show-cdup --show-source-root

  diff -u <(expected) <(print_result)
  [ "$status" -eq 0 ]
}

@test "'bam [options] misc' shows for updated paths" {
  function expected() {
    echo "$(pwd)/src"
    echo "//.out"
    echo "../.foo"
    echo "."
    echo "."
    echo "/tmp/src"
  }
  run bam -C src --bam-dir="../.foo" -o "//.out" --source-root "/tmp/src" misc --show-top-level --show-out-dir --show-bam-dir --show-prefix --show-cdup --show-source-root

  diff -u <(expected) <(print_result)
  [ "$status" -eq 0 ]
}

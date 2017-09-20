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

@test "'bam ls --help' displays help" {
  function expected() {
    cat << EOF
BAM-LS(1)                         Bam Manual                         BAM-LS(1)



NAME
       bam-ls - List matching targets

EOF
    build_gn_synopsis "ls"
    cat << EOF
                [<label-pattern>] [--all-toolchains] [--as=...]
                [--type=...] [--testonly=...]

DESCRIPTION
       Lists all targets matching the given pattern for the given build direc-
       tory.  By default, only  targets  in  the  default  toolchain  will  be
       matched unless a toolchain is explicitly supplied.

       If  the label pattern is unspecified, list all targets.  The label pat-
       tern is not a general regular expression (see "gn help label_pattern").
       If you need more complex expressions, pipe the result through grep.

EOF
    build_gn_options_common
    cat << EOF

       --as=(buildfile|label|output)
              How to print targets.

              buildfile
                     Prints the build files where the given target was de-
                     clared as file names.

              label (default)
                     Prints the label of the target.

              output Prints the first output file for the target relative to
                     the root build directory.

       --all-toolchains
              Matches all toolchains.  When set, if the label pattern does not
              specify an explicit toolchain, labels from all toolchains  will
              be  matched.   When unset, only targets in the default toolchain
              will be matched unless an explicit toolchain in the label is
              set.

       --testonly=(true|false)
              Restrict outputs to targets with the testonly flag set accord-
              ingly. When unspecified, the target's testonly flags are ig-
              nored.

       --type=(action|copy|executable|group|loadable_module|shared_li-
       brary|source_set|static_library)
              Restrict outputs to targets matching the given type.  If unspec-
              ified, no filtering will be performed.



Bam $BAM_VERSION                                                     BAM-LS(1)
EOF
  }
  LC_ALL=C bam ls --help | col -bx | diff -Bbu <(expected) -
}

@test "'bam ls -h' is the same as 'bam ls --help'" {
  bam ls -h | diff -u <(bam ls --help) -
}

@test "'bam help ls' is the same as 'bam ls --help'" {
  bam help ls | diff -u <(bam ls --help) -
}

@test "'bam ls' forwards to gn ls" {
  function expected() {
    echo "//:integrate"
    echo "//:lint"
    echo "//:style"
    echo "//:test"
  }
  gn gen out
  run bam ls ':lint' ':style' ':integrate' ':test'

  diff -u <(expected) <(print_result)
  [ "$status" -eq 0 ]
}

@test "'bam ls' works outside source" {
  function expected() {
    echo "//:lint"
  }
  gn gen out
  run bam -C .. --source-root foobar -o foobar/out ls '//:lint'

  diff -u <(expected) <(print_result)
  [ "$status" -eq 0 ]
}

@test "'bam -o <path> ls' changes output dir" {
  run bam -o .tmp1 ls ':style'
  print_result | grep '\.tmp1'
  [ "$status" -eq 1 ]
}

@test "'bam ls' uses BAM_OUTPUT_DIR as default output dir" {
  export BAM_OUTPUT_DIR=".tmp2"
  run bam ls ':style'
  print_result | grep '\.tmp2'
  [ "$status" -eq 1 ]
}

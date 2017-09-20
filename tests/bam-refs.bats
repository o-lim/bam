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

@test "'bam refs --help' displays help" {
  function expected() {
    cat << EOF
BAM-REFS(1)                       Bam Manual                       BAM-REFS(1)



NAME
       bam-refs - Find stuff referencing a target or file

EOF
    build_gn_synopsis_quiet "refs"
    cat << EOF
                (<label-pattern>|<label>|<file>|@<response-file>)* [--all]
                [--all-toolchains] [--as=...] [--testonly=...] [--type=...]

DESCRIPTION
       Finds  reverse  dependencies  (which targets reference something).  The
       input is a list containing:

       o Target label: The result will be which targets depend on it.

       o Config label: The result will be which targets list the given  config
         in its "configs" or "public_configs" list.

       o Label  pattern: The result will be which targets depend on any target
         matching the given pattern.  Patterns will not match configs.   These
         are  not general regular expressions, see "gn help label_pattern" for
         details.

       o File name: The result will be which targets list the  given  file  in
         its  "inputs",  "sources", "public", "data", or "outputs".  Any input
         that does not contain wildcards and does not match a target or a con-
         fig will be treated as a file.

       o Response  file: If the input starts with an "@", it will be interpret-
         ed as a path to a file containing a list of labels or file names, one
         per line. This allows us to handle long lists of inputs without wor-
         rying about command line limits.

EOF
    build_gn_options_common
    cat << EOF

       --all  When used without --tree, will recurse and  display  all  unique
              dependencies of the given targets.  For example, if the input is
              a target, this will output all targets that depend  directly  or
              indirectly on the input.  If the input is a file, this will out-
              put all targets that depend directly or indirectly on that file.

              When used with --tree, turns off  eliding  to  show  a  complete
              tree.

       --all-toolchains
              Normally  only inputs in the default toolchain will be included.
              This switch will turn on matching all toolchains.

              For example, a file is in a target might be compiled twice: once
              in  the  default toolchain and once in a secondary one.  Without
              this flag, only the default toolchain one will  be  matched  and
              printed  (potentially with its recursive dependencies, depending
              on the other options).  With this flag,  both  will  be  printed
              (potentially with both of their recursive dependencies).

       --as=(buildfile|label|output)
              How to print targets.

              buildfile
                     Prints  the  build files where the given target was de-
                     clared as file names.

              label (default)
                     Prints the label of the target.

              output Prints the first output file for the target relative to
                     the root build directory.

       -q     Quiet. If  nothing  matches, don't print any output. Without
              this option, if there are no matches there will be an informa-
              tional  message  printed which might interfere with scripts pro-
              cessing the output.

       --testonly=(true|false)
              Restrict outputs to targets with the testonly flag  set  accord-
              ingly. When unspecified, the target's testonly flags are ig-
              nored.

       --tree Outputs a reverse dependency tree from the given target.  Dupli-
              cates  will  be elided.  Combine with --all to see a full depen-
              dency tree.

              Tree output can not be used with the filtering or output  flags:
              --as, --type, --testonly.

       --type=(action|copy|executable|group|loadable_module|shared_li-
       brary|source_set|static_library)
              Restrict outputs to targets matching the given type.  If unspec-
              ified, no filtering will be performed.



Bam $BAM_VERSION                                                   BAM-REFS(1)
EOF
  }
  LC_ALL=C bam refs --help | col -bx | diff -Bbu <(expected) -
}

@test "'bam refs -h' is the same as 'bam refs --help'" {
  bam refs -h | diff -u <(bam refs --help) -
}

@test "'bam help refs' is the same as 'bam refs --help'" {
  bam help refs | diff -u <(bam refs --help) -
}

@test "'bam refs' forwards to gn refs" {
  function expected() {
    echo "//:style"
  }
  gn gen out
  run bam refs ':style-headers' deps

  diff -u <(expected) <(print_result)
  [ "$status" -eq 0 ]
}

@test "'bam refs' works outside source" {
  function expected() {
    echo "//:style"
  }
  gn gen out
  run bam -C .. --source-root foobar -o foobar/out refs '//:style-headers' deps

  diff -u <(expected) <(print_result)
  [ "$status" -eq 0 ]
}

@test "'bam -o <path> refs' changes output dir" {
  run bam -o .tmp1 refs ':style'
  print_result | grep '\.tmp1'
  [ "$status" -eq 1 ]
}

@test "'bam refs' uses BAM_OUTPUT_DIR as default output dir" {
  export BAM_OUTPUT_DIR=".tmp2"
  run bam refs ':style'
  print_result | grep '\.tmp2'
  [ "$status" -eq 1 ]
}

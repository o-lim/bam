#!/usr/bin/env bats

set -o pipefail

setup() {
  export MANWIDTH=80
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

@test "'bam format --help' displays help" {
  function expected() {
    cat << EOF
BAM-FORMAT(1)                     Bam Manual                     BAM-FORMAT(1)



NAME
       bam-format - Format .gn file

SYNOPSIS
       bam format [-h|--help] [--dry-run] [--dump-tree] (--stdin | <file>)

DESCRIPTION
  Formats .gn file to a standard format.

OPTIONS
  -h, --help
      Display this help and exit.

  --dry-run
      Does not change or output anything, but sets the process exit
      code based on whether output would be different than what's on
      disk. This is useful for presubmit/lint-type checks.

      o Exit code 0: successful format, matches on disk.

      o Exit code 1: general failure (parse error, etc.)

      o Exit code 2: successful format, but differs from on disk.

  --dump-tree
      For debugging only, dumps the parse tree to stdout and does not
      update the file or print formatted output.

  --stdin
      Read input from stdin and write to stdout rather than update a
      file in-place.



Bam $BAM_VERSION                                                 BAM-FORMAT(1)
EOF
  }
  LC_ALL=C bam format --help | col -bx | diff -Bbu <(expected) -
}

@test "'bam format -h' is the same as 'bam format --help'" {
  bam format -h | diff -u <(bam format --help) -
}

@test "'bam help format' is the same as 'bam format --help'" {
  bam help format | diff -u <(bam format --help) -
}

@test "'bam format' forwards to gn format" {
  mkdir .tmp
  bam format foobar/BUILD.gn
  cat foobar/BUILD.gn | bam format --stdin > .tmp/BUILD.gn
  diff -u foobar/BUILD.gn .tmp/BUILD.gn
}

#!/usr/bin/env bats

set -o pipefail

before_each() {
  rm -rf .tmp*
}

after_each() {
  rm -rf .tmp*
}

@test "'bam help' displays help" {
  bam help | diff -u <(bam --help) -
}

@test "'bam help --help' displays help for help" {
  function expected() {
    cat << EOF
BAM-HELP(1)                       Bam Manual                       BAM-HELP(1)



NAME
       bam-help - Display help information about the bam command

SYNOPSIS
       bam help [-h|--help] [<command>]

DESCRIPTION
       With no options and no <command> specified, the synopsis of the bam
       command and a list of bam commands are printed to the standard output.

       If <command> is specified, a help page for that command is displayed.

OPTIONS
       -h, --help
              Displays this help and exits.



Bam $BAM_VERSION                                                   BAM-HELP(1)
EOF
  }
  LC_ALL=C MANWIDTH=80 bam help help | col -bx | diff -Bbu <(expected) -
}

@test "'bam help doesnotexit' displays no help for command error" {
  function expected() {
    echo "bam-help: error: no help for 'bam-doesnotexist'"
  }
  run bam help doesnotexist

  diff -u <(expected) <(echo "${lines[@]}")
  [ "$status" -eq 1 ]
}

@test "'bam help alias' displays alias information" {
  function expected_foo() {
    echo "\`bam foo' is aliased to \`aliased command goes here'"
  }
  function expected_bar() {
    echo "\`bam bar' is aliased to \`!shell command'"
  }
  mkdir .tmp
  cat > .tmp/config << EOF
[alias]
    foo = aliased command goes here
    bar = !shell command
EOF

  BAM_CONFIG=".tmp/config" bam help foo | diff -u <(expected_foo) -
  BAM_CONFIG=".tmp/config" bam help bar | diff -u <(expected_bar) -
}

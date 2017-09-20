#!/usr/bin/env bats

set -o pipefail

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

#!/usr/bin/env bats

set -o pipefail

setup() {
  export MANWIDTH=80
  export BAM_OUTPUT_DIR=".tmp"
  cd foobar
}

teardown() {
  cd ..
}

before_each() {
  rm -rf .tmp*
}

after_each() {
  rm -rf .tmp*
}

function print_result() {
  for line in "${lines[@]}"; do
    echo "$line"
  done
}

@test "'bam project --help' displays help" {
  function expected() {
    cat << EOF
BAM-PROJECT(1)                    Bam Manual                    BAM-PROJECT(1)



NAME
       bam-project - Generate project files for an IDE (i.e. Eclipse)

SYNOPSIS
       bam project [-h|--help] [-g <generator>|--generator <generator>]
                   [-n <name>|--name <name>] [--all-toolchains]
                   [-t <toolchain>|--toolchain <toolchain>] [<directory>]

DESCRIPTION
       This command generates an IDE project for use with the 'bam' tool. If
       <directory> is specified, the command is run inside it, otherwise the
       current working directory is used. If this directory does not exist,
       it will be created.

OPTIONS
       -h, --help
              Display this help and exit.

       -g <generator>, --generator <generator>
              Specifies a project generator (use -g list to list available
              generators).  If a generator is not specified, defaults to
              eclipse.

       -n <name>, --name <name>
              Sets the name for the project. The default project name is the
              name of the directory where this command is run.

       -t <toolchain>, --toolchain <toolchain>
              Sets the toolchain for the project. The default project
              toolchain is dependent on the generator.

       --all-toolchains
              Generates a single project for all toolchains. This is not sup-
              ported by all generators.

       <directory>
              The name of the directory in which to create the IDE project.
              If specified, the command is run inside this directory, other-
              wise the current working directory is used.



Bam $BAM_VERSION                                                BAM-PROJECT(1)
EOF
  }
  LC_ALL=C bam project --help | col -bx | diff -Bbu <(expected) -
}

@test "'bam project -h' is the same as 'bam project --help'" {
  bam project -h | diff -u <(bam project --help) -
}

@test "'bam help project' is the same as 'bam project --help'" {
  bam help project | diff -u <(bam project --help) -
}

@test "'bam project -g list' lists all project generators" {
  function expected() {
    echo "Project generators:"
    echo "  eclipse     Generates Eclipse CDT project files"
    echo "  qtcreator   Generates QtCreator project files"
    echo "  vscode      Generates Visual Studio Code project files"
  }
  run bam project -g list

  diff -u <(expected) <(print_result)
  [ "$status" -eq 0 ]
}

@test "'bam project -g does-not-exist' generates error" {
  function expected() {
    echo "bam-project: error: unknown generator 'does-not-exist'"
  }
  run bam project -g does-not-exist

  diff -u <(expected) <(print_result)
  [ "$status" -eq 1 ]
}

@test "'bam project' defaults to eclipse project" {
  mkdir .tmp
  bam -C .tmp project
  [ -f .tmp/.project ]
  [ -f .tmp/.cproject ]
  [ -d .tmp/.settings ]
  grep '.tmp' .tmp/.project
  grep '.tmp' .tmp/.cproject
}

@test "'bam project -g eclipse' generates an eclipse project" {
  mkdir .tmp
  bam -C .tmp project -g eclipse
  [ -f .tmp/.project ]
  [ -f .tmp/.cproject ]
  [ -d .tmp/.settings ]
  grep '.tmp' .tmp/.project
  grep '.tmp' .tmp/.cproject
}

@test "'bam project -g qtcreator' generates a qtcreator project" {
  mkdir .tmp
  bam -C .tmp project -g qtcreator
  [ -f .tmp/.tmp.config ]
  [ -f .tmp/.tmp.creator ]
  [ -f .tmp/.tmp.creator.user ]
  [ -f .tmp/.tmp.files ]
  [ -f .tmp/.tmp.includes ]
}

@test "'bam project -g qtcreator --name=<name>' generates a qtcreator project with <name>" {
  mkdir .tmp
  bam -C .tmp project -g qtcreator --name myproj
  [ -f .tmp/myproj.config ]
  [ -f .tmp/myproj.creator ]
  [ -f .tmp/myproj.creator.user ]
  [ -f .tmp/myproj.files ]
  [ -f .tmp/myproj.includes ]
}

@test "'bam project -g vscode' generates a vscode project" {
  mkdir .tmp
  bam -C .tmp project -g vscode
  [ -d .tmp/.vscode ]
  [ -f .tmp/.vscode/c_cpp_properties.json ]
  [ -f .tmp/.vscode/tasks.json ]
}

@test "'bam project -g vscode -t <toolchain>' generates a vscode project" {
  mkdir .tmp
  bam -C .tmp project -g vscode -t "//build/toolchain:ut"
  [ -d .tmp/.vscode ]
  [ -f .tmp/.vscode/c_cpp_properties.json ]
  [ -f .tmp/.vscode/tasks.json ]
  grep -q 'UNIT_TEST' .tmp/.vscode/c_cpp_properties.json
  grep -q '/usr/local/include' .tmp/.vscode/c_cpp_properties.json
}

@test "'bam project -g vscode --all-toolchains' generates a vscode project" {
  mkdir .tmp
  bam -C .tmp project -g vscode --all-toolchains
  [ -d .tmp/.vscode ]
  [ -f .tmp/.vscode/c_cpp_properties.json ]
  [ -f .tmp/.vscode/tasks.json ]
  cat .tmp/.vscode/c_cpp_properties.json
  grep -q 'ARM_DEFINES' .tmp/.vscode/c_cpp_properties.json
  grep -q 'LINT_DEFINES' .tmp/.vscode/c_cpp_properties.json
  grep -q 'MINGW64_DEFINES' .tmp/.vscode/c_cpp_properties.json
  grep -q 'UNIT_TEST' .tmp/.vscode/c_cpp_properties.json
  grep -q 'WIN32' .tmp/.vscode/c_cpp_properties.json
  grep -q '/usr/local/include' .tmp/.vscode/c_cpp_properties.json
}

@test "'bam -o <path> project' still uses cwd" {
  mkdir .tmp1
  bam -C .tmp1 -o .tmp2 project
  [ -f .tmp1/.project ]
}

@test "'bam --out-dir <path> project' still uses cwd" {
  mkdir .tmp2
  bam -C .tmp2 --out-dir .tmp1 project
  [ -f .tmp2/.project ]
}

@test "'bam project <directory>' writes files to <directory>" {
  bam project .tmp2
  [ -f .tmp2/.project ]
}

@test "'bam project' ignores BAM_OUTPUT_DIR" {
  export BAM_OUTPUT_DIR=".tmp3"
  mkdir .tmp
  bam -C .tmp project
  [ -f .tmp/.project ]
}

@test "'bam project --name <name>' sets the project name to <name>" {
  mkdir .tmp
  bam -C .tmp project --name myproj
  grep myproj .tmp/.project
  grep myproj .tmp/.cproject
}

@test "'bam project -n <name>' sets the project name to <name>" {
  mkdir .tmp
  bam -C .tmp project -n myproj
  grep myproj .tmp/.project
  grep myproj .tmp/.cproject
}

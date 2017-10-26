#!/usr/bin/env bats

set -o pipefail

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

function get_install_prefix() {
  if [ $BAM_TEST_ENV == 1 ]; then
    echo "@prefix@"
  else
    echo "$(dirname $(dirname $(which bam)))"
  fi
}

@test "'man bam' displays man page for bam" {
  function expected() {
    cat << EOF
BAM(1)                            Bam Manual                            BAM(1)



NAME
       bam - the program builder

SYNOPSIS
       bam [--version] [-h|--help] [-C <path>] [--core-path [<path>]]
           [--exec-path [<path>]] [-o <path>|--out-dir <path>]
           [--source-root <path>|--root <path>] [--top-level <path>]
           [--bam-dir <path>] <command> [<args>]

DESCRIPTION
       A build system wrapper for gn (Generate Ninja) and ninja.

OPTIONS
       --version
              Prints the Bam suite version that the bam program came from.

       -h, --help
              Prints the synopsis and a list of bam commands.   If  a  bam com-
              mand is named, this option will bring up the help for that com-
              mand.

       -C <path>
              Run as if bam were started in <path> instead  of  the  current
              working directory.  When multiple -C options are specified, each
              subsequent non-absolute -C <path> is interpreted relative to the
              preceding -C <path>.

       --core-path [<path>]
              Path  to wherever your core bam configuration files are in-
              stalled.    This   can   also   be  controlled  by  setting  the
              BAM_CORE_PATH environment variable.  If no  path  is  specified,
              bam will print the current setting and then exit.

       --exec-path [<path>]
              Path  to wherever your core bam programs are installed.  This can
              also be controlled by setting the  BAM_EXEC_PATH  environment
              variable. If  no path is specified, bam will print the current
              setting and then exit.

       -o <path>, --out-dir <path>
              Set  the  path  to  the output directory.  This can also be con-
              trolled by setting the BAM_OUTPUT_DIR environment variable.  It
              can be an absolute path or relative path to the current working
              directory.

       --bam-dir <path>
              Set the path to the project configuration directory. This can
              also be controlled by setting the BAM_DIR environment variable.
              It can be an absolute path or relative path to the current work-
              ing directory.

       --source-root <path>, --root <path>
              Set the path to the source root directory. The source root di-
              rectory specifies the meaning of "//" at the beginning of a
              path, and the BUILD.gn file in that directory will be the first
              thing loaded. This can also be controlled by setting the
              BAM_SOURCE_ROOT environment variable. It can be an absolute
              path or relative path to the current working directory.

       --top-level <path>
              Set the path to the base directory of the bam project. This can
              also be controlled by setting the BAM_TOP_LEVEL environment
              variable. It can be an absolute path or relative path to the
              current working directory.

ENVIRONMENT VARIABLES
       Various bam commands use the following environment variables:

       BAM_OUTPUT_DIR
              If the BAM_OUTPUT_DIR  environment  variable is set then it speci-
              fies the path to use for the bam output  directory. The default
              is to use the current working directory. This is where Ninja
              build files will be created, as well as any build outputs such
              as  generated  files,  object  files,  executables,  etc.  The
              --out-dir command-line option also sets this value.

       BAM_CORE_PATH
              This specifies the path to wherever your core bam configuration
              files are installed. If this environment variable is not set
              the default setting is used.

       BAM_EXEC_PATH
              This specifies the path to wherever your core bam programs are
              installed. If this environment variable is not set the default
              setting is used.

       BAM_DIR
              If the BAM_DIR environment variable is set then it specifies a
              path to use instead of the default .bam located at the base of
              the project. The --bam-dir command-line option also sets this
              value.

       BAM_SOURCE_ROOT
              If the BAM_SOURCE_ROOT environment variable is set then it spec-
              ifies a path to use instead searching for the source root direc-
              tory. The --source-root command-line option also sets this val-
              ue.

       BAM_TOP_LEVEL
              If the BAM_TOP_LEVEL environment variable is set then it speci-
              fies a path to use as the base directory of the project. The
              --top-level command-line option also sets this value.



Bam $BAM_VERSION                                                        BAM(1)
EOF
  }
  LC_ALL=C MANWIDTH=80 man bam | col -bx | diff -Bbu <(expected) -
}

@test "'bam --help' displays usage and commands" {
  run bam --help

  print_result | grep '^Usage: bam '
  print_result | grep '^Commands:'
  [ "$status" -eq 0 ]
}

@test "'bam -h' is the same as bam --help" {
  bam -h | diff -u <(bam --help) -
}

@test "'bam' with no arguments displays help and returns error" {
  run bam
  diff -u <(bam --help) <(bam)
  [ "$status" -eq 1 ]
}

@test "'bam doesnotexist' displays unknown command error" {
  function expected() {
    echo "bam: error: 'doesnotexist' is not a bam command. See 'bam --help'"
  }
  run bam doesnotexist
  diff -u <(expected) <(echo "${lines[@]}")
  [ "$status" -eq 1 ]
}

@test "'bam -o' without <out-dir> generates error" {
  run bam -o
  diff -u <(echo "bam: error: no directory given for -o") <(echo "${lines[@]}")
  [ "$status" -eq 1 ]
}

@test "'bam --out-dir' without <out-dir> generates error" {
  run bam --out-dir
  diff -u <(echo "bam: error: no directory given for --out-dir") <(echo "${lines[@]}")
  [ "$status" -eq 1 ]
}

@test "'bam --out-dir=' without <out-dir> generates error" {
  run bam --out-dir=
  diff -u <(echo "bam: error: no directory given for --out-dir") <(echo "${lines[@]}")
  [ "$status" -eq 1 ]
}

@test "'bam -C' without <dir> generates error" {
  run bam -C
  diff -u <(echo "bam: error: no directory given for -C") <(echo "${lines[@]}")
  [ "$status" -eq 1 ]
}

@test "'bam -C <bad-path>' generates error" {
  run bam -C xxx
  diff -u <(echo "bam: No such file or directory") <(echo "${lines[@]}" | sed 's/.*:/bam:/')
  [ "$status" -eq 1 ]
}

@test "'bam --core-path' displays default exec path" {
  function default_core_path() {
    echo "$(get_install_prefix)/share/bam-core"
  }
  BAM_CORE_PATH= bam --core-path | diff -u <(default_core_path) -
  BAM_CORE_PATH="/foo" bam --core-path | diff -u <(echo "/foo") -
}

@test "'bam --core-path=' sets empty core path" {
  function expected() {
    echo "BAM_CORE_PATH=\"\""
  }
  mkdir .tmp
  cat > .tmp/bam-show << EOF
#!/usr/bin/env bash
echo "BAM_CORE_PATH=\"\$BAM_CORE_PATH\""
EOF
  chmod +x .tmp/bam-show
  PATH="$(pwd)/.tmp:$PATH" BAM_CORE_PATH="/foobar" bam --core-path= show | diff -u <(expected) -
}

@test "'bam --core-path=<path>' uses <path> for core path" {
  function expected() {
    echo "BAM_CORE_PATH=\"/foobar\""
  }
  mkdir .tmp
  cat > .tmp/bam-show << EOF
#!/usr/bin/env bash
echo "BAM_CORE_PATH=\"\$BAM_CORE_PATH\""
EOF
  chmod +x .tmp/bam-show
  PATH="$(pwd)/.tmp:$PATH" bam --core-path=/foobar show | diff -u <(expected) -
}

@test "'bam --core-path <path>' uses <path> for core path" {
  function expected() {
    echo "BAM_CORE_PATH=\"/bar\""
  }
  mkdir .tmp
  cat > .tmp/bam-show << EOF
#!/usr/bin/env bash
echo "BAM_CORE_PATH=\"\$BAM_CORE_PATH\""
EOF
  chmod +x .tmp/bam-show
  PATH="$(pwd)/.tmp:$PATH" bam --core-path /bar show | diff -u <(expected) -
}

@test "'bam --exec-path' displays default exec path" {
  function default_exec_path() {
    echo "$(get_install_prefix)/libexec/bam-core"
  }
  BAM_EXEC_PATH= bam --exec-path | diff -u <(default_exec_path) -
  BAM_EXEC_PATH="/foo" bam --exec-path | diff -u <(echo "/foo") -
}

@test "'bam --exec-path=' uses default exec path" {
  function expected() {
    echo "BAM_EXEC_PATH=\"\""
    echo "DEFAULT_EXEC_PATH=\"$(get_install_prefix)/libexec/bam-core\""
  }
  mkdir .tmp
  cat > .tmp/bam-show << EOF
#!/usr/bin/env bash
echo "BAM_EXEC_PATH=\"\$BAM_EXEC_PATH\""
echo "DEFAULT_EXEC_PATH=\"\${PATH%%:*}\""
EOF
  chmod +x .tmp/bam-show
  PATH="$(pwd)/.tmp:$PATH" BAM_EXEC_PATH="/foobar" bam --exec-path= show | diff -u <(expected) -
}

@test "'bam --exec-path=<path>' uses <path> for exec path" {
  run bam --exec-path="/bar/libexec" help
  diff -u <(echo "bam: error: 'help' is not a bam command. See 'bam --help'") <(echo "${lines[@]}")
  [ "$status" -eq 1 ]
}

@test "'bam --exec-path <path>' uses <path> for exec path" {
  run bam --exec-path "/bar/libexec" help
  diff -u <(echo "bam: error: 'help' is not a bam command. See 'bam --help'") <(echo "${lines[@]}")
  [ "$status" -eq 1 ]
}

@test "'bam --xxx' generates error for unknown option" {
  run bam --xxx
  diff -u <(echo "bam: error: unknown option --xxx") <(echo "${lines[@]}")
  [ "$status" -eq 1 ]
}

@test "'bam <alias>' supports running subcommands as aliases from local config" {
  function expected() {
    echo "'hello  world'"
    echo "'I am #here#!!!'"
    echo "'arg 1'"
    echo "'arg#2'"
    echo "'arg;3'"
  }
  mkdir .tmp
  cat > .tmp/config << EOF
[alias]
    foo = echo "hello  world" "I am #here#!!!" # comment
EOF
  cat > .tmp/bam-echo << EOF
#!/usr/bin/env bash

for arg in "\$@"; do
  echo "'\$arg'"
done
EOF
  chmod +x .tmp/bam-echo
  PATH="$(pwd)/.tmp:$PATH" BAM_CONFIG=".tmp/config" run bam foo "arg 1" "arg#2" "arg;3"

  diff -u <(expected) <(print_result)
  [ "$status" -eq 0 ]
}

@test "'bam <alias>' supports running subcommands as aliases from global config" {
  function expected() {
    echo "'hello  world'"
    echo "'I am #here#!!!'"
    echo "'arg 1'"
    echo "'arg#2'"
    echo "'arg;3'"
  }
  mkdir .tmp
  cat > .tmp/.bamconfig << EOF
[alias]
    bar = echo "hello  world" "I am #here#!!!" ; comment
EOF
  cat > .tmp/bam-echo << EOF
#!/usr/bin/env bash

for arg in "\$@"; do
  echo "'\$arg'"
done
EOF
  chmod +x .tmp/bam-echo
  PATH="$(pwd)/.tmp:$PATH" HOME=".tmp/" run bam bar "arg 1" "arg#2" "arg;3"

  diff -u <(expected) <(print_result)
  [ "$status" -eq 0 ]
}

@test "'bam <alias>' supports running shell commands as aliases" {
  function expected() {
    echo "'hi  there'"
    echo "'I am #here#!!!'"
    echo "'arg 1'"
    echo "'arg#2'"
    echo "'arg;3'"
    echo "BAM_PREFIX=src"
    echo "PWD=$(realpath foobar)"
  }
  mkdir .tmp
  cat > .tmp/config << EOF
[alias]
    shell = !do-echo "hi  there" "I am #here#!!!" # comment
EOF
  cat > .tmp/do-echo << EOF
#!/usr/bin/env bash

for arg in "\$@"; do
  echo "'\$arg'"
done
echo "BAM_PREFIX=\$BAM_PREFIX"
echo "PWD=\$(pwd)"
EOF
  chmod +x .tmp/do-echo
  PATH="$(pwd)/.tmp:$PATH" BAM_CONFIG="../../.tmp/config" run bam -C foobar/src shell "arg 1" "arg#2" "arg;3"

  diff -u <(expected) <(print_result)
  [ "$status" -eq 0 ]
}

@test "'bam --top-level' without <path> generates error" {
  function expected() {
    echo "bam: error: no directory given for --top-level"
  }
  run bam --top-level

  diff -u <(expected) <(print_result)
  [ "$status" -eq 1 ]
}

@test "'bam --top-level=' without <path> generates error" {
  function expected() {
    echo "bam: error: no directory given for --top-level"
  }
  run bam --top-level=

  diff -u <(expected) <(print_result)
  [ "$status" -eq 1 ]
}

@test "'bam --bam-dir' without <path> generates error" {
  function expected() {
    echo "bam: error: no directory given for --bam-dir"
  }
  run bam --bam-dir

  diff -u <(expected) <(print_result)
  [ "$status" -eq 1 ]
}

@test "'bam --bam-dir=' without <path> generates error" {
  function expected() {
    echo "bam: error: no directory given for --bam-dir"
  }
  run bam --bam-dir=

  diff -u <(expected) <(print_result)
  [ "$status" -eq 1 ]
}

@test "'bam --source-root' without <path> generates error" {
  function expected() {
    echo "bam: error: no directory given for --source-root"
  }
  run bam --source-root

  diff -u <(expected) <(print_result)
  [ "$status" -eq 1 ]
}

@test "'bam --source-root=' without <path> generates error" {
  function expected() {
    echo "bam: error: no directory given for --source-root"
  }
  run bam --source-root=

  diff -u <(expected) <(print_result)
  [ "$status" -eq 1 ]
}

@test "'bam --root' without <path> generates error" {
  function expected() {
    echo "bam: error: no directory given for --root"
  }
  run bam --root

  diff -u <(expected) <(print_result)
  [ "$status" -eq 1 ]
}

@test "'bam --root=' without <path> generates error" {
  function expected() {
    echo "bam: error: no directory given for --root"
  }
  run bam --root=

  diff -u <(expected) <(print_result)
  [ "$status" -eq 1 ]
}

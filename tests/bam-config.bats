#!/usr/bin/env bats

set -o pipefail

setup() {
  export MANWIDTH=80
  export HOME="$(pwd)"
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

@test "'bam config --help' displays help" {
  function expected() {
    cat << EOF
BAM-CONFIG(1)                     Bam Manual                     BAM-CONFIG(1)



NAME
       bam-config - Get and set project or global options

SYNOPSIS
       bam config [<file-option>] <name> [<value>]
       bam config [<file-option>] --add <name> <value>
       bam config [<file-option>] --replace-all <name> <value>
       bam config [<file-option>] --get <name>
       bam config [<file-option>] --get-all <name>
       bam config [<file-option>] --unset <name>
       bam config [<file-option>] --unset-all <name>
       bam config [<file-option>] --rename-section <old-name> <new-name>
       bam config [<file-option>] --remove-section <name>
       bam config [<file-option>] -l | --list
       bam config -h | --help

DESCRIPTION
       You can query/set/replace/unset options with this command. The name is
       actually the section and the key separated by a dot, and the value will
       be escaped.

       When reading, the values are read from the global and project local
       configuration files by default, and options --global, --local and
       --file <file> can be used to tell the command to read from only that
       location.

       When writing, the new value is written to the project local configura-
       tion file by default, and options --global, --file <file> can be used
       to tell the command to write to that location (you can say --local, but
       that is the default).

       The command will fail with non-zero status upon error.

OPTIONS
       -h, --help
              Display this help and exit.

       --replace-all <name> <value>
              Default behavior is to replace at most one line. This replaces
              all lines matching the key.

       --add <name> <value>
              Adds a new line to the option without altering any existing val-
              ues.

       --get <name>
              Get the value for the given key. Returns error code 1 if the
              key was not found and the last value if multiple keys were
              found.

       --get-all <name>
              Like --get, but gets all values matching the given key.

       --global
              For writing options: write to global ~/.bamconfig file rather
              than the project .bam/config.

              For reading options: read only from global ~/.bamconfig rather
              than from all available files.

       --local
              For writing options: write to the project .bam/config file.
              This is the default behavior.

              For reading options: read only from the project .bam/config
              rather than from all available files.

        -f <config-file>, --file <config-file>
              Use the given config file instead of the one specified by
              BAM_CONFIG.

        --remove-section <name>
              Remove the given section from the configuration file.

        --rename-section <old-name> <new-name>
              Rename the given section to a new name.

        --unset <name>
              Remove the line matching the key from the config file.

        --unset-all <name>
              Remove all lines matching the key from the config file.

FILES
       If not set explicitly with --file, there are two files where bam config
       will search for configuration options:

       ~/.bamconfig
          User-specific configuration file. Also called "global" configu-
          ration file.

       \$BAM_DIR/config
          Project specific configuration file.

       If no further options are given, all reading options will read all of
       these files that are available. If the global configuration file is
       not available it will be ignored. If the project configuration file is
       not available or readable, bam config will exit with a non-zero error
       code. However, in neither case will an error message be issued.

       All writing options will per default write to the project specific con-
       figuration file. bam config will only ever change one file at a time.

       You can override these rules either by command line options or by envi-
       ronment variables. The --global option will limit the file used to the
       global file. The BAM_CONFIG environment variable has a similar effect,
       but you can specify any filename you want.

ENVIRONMENT
       BAM_CONFIG
          Take the configuration from the given file instead of .bam/con-
          fig. Using the --global option forces this to ~/.bamconfig.

CONFIGURATION FILE
       The bam configuration file contains a number of variables that affect
       the bam commands' behavior. The .bam/config file in each project is
       used to store the configuration for that project, and the \$HOME/.bam-
       config is used to store a per-user configuration as fallback values for
       the .bam/config file.

       Configuration variables are divided into sections, wherein the fully
       qualified variable name of the variable itself is the last dot-separat-
       ed segment, and the section name is everything before the last dot.
       The variable names are case-sensitive, allow only alphanumeric charac-
       ters and -, and must start with an alphabetic character. Some vari-
       ables may appear multiple times.

  Variables
       Note that this list is non-comprehensive and not necessarily complete.
       For command-specific variables, you will find a more detailed descrip-
       tion in the appropriate manual page.

       core.outdir
          Set the path to the build output directory. This can be over-
          ridden by the BAM_OUTPUT_DIR environment variable and the
          --out-dir command-line option. The value can be a source abso-
          lute path, system absolute path, or relative to the path to the
          '.bam' directory, which is either specified by --bam-dir or
          BAM_DIR, or automatically discovered. If --bam-dir or BAM_DIR
          is specified, but none of --out-dir, BAM_OUTPUT_DIR, and
          core.outdir is specified, the source root directory is regarded
          as the output directory.

       core.sourceroot
          Set the path to the source root directory. This can be overrid-
          den by the BAM_SOURCE_ROOT environment variable and the
          --source-root command-line option. The value can be a system
          absolute path, or relative to the path to the '.bam' directory,
          which is either specified by --bam-dir or BAM_DIR, or automati-
          cally discovered. If --bam-dir or BAM_DIR is specified, but
          none of --source-root, BAM_SOURCE_ROOT, core.sourceroot,
          --out-dir, BAM_OUTPUT_DIR, core.outdir is specified, the source
          root directory is automatically discovered by walking up the di-
          rectory tree until a .gn file is found. If one of --out-dir,
          BAM_OUTPUT_DIR, core.outdir is specified as a system absolute or
          relative path and contains a previously generated build, the
          source root directory is automatically determined from the pre-
          viously generated build.

       core.toplevel
          Set the path to the project base directory. This can be over-
          ridden by the BAM_TOP_LEVEL environment variable and the
          --top-level command-line option. The value can be a system ab-
          solute path, or relative to the path to the '.bam' directory,
          which is either specified by --bam-dir or BAM_DIR, or automati-
          cally discovered. If --bam-dir or BAM_DIR is specified, but
          none of --top-level, BAM_TOP_LEVEL, and core.toplevel is speci-
          fied, the current working directory is regarded as the top level
          directory.

       alias.*
          Command aliases for the bam command wrapper (e.g. after defin-
          ing "alias.all = build all", the invocation "bam all" is equiva-
          lent to "bam build all"). To avoid confusion and troubles with
          script usage, aliases that hide existing bam commands are ig-
          nored. Arguments are split by spaces, the usual shell quoting
          and escaping is supported.

          If the alias expansion is prefixed with an exclamation point, it
          will be treated as a shell command. For example, defining
          "alias.touch = !touch .gn", the invocation "bam touch" is equiv-
          alent to running the shell command "touch .gn". Note that shell
          commands will be executed from the top-level directory of the
          project, which may not necessarily be the current directory.
          BAM_PREFIX is set as returned by running bam misc --show-prefix
          from the original current directory. See bam-misc.



Bam $BAM_VERSION                                                 BAM-CONFIG(1)
EOF
  }
  LC_ALL=C bam config --help | col -bx | diff -Bbu <(expected) -
}

@test "'bam config -h' is the same as 'bam config --help'" {
  bam config -h | diff -u <(bam config --help) -
}

@test "'bam help config' is the same as 'bam config --help'" {
  bam help config | diff -u <(bam config --help) -
}

@test "'bam config' without args shows usage" {
  function expected() {
    cat << EOF
Usage: bam config [options]

Config file location:
    --global              use global config file
    --local               use project config file
    -f, --file <file>     use given config file

Actions:
    --get                 get value: name
    --get-all             get all values: name
    --replace-all         replace all matching variables: name value
    --add                 add a new variable: name value
    --unset               remove a variable: name
    --unset-all           remove all matches: name
    --rename-section      rename a section: old-name new-name
    --remove-section      remove a section: name
    -l, --list            list all

EOF
  }
  BAM_OUTPUT_DIR=out run bam config

  diff -u <(expected) <(bam config)
  [ "$status" -eq 1 ]
}

@test "'bam config <name>' gets last matching key" {
  mkdir .tmp
  cat > .tmp/config << EOF
[mysection]
    foo = my value1
    foo = my value2
[section2]
    bar = something
[mysection]
    foo = my value3   # comment
[baz]
    foo = baz value
EOF
  BAM_CONFIG=.tmp/config run bam config mysection.foo

  diff -u <(echo "my value3") <(print_result)
  [ "$status" -eq 0 ]
}

@test "'bam config --global <name>' gets from global config only" {
  mkdir .tmp
  cat > .tmp/.bamconfig << EOF
[foo]
    bar = baz
EOF
  cat > .tmp/config << EOF
[foo]
    bar = boo
EOF
  HOME=.tmp BAM_CONFIG=.tmp/config run bam config --global foo.bar

  diff -u <(echo "baz") <(print_result)
  [ "$status" -eq 0 ]
}

@test "'bam config --local <name>' gets from local config only" {
  mkdir .tmp
  cat > .tmp/.bamconfig << EOF
[foo]
    bar = baz
EOF
  cat > .tmp/config << EOF
[foo]
EOF
  HOME=.tmp BAM_CONFIG=.tmp/config run bam config --local foo.bar

  diff -u /dev/null <(print_result)
  [ "$status" -eq 1 ]
}

@test "'bam config --file <file>' gets from file config" {
  mkdir .tmp
  cat > .tmp/.bamconfig << EOF
[foo]
    bar = baz
EOF
  cat > .tmp/conf << EOF
[foo]
    bar = bzz
EOF
  HOME=.tmp run bam config --file .tmp/conf foo.bar

  diff -u <(echo "bzz") <(print_result)
  [ "$status" -eq 0 ]
}

@test "'bam config -f <file>' gets from file config" {
  mkdir .tmp
  cat > .tmp/.bamconfig << EOF
[foo]
    bar = baz
EOF
  cat > .tmp/conf.ini << EOF
[foo]
    bar = hello
EOF
  HOME=.tmp run bam config --file .tmp/conf.ini foo.bar

  diff -u <(echo "hello") <(print_result)
  [ "$status" -eq 0 ]
}

@test "'bam config --file <file>' gets does not read from global config" {
  mkdir .tmp
  cat > .tmp/.bamconfig << EOF
[foo]
    bar = baz
EOF
  cat > .tmp/conf << EOF
[foo]
EOF
  HOME=.tmp run bam config --file .tmp/conf foo.bar

  diff -u /dev/null <(print_result)
  [ "$status" -eq 1 ]
}

@test "'bam config <name>' with bad name" {
  function expected() {
    echo "bam-config: error: key does not contain a section: bar"
  }
  BAM_CONFIG=.tmp/config run bam config bar

  diff -u <(expected) <(print_result)
  [ "$status" -eq 1 ]
}

@test "'bam config --get <name>' with bad name" {
  function expected() {
    echo "bam-config: error: key does not contain a section: foo"
  }
  BAM_CONFIG=.tmp/config run bam config --get foo

  diff -u <(expected) <(print_result)
  [ "$status" -eq 1 ]
}

@test "'bam config --get <name>' gets last matching key" {
  mkdir .tmp
  cat > .tmp/config << EOF
[mysection]
    foo = my value1
    foo = my value2   ; comment
[baz]
    foo = baz value
EOF
  BAM_CONFIG=.tmp/config run bam config --get mysection.foo

  diff -u <(echo "my value2") <(print_result)
  [ "$status" -eq 0 ]
}

@test "'bam config --get-all <name>' gets all matching keys" {
  function expected() {
    echo "my value1"
    echo ""
    echo "my value2"
  }
  mkdir .tmp
  cat > .tmp/config << EOF
[mysection]
    foo = my value1  # comment
    foo =
    foo = my value2  ; comment
[baz]
    foo = baz value
EOF

  BAM_CONFIG=.tmp/config bam config --get-all mysection.foo | diff -u <(expected) -
}

@test "'bam config <name>' for empty key" {
  mkdir .tmp
  cat > .tmp/config << EOF
[mysection]
    foo = my value1  # comment
    foo = my value2  ; comment
    empty =
[baz]
    foo = baz value
EOF

  BAM_CONFIG=.tmp/config bam config mysection.empty | diff -u <(echo) -
}

@test "'bam config <name>' errors if no name" {
  mkdir .tmp
  cat > .tmp/config << EOF
[mysection]
    foo = my value1  # comment
    foo = my value2  ; comment
[baz]
    foo = baz value
EOF
  BAM_CONFIG=.tmp/config run bam config mysection.notfound

  diff -u /dev/null <(BAM_CONFIG=.tmp/config bam config mysection.notfound)
  [ "$status" -eq 1 ]
}

@test "'bam config --rename-section' wrong number of args" {
  function expected() {
    echo "bam-config: error: wrong number of arguments"
  }
  BAM_CONFIG=.tmp/config run bam config --rename-section foo

  diff -u <(expected) <(print_result)
  [ "$status" -eq 1 ]
}

@test "'bam config --rename-section <old-name> <new-name>' renames section" {
  function expected() {
  cat << EOF
[bar]
    foo = my value1  # comment
    foo = my value2  ; comment
[baz]
    foo = baz value
 [bar]
    bar = hello
[bar]
    bax = world
EOF
  }
  mkdir .tmp
  cat > .tmp/config << EOF
[foo]
    foo = my value1  # comment
    foo = my value2  ; comment
[baz]
    foo = baz value
 [foo]
    bar = hello
[foo]
    bax = world
EOF
  BAM_CONFIG=.tmp/config run bam config --rename-section foo bar

  diff -u <(expected) .tmp/config
  [ "$status" -eq 0 ]
}

@test "'bam config --remove-section' wrong number of args" {
  function expected() {
    echo "bam-config: error: wrong number of arguments"
  }
  BAM_CONFIG=.tmp/config run bam config --remove-section

  diff -u <(expected) <(print_result)
  [ "$status" -eq 1 ]
}

@test "'bam config --remove-section <name>' removes section" {
  function expected() {
  cat << EOF
[baz]
    foo = baz value
EOF
  }
  mkdir .tmp
  cat > .tmp/config << EOF
[foo]
    foo = my value1  # comment
    foo = my value2  ; comment
 [foo]
    bar = value
[foo]
    foo1 = my value1
    foo2 = my value2
[baz]
    foo = baz value
[foo]
    bar = hello
[foo]
    value = 2
    bax = world
EOF
  BAM_CONFIG=.tmp/config bam config --remove-section foo

  diff -u <(expected) .tmp/config
}

@test "'bam config <name> <value>' with bad name" {
  function expected() {
    echo "bam-config: error: key does not contain a section: foo"
  }
  BAM_CONFIG=.tmp/config run bam config foo val

  diff -u <(expected) <(print_result)
  [ "$status" -eq 1 ]
}

@test "'bam config <name> <value> <value>' too many args" {
  function expected() {
    echo "bam-config: error: wrong number of arguments"
  }
  BAM_CONFIG=.tmp/config run bam config foo.bar val more

  diff -u <(expected) <(print_result)
  [ "$status" -eq 1 ]
}

@test "'bam config <name> <value>' sets the name to value" {
  function expected() {
  cat << EOF
[foo]
    foo = new value
[foo]
    hello = there
 [fubar]
    zoom = yes
[baz]
    boo = hello world
[foo]
    value = bar
EOF
  }
  mkdir .tmp
  cat > .tmp/config << EOF
[foo]
    foo = my value1  # comment
[foo]
    hello = world
 [fubar]
    zoom = yes
[baz]
    boo = hello world
[foo]
    value = 2
EOF
  BAM_CONFIG=.tmp/config bam config foo.foo "new value"
  BAM_CONFIG=.tmp/config bam config foo.value bar
  BAM_CONFIG=.tmp/config bam config foo.hello there

  diff -u <(expected) .tmp/config
}

@test "'bam config <name> <value> <value>' can set dir values" {
  function expected() {
  cat << EOF
[foo]
    outdir = /tmp/foo/bar
    path = ../relative/path/to/dir
EOF
  }
  mkdir .tmp
  cat > .tmp/config << EOF
[foo]
    outdir = some value
    path = /abs/path/to/dir
EOF
  BAM_CONFIG=.tmp/config bam config foo.outdir "/tmp/foo/bar"
  BAM_CONFIG=.tmp/config bam config foo.path "../relative/path/to/dir"

  diff -u <(expected) .tmp/config
}

@test "'bam config <name> <value>' cannot set multiple values" {
  function expected() {
    echo "bam-config: warning: foo.bar has multiple values"
    echo "bam-config: error: cannot overwrite multiple values with a single value"
    echo "                     use --add or --replace-all to change foo.bar"
  }
  mkdir .tmp
  cat > .tmp/config << EOF
[foo]
    bar = value1
    bar = value2
EOF
  cp .tmp/config .tmp/config.sav
  BAM_CONFIG=.tmp/config run bam config foo.bar value3

  diff -u <(expected) <(print_result)
  diff -u .tmp/config.sav .tmp/config
  [ "$status" -eq 1 ]
}

@test "'bam config --replace-all <name> <value>' sets all names to value" {
  function expected() {
  cat << EOF
[foo]
    hello = there
    foo = my value1  # comment
    hello = there
[foo]
    hello = there
    hello = there
 [fubar]
    hello = yes
[baz]
    boo = hello world
[foo]
    value = 2
    hello = there
EOF
  }
  mkdir .tmp
  cat > .tmp/config << EOF
[foo]
    hello = val
    foo = my value1  # comment
    hello = value
[foo]
    hello = world
    hello = foobar
 [fubar]
    hello = yes
[baz]
    boo = hello world
[foo]
    value = 2
    hello = config
EOF
  BAM_CONFIG=.tmp/config bam config --replace-all foo.hello there

  diff -u <(expected) .tmp/config
}

@test "'bam config <name> <value>' adds new value if not exists" {
  function expected() {
  cat << EOF
[foo]
    hello = there
[baz]
    boo = hello world
	newboo = here
[foo]
    value = 1
	new = value
EOF
  }
  mkdir .tmp
  cat > .tmp/config << EOF
[foo]
    hello = there
[baz]
    boo = hello world
[foo]
    value = 1
EOF
  BAM_CONFIG=.tmp/config bam config foo.new value
  BAM_CONFIG=.tmp/config bam config baz.newboo here

  diff -u <(expected) .tmp/config
}

@test "'bam config <name> <value> <value>' can add new dir values" {
  function expected() {
  cat << EOF
[foo]
    value = /path/to/some/file
	dir = /home/foo/bar
	out = ../here/is/the/path
EOF
  }
  mkdir .tmp
  cat > .tmp/config << EOF
[foo]
    value = /path/to/some/file
EOF
  BAM_CONFIG=.tmp/config bam config foo.dir "/home/foo/bar"
  BAM_CONFIG=.tmp/config bam config foo.out "../here/is/the/path"

  diff -u <(expected) .tmp/config
}

@test "'bam config --add <name> <value>' adds new value even if exists" {
  function expected() {
  cat << EOF
[foo]
    hello = there
[baz]
    boo = hello world
	boo = newvalue
[foo]
    value = 1
	value = value
EOF
  }
  mkdir .tmp
  cat > .tmp/config << EOF
[foo]
    hello = there
[baz]
    boo = hello world
[foo]
    value = 1
EOF
  BAM_CONFIG=.tmp/config bam config --add baz.boo newvalue
  BAM_CONFIG=.tmp/config bam config --add foo.value value

  diff -u <(expected) .tmp/config
}

@test "'bam config <name> <value>' adds new section if none exists" {
  function expected() {
  cat << EOF
[foo]
    hello = there
[baz]
    boo = hello world
[foo]
    value = 1
[bar]
	fab = fubar
[user]
	name = root
EOF
  }
  mkdir .tmp
  cat > .tmp/config << EOF
[foo]
    hello = there
[baz]
    boo = hello world
[foo]
    value = 1
EOF
  BAM_CONFIG=.tmp/config bam config bar.fab fubar
  BAM_CONFIG=.tmp/config bam config --add user.name root

  diff -u <(expected) .tmp/config
}

@test "'bam config --unset <name>' with bad name" {
  function expected() {
    echo "bam-config: error: key does not contain a section: foo"
  }
  BAM_CONFIG=.tmp/config run bam config --unset foo

  diff -u <(expected) <(print_result)
  [ "$status" -eq 1 ]
}

@test "'bam config --unset <name>' error if no name" {
  mkdir .tmp
  cat > .tmp/config << EOF
[foo]
    hello = there
EOF
  cp .tmp/config .tmp/config.sav
  BAM_CONFIG=.tmp/config run bam config --unset foo.notfound

  diff -u .tmp/config.sav .tmp/config
  [ "$status" -eq 1 ]
}

@test "'bam config --unset <name>' removes name" {
  function expected() {
  cat << EOF
[foo]
    hello = there
[baz]
    boo = hello world
[foo]
[user]
EOF
  }
  mkdir .tmp
  cat > .tmp/config << EOF
[foo]
    hello = there
[baz]
    boo = hello world
[foo]
    value = 1
[user]
    name = foo
EOF
  BAM_CONFIG=.tmp/config bam config --unset foo.value
  BAM_CONFIG=.tmp/config bam config --unset user.name

  diff -u <(expected) .tmp/config
}

@test "'bam config --unset <name>' errors on multiple matches" {
  function expected() {
    echo "bam-config: warning: foo.value has multiple values"
    echo "bam-config: error: cannot unset multiple values"
    echo "                     use --unset-all to unset foo.value"
  }
  mkdir .tmp
  cat > .tmp/config << EOF
[foo]
    value = 1
    value = 2
EOF
  cp .tmp/config .tmp/config.sav
  BAM_CONFIG=.tmp/config run bam config --unset foo.value

  diff -u .tmp/config.sav .tmp/config
  [ "$status" -eq 1 ]
}

@test "'bam config --unset-all <name>' removes all names" {
  function expected() {
  cat << EOF
[foo]
    hello = there
[baz]
    boo = hello world
[foo]
[foo]
[foo]
[user]
    name = foo
EOF
  }
  mkdir .tmp
  cat > .tmp/config << EOF
[foo]
    hello = there
    bar = value1
    bar = value2
    bar = value3
[baz]
    boo = hello world
[foo]
    bar = value4
[foo]
    bar = value5
[foo]
    bar = value6
[user]
    name = foo
EOF
  BAM_CONFIG=.tmp/config bam config --unset-all foo.bar

  diff -u <(expected) .tmp/config
}

@test "'bam config <name> <value>' creates config file if not exist" {
  function expected() {
    echo "[foo.bar]"
    echo -e "\tmessage = hello world"
  }
  BAM_CONFIG=.tmp/config run bam config foo.bar.message "hello world"

  [ -f .tmp/config ]
  diff -u <(expected) .tmp/config
  diff -u /dev/null <(print_result)
  [ "$status" -eq 0 ]
}

@test "'bam config --unset <name> <value>' does not create config file if not exist" {
  BAM_CONFIG=.tmp/config run bam config --unset foo.bar

  ! [ -f .tmp/config ]
  [ "$status" -eq 1 ]
}

@test "'bam config --list' lists all values" {
  function expected() {
    echo "user.name=friend"
    echo "foo.bar=hi"
    echo "foo.bar=hello world"
    echo "foo.baz=I am here"
    echo "boo.name=ghost"
    echo "boo.name=casper"
    echo "user.name=other"
  }
  mkdir .tmp
  cat > .tmp/.bamconfig << EOF
[user]
    name = friend
[foo]
    bar = hi
EOF
  cat > .tmp/config << EOF
[foo]
    bar = hello world
    baz = I am here
    #fu = comment
[boo]
    name = ghost
    name = casper
    ;ghost = nothing
#comment
;comment
[user]
    name = other
EOF

  HOME=.tmp BAM_CONFIG=.tmp/config run bam config --list

  diff -u <(expected) <(print_result)
  [ "$status" -eq 0 ]
}

@test "'bam config -l' lists all values" {
  function expected() {
    echo "user.name=friend"
    echo "foo.baz=I am here"
    echo "boo.name=casper"
  }
  mkdir .tmp
  cat > .tmp/.bamconfig << EOF
[user]
    name = friend
EOF
  cat > .tmp/config << EOF
[foo]
    baz = I am here
[boo]
    name = casper
EOF

  HOME=.tmp BAM_CONFIG=.tmp/config run bam config -l

  diff -u <(expected) <(print_result)
  [ "$status" -eq 0 ]
}

@test "'bam config --file <file> --list' lists only file values" {
  function expected() {
    echo "foo.bar=hello world"
    echo "foo.baz=I am here"
    echo "boo.name=ghost"
    echo "boo.name=casper"
    echo "user.name=other"
  }
  mkdir .tmp
  cat > .tmp/.bamconfig << EOF
[user]
    name = friend
[foo]
    bar = hi
EOF
  cat > .tmp/config << EOF
[foo]
    bar = hello world
    baz = I am here
[boo]
    name = ghost
    name = casper
[user]
    name = other
EOF

  HOME=.tmp run bam config --file .tmp/config --list

  diff -u <(expected) <(print_result)
  [ "$status" -eq 0 ]
}

@test "'bam config --global --list' lists only global values" {
  function expected() {
    echo "user.name=friend"
    echo "foo.bar=hi"
  }
  mkdir .tmp
  cat > .tmp/.bamconfig << EOF
[user]
    name = friend
[foo]
    bar = hi
EOF
  cat > .tmp/config << EOF
[foo]
    bar = hello world
    baz = I am here
[boo]
    name = ghost
    name = casper
[user]
    name = other
EOF

  HOME=.tmp BAM_CONFIG=.tmp/config run bam config --global --list

  diff -u <(expected) <(print_result)
  [ "$status" -eq 0 ]
}

@test "'bam config --list' with missing global config" {
  function expected() {
    echo "foo.bar=hi there"
    echo "boo.name=casper"
    echo "user.name=other"
  }
  mkdir .tmp
  cat > .tmp/config << EOF
[foo]
    bar = hi there
[boo]
    name = casper
[user]
    name = other
EOF

  HOME=.tmp BAM_CONFIG=.tmp/config run bam config --list

  diff -u <(expected) <(print_result)
  [ "$status" -eq 0 ]
}

@test "'bam config --list arg' with args has error" {
  function expected() {
    echo "bam-config: error: wrong number of arguments"
  }
  HOME=.tmp BAM_CONFIG=.tmp/config run bam config --list arg

  diff -u <(expected) <(print_result)
  [ "$status" -eq 1 ]
}

@test "'bam config <name>' with missing local config file" {
  function expected() {
    echo "friend"
  }
  mkdir .tmp
  cat > .tmp/.bamconfig << EOF
[user]
    name = friend
EOF
  HOME=.tmp run bam config user.name

  diff -u <(expected) <(print_result)
  [ "$status" -eq 1 ]
}

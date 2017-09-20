% BAM-TEST(1) | Bam Manual

# NAME

bam-test - Build and run tests for one or more targets

# SYNOPSIS

**bam** **test** [**-h**|**--help**] [**-j** \<N\>|**--jobs** \<N\>] [**-l** \<N\>|**--load-average** \<N\>]\
\  \  \  \  \ [**-k**|**--[no-]keep-going**|**-S**|**--stop**] [**-n**|**--dry-run**]\
\  \  \  \  \ [**--runs-per-test** \<N\>] [**--run-under** \<command-prefix\>]\
\  \  \  \  \ [**-r**|**--recursive**] [**--replace-test-args**] [**--test-arg** \<arg\>]\
\  \  \  \  \ [**--cache-results** (yes|no|auto)] [**--check-up-to-date**]\
\  \  \  \  \ [**--only \<pattern\>**] [**--skip \<pattern\>**]\
\  \  \  \  \ [**-v**|**--verbose**] \<target-patterns...\>

# DESCRIPTION
  The *bam test* command is similar to *bam build*, except it is used to
  build and run tests for one or more targets.

# OPTIONS
-h, --help
:   Display this help and exit.

--check-up-to-date
:   Do not perform a build or run any tests, but merely check whether all
    specified tests are up-to-date. If there are any tests which have not been
    previously built or run, or whose test results are out-of-date, an error is
    reported and the test fails.

-j \<N\>, --jobs \<N\>
:   Run N jobs in parallel. The default is derived from the number of CPUs
    available.

-k, --keep-going
:   Continue as much as possible after an error. While a target that failed,
    and those that depend on it, cannot be remade, the other dependencies of
    these targets can be processed all the same.

-l \<N\>, --load-average \<N\>
:   Do not start new jobs if the load average is greater than N.

-n, --dry-run
:   Dry run (don't run commands but act like they succeeded).

--only \<pattern\>
:   Only build and test the target labels matching the specified pattern.

-r, --recursive
:   Recursively build and run the tests for the specified targets as well as the
    tests for each of their dependencies.

--replace-test-args
:   If specified the default test arguments are replaced with those specified
    with **--test-arg**.

--runs-per-test \<N\>
:   Specifies the number of times each test should be executed.

--run-under \<command-prefix\>
:   This specifies a prefix that the test runner will insert in front of the
    test command being executed. The \<command-prefix\> is split into words
    using Bourne shell tokenization rules, and then the list of words is
    prepended to the command that will be executed.

--skip \<pattern\>
:   Do not build or test the target labels matching the specified pattern.
    (Note: **skip** targets take precedence over **only** targets)

-S, --no-keep-going, --stop
:   Cancel the effect of the **-k** option.

-t (yes|no|auto), --cache-results (yes|no|auto)
:   If set to 'auto' (the default) then only rerun a test if any of the
    following conditions apply:

    - A change is detected in the test or its dependencies

    - Multiple test runs were requested with **--runs-per-test**

    - The test failed

    If 'no', all tests will be executed unconditionally.

    If 'yes', the caching behavior will be the same as 'auto' except that it may
    cache results with **--runs-per-test**.

--test-arg \<arg\>
:   Passes command-line options/flags/arguments to the test (not to the test
    runner). This option can be used multiple times to pass several arguments
    (i.e. --test-arg=--logtostderr --test-arg=-v). By default, any specified
    test arguments are appended to the default set of test arguments. To replace
    the default arguments use **--replace-test-args**.

-v, --verbose
:   Show all command lines while building.

\<target-patterns\>
:   The target label patterns to build and test.

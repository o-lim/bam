#!/usr/bin/env bats

set -o pipefail

setup() {
  source bam-sh-test-setup
  export BAM_OUTPUT_DIR="out"
  export UNAME="$(uname -s | tr A-Z a-z)"
}

before_each() {
  cp -r ../examples .tmp
  cd .tmp
  sed -i "s/host_platform = \"x86_64-linux-gnu\"/host_platform = \"x86_64-${UNAME}-gnu\"/" hello/build/config/BUILDCONFIG.gn
  touch flint
  chmod +x flint
  PATH="$(pwd):$PATH"
}

after_each() {
  cd ..
  rm -rf .tmp*
}

@test "hello example: no errors in gn files" {
  function expected() {
    echo "Generating JSON projects took XXms"
    echo "Done. Made XX targets from XX files in XXms"
  }

  bam -C hello gen | sed -r 's/[0-9]+/XX/g' | diff -u <(expected) -
  [ -d hello/out ]
}

@test "hello example: build and execute for host and ut" {
  function expected() {
    echo "Hello World from SetText!!!"
    echo "Hello World from StaticText!!!"
  }
  bam -C hello gen --args="platforms = [\"x86_64-${UNAME}-gnu\", \"ut\"]"
  bam -C hello ninja
  hello/out/hello | diff -u <(expected) -
}

@test "hello example: rebuild and execute after changing dirname" {
  function expected() {
    echo "Hello World from SetText!!!"
    echo "Hello World from StaticText!!!"
  }
  bam -C hello config core.sourceroot ..
  bam -C hello gen --args="platforms = [\"x86_64-${UNAME}-gnu\", \"ut\"]"
  bam -C hello ninja
  rm -f hello/out/build-env.log
  mv hello hello_world
  sleep 1
  bam -C hello_world ninja
  [ -f hello_world/out/build-env.log ]
  hello_world/out/hello | diff -u <(expected) -
}

@test "hello example: no errors in gn files when outdir is source root" {
  function expected() {
    echo "Generating JSON projects took XXms"
    echo "Done. Made XX targets from XX files in XXms"
  }

  bam -C hello -o . gen | sed -r 's/[0-9]+/XX/g' | diff -u <(expected) -
  ! [ -d hello/out ]
}

@test "hello example: build and execute when outdir is source root" {
  function expected() {
    echo "Hello World from SetText!!!"
    echo "Hello World from StaticText!!!"
  }

  bam -C hello -o . gen --args="platforms = [\"x86_64-${UNAME}-gnu\", \"ut\"]"
  bam -C hello -o . ninja
  hello/hello | diff -u <(expected) -
  ! [ -d hello/out ]
}

@test "hello example: build and execute when outdir outside source root" {
  function expected() {
    echo "Hello World from SetText!!!"
    echo "Hello World from StaticText!!!"
  }

  bam -C hello -o ../out gen --args="platforms = [\"x86_64-${UNAME}-gnu\", \"ut\"]"
  bam -C hello -o ../out ninja
  out/hello | diff -u <(expected) -
  ! [ -d hello/out ]
}

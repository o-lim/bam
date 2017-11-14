ifeq ($(OS),Windows_NT)
  OS := Windows
else
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
  OS := Linux
endif
ifeq ($(UNAME_S),Darwin)
  OS := Mac
endif
endif

GN_VERSION = 0.3.2
GN_PLATFORM = x86_64-linux
GN_URL = https://github.com/o-lim/generate-ninja/releases/download/v$(GN_VERSION)/gn-$(GN_PLATFORM).tar.gz

NINJA_VERSION = 1.8.2
NINJA_PLATFORM = linux
NINJA_URL = https://github.com/ninja-build/ninja/releases/download/v$(NINJA_VERSION)/ninja-$(NINJA_PLATFORM).zip

JQ_VERSION = 1.5
JQ_PLATFORM = linux64
JQ_URL = https://github.com/stedolan/jq/releases/download/jq-$(JQ_VERSION)/jq-$(JQ_PLATFORM)

CPPLINT_VERSION = 9883c5157801576bf40fc69c25115276f9edb24a
CPPLINT_URL = https://raw.githubusercontent.com/google/styleguide/$(CPPLINT_VERSION)/cpplint/cpplint.py

PANDOC_VERSION = 1.16.0.2
PANDOC_PLATFORM = -1-amd64.deb
PANDOC_URL = https://github.com/jgm/pandoc/releases/download/$(PANDOC_VERSION)/pandoc-$(PANDOC_VERSION)$(PANDOC_PLATFORM)

BATS_VERSION = 0.4.0
BATS_URL = https://github.com/sstephenson/bats/archive/v$(BATS_VERSION).tar.gz

GTEST_VERSION = 1.8.0
GTEST_URL = https://github.com/google/googletest/archive/release-$(GTEST_VERSION).tar.gz

COREUTILS_VERSION = 8.23
COREUTILS_URL = https://github.com/coreutils/coreutils.git
COREUTILS_CFLAGS="-m64"
COREUTILS_LDFLAGS="-static -m64"

EXE =

ifeq ($(system),i686-linux)
GN_PLATFORM = i686-linux
NINJA_PLATFORM = linux
JQ_PLATFORM = linux32
COREUTILS_CFLAGS="-m32"
COREUTILS_LDFLAGS="-static -m32"
endif
ifeq ($(OS),Mac)
GN_PLATFORM = x86_64-darwin
NINJA_PLATFORM = mac
JQ_PLATFORM = osx-amd64
PANDOC_PLATFORM = -osx.pkg
endif
ifeq ($(OS),Windows)
GN_PLATFORM = x86_64-windows
NINJA_PLATFORM = win
JQ_PLATFORM = win64.exe
PANDOC_PLATFORM = -windows.msi
EXE = .exe
endif


ifeq ($(TRAVIS),)
DEPS_DIR := $(CURRENT_DIR)/deps
else
DEPS_DIR := $(abspath $(CURRENT_DIR)/deps)
endif

.PHONY: deps
deps: $(DEPS_DIR)/gn$(EXE) $(DEPS_DIR)/ninja$(EXE) $(DEPS_DIR)/jq$(EXE) $(DEPS_DIR)/pandoc-$(PANDOC_VERSION)$(PANDOC_PLATFORM)
	@true

ifeq ($(OS),Linux)
ifeq ($(shell which realpath),)
deps: $(DEPS_DIR)/realpath
endif
endif

.PHONY: test-deps
test-deps: $(DEPS_DIR)/bats-$(BATS_VERSION)
test-deps: $(DEPS_DIR)/googletest-release-$(GTEST_VERSION)
test-deps: $(DEPS_DIR)/cpplint.py
	@true

clean: clean-deps

.PHONY: clean-deps
clean-deps:
	@rm -rf $(DEPS_DIR)

.PHONY: clean-test-deps
clean-test-deps: clean-gtest clean-bats clean-cpplint.py
	@true

.PHONY: clean-gtest
clean-gtest:
	@rm -rf $(DEPS_DIR)/googletest-release-$(GTEST_VERSION)

.PHONY: clean-bats
clean-bats:
	@rm -rf $(DEPS_DIR)/bats-$(BATS_VERSION)

.PHONY: clean-coreutils
clean-coreutils:
	@rm -rf $(DEPS_DIR)/coreutils-v$(COREUTILS_VERSION)

.PHONY: clean-cpplint.py
clean-cpplint.py:
	@rm -rf $(DEPS_DIR)/cpplint.py

.PHONY: clean-make-deps
clean-make-deps: clean-pandoc clean-coreutils
	@true

.PHONY: clean-pandoc
clean-pandoc:
	@rm -rf $(DEPS_DIR)/pandoc-$(PANDOC_VERSION)$(PANDOC_PLATFORM)

$(DEPS_DIR)/:
	@mkdir -p $@

$(DEPS_DIR)/gn$(EXE): | $(DEPS_DIR)/
	@curl --location $(GN_URL) | tar -C deps -xzf -

$(DEPS_DIR)/ninja$(EXE): | $(DEPS_DIR)/
	@curl -o ninja-$(NINJA_PLATFORM).zip --location $(NINJA_URL)
	@unzip -d $(@D) ninja-$(NINJA_PLATFORM).zip
	@rm -f ninja-$(NINJA_PLATFORM).zip

$(DEPS_DIR)/jq$(EXE): | $(DEPS_DIR)/
	@curl -o $@ --location $(JQ_URL)
	@chmod +x $@

$(DEPS_DIR)/cpplint.py: | $(DEPS_DIR)/
	@curl -o $@ --location $(CPPLINT_URL)
	@patch -d $(@D) -p1 < patches/cpplint.patch
	@chmod +x $@

$(DEPS_DIR)/bats-$(BATS_VERSION): | $(DEPS_DIR)/
	@curl --location $(BATS_URL) | tar -C $(@D) -xzf -
	@patch -d $@ -p1 < patches/bats_before_after.patch

$(DEPS_DIR)/googletest-release-$(GTEST_VERSION): | $(DEPS_DIR)/
	@curl --location $(GTEST_URL) | tar -C $(@D) -xzf -
	@patch -d $@ -p1 < patches/googletest-support-for-pkgconfig.patch
	@mkdir -p $@/build
	@cd $@/build && cmake ..
	@make -C $@/build

$(DEPS_DIR)/coreutils-v$(COREUTILS_VERSION): | $(DEPS_DIR)/
	@git -C $(@D) clone --depth=50 -b v$(COREUTILS_VERSION) $(COREUTILS_URL) $(@F)

$(DEPS_DIR)/realpath: $(DEPS_DIR)/coreutils-v$(COREUTILS_VERSION)
	@mkdir -p $</build
	@cd $< && ./bootstrap
	@cd $</build && ../configure CFLAGS=$(COREUTILS_CFLAGS) LDFLAGS=$(COREUTILS_LDFLAGS)
	@printf '\ngen-sources: $$(BUILT_SOURCES)\n\t@true' >> $</build/Makefile
	@make -C $</build gen-sources
	@make -C $</build src/$(@F) man/$(basename $(@F)).1
	@install -d $(dir $@)/man
	@install $</build/src/$(@F) $@
	@install --mode=644 $</build/man/$(basename $(@F)).1 $(dir $@)/man

$(DEPS_DIR)/pandoc-$(PANDOC_VERSION)$(PANDOC_PLATFORM):
	@curl -o $@ --location $(PANDOC_URL)

.PHONY: install-make-deps
install-make-deps: install-pandoc
	@true

.PHONY: install-realpath-deps
ifeq ($(OS),Linux)
install-realpath-deps:
	@apt-get install -qq -y autopoint gperf texinfo
endif
ifeq ($(OS),Mac)
install-realpath-deps:
	@true
endif

.PHONY: install-deps
install-deps: install-gn install-ninja install-jq
ifeq ($(OS),Linux)
install-deps: install-realpath
	@true
endif

ifeq ($(OS),Mac)
install-deps:
	@brew list cmake > /dev/null 2>&1 || brew install cmake
	@brew list coreutils > /dev/null 2>&1 || brew install coreutils
	@brew list gnu-getopt > /dev/null 2>&1 || brew install gnu-getopt
	@brew link --force gnu-getopt
	@brew install gnu-sed --default-names
	@brew link --force gnu-sed
	@brew list binutils > /dev/null 2>&1 || brew install binutils
endif

.PHONY: install-gn
install-gn: $(DEPS_DIR)/gn$(EXE)
	@install -d $(PREFIX)/bin
	@install $< $(PREFIX)/bin/

.PHONY: install-ninja
install-ninja: $(DEPS_DIR)/ninja$(EXE)
	@install -d $(PREFIX)/bin
	@install $< $(PREFIX)/bin/

.PHONY: install-jq
install-jq: $(DEPS_DIR)/jq$(EXE)
	@install -d $(PREFIX)/bin
	@install $< $(PREFIX)/bin/

.PHONY: install-realpath
ifeq ($(shell which realpath),)
install-realpath: $(DEPS_DIR)/realpath
	@install -d $(PREFIX)/bin $(PREFIX)/man/man1
	@install $< $(PREFIX)/bin/
	@install --mode=644 $(dir $<)/man/$(basename $(<F)).1 $(PREFIX)/man/man1/
else
install-realpath:
	@true
endif

.PHONY: install-pandoc
ifeq ($(shell which pandoc),)
install-pandoc: $(DEPS_DIR)/pandoc-$(PANDOC_VERSION)$(PANDOC_PLATFORM)
ifeq ($(OS),Linux)
install-pandoc:
	@dpkg -i $<
endif
ifeq ($(OS),Mac)
install-pandoc:
	@sudo installer -pkg $< -target /
endif
else
install-pandoc:
	@true
endif

.PHONY: install-test-deps
install-test-deps: install-bats install-gtest install-cpplint.py
ifeq ($(OS),Linux)
install-test-deps:
	@apt-get install -qq -y lua5.2
	@apt-get install -qq -y lua5.2-dev
	@apt-get install -qq -y valgrind
	@apt-get install -qq -y python-dev
	@add-apt-repository ppa:team-gcc-arm-embedded/ppa -y
	@apt-get update -qq
	@apt-get install -qq -y gcc-arm-embedded
	@apt-get install -qq -y gcc-mingw-w64-i686 g++-mingw-w64-i686 binutils-mingw-w64-i686
	@apt-get install -qq -y gcc-mingw-w64-x86-64 g++-mingw-w64-x86-64 binutils-mingw-w64-x86-64
endif
ifeq ($(OS),Mac)
install-test-deps:
	@brew list lua > /dev/null 2>&1 || brew install lua
	@brew list python > /dev/null 2>&1 || brew install python
	@brew list gcc49 > /dev/null 2>&1 || brew install gcc49
	@ln -s gcc-4.9 /usr/local/bin/gcc
	@ln -s g++-4.9 /usr/local/bin/g++
	@brew tap PX4/homebrew-px4
	@brew install gcc-arm-none-eabi-49
	@ln -s /usr/local/bin/ghead ~/bin/head
	@ln -s /usr/local/bin/gtail ~/bin/tail
endif

.PHONY: install-gtest
install-gtest: $(DEPS_DIR)/googletest-release-$(GTEST_VERSION)
	@make -C $</build install

.PHONY: install-cpplint.py
install-cpplint.py: $(DEPS_DIR)/cpplint.py
	@install -d $(PREFIX)/bin
	@install $< $(PREFIX)/bin/

.PHONY: install-bats
install-bats: $(DEPS_DIR)/bats-$(BATS_VERSION)
	@cd $< && ./install.sh $(PREFIX)


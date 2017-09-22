
GN_VERSION = 0.2.2
GN_PLATFORM = x86_64-linux
GN_URL = https://github.com/o-lim/generate-ninja/releases/download/v$(GN_VERSION)/gn-$(GN_PLATFORM).tar.gz

NINJA_VERSION = 1.7.2
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



DEPS_DIR := $(abspath $(CURRENT_DIR)/deps)

.PHONY: deps
deps: $(DEPS_DIR)/gn $(DEPS_DIR)/ninja $(DEPS_DIR)/jq $(DEPS_DIR)/pandoc-$(PANDOC_VERSION)$(PANDOC_PLATFORM)
	@true

.PHONY: test-deps
test-deps: $(DEPS_DIR)/bats-$(BATS_VERSION)
test-deps: $(DEPS_DIR)/googletest-release-$(GTEST_VERSION)
test-deps: $(DEPS_DIR)/cpplint.py
	@true

clean: clean-deps

.PHONY: clean-deps
clean-deps:
	@rm -rf $(DEPS_DIR)

$(DEPS_DIR):
	@mkdir -p $@

$(DEPS_DIR)/gn: | $(DEPS_DIR)
	@curl --location $(GN_URL) | tar -C deps -xzf -

$(DEPS_DIR)/ninja: | $(DEPS_DIR)
	@curl -o ninja-$(NINJA_PLATFORM).zip --location $(NINJA_URL)
	@unzip -d $(DEPS_DIR) ninja-$(NINJA_PLATFORM).zip
	@rm -f ninja-$(NINJA_PLATFORM).zip

$(DEPS_DIR)/jq: | $(DEPS_DIR)
	@curl -o $(TOP_LEVEL_DIR)/deps/jq --location $(JQ_URL)
	@chmod +x $(TOP_LEVEL_DIR)/deps/jq

$(DEPS_DIR)/cpplint.py: | $(DEPS_DIR)
	@curl -o $@ --location $(CPPLINT_URL)
	@patch -d $(DEPS_DIR) -p1 < patches/cpplint.patch
	@chmod +x $@

$(DEPS_DIR)/bats-$(BATS_VERSION): | $(DEPS_DIR)
	@curl --location $(BATS_URL) | tar -C $(@D) -xzf -
	@patch -d $@ -p1 < patches/bats_before_after.patch

$(DEPS_DIR)/googletest-release-$(GTEST_VERSION): | $(DEPS_DIR)
	@curl --location $(GTEST_URL) | tar -C $(@D) -xzf -
	@patch -d $@ -p1 < patches/googletest-support-for-pkgconfig.patch
	@mkdir -p $@/build
	@cd $@/build && cmake ..
	@make -C $@/build

$(DEPS_DIR)/pandoc-$(PANDOC_VERSION)$(PANDOC_PLATFORM):
	@curl -o $@ --location $(PANDOC_URL)

.PHONY: install-make-deps
install-make-deps: install-pandoc
	@true

.PHONY: install-deps
install-deps: install-gn install-ninja install-jq

.PHONY: install-gn
install-gn: $(DEPS_DIR)/gn
	@install -d $(PREFIX)/bin
	@install $< $(PREFIX)/bin/

.PHONY: install-ninja
install-ninja: $(DEPS_DIR)/ninja
	@install -d $(PREFIX)/bin
	@install $< $(PREFIX)/bin/

.PHONY: install-jq
install-jq: $(DEPS_DIR)/jq
	@install -d $(PREFIX)/bin
	@install $< $(PREFIX)/bin/

.PHONY: install-pandoc
ifeq ($(shell which pandoc),)
install-pandoc: $(DEPS_DIR)/pandoc-$(PANDOC_VERSION)$(PANDOC_PLATFORM)
	@dpkg -i $<
else
install-pandoc:
	@true
endif

.PHONY: install-test-deps
install-test-deps: install-bats install-gtest install-cpplint.py
	@apt-get install -qq -y lua5.2
	@apt-get install -qq -y lua5.2-dev
	@apt-get install -qq -y valgrind
	@add-apt-repository ppa:team-gcc-arm-embedded/ppa -y
	@apt-get update -qq
	@apt-get install -qq -y gcc-arm-embedded
	@apt-get install -qq -y gcc-mingw-w64-i686 g++-mingw-w64-i686 binutils-mingw-w64-i686
	@apt-get install -qq -y gcc-mingw-w64-x86-64 g++-mingw-w64-x86-64 binutils-mingw-w64-x86-64

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


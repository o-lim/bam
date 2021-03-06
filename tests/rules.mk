include $(TOP_LEVEL_DIR)/header.mk

export BAM_VERSION = 0.0.0
ifeq ($(BAM_TEST_ENV),1)
export BAM_CORE_PATH = $(realpath $(TOP_LEVEL_DIR))
export BAM_EXEC_PATH = $(BAM_CORE_PATH)/libexec
else
export BAM_CORE_PATH = $(shell bam --core-path 2> /dev/null)
endif
export LC_ALL = C

TESTS_DIR := $(CURRENT_DIR)
BATS_FILES := $(wildcard $(TESTS_DIR)/*.bats)
BAM_BATS_FILES := $(wildcard $(TESTS_DIR)/bam*.bats)

.PHONY: test tests
test tests: man lnt
	@cd $(TESTS_DIR) && env -u NINJA_STATUS bats $(BATS_FILES)

.PHONY: $(BATS_FILES)
$(BATS_FILES):
	@cd $(TESTS_DIR) && env -u NINJA_STATUS bats $@

$(foreach bats,$(BAM_BATS_FILES),\
  $(eval $(bats): $(TOP_LEVEL_DIR)/man/man1/$(notdir $(basename $(bats))).1)\
)

include $(TOP_LEVEL_DIR)/footer.mk

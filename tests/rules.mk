include $(TOP_LEVEL_DIR)/header.mk

export BAM_CORE_PATH = $(realpath $(TOP_LEVEL_DIR))
export BAM_EXEC_PATH = $(BAM_CORE_PATH)/libexec
export BAM_TEMPLATE_DIR = $(BAM_CORE_PATH)/templates
export LC_ALL = C

TESTS_DIR := $(CURRENT_DIR)
BATS_FILES := $(wildcard $(TESTS_DIR)/*.bats)
BAM_BATS_FILES := $(wildcard $(TESTS_DIR)/bam*.bats)

.PHONY: test tests
test tests: man lnt
	@cd $(TESTS_DIR) && BAM_INSTALL_PREFIX=$(PREFIX) bats $(BATS_FILES)

.PHONY: $(BATS_FILES)
$(BATS_FILES):
	@cd $(TESTS_DIR) && BAM_INSTALL_PREFIX=$(PREFIX) bats $@

$(foreach bats,$(BAM_BATS_FILES),\
  $(eval $(bats): $(TOP_LEVEL_DIR)/man/man1/$(notdir $(basename $(bats))).1.gz)\
)

include $(TOP_LEVEL_DIR)/footer.mk

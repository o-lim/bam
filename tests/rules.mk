include $(TOP_LEVEL_DIR)/header.mk

export LC_COLLATE = C

TESTS_DIR := $(CURRENT_DIR)
BATS_FILES := $(wildcard $(TESTS_DIR)/*.bats)

.PHONY: test tests
test tests:
	@cd $(TESTS_DIR) && bats $(BATS_FILES)

.PHONY: $(BATS_FILES)
$(BATS_FILES):
	@cd $(TESTS_DIR) && bats $@

include $(TOP_LEVEL_DIR)/footer.mk

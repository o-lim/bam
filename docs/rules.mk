include $(TOP_LEVEL_DIR)/header.mk

BAM_DOCS := $(wildcard $(CURRENT_DIR)/*.md)
BAM_MANPAGES := $(patsubst $(CURRENT_DIR)/%.1.md,$(TOP_LEVEL_DIR)/man/man1/%.1.gz,$(BAM_DOCS))
PANDOC_MAN_TEMPLATE_FILE := $(CURRENT_DIR)/template.man

all: doc

.PHONY: doc docs
doc docs: man
	@true

.PHONY: man
man: $(BAM_MANPAGES)
	@true

ifneq (.,$(CURRENT_DIR))
clean: $(CURRENT_DIR)/clean
endif

.PHONY: $(CURRENT_DIR)/clean
$(CURRENT_DIR)/clean:
	@rm -rf $(TOP_LEVEL_DIR)/man

$(TOP_LEVEL_DIR)/man/man1:
	@mkdir -p $@

$(PANDOC_MAN_TEMPLATE_FILE): $(TOP_LEVEL_DIR)/libexec/bam-version $(CURRENT_DIR)/rules.mk
	@pandoc -D man | sed "s/\\\$$footer\\\$$/Bam $$($<)/g" > $@

$(TOP_LEVEL_DIR)/man/man1/%.1.gz: $(CURRENT_DIR)/%.1.md $(PANDOC_MAN_TEMPLATE_FILE) $(CURRENT_DIR)/rules.mk | $(TOP_LEVEL_DIR)/man/man1
	@echo "Generating man page for $(*F)"
	@sed -e 's|\@prefix\@|$(shell echo $(PREFIX) | sed -r 's/([\\@\s])/\\\1/g')|g' $< | pandoc -f markdown -t man -s --template $(PANDOC_MAN_TEMPLATE_FILE) | gzip > $@

include $(TOP_LEVEL_DIR)/footer.mk

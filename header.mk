include $(TOP_LEVEL_DIR)/prefix.mk

SP := $(SP).x
DIRSTACK_$(SP) := $(CURRENT_DIR)
CURRENT_DIR := $(DIR)

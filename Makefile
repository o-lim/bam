TOP_LEVEL_DIR := .
CURRENT_DIR := .

DIR := $(CURRENT_DIR)
include $(DIR)/rules.mk

DIR := $(CURRENT_DIR)/tests
include $(DIR)/rules.mk

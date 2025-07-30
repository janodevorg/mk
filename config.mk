# ===========================================
# Common Configuration
# ===========================================

# This is imported by xcode.mk, package.mk

# Default simulator configuration
SIMULATOR       ?= iPhone 16
SIMULATOR_OS    ?= 18.5

# Result bundle for tests
RESULT_BUNDLE   ?= TestRun.xcresult

# ANSI colors for nice logs
BLUE    = \033[34m
GREEN   = \033[32m
RED     = \033[31m
RESET   = \033[0m

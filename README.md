# mk

Makefile imports to build Swift packages.

## Usage

From a parallel folder create a Makefile like these below.

For a Package:
```
PROJECT_NAME := $(notdir $(shell pwd))
MK_DIR := ../mk
ifeq ($(wildcard $(MK_DIR)),)
    $(error Missing Makefiles. Clone to parent folder with: 'git clone git@github.com:janodev/mk.git ../mk')
endif
include $(MK_DIR)/package.mk
```

Package producing an executable:
```
PROJECT_NAME := $(notdir $(shell pwd))
MK_DIR := ../mk
ifeq ($(wildcard $(MK_DIR)),)
    $(error Missing Makefiles. Clone to parent folder with: 'git clone git@github.com:janodev/mk.git ../mk')
endif
include $(MK_DIR)/package.mk
include $(MK_DIR)/tool.mk
```

## Help

Run `make help` from the parallel folder.

```
AVAILABLE COMMANDS:
  make build                 Build the project with Swift Package Manager
  make build-and-test        Build the project and run all tests
  make chunks-clean          Clean the chunks output directory
  make chunks-generate       Generate chunks from source files in SOURCE_DIR
  make clean                 Clean build artifacts and cached files
  make coverage              Generate and display code coverage summary
  make coverage-file         Show coverage for a specific file (usage: make coverage-file FILE=path/to/File.swift)
  make coverage-html         Generate HTML coverage report and open in browser
  make coverage-lcov         Generate LCOV file at coverage/coverage.lcov
  make docs-build            Generate DocC documentation archive to .docc-build/
  make docs-clean            Clean and regenerate documentation preview
  make docs-deploy           Deploy documentation to GitHub Pages
  make docs-preview          Serve documentation locally in a web browser
  make docs-render           Build HTML docs ready to be hosted
  make help                  Show this help message
  make list-simulators       List available iOS simulators
  make results-brief         Build tests and print brief pass/fail statistics
  make results-bundle        Build tests and save results to TestRun.xcresult
  make results-file          Build tests and save a JSON summary to summary.json
  make results-summary       Build tests and print a JSON test summary
  make test                  Run all tests with code coverage enabled
  make test-file             Run tests for a specific file (usage: make test-file TEST_FILE=YourTestFileName)
  make test-method           Run a specific test method (usage: make test-method TEST_FILE=YourTestFileName METHOD=yourTestMethod)
  make tool-copy             Build and copy the tool to the current directory
  make tool-find             Locate the path to the built tool
  make tool-help             Build the tool and display its help information

```

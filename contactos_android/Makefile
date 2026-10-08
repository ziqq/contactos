SHELL :=/bin/bash -e -o pipefail
PWD   :=$(shell pwd)

# Prefer FVM when it is installed, otherwise use the SDK from PATH
# (for example, the one activated by mise).
FVM := $(shell command -v fvm 2>/dev/null)
ifeq ($(strip $(FVM)),)
DART    := dart
FLUTTER := flutter
else
DART    := fvm dart
FLUTTER := fvm flutter
endif

FORMAT_DIRS := $(wildcard lib test tool example/lib example/test example/screenshots)

.DEFAULT_GOAL := all
.PHONY: all
all: ## build pipeline
all: format check test-unit publish-check

.PHONY: ci
ci: ## CI build pipeline
ci: all

.PHONY: precommit
precommit: ## validate the branch before commit
precommit: all

.PHONY: help
help: ## Help dialog
				@echo 'Usage: make <OPTIONS>  <TARGETS>'
				@echo ''
				@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: doctor
doctor: ## Check flutter doctor
				@$(FLUTTER) doctor

.PHONY: version
version: ## Check flutter version
				@$(FLUTTER) --version

.PHONY: format
format: ## Format code
				@$(DART) format -l 80 $(FORMAT_DIRS) || (echo "¯\_(ツ)_/¯ Format code error"; exit 1)

.PHONY: format-check
format-check: ## Check formatting without changing files
				@$(DART) format -l 80 --set-exit-if-changed -o none $(FORMAT_DIRS) || (echo "¯\_(ツ)_/¯ Format check error"; exit 1)

.PHONY: fix
fix: format ## Fix code
				@$(DART) fix --apply lib

.PHONY: clean-cache
clean-cache: ## Clean the pub cache
				@$(FLUTTER) pub cache repair

.PHONY: clean
clean: ## Clean flutter
				@$(FLUTTER) clean

.PHONY: get
get: ## Get dependencies
				@$(FLUTTER) pub get || (echo "¯\_(ツ)_/¯ Get contactos_android dependencies error"; exit 1)

.PHONY: analyze
analyze: get format ## Analyze code
				@$(DART) analyze --fatal-infos --fatal-warnings || (echo "¯\_(ツ)_/¯ Analyze code error"; exit 1)

.PHONY: check
check: analyze ## Check the code
				@$(DART) pub global deactivate pana > /dev/null 2>&1 || true
				@$(DART) pub global activate pana
				@$(DART) pub global run pana --json > log.pana.json || (echo "¯\_(ツ)_/¯ Pana analysis error"; exit 1)

.PHONY: publish-check
publish-check: check ## Check the code before publish
				@$(DART) pub publish --dry-run || (echo "¯\_(ツ)_/¯ Publish check error"; exit 1)

.PHONY: publish
publish: ## Publish package
				@$(DART) pub publish --server=https://pub.dartlang.org || (echo "¯\_(ツ)_/¯ Publish error"; exit 1)

.PHONY: coverage
coverage: ## Runs get coverage
				@lcov --summary coverage/lcov.info

.PHONY: run-genhtml
run-genhtml: ## Runs generage coverage html
				@genhtml coverage/lcov.info -o coverage/html

.PHONY: test-unit
test-unit: ## Runs unit tests
				@$(FLUTTER) test --coverage test/contactos_android_test.dart || (echo "¯\_(ツ)_/¯ Error while running test-unit"; exit 1)
				@genhtml coverage/lcov.info --output=coverage -o coverage/html || (echo "¯\_(ツ)_/¯ Error while running genhtml with coverage"; exit 2)

.PHONY: test-android-native
test-android-native: ## Run Android JVM tests and generate JaCoCo coverage
				@cd example && $(FLUTTER) pub get
				@cd example && $(FLUTTER) build apk --debug --config-only --no-pub
				@cd example/android && ./gradlew :contactos_android:nativeCoverage --console=plain

.PHONY: tag
tag: ## Add a tag to the current commit
	@$(DART) run tool/tag.dart

.PHONY: tag-add
tag-add: ## Add TAG. E.g: make tag-add TAG=v1.0.0
				@if [ -z "$(TAG)" ]; then echo "¯\_(ツ)_/¯ TAG is not set"; exit 1; fi
				@echo ""
				@echo "START ADDING TAG: $(TAG)"
				@echo ""
				@git tag $(TAG)
				@git push origin $(TAG)
				@echo ""
				@echo "CREATED AND PUSHED TAG $(TAG)"
				@echo ""

.PHONY: tag-remove
tag-remove: ## Delete TAG. E.g: make tag-delete TAG=v1.0.0
				@if [ -z "$(TAG)" ]; then echo "¯\_(ツ)_/¯ TAG is not set"; exit 1; fi
				@echo ""
				@echo "START REMOVING TAG: $(TAG)"
				@echo ""
				@git tag -d $(TAG)
				@git push origin --delete $(TAG)
				@echo ""
				@echo "DELETED TAG $(TAG) LOCALLY AND REMOTELY"
				@echo ""

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

# All packages in dependency order
PACKAGES := contactos_platform_interface contactos_android contactos_foundation contactos

.DEFAULT_GOAL := all
.PHONY: all
all: ## Full pipeline: format + check + test-unit
all: format check test-unit

.PHONY: ci
ci: ## CI build pipeline
ci: all

.PHONY: precommit
precommit: ## Validate the branch before commit
precommit: all

.PHONY: help
help: ## Help dialog
				@echo 'Usage: make <OPTIONS> <TARGETS>'
				@echo ''
				@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: doctor
doctor: ## Check flutter doctor
				@$(FLUTTER) doctor

.PHONY: version
version: ## Check flutter version
				@$(FLUTTER) --version

.PHONY: format
format: ## Format all packages
				@for pkg in $(PACKAGES); do \
					echo "Formatting $$pkg..."; \
					$(MAKE) -s -C $(PWD)/$$pkg format || (echo "¯\_(ツ)_/¯ Format $$pkg error"; exit 1); \
				done

.PHONY: format-check
format-check: ## Check formatting of all packages without changing files
				@for pkg in $(PACKAGES); do \
					echo "Checking format of $$pkg..."; \
					$(MAKE) -s -C $(PWD)/$$pkg format-check || (echo "¯\_(ツ)_/¯ Format check $$pkg error"; exit 1); \
				done

.PHONY: fix
fix: ## Fix all packages
				@for pkg in $(PACKAGES); do \
					echo "Fixing $$pkg..."; \
					cd $(PWD)/$$pkg && $(DART) fix --apply lib || (echo "¯\_(ツ)_/¯ Fix $$pkg error"; exit 1); \
				done

.PHONY: clean-cache
clean-cache: ## Clean the pub cache
				@$(FLUTTER) pub cache repair

.PHONY: clean
clean: ## Clean all packages
				@for pkg in $(PACKAGES); do \
					echo "Cleaning $$pkg..."; \
					cd $(PWD)/$$pkg && $(FLUTTER) clean || true; \
				done

.PHONY: get
get: ## Get dependencies for all packages
				@for pkg in $(PACKAGES); do \
					echo "Getting dependencies for $$pkg..."; \
					cd $(PWD)/$$pkg && $(FLUTTER) pub get || (echo "¯\_(ツ)_/¯ Get $$pkg dependencies error"; exit 1); \
				done

.PHONY: analyze
analyze: get ## Analyze all packages
				@for pkg in $(PACKAGES); do \
					echo "Analyzing $$pkg..."; \
					cd $(PWD)/$$pkg && $(DART) analyze --fatal-infos --fatal-warnings || (echo "¯\_(ツ)_/¯ Analyze $$pkg error"; exit 1); \
				done

.PHONY: check
check: analyze ## Analyze + pana for all packages
				@$(DART) pub global deactivate pana > /dev/null 2>&1 || true
				@$(DART) pub global activate pana
				@for pkg in $(PACKAGES); do \
					echo "Running pana for $$pkg..."; \
					cd $(PWD)/$$pkg && $(DART) pub global run pana --json > log.pana.json || (echo "¯\_(ツ)_/¯ Pana $$pkg error"; exit 1); \
				done

.PHONY: publish-check
publish-check: ## Dry-run publish for all packages
				@for pkg in $(PACKAGES); do \
					echo "Publish check $$pkg..."; \
					cd $(PWD)/$$pkg && $(DART) pub publish --dry-run || (echo "¯\_(ツ)_/¯ Publish check $$pkg error"; exit 1); \
				done

.PHONY: test-unit
test-unit: ## Run unit tests for all packages
				@for pkg in $(PACKAGES); do \
					echo "Testing $$pkg..."; \
					cd $(PWD)/$$pkg && $(FLUTTER) test --coverage || (echo "¯\_(ツ)_/¯ Test $$pkg error"; exit 1); \
				done

.PHONY: screenshots
screenshots: ## Regenerate README and pub.dev screenshots of the example app
				@$(MAKE) -s -C $(PWD)/contactos screenshots

.PHONY: record-ios
record-ios: ## Record the booted iOS Simulator until Ctrl+C. E.g: make record-ios OUT=build/media/ios.mov
				@bash tool/media/record_ios.sh $(OUT)

.PHONY: record-android
record-android: ## Record the connected Android device until Ctrl+C. E.g: make record-android OUT=build/media/android.mp4
				@bash tool/media/record_android.sh $(OUT)

.PHONY: media
media: ## Convert a recording to README mp4/webp/gif. E.g: make media IN=build/media/ios.mov NAME=example
				@if [ -z "$(IN)" ]; then echo "¯\_(ツ)_/¯ IN is not set"; exit 1; fi
				@bash tool/media/convert.sh $(IN) .github/images $(or $(NAME),example)

.PHONY: tag
tag: ## Tag the current commit for a package release. E.g: make tag PKG=contactos_android
				@if [ -z "$(PKG)" ]; then echo "¯\_(ツ)_/¯ PKG is not set"; exit 1; fi
				@$(MAKE) -s -C $(PWD)/$(PKG) tag

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
tag-remove: ## Delete TAG. E.g: make tag-remove TAG=v1.0.0
				@if [ -z "$(TAG)" ]; then echo "¯\_(ツ)_/¯ TAG is not set"; exit 1; fi
				@echo ""
				@echo "START REMOVING TAG: $(TAG)"
				@echo ""
				@git tag -d $(TAG)
				@git push origin --delete $(TAG)
				@echo ""
				@echo "DELETED TAG $(TAG) LOCALLY AND REMOTELY"
				@echo ""

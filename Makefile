SHELL :=/bin/bash -e -o pipefail
PWD   :=$(shell pwd)

.DEFAULT_GOAL := all
.PHONY: all
all: ## build pipeline
all: format check test-unit

.PHONY: ci
ci: ## CI build pipeline
ci: all

.PHONY: precommit
precommit: ## validate the branch before commit
precommit: all

.PHONY: help
help: ## Help dialog
				@echo 'Usage: make <OPTIONS> ... <TARGETS>'
				@echo ''
				@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: doctor
doctor: ## Check flutter doctor
				@fvm flutter doctor

.PHONY: version
version: ## Check flutter version
				@fvm flutter --version

.PHONY: format
format: ## Format code
				@echo "╠ RUN FORMAT THE CODE"
				@fvm dart format -l 80 lib test || (echo "¯\_(ツ)_/¯ Format code error"; exit 1)
				@echo "╠ CODE FORMATED SUCCESSFULLY"

.PHONY: fix
fix: format ## Fix code
				@fvm dart fix --apply lib

.PHONY: clean-cache
clean-cache: ## Clean the pub cache
				@echo "╠ CLEAN PUB CACHE"
				@fvm flutter pub cache repair
				@echo "╠ PUB CACHE CLEANED SUCCESSFULLY"

.PHONY: clean
clean: ## Clean flutter
				@echo "╠ RUN FLUTTER CLEAN"
				@fvm flutter clean
				@echo "╠ FLUTTER CLEANED SUCCESSFULLY"

.PHONY: get
get: ## Get dependencies
				@echo "╠ RUN GET DEPENDENCIES..."
				@fvm flutter pub get || (echo "¯\_(ツ)_/¯ Get dependencies error"; exit 1)
				@echo "╠ DEPENDENCIES GETED SUCCESSFULLY"

.PHONY: analyze
analyze: get format ## Analyze code
				@echo "╠ RUN ANALYZE THE CODE..."
				@fvm dart analyze --fatal-infos --fatal-warnings
				@echo "╠ ANALYZED CODE SUCCESSFULLY"

.PHONY: check
check: analyze publish-check ## Check the code
	@dart pub global activate pana
	@pana --json --no-warning --line-length 120 > log.pana.json

.PHONY: publish
publish: ## Publish package
				@echo "╠ RUN PUBLISHING..."
				@fvm dart pub publish --server=https://pub.dartlang.org || (echo "¯\_(ツ)_/¯ Publish error"; exit 1)
				@echo "╠ PUBLISH PACKAGE SUCCESSFULLY"

.PHONY: coverage
coverage: ## Runs get coverage
				@lcov --summary coverage/lcov.info

.PHONY: run-genhtml
run-genhtml: ## Runs generage coverage html
				@genhtml coverage/lcov.info -o coverage/html

.PHONY: test-unit
test-unit: ## Runs unit tests
				@echo "╠ RUNNING UNIT TESTS..."
				@fvm flutter test --coverage || (echo "¯\_(ツ)_/¯ Error while running test-unit"; exit 1)
				@genhtml coverage/lcov.info --output=coverage -o coverage/html || (echo "¯\_(ツ)_/¯ Error while running genhtml with coverage"; exit 2)
				@echo "╠ UNIT TESTS SUCCESSFULLY"

.PHONY: tag
tag: ## Add a tag to the current commit
	@dart run tool/tag.dart

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

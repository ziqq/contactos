SHELL :=/bin/bash -e -o pipefail
PWD   :=$(shell pwd)

.PHONY: help
help: ## Help dialog
				@echo 'Usage: make <OPTIONS>  <TARGETS>'
				@echo ''
				@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: format
format: ## Format code
				@fvm dart format -l 80 lib test || (echo "¯\_(ツ)_/¯ Format code error"; exit 1)

.PHONY: fix
fix: format ## Fix code
				@fvm dart fix --apply lib

.PHONY: get
get: ## Get dependencies
				@fvm flutter pub get || (echo "¯\_(ツ)_/¯ Get dependencies error"; exit 1)

.PHONY: analyze
analyze: get format ## Analyze code
				@fvm dart analyze --fatal-infos --fatal-warnings

.PHONY: check
check: analyze ## Check the code
				@dart pub global activate pana
				@pana --json --no-warning --line-length 80 > log.pana.json
				@dart pub publish --dry-run

.PHONY: coverage
coverage: ## Runs get coverage
				@lcov --summary coverage/lcov.info

.PHONY: run-genhtml
run-genhtml: ## Runs generage coverage html
				@genhtml coverage/lcov.info -o coverage/html

.PHONY: test-unit
test-unit: ## Runs unit tests
				@flutter test --coverage || (echo "¯\_(ツ)_/¯ Error while running test-unit"; exit 1)
				@genhtml coverage/lcov.info --output=coverage -o coverage/html || (echo "¯\_(ツ)_/¯ Error while running genhtml with coverage"; exit 2)
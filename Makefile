TARGET_DIR ?= $(PWD)/hello-world
CARGO ?= cargo

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
.DEFAULT_GOAL := help

.PHONY: install-deps
install-deps: ## install dependencies
	$(CARGO) install \
		cargo-edit
	rustup component add \
		rustfmt \
		clippy \
		rls \
		rust-analysis \
		rust-src

.PHONY: format
format: ## format codes
	$(CARGO) fmt --all

.PHONY: format-check
format-check: ## check format
	$(CARGO) fmt --all --check

.PHONY: lint
lint: ## lint codes
	$(CARGO) fmt --all -- --check --verbose
	$(CARGO) clippy -- -D warnings --verbose

.PHONY: build
build: ## build an app
	$(CARGO) build --verbose

.PHONY: test
test: ## run tests
	$(CARGO) test --release --all-features --verbose

.PHONY: docs
docs: ## generate docs
	$(CARGO) doc

.PHONY: run
run: ## run an app
	$(CARGO) run --verbose -- --name test

.PHONY: _ci-test-base
_ci-test-base: install-deps format-check lint build test docs run ## ci test base

.PHONY: ci-test
ci-test: ## ci test
	for target_dir in . ; do \
		make _ci-test-base TARGET_DIR=$$target_dir ; \
	done

.PHONY: publish
publish: ## upload a package to the registry
	$(CARGO) publish \
		--manifest-path=$(CARGO_TOML) \
		--verbose

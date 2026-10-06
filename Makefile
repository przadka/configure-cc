SHELL := /bin/bash

# The gate the global pre-commit hook and CI both run.
.PHONY: check
check:
	@bash test/smoke-test.sh

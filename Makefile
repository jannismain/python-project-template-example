.PHONY: init
init:
	rm -f context
	git init -b main || echo 'Error during initialisation of git repository.'
	git remote add origin git@git01.iis.fhg.de:mkj/sample-project.git || echo 'Error when trying to add remote to git repository.'
	pre-commit install || echo 'Error during installation of pre-commit hooks. Is pre-commit installed?'

.PHONY: install-dev
install-dev:	## install project including all development dependencies
	pip install -e .[test,doc,dev]

.PHONY: maintainability
maintainability:  ## run maintainability checks
	@radon cc --total-average -nB -s src

.PHONY: coverage coverage-ci
coverage:	## collect coverage data and open report in browser
	@pytest --doctest-modules --cov --cov-config=pyproject.toml --cov-branch --cov-report term --cov-report html:build/coverage
	@test -z "$(CI)" \
		&& ( echo "Opening 'build/coverage/index.html'..."; open build/coverage/index.html )\
		|| echo ""
coverage-ci:
	@CI=true $(MAKE) coverage

.PHONY: lint
lint:	## run static code checks
	@ruff src tests


DOCS_TARGET?=build/docs
MKDOCS_BIN?=mkdocs

.PHONY: docs docs-live
docs:	## build documentation
	${MKDOCS_BIN} build --site-dir ${DOCS_TARGET}/html
docs-live:	## serve documentation
	mkdocs serve


# a nice way to document Makefiles, found here: https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

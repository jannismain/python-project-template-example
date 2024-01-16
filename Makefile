.PHONY: install-dev
install-dev:	## install project including all development dependencies
	pip install -e .[test,dev]
	pip install -r docs/requirements.txt

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

.PHONY: docs docs-live
DOCS_TARGET?=build/docs
MKDOCS_BIN?=mkdocs
docs:	## build documentation
	${MKDOCS_BIN} build --site-dir ${DOCS_TARGET}/html
docs-live:	## serve documentation
	mkdocs serve

.PHONY: cspell-install
cspell-install: ## install cspell (npm required!)
	@cspell --version || npm install -g --no-fund cspell

.PHONY: cspell cspell-dump
CSPELL_ARGS=--show-suggestions --show-context --unique
CSPELL_FILES="**/*.*"
DICT_FILE=project-terms.txt
cspell: ## check spelling using cspell
	cspell ${CSPELL_ARGS} ${CSPELL_FILES}
cspell-dump: ## save all flagged words to project terms dictionary
	cspell ${CSPELL_ARGS} ${CSPELL_FILES} --words-only >> ${DICT_FILE}
	sort --ignore-case --output=${DICT_FILE} ${DICT_FILE}

.PHONY: help
# a nice way to document Makefiles, found here: https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

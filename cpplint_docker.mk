
ifeq ($(filter cpplint_docker.mk, $(notdir $(MAKEFILE_LIST))), cpplint_docker.mk)

CPPLINT_DOCKER_MAKEFILE_PATH:=$(strip $(shell realpath "$(shell dirname "$(lastword $(MAKEFILE_LIST))")"))

.PHONY: lintfix 
lintfix: ## Attempts to fix linting errors using clang-format on the provided source directory
	cd "${CPPLINT_DOCKER_MAKEFILE_PATH}" && \
    make _lintfix

.PHONY: lintfix_simulate
lintfix_simulate:
	cd "${CPPLINT_DOCKER_MAKEFILE_PATH}" && \
    make _lintfix_simulate

.PHONY: lint
lint: ## lint provided source directory call with: make lint CPP_PROJECT_DIRECTORY=/absolute/path/to/source
	cd "${CPPLINT_DOCKER_MAKEFILE_PATH}" && \
    make _lint

endif

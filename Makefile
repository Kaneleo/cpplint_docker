SHELL:=/bin/bash

.DEFAULT_GOAL := all

PROJECT="cpplint"
VERSION="latest"
TAG="${PROJECT}:${VERSION}"

ROOT_DIR:=$(shell dirname "$(realpath $(firstword $(MAKEFILE_LIST)))")
MAKEFLAGS += --no-print-directory
include ${ROOT_DIR}/cpplint_docker.mk

.EXPORT_ALL_VARIABLES:
DOCKER_BUILDKIT?=1
DOCKER_CONFIG?=


#LINTFIX_COMMAND=find -regex '.*\.\(cpp\|hpp\|cc\|cxx\)\' -exec clang-format -style=.clang-format-google -i {} \;
#LINTFIX_COMMAND="find ."
FIND_COMMAND=find . -regex ".*\.\(cpp\|h\|cc\|cxx\|hpp\)" -not -path "*/build/*"
LINTFIX_COMMAND=${FIND_COMMAND} | xargs clang-format -style=file -i
LINTFIX_SIMULATE_COMMAND=${FIND_COMMAND}

.PHONY: help
help:
	@awk 'BEGIN {FS = ":.*##"; printf "Usage: make \033[36m<target>\033[0m CPP_PROJECT_DIRECTORY=<absolute path to cpp source directory>\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

.PHONY: all
all: build

.PHONY: clean
clean:
	docker rm $$(docker ps -a -q --filter "ancestor=${TAG}") 2> /dev/null || true
	docker rmi $$(docker images -q ${TAG}) --force 2> /dev/null || true
	docker rmi ${TAG} --force 2> /dev/null

.PHONY: build
build: clean ## Build the cpplint docker image, happens automatically on make lint call
	cd "${CPPLINT_DOCKER_MAKEFILE_PATH}" && docker build --network host -t ${TAG} -f Dockerfile.cpplint .

.PHONY: build_fast
build_fast: # Build docker context only if it does not already exist
	@[ ! -n "$$(docker images -q ${TAG})" ] && make build || true

.PHONY: check_CPP_PROJECT_DIRECTORY
check_CPP_PROJECT_DIRECTORY:
	@[ "${CPP_PROJECT_DIRECTORY}" ] || ( echo "CPP_PROJECT_DIRECTORY is not set. You must provide a project directory. make <target> CPP_PROJECT_DIRECTORY=<absolute path to cpp source code>"; exit 1 )

.PHONY: lint
_lint: check_CPP_PROJECT_DIRECTORY build_fast
	docker run -v "${CPP_PROJECT_DIRECTORY}:/tmp/cpp_source_directory" ${TAG} |& \
    tee "${CPP_PROJECT_DIRECTORY}/lint_report.log"; EXIT_CODE=$$PIPESTATUS; \
    BASE_DIR=$$(basename "${CPP_PROJECT_DIRECTORY}") && \
    mv "${CPP_PROJECT_DIRECTORY}/lint_report.log" "${CPP_PROJECT_DIRECTORY}/$${BASE_DIR}_lint_report.log" && \
    exit $$EXIT_CODE

.PHONY: lintfix
_lintfix: build_check check_CPP_PROJECT_DIRECTORY
	@echo "Running clang-format on: ${CPP_PROJECT_DIRECTORY}"
	docker run --entrypoint "" -v "${CPP_PROJECT_DIRECTORY}:${CPP_PROJECT_DIRECTORY}" ${TAG} /bin/bash -c 'cd "${CPP_PROJECT_DIRECTORY}" && ${LINTFIX_COMMAND}'

.PHONY: lintfix_simulate
_lintfix_simulate: build_check check_CPP_PROJECT_DIRECTORY
	@echo "Running clang-format on: ${CPP_PROJECT_DIRECTORY}"
	@docker run --entrypoint "" -v "${CPP_PROJECT_DIRECTORY}:${CPP_PROJECT_DIRECTORY}" ${TAG} /bin/bash -c 'cd "${CPP_PROJECT_DIRECTORY}" && ${LINTFIX_SIMULATE_COMMAND}'

.PHONY: cpplint_demo
lint_demo: ## Show a demo with provided hello_world project
	make lint CPP_PROJECT_DIRECTORY="$$(realpath "${CPPLINT_DOCKER_MAKEFILE_PATH}/hello_world")"

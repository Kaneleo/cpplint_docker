SHELL:=/bin/bash

.DEFAULT_GOAL := all

PROJECT="cpplint"
VERSION="latest"
TAG="${PROJECT}:${VERSION}"

ROOT_DIR:=$(shell dirname "$(realpath $(firstword $(MAKEFILE_LIST)))")
MAKEFLAGS += --no-print-directory
.EXPORT_ALL_VARIABLES:
DOCKER_BUILDKIT?=1
DOCKER_CONFIG?=


#LINTFIX_COMMAND=find -regex '.*\.\(cpp\|hpp\|cc\|cxx\)\' -exec clang-format -style=.clang-format-google -i {} \;
#LINTFIX_COMMAND="find ."
FIND_COMMAND=find . -regex ".*\.\(cpp\|h\|cc\|cxx\|hpp\)" -not -path "*/build/*"
LINTFIX_COMMAND=${FIND_COMMAND} | xargs clang-format -style=file -i
LINTFIX_SIMULATE_COMMAND=${FIND_COMMAND} && pwd && ls -la

.PHONY: help
help:
	@awk 'BEGIN {FS = ":.*##"; printf "Usage: make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

.PHONY: all
all: build

.PHONY: clean
clean:
	docker rm $$(docker ps -a -q --filter "ancestor=${TAG}") 2> /dev/null || true
	docker rmi $$(docker images -q ${TAG}) 2> /dev/null || true
	docker rmi ${TAG} --force 2> /dev/null

.PHONY: build
build: clean ## build the cpplint docker image
	docker build -t "cpplint:latest" -f Dockerfile.cpplint .

.PHONY: build_check
build_check:
	@[ -n "$$(docker images -q ${TAG} 2> /dev/null)" ] && \
          echo "" || \
          make build

.PHONY: check_CPP_PROJECT_DIRECTORY
check_CPP_PROJECT_DIRECTORY:
	@[ "${CPP_PROJECT_DIRECTORY}" ] || ( echo "CPP_PROJECT_DIRECTORY is not set. You must provide a project directory. make <target> CPP_PROJECT_DIRECTORY=<absolute path to cpp source code>"; exit 1 )

.PHONY: lint
lint: build_check ## lint provided source directory call with: make cpplint CPP_PROJECT_DIRECTORY=/absolute/path/to/source
	docker run -v "${CPP_PROJECT_DIRECTORY}:/home/cpplint/$$(basename ${CPP_PROJECT_DIRECTORY})" cpplint:latest

.PHONY: lintfix
lintfix: build_check check_CPP_PROJECT_DIRECTORY ## Attempts to fix linting errors using clang-format on the provided source directory
	@echo "Running clang-format on: ${CPP_PROJECT_DIRECTORY}"
	docker run --entrypoint "" -v "${CPP_PROJECT_DIRECTORY}:${CPP_PROJECT_DIRECTORY}" cpplint:latest /bin/bash -c 'cd "${CPP_PROJECT_DIRECTORY}" && ${LINTFIX_COMMAND}'

.PHONY: lintfix_simulate
lintfix_simulate: build_check check_CPP_PROJECT_DIRECTORY
	@echo "Running clang-format on: ${CPP_PROJECT_DIRECTORY}"
	@docker run --entrypoint "" -v "${CPP_PROJECT_DIRECTORY}:${CPP_PROJECT_DIRECTORY}" cpplint:latest /bin/bash -c 'cd "${CPP_PROJECT_DIRECTORY}" && ${LINTFIX_SIMULATE_COMMAND}'


ifndef cpplint_docker

cpplint_docker:=""

.PHONY: lintfix 
lintfix: ## Automated lint fixing of sumo_if_ros source code using clang-format
	cd cpplint_docker && \
    make lintfix CPP_PROJECT_DIRECTORY=$(realpath ${ROOT_DIR}/${PROJECT})

.PHONY: lintfix_simulate
lintfix_simulate:
	cd cpplint_docker && \
    make lintfix_simulate CPP_PROJECT_DIRECTORY=$(realpath ${ROOT_DIR}/${PROJECT})

.PHONY: lint
lint: ## Print out lint report to console
	find . -name "**lint_report.log" -exec rm -rf {} \;
	cd cpplint_docker && \
    make lint CPP_PROJECT_DIRECTORY=$$(realpath ${ROOT_DIR}/${PROJECT}) | \
	tee ${ROOT_DIR}/${PROJECT}/${PROJECT}_lint_report.log; exit $$PIPESTATUS

endif

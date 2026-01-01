SHELL := /bin/bash
.DEFAULT_GOAL := help

help:
	@echo "Targets:"
	@echo "  make gen            - Generate Go+Java for ALL services (recommended)"
	@echo "  make gen-changed    - Generate for locally changed services"
	@echo ""
	@echo "Tip: commit gen/ with your proto changes."

gen:
	@services="$$(./scripts/list_services.sh)"; \
	if [[ -z "$$services" ]]; then echo "No services found under proto/services"; exit 0; fi; \
	for s in $$services; do \
	  echo "GEN $$s"; \
	  ./scripts/gen_go.sh "$$s"; \
	  ./scripts/gen_java.sh "$$s"; \
	done

gen-changed:
	@files="$$(git diff --name-only HEAD || true)"; \
	services="$$(echo "$$files" | awk -F'/' '$$1=="proto" && $$2=="services"{print $$3} $$1=="gen" && $$3=="apis" && $$4=="v1"{print $$5}' | sort -u)"; \
	if [[ -z "$$services" ]]; then echo "No local changes detected. Running gen for ALL."; $(MAKE) gen; exit 0; fi; \
	for s in $$services; do \
	  echo "GEN $$s"; \
	  ./scripts/gen_go.sh "$$s"; \
	  ./scripts/gen_java.sh "$$s"; \
	done

SHELL := /bin/bash
.DEFAULT_GOAL := help

.PHONY: help docker-build docker-shell gen publish publish-all

DOCKER_COMPOSE := docker compose -f docker/docker-compose.yml
RUN_IDL := $(DOCKER_COMPOSE) run --rm idl

help:
	@echo "Targets (Docker-only):"
	@echo "  make docker-build   - Build the dev image"
	@echo "  make gen            - Generate Go+Java for all services (inside Docker)"
	@echo "  make publish        - Publish changed services (inside Docker)"
	@echo "  make publish-all    - Publish all services (inside Docker)"
	@echo "  make docker-shell   - Open a bash shell in the container"

docker-build:
	@$(DOCKER_COMPOSE) build

docker-shell:
	@$(RUN_IDL) bash

# ===== Developer commands (run inside Docker) =====
gen:
	@$(RUN_IDL) bash -lc "chmod +x scripts/*.sh && ./scripts/gen_go.sh && ./scripts/gen_java.sh"

# ===== CI command (run inside Docker) =====
publish:
	@$(RUN_IDL) bash -lc "chmod +x scripts/*.sh && ./scripts/publish.sh"

publish-all:
	@$(RUN_IDL) bash -lc "chmod +x scripts/*.sh && ./scripts/publish.sh --all"

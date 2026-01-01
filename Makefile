SHELL := /bin/bash
.DEFAULT_GOAL := help

.PHONY: help docker-build docker-shell gen gen-changed release

DOCKER_COMPOSE := docker compose -f docker/docker-compose.yml
RUN_IDL := $(DOCKER_COMPOSE) run --rm idl

help:
	@echo "Targets (Docker-only):"
	@echo "  make docker-build   - Build the dev image"
	@echo "  make gen            - Generate Go+Java (inside Docker)"
	@echo "  make gen-changed    - Generate only changed services (inside Docker)"
	@echo "  make release        - CI release (tag + publish) (inside Docker)"
	@echo "  make docker-shell   - Open a bash shell in the container"

docker-build:
	@$(DOCKER_COMPOSE) build

docker-shell:
	@$(RUN_IDL) bash

# ===== Developer commands (run inside Docker) =====
gen:
	@$(RUN_IDL) bash -lc "chmod +x scripts/*.sh && ./scripts/make_gen_all.sh"

gen-changed:
	@$(RUN_IDL) bash -lc "chmod +x scripts/*.sh && ./scripts/make_gen_changed.sh"

# ===== CI command (run inside Docker) =====
release:
	@$(RUN_IDL) bash -lc "chmod +x scripts/*.sh && ./scripts/ci_release.sh"

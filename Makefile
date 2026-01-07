SHELL := /bin/bash
.DEFAULT_GOAL := help

.PHONY: help docker-build  gen publish

DOCKER_COMPOSE := docker compose -f docker/docker-compose.yml
RUN_IDL_HELPER := $(DOCKER_COMPOSE) run --rm idl-helper

help:
	@echo "Targets (Docker-only):"
	@echo "  make docker-build   - Build the dev image"
	@echo "  make gen            - Generate Go+Java for all services (inside Docker)"
	@echo "  make publish        - Publish changed services (inside Docker)"

docker-build:
	@$(DOCKER_COMPOSE) build

gen:
	@$(RUN_IDL_HELPER) bash -lc "chmod +x scripts/*.sh && ./scripts/generate.sh"

publish:
	@$(DOCKER_COMPOSE) run --rm -e GITHUB_TOKEN=$(GITHUB_TOKEN) -e GITHUB_REPOSITORY=$(GITHUB_REPOSITORY) -e GITHUB_ACTOR=$(GITHUB_ACTOR) idl-helper bash -lc "chmod +x scripts/*.sh && ./scripts/publish_java.sh"
#!/usr/bin/env bash
set -euo pipefail

# Lint + Breaking check (optional but recommended for local)
buf lint
# buf breaking --against .git#branch=main  # main 기준 breaking 체크를 하고 싶으면 주석 해제

# Generate code into gen/* with verbose output
buf generate --debug

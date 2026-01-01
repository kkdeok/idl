#!/usr/bin/env bash
set -euo pipefail

SERVICE="${1:-}"
if [[ -z "${SERVICE}" ]]; then
  echo "Usage: $0 <service>" >&2
  exit 1
fi

# 없으면 빈 문자열
git tag --list "${SERVICE}-v*" --sort=-v:refname | head -n 1 || true

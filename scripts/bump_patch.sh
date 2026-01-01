#!/usr/bin/env bash
set -euo pipefail

VER="${1:-}"
if [[ -z "${VER}" ]]; then
  echo "0.0.1"
  exit 0
fi

IFS='.' read -r MA MI PA <<< "${VER}"
PA=$((PA + 1))
echo "${MA}.${MI}.${PA}"

#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SERV_DIR="${ROOT_DIR}/proto/services"

if [[ ! -d "${SERV_DIR}" ]]; then
  exit 0
fi

find "${SERV_DIR}" -maxdepth 1 -mindepth 1 -type d \
  | sed 's|.*/||' \
  | sort

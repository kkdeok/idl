#!/usr/bin/env bash
set -euo pipefail

BASE_SHA="${BASE_SHA:-}"
HEAD_SHA="${HEAD_SHA:-HEAD}"

if [[ -z "${BASE_SHA}" ]]; then
  echo "ERROR: BASE_SHA is required" >&2
  exit 1
fi

# GitHub 첫 push 등 before가 0000..일 때: 모든 서비스
if [[ "${BASE_SHA}" =~ ^0+$ ]]; then
  ./scripts/list_services.sh
  exit 0
fi

CHANGED="$(git diff --name-only "${BASE_SHA}" "${HEAD_SHA}" || true)"

# 허용 패턴:
# - proto/services/{svc}/...
# - gen/{lang}/apis/v1/{svc}/...
# svc는 3번째 토큰
echo "${CHANGED}" \
  | awk -F'/' '
      $1=="proto" && $2=="services" { print $3 }
      $1=="gen" && $3=="apis" && $4=="v1" { print $5 }
    ' \
  | sed '/^$$/d' \
  | sort -u

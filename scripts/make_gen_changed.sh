#!/usr/bin/env bash
set -euo pipefail

# 로컬에서 실행 시: working tree 기준 변경 감지
files="$(git diff --name-only HEAD || true)"
services="$(echo "${files}" | awk -F'/' '
  $1=="proto" && $2=="services" { print $3 }
  $1=="gen" && $3=="apis" && $4=="v1" { print $5 }
' | sed '/^$/d' | sort -u)"

if [[ -z "${services}" ]]; then
  echo "No local changes detected. Running gen for ALL."
  exec ./scripts/make_gen_all.sh
fi

for s in ${services}; do
  echo "GEN ${s}"
  ./scripts/gen_go.sh "${s}"
  ./scripts/gen_java.sh "${s}"
done

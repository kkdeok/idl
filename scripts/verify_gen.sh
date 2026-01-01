#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
  echo "ERROR: not inside a git repository (cwd=$(pwd))" >&2
  exit 1
}

SERVICES="${1:-}"
if [[ -z "${SERVICES}" ]]; then
  echo "ERROR: services list required" >&2
  exit 1
fi

for s in ${SERVICES}; do
  ./scripts/gen_go.sh "${s}"
  ./scripts/gen_java.sh "${s}"
done

git diff --exit-code || (echo "ERROR: gen output differs. Run make gen and commit gen/ before pushing." >&2; exit 1)

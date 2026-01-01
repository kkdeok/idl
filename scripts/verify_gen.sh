#!/usr/bin/env bash
set -euo pipefail

SERVICES="${1:-}"
if [[ -z "${SERVICES}" ]]; then
  echo "ERROR: services list required" >&2
  exit 1
fi

for s in ${SERVICES}; do
  ./scripts/gen_go.sh "${s}"
  ./scripts/gen_java.sh "${s}"
done

# gen이 커밋되어 있어야 하므로 diff가 있으면 실패
git diff --exit-code || (echo "ERROR: gen output differs. Run make gen and commit gen/ before pushing." >&2; exit 1)

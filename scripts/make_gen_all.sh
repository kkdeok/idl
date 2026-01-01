#!/usr/bin/env bash
set -euo pipefail

services="$(./scripts/list_services.sh)"
if [[ -z "${services}" ]]; then
  echo "No services found under proto/services"
  exit 0
fi

for s in ${services}; do
  echo "GEN ${s}"
  ./scripts/gen_go.sh "${s}"
  ./scripts/gen_java.sh "${s}"
done

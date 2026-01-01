#!/usr/bin/env bash
set -euo pipefail

SERVICE="${1:-}"
if [[ -z "${SERVICE}" ]]; then
  echo "Usage: $0 <service>" >&2
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROTO_ROOT="${ROOT_DIR}/proto"
SERVICE_PROTO_DIR="${PROTO_ROOT}/services/${SERVICE}"

if [[ ! -d "${SERVICE_PROTO_DIR}" ]]; then
  echo "ERROR: proto dir not found: ${SERVICE_PROTO_DIR}" >&2
  exit 1
fi

command -v protoc >/dev/null 2>&1 || { echo "ERROR: protoc not found"; exit 1; }
command -v protoc-gen-go >/dev/null 2>&1 || { echo "ERROR: protoc-gen-go not found"; exit 1; }
command -v protoc-gen-go-grpc >/dev/null 2>&1 || { echo "ERROR: protoc-gen-go-grpc not found"; exit 1; }

PROTO_FILES=()
while IFS= read -r -d '' f; do PROTO_FILES+=("$f"); done < <(
  find "${SERVICE_PROTO_DIR}" -maxdepth 1 -name '*.proto' -print0
)

if [[ "${#PROTO_FILES[@]}" -eq 0 ]]; then
  echo "ERROR: no .proto files found under ${SERVICE_PROTO_DIR}" >&2
  exit 1
fi

protoc \
  -I "${PROTO_ROOT}" \
  --go_out="${ROOT_DIR}" --go_opt=paths=import \
  --go-grpc_out="${ROOT_DIR}" --go-grpc_opt=paths=import \
  "${PROTO_FILES[@]}"

echo "OK: Go gen for ${SERVICE}"

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

GRPC_JAVA_PLUGIN="${GRPC_JAVA_PLUGIN:-}"
if [[ -z "${GRPC_JAVA_PLUGIN}" ]]; then
  if command -v protoc-gen-grpc-java >/dev/null 2>&1; then
    GRPC_JAVA_PLUGIN="$(command -v protoc-gen-grpc-java)"
  else
    echo "ERROR: GRPC_JAVA_PLUGIN is not set and protoc-gen-grpc-java not found in PATH" >&2
    exit 1
  fi
fi

OUT_DIR="${ROOT_DIR}/gen/java/apis/v1/${SERVICE}"
mkdir -p "${OUT_DIR}"

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
  --java_out="${OUT_DIR}" \
  --grpc-java_out="${OUT_DIR}" \
  --plugin=protoc-gen-grpc-java="${GRPC_JAVA_PLUGIN}" \
  "${PROTO_FILES[@]}"

echo "OK: Java gen for ${SERVICE}"

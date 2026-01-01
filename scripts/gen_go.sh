#!/usr/bin/env bash
set -euo pipefail

# proto 아래에 있는 모든 *.proto를 Go 언어에서 사용가능하도록 protoc 컴파일

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROTO_ROOT="${ROOT_DIR}/proto"
GEN_DIR="${ROOT_DIR}/gen"

command -v protoc >/dev/null 2>&1 || { echo "ERROR: protoc not found"; exit 1; }
command -v protoc-gen-go >/dev/null 2>&1 || { echo "ERROR: protoc-gen-go not found"; exit 1; }
command -v protoc-gen-go-grpc >/dev/null 2>&1 || { echo "ERROR: protoc-gen-go-grpc not found"; exit 1; }

# 전체 서비스 목록 가져오기
SERV_DIR="${PROTO_ROOT}/services"
if [[ ! -d "${SERV_DIR}" ]]; then
  echo "No services found in ${SERV_DIR}"
  exit 0
fi

SERVICES="$(find "${SERV_DIR}" -maxdepth 1 -mindepth 1 -type d \
  | sed 's|.*/||' \
  | sort)"

if [[ -z "${SERVICES}" ]]; then
  echo "No services found. Skip Go generation."
  exit 0
fi

echo "Compiling all services for Go generation: ${SERVICES}"

# 각 서비스별로 proto 파일 컴파일
for SERVICE in ${SERVICES}; do
  SERVICE_PROTO_DIR="${PROTO_ROOT}/services/${SERVICE}"
  
  if [[ ! -d "${SERVICE_PROTO_DIR}" ]]; then
    echo "WARNING: proto dir not found: ${SERVICE_PROTO_DIR}" >&2
    continue
  fi
  
  PROTO_FILES=()
  while IFS= read -r -d '' f; do PROTO_FILES+=("$f"); done < <(
    find "${SERVICE_PROTO_DIR}" -maxdepth 1 -name '*.proto' -print0
  )
  
  if [[ "${#PROTO_FILES[@]}" -eq 0 ]]; then
    echo "WARNING: no .proto files found under ${SERVICE_PROTO_DIR}" >&2
    continue
  fi
  
  echo "Generating Go code for ${SERVICE}..."
  protoc \
    -I "${PROTO_ROOT}" \
    --go_out="${ROOT_DIR}" --go_opt=paths=import \
    --go-grpc_out="${ROOT_DIR}" --go-grpc_opt=paths=import \
    "${PROTO_FILES[@]}"
  
  echo "OK: Go gen for ${SERVICE}"
done

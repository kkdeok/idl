#!/usr/bin/env bash
set -euo pipefail

# gen 디렉토리와 proto 디렉토리에서 변경된 SVC를 파악하는 스크립트
# 목적: 해당 SVC만 publish 하기 위함
# 실제 파일 변경 또는 이전 커밋과의 diff를 보고 판단
# 이전 커밋이 없다면 전체 SVC를 반환

BASE_SHA="${BASE_SHA:-}"
HEAD_SHA="${HEAD_SHA:-HEAD}"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROTO_ROOT="${ROOT_DIR}/proto"
GEN_DIR="${ROOT_DIR}/gen"

# 전체 서비스 목록 가져오기
list_all_services() {
  local SERV_DIR="${PROTO_ROOT}/services"
  if [[ ! -d "${SERV_DIR}" ]]; then
    return 0
  fi
  find "${SERV_DIR}" -maxdepth 1 -mindepth 1 -type d \
    | sed 's|.*/||' \
    | sort
}

# git repository인지 확인
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  # git repository가 아니면 전체 서비스 반환
  list_all_services
  exit 0
fi

# 이전 커밋이 있는지 확인
HAS_PREVIOUS_COMMIT=false
if [[ -n "${BASE_SHA}" ]]; then
  if git rev-parse --verify "${BASE_SHA}" >/dev/null 2>&1; then
    HAS_PREVIOUS_COMMIT=true
  fi
else
  # BASE_SHA가 없으면 HEAD의 부모 커밋 확인
  if git rev-parse HEAD^ >/dev/null 2>&1; then
    HAS_PREVIOUS_COMMIT=true
    BASE_SHA="HEAD^"
  fi
fi

# 이전 커밋이 없으면 전체 서비스 반환
if [[ "${HAS_PREVIOUS_COMMIT}" == "false" ]]; then
  echo "No previous commit found. Returning all services." >&2
  list_all_services
  exit 0
fi

# proto와 gen 디렉토리에서 변경된 파일 확인
CHANGED_PROTO=""
CHANGED_GEN=""

if [[ -z "${BASE_SHA}" ]]; then
  # HEAD와 working tree 비교
  CHANGED_PROTO="$(git diff --name-only HEAD -- "${PROTO_ROOT}" 2>&1 || true)"
  CHANGED_GEN="$(git diff --name-only HEAD -- "${GEN_DIR}" 2>&1 || true)"
else
  # BASE_SHA와 HEAD_SHA 비교
  CHANGED_PROTO="$(git diff --name-only "${BASE_SHA}" "${HEAD_SHA}" -- "${PROTO_ROOT}" 2>&1 || true)"
  CHANGED_GEN="$(git diff --name-only "${BASE_SHA}" "${HEAD_SHA}" -- "${GEN_DIR}" 2>&1 || true)"
fi

# proto 파일에서 변경된 서비스 추출
CHANGED_SERVICES_PROTO="$(echo "${CHANGED_PROTO}" \
  | awk -F'/' '
      $1=="proto" && $2=="services" { print $3 }
    ' \
  | sed '/^$/d' \
  | sort -u)"

# gen 디렉토리에서 변경된 서비스 추출
# 패턴: gen/{lang}/apis/v1/{svc}/...
CHANGED_SERVICES_GEN="$(echo "${CHANGED_GEN}" \
  | awk -F'/' '
      $1=="gen" && $3=="apis" && $4=="v1" { print $5 }
    ' \
  | sed '/^$/d' \
  | sort -u)"

# 두 결과를 합치고 중복 제거
{
  echo "${CHANGED_SERVICES_PROTO}"
  echo "${CHANGED_SERVICES_GEN}"
} | sed '/^$/d' | sort -u


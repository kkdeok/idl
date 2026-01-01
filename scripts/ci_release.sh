#!/usr/bin/env bash
set -euo pipefail

BASE_SHA="${BASE_SHA:-}"
HEAD_SHA="${HEAD_SHA:-}"
GITHUB_REPOSITORY="${GITHUB_REPOSITORY:-}"

if [[ -z "${BASE_SHA}" || -z "${HEAD_SHA}" || -z "${GITHUB_REPOSITORY}" ]]; then
  echo "ERROR: BASE_SHA, HEAD_SHA, GITHUB_REPOSITORY required" >&2
  exit 1
fi

SERVICES="$(BASE_SHA="${BASE_SHA}" HEAD_SHA="${HEAD_SHA}" ./scripts/detect_changed_services.sh || true)"
if [[ -z "${SERVICES}" ]]; then
  echo "No changed services. Skip."
  exit 0
fi

echo "Changed services: ${SERVICES}"

# 1) gen 검증 (변경 서비스만 재생성)
./scripts/verify_gen.sh "${SERVICES}"

# 2) 서비스별 next version 계산 → tag 생성/푸시 → publish
for s in ${SERVICES}; do
  latest="$(./scripts/latest_tag.sh "${s}")"
  if [[ -z "${latest}" ]]; then
    next="0.0.1"
  else
    # latest = service-vX.Y.Z
    ver="${latest#${s}-v}"
    next="$(./scripts/bump_patch.sh "${ver}")"
  fi

  tag="${s}-v${next}"
  echo "Release ${s}: ${latest:-<none>} -> ${tag}"

  # tag 생성
  git tag "${tag}"

  # tag push
  git push origin "${tag}"

  # Java publish
  SERVICE="${s}" VERSION="${next}" GITHUB_REPOSITORY="${GITHUB_REPOSITORY}" ./scripts/publish_java.sh
done

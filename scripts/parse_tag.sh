#!/usr/bin/env bash
set -euo pipefail

TAG="${1:-}"
if [[ -z "${TAG}" ]]; then
  echo "ERROR: tag is required. ex) search-v1.2.3" >&2
  exit 1
fi

if [[ ! "${TAG}" =~ ^([a-zA-Z0-9_-]+)-v([0-9]+\.[0-9]+\.[0-9]+)$ ]]; then
  echo "ERROR: invalid tag format: ${TAG}. expected: {service}-v1.2.3" >&2
  exit 1
fi

SERVICE="${BASH_REMATCH[1]}"
VERSION="${BASH_REMATCH[2]}"

echo "${SERVICE} ${VERSION}"

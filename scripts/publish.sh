#!/usr/bin/env bash
set -euo pipefail

# gen 경로에서 업데이트된(변경된) SVC를 배포하는 스크립트
# java는 github packages로 배포하고, golang은 tags로 배포한다.
# --all 플래그가 있으면 전체 서비스 배포

BASE_SHA="${BASE_SHA:-}"
HEAD_SHA="${HEAD_SHA:-HEAD}"
GITHUB_REPOSITORY="${GITHUB_REPOSITORY:-}"
GITHUB_ACTOR="${GITHUB_ACTOR:-}"

if [[ -z "${GITHUB_REPOSITORY}" ]]; then
  echo "ERROR: GITHUB_REPOSITORY is required" >&2
  exit 1
fi

if [[ -z "${GITHUB_TOKEN}" ]]; then
  echo "ERROR: GITHUB_TOKEN is required" >&2
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROTO_ROOT="${ROOT_DIR}/proto"

# print env
echo "GITHUB_REPOSITORY: ${GITHUB_REPOSITORY}"
echo "GITHUB_ACTOR: ${GITHUB_ACTOR}"
echo "GITHUB_TOKEN: ${GITHUB_TOKEN}"
echo "BASE_SHA: ${BASE_SHA}"
echo "HEAD_SHA: ${HEAD_SHA}"

# --all 플래그 확인
ALL_FLAG=false
if [[ "${1:-}" == "--all" ]]; then
  ALL_FLAG=true
fi

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

# 컨테이너 안에서 git 설정
# Docker 컨테이너 내부에서 마운트된 디렉토리의 소유권 문제 해결
git config --global --add safe.directory /workspace || true

# GITHUB_TOKEN이 있고 GITHUB_REPOSITORY가 설정된 경우에만 remote URL 변경
# (CI 환경에서만 필요, 로컬에서는 기존 설정 유지)
if [[ -n "${GITHUB_TOKEN}" && -n "${GITHUB_REPOSITORY}" ]]; then
  git remote set-url origin "https://x-access-token:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git" || true
fi

# 변경된 서비스 목록 가져오기
if [[ "${ALL_FLAG}" == "true" ]]; then
  SERVICES="$(list_all_services)"
  echo "Publishing all services: ${SERVICES}"
else
  SERVICES="$(BASE_SHA="${BASE_SHA}" HEAD_SHA="${HEAD_SHA}" "${ROOT_DIR}/scripts/detect_change.sh" || true)"
  
  if [[ -z "${SERVICES}" ]]; then
    echo "No changed services. Skip release."
    exit 0
  fi
  
  echo "Changed services: ${SERVICES}"
fi

# 서비스별 배포 (항상 latest 버전으로)
VERSION="latest"

for SERVICE in ${SERVICES}; do
  echo "Release ${SERVICE} with version: ${VERSION}"
  
  # Go: latest 태그 생성 및 푸시
  TAG="${SERVICE}-latest"
  echo "Creating and pushing tag for Go: ${TAG}"
  # 기존 태그가 있으면 삭제 후 재생성
  git tag -d "${TAG}" 2>/dev/null || true
  git push origin ":refs/tags/${TAG}" 2>/dev/null || true
  git tag "${TAG}"
  git push origin "${TAG}"
  
  # Java: GitHub Packages로 latest 버전 배포
  echo "Publishing Java package for ${SERVICE} version ${VERSION}..."
  
  GROUP_ID="com.nextsecurities.idl"
  ARTIFACT_ID="idl-${SERVICE}-v1"
  REPO_URL="https://maven.pkg.github.com/${GITHUB_REPOSITORY}"
  REPO_ID="github"
  
  SRC_DIR="${ROOT_DIR}/gen/java/apis/v1/${SERVICE}"
  if [[ ! -d "${SRC_DIR}" ]]; then
    echo "ERROR: generated java dir not found: ${SRC_DIR}" >&2
    continue
  fi
  
  WORKDIR="$(mktemp -d)"
  trap 'rm -rf "${WORKDIR}"' EXIT
  
  mkdir -p "${WORKDIR}/src/main/java"
  cp -R "${SRC_DIR}/." "${WORKDIR}/src/main/java/"
  
  cat > "${WORKDIR}/pom.xml" <<EOF
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>

  <groupId>${GROUP_ID}</groupId>
  <artifactId>${ARTIFACT_ID}</artifactId>
  <version>${VERSION}</version>
  <packaging>jar</packaging>

  <properties>
    <maven.compiler.source>17</maven.compiler.source>
    <maven.compiler.target>17</maven.compiler.target>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    <grpc.version>1.68.0</grpc.version>
    <protobuf.version>3.25.3</protobuf.version>
    <maven.compiler.plugin.version>3.11.0</maven.compiler.plugin.version>
  </properties>

  <build>
    <plugins>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-compiler-plugin</artifactId>
        <version>\${maven.compiler.plugin.version}</version>
        <configuration>
          <source>17</source>
          <target>17</target>
        </configuration>
      </plugin>
    </plugins>
  </build>

  <dependencies>
    <dependency>
      <groupId>io.grpc</groupId>
      <artifactId>grpc-stub</artifactId>
      <version>\${grpc.version}</version>
    </dependency>
    <dependency>
      <groupId>io.grpc</groupId>
      <artifactId>grpc-protobuf</artifactId>
      <version>\${grpc.version}</version>
    </dependency>
    <dependency>
      <groupId>com.google.protobuf</groupId>
      <artifactId>protobuf-java</artifactId>
      <version>\${protobuf.version}</version>
    </dependency>
    <dependency>
      <groupId>javax.annotation</groupId>
      <artifactId>javax.annotation-api</artifactId>
      <version>1.3.2</version>
    </dependency>
  </dependencies>

  <distributionManagement>
    <repository>
      <id>${REPO_ID}</id>
      <url>${REPO_URL}</url>
    </repository>
  </distributionManagement>
</project>
EOF

  # Maven settings.xml 생성 (GitHub Packages 인증)
  mkdir -p "${WORKDIR}/.m2"
  cat > "${WORKDIR}/.m2/settings.xml" <<EOF
<settings>
  <servers>
    <server>
      <id>${REPO_ID}</id>
      <username>\${env.GITHUB_ACTOR}</username>
      <password>\${env.GITHUB_TOKEN}</password>
    </server>
  </servers>
</settings>
EOF
  
  export GITHUB_ACTOR="${GITHUB_ACTOR:-github-actions[bot]}"
  export GITHUB_TOKEN="${GITHUB_TOKEN}"
  
  mvn -q -f "${WORKDIR}/pom.xml" -s "${WORKDIR}/.m2/settings.xml" -DskipTests package
  mvn -q -f "${WORKDIR}/pom.xml" -s "${WORKDIR}/.m2/settings.xml" -DskipTests deploy
  
  echo "OK: published ${GROUP_ID}:${ARTIFACT_ID}:${VERSION}"
  
  # trap 정리
  rm -rf "${WORKDIR}"
  trap - EXIT
done

echo "Release completed successfully"


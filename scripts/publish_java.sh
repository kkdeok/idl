#!/usr/bin/env bash
set -euo pipefail

# gen 경로에서 서비스를 배포하는 스크립트
# java와 python은 github packages로 배포하고, golang은 버전 관리 없음 (커밋 해시로 import)

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
PROTO_ROOT="${ROOT_DIR}/protos"

# print env
echo "GITHUB_REPOSITORY: ${GITHUB_REPOSITORY}"
echo "GITHUB_ACTOR: ${GITHUB_ACTOR}"

# 플래그 확인
DRY_RUN=false

for arg in "$@"; do
  case "${arg}" in
    --dry-run)
      DRY_RUN=true
      ;;
  esac
done

if [[ "${DRY_RUN}" == "true" ]]; then
  echo "=== DRY RUN MODE: 실제 배포는 하지 않습니다 ==="
fi

# 전체 서비스 목록 가져오기
list_all_services() {
  local SERV_DIR="${PROTO_ROOT}/apis"
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

# 서비스 목록 가져오기
SERVICES="$(list_all_services)"
if [[ -z "${SERVICES}" ]]; then
  echo "No services found. Skip release."
  exit 0
fi
echo "Publishing services: ${SERVICES}"

# GitHub Packages API로 최신 버전 가져오기
get_latest_version() {
  local GROUP_ID="$1"
  local ARTIFACT_ID="$2"
  
  # Maven (Java) 패키지의 경우
  local URL="https://maven.pkg.github.com/${GITHUB_REPOSITORY}/${GROUP_ID//\./\/}/${ARTIFACT_ID}/maven-metadata.xml"
  
  local VERSION=""
  if [[ "${DRY_RUN}" == "true" ]]; then
    echo "[DRY RUN] Would check version from: ${URL}" >&2
    echo "0.0.0"
  else
    # curl 실행 및 HTTP 코드 확인
    local RESPONSE
    local CURL_EXIT_CODE
    RESPONSE=$(curl -s -w "\n%{http_code}" -H "Authorization: token ${GITHUB_TOKEN}" "${URL}" 2>&1)
    CURL_EXIT_CODE=$?
    local HTTP_CODE
    HTTP_CODE=$(echo "${RESPONSE}" | tail -1)
    local BODY
    BODY=$(echo "${RESPONSE}" | sed '$d')
    
    # 디버깅: HTTP 코드와 응답 확인
    echo "DEBUG: curl exit code: ${CURL_EXIT_CODE}, HTTP code: ${HTTP_CODE}" >&2
    if [[ "${HTTP_CODE}" != "200" ]]; then
      echo "DEBUG: Response body (first 200 chars): ${BODY:0:200}" >&2
    fi
    
    # curl 실패 또는 HTTP 에러인 경우
    if [[ ${CURL_EXIT_CODE} -ne 0 ]] || [[ ! "${HTTP_CODE}" =~ ^[0-9]+$ ]]; then
      echo "DEBUG: curl failed or invalid HTTP code" >&2
      echo "0.0.0"
    elif [[ "${HTTP_CODE}" == "200" ]]; then
      echo "DEBUG: Response body (first 500 chars): ${BODY:0:500}" >&2
      if VERSION=$(echo "${BODY}" | sed -n 's/.*<version>\([^<]*\)<\/version>.*/\1/p' | grep -v 'SNAPSHOT' | sort -V | tail -1); then
        echo "DEBUG: Found version: ${VERSION}" >&2
        echo "${VERSION}"
      else
        echo "DEBUG: No version found in response" >&2
        echo "0.0.0"
      fi
    else
      # HTTP 에러 코드가 200이 아닌 경우 (404: 패키지 없음, 401/403: 인증 문제 등)
      echo "DEBUG: HTTP error code: ${HTTP_CODE}" >&2
      echo "0.0.0"
    fi
  fi
}

# 버전 증가 (PATCH 버전 증가)
increment_version() {
  local VERSION="$1"
  if [[ -z "${VERSION}" || "${VERSION}" == "0.0.0" ]]; then
    echo "0.0.1"
    return
  fi
  
  # semantic versioning: MAJOR.MINOR.PATCH
  local MAJOR=$(echo "${VERSION}" | cut -d. -f1)
  local MINOR=$(echo "${VERSION}" | cut -d. -f2)
  local PATCH=$(echo "${VERSION}" | cut -d. -f3)
  
  # PATCH 버전 증가
  PATCH=$((PATCH + 1))
  echo "${MAJOR}.${MINOR}.${PATCH}"
}

# Python 패키지 버전 가져오기 (GitHub Packages API)
get_latest_python_version() {
  local PACKAGE_NAME="$1"
  
  # Python 패키지는 PyPI 형식으로 GitHub Packages에 저장됨
  # API: https://api.github.com/orgs/{owner}/packages/{package_type}/{package_name}/versions
  local URL="https://api.github.com/orgs/${GITHUB_REPOSITORY%%/*}/packages/pypi/${PACKAGE_NAME}/versions"
  
  local VERSION=""
  if [[ "${DRY_RUN}" == "true" ]]; then
    echo "[DRY RUN] Would check Python version from: ${URL}" >&2
    echo "0.0.0"
  elif VERSION=$(curl -s -f -H "Authorization: token ${GITHUB_TOKEN}" -H "Accept: application/vnd.github.v3+json" "${URL}" 2>/dev/null | sed -n 's/.*"name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | grep -v 'dev' | sort -V | tail -1); then
    echo "${VERSION}"
  else
    echo "0.0.0"
  fi
}

# Java: 모든 서비스를 하나의 JAR로 배포
echo "=========================================="
echo "Publishing Java package (all services)"
echo "=========================================="

GROUP_ID="com.kkdeok"
ARTIFACT_ID="idl"
REPO_URL="https://maven.pkg.github.com/${GITHUB_REPOSITORY}"
REPO_ID="github"

JAVA_SRC_DIR="${ROOT_DIR}/gen/java/com/kkdeok/idl"
if [[ ! -d "${JAVA_SRC_DIR}/apis" ]]; then
  echo "WARNING: generated java dir not found: ${JAVA_SRC_DIR}/apis, skipping Java publish" >&2
else
  # 최신 버전 확인 및 증가
  VERSION_URL="https://maven.pkg.github.com/${GITHUB_REPOSITORY}/${GROUP_ID//\./\/}/${ARTIFACT_ID}/maven-metadata.xml"
  echo "Checking version from: ${VERSION_URL}"
  LATEST_VERSION=$(get_latest_version "${GROUP_ID}" "${ARTIFACT_ID}")
  NEW_VERSION=$(increment_version "${LATEST_VERSION}")
  echo "Latest version: ${LATEST_VERSION}, New version: ${NEW_VERSION}"
  
  WORKDIR="$(mktemp -d)"
  trap 'rm -rf "${WORKDIR}"' EXIT
  
  mkdir -p "${WORKDIR}/src/main/java/com/kkdeok/idl"
  cp -R "${JAVA_SRC_DIR}/apis" "${WORKDIR}/src/main/java/com/kkdeok/idl/"
  
  cat > "${WORKDIR}/pom.xml" <<EOF
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>

  <groupId>${GROUP_ID}</groupId>
  <artifactId>${ARTIFACT_ID}</artifactId>
  <version>${NEW_VERSION}</version>
  <packaging>jar</packaging>

  <properties>
    <maven.compiler.source>17</maven.compiler.source>
    <maven.compiler.target>17</maven.compiler.target>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    <grpc.version>1.77.0</grpc.version>
    <protobuf.version>4.33.2</protobuf.version>
    <protoc.version>3.25.3</protoc.version>
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
      <username>${GITHUB_ACTOR}</username>
      <password>${GITHUB_TOKEN}</password>
    </server>
  </servers>
</settings>
EOF
  
  if [[ "${DRY_RUN}" == "true" ]]; then
    echo "[DRY RUN] Would run: mvn clean package"
    echo "[DRY RUN] Would run: mvn deploy"
    echo "[DRY RUN] Would publish: ${GROUP_ID}:${ARTIFACT_ID}:${NEW_VERSION}"
    echo "[DRY RUN] POM file location: ${WORKDIR}/pom.xml"
    echo "[DRY RUN] Source files: ${JAVA_SRC_DIR}/apis"
  else
    mvn -q -f "${WORKDIR}/pom.xml" -s "${WORKDIR}/.m2/settings.xml" -DskipTests clean package
    
    # deploy 시도, 409 에러 발생 시 버전 증가 후 재시도
    DEPLOY_OUTPUT=$(mvn -f "${WORKDIR}/pom.xml" -s "${WORKDIR}/.m2/settings.xml" -DskipTests deploy 2>&1)
    DEPLOY_EXIT_CODE=$?
    
    if [[ ${DEPLOY_EXIT_CODE} -eq 0 ]]; then
      echo "OK: published ${GROUP_ID}:${ARTIFACT_ID}:${NEW_VERSION}"
    elif echo "${DEPLOY_OUTPUT}" | grep -q "409\|Conflict"; then
      # 409 에러 발생: 버전이 이미 존재함, 버전 증가 후 재시도
      echo "Version ${NEW_VERSION} already exists, incrementing version..."
      NEW_VERSION=$(increment_version "${NEW_VERSION}")
      echo "New version: ${NEW_VERSION}"
      
      # pom.xml의 버전 업데이트
      sed -i.bak "s/<version>.*<\/version>/<version>${NEW_VERSION}<\/version>/" "${WORKDIR}/pom.xml"
      rm -f "${WORKDIR}/pom.xml.bak"
      
      # 다시 deploy
      mvn -q -f "${WORKDIR}/pom.xml" -s "${WORKDIR}/.m2/settings.xml" -DskipTests deploy
      echo "OK: published ${GROUP_ID}:${ARTIFACT_ID}:${NEW_VERSION}"
    else
      # 다른 에러 발생: 원래 에러 메시지 출력
      echo "${DEPLOY_OUTPUT}" >&2
      exit ${DEPLOY_EXIT_CODE}
    fi
  fi
  
  # trap 정리
  rm -rf "${WORKDIR}"
  trap - EXIT
fi
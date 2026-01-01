#!/usr/bin/env bash
set -euo pipefail

SERVICE="${SERVICE:-}"
VERSION="${VERSION:-}"
GITHUB_REPOSITORY="${GITHUB_REPOSITORY:-}"

if [[ -z "${SERVICE}" || -z "${VERSION}" || -z "${GITHUB_REPOSITORY}" ]]; then
  echo "ERROR: SERVICE, VERSION, GITHUB_REPOSITORY are required" >&2
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GROUP_ID="com.nextsecurities.idl"
ARTIFACT_ID="idl-${SERVICE}-v1"
REPO_URL="https://maven.pkg.github.com/${GITHUB_REPOSITORY}"
REPO_ID="github"

SRC_DIR="${ROOT_DIR}/gen/java/apis/v1/${SERVICE}"
if [[ ! -d "${SRC_DIR}" ]]; then
  echo "ERROR: generated java dir not found: ${SRC_DIR}" >&2
  exit 1
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
    <maven.compiler.release>17</maven.compiler.release>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    <grpc.version>1.68.0</grpc.version>
    <protobuf.version>4.28.2</protobuf.version>
  </properties>

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
  </dependencies>

  <distributionManagement>
    <repository>
      <id>${REPO_ID}</id>
      <url>${REPO_URL}</url>
    </repository>
  </distributionManagement>
</project>
EOF

mvn -q -f "${WORKDIR}/pom.xml" -DskipTests package
mvn -q -f "${WORKDIR}/pom.xml" -DskipTests deploy

echo "OK: published ${GROUP_ID}:${ARTIFACT_ID}:${VERSION}"

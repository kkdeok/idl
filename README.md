# IDL 저장소

Protocol Buffers 정의를 관리하고, Go와 Java 코드를 생성하는 저장소입니다.

## 프로젝트 구조

```
idl/
├── proto/
│   └── services/              # 서비스별 proto 정의
│       └── search/
│           └── search.proto
├── gen/                       # 생성된 코드
│   ├── go/
│   │   └── apis/v1/
│   │       └── search/
│   └── java/
│       └── apis/v1/
│           └── search/
├── scripts/                   # 코드 생성 및 배포 스크립트
├── docker/                    # Docker 빌드 환경
└── Makefile                   # Docker 기반 빌드 명령어
```

## 사전 요구사항

- Docker 및 Docker Compose
- Git

모든 코드 생성은 Docker 컨테이너 내에서 실행되므로, 로컬에 protoc나 Go, Java를 설치할 필요가 없습니다.

## Getting Started

프로젝트를 처음 시작하는 경우 다음 단계를 따르세요:

1. 저장소 클론
   ```bash
   git clone <repository-url>
   cd idl
   ```

2. Docker 이미지 빌드
   ```bash
   make docker-build
   ```

3. 코드 생성
   ```bash
   make gen
   ```

4. 생성된 코드 확인
   ```bash
   ls -la gen/go/apis/v1/
   ls -la gen/java/apis/v1/
   ```

## Run on your local

로컬 개발 환경에서 코드를 생성하고 테스트하는 방법입니다.

### 1. Docker 이미지 빌드 (최초 1회)

```bash
make docker-build
```

이 명령어는 `docker/Dockerfile`을 사용하여 개발 환경 이미지를 빌드합니다. 이미지에는 protoc, Go, Java, Maven 등 필요한 도구들이 포함되어 있습니다.

### 2. 모든 서비스 코드 생성

```bash
make gen
```

모든 서비스의 Go와 Java 코드를 생성합니다. 생성된 코드는 `gen/` 디렉토리에 저장됩니다.

### 3. 변경된 서비스만 코드 생성

proto 파일을 수정한 후 변경된 서비스만 재생성하려면:

```bash
make gen-changed
```

이 명령어는 Git을 사용하여 변경된 서비스를 감지하고 해당 서비스만 코드를 생성합니다.

### 4. Docker 컨테이너에서 직접 작업

컨테이너 내부에서 직접 명령어를 실행하려면:

```bash
make docker-shell
```

컨테이너 내부에서 `./scripts/gen_go.sh <service>` 또는 `./scripts/gen_java.sh <service>` 같은 스크립트를 직접 실행할 수 있습니다.

### 5. 사용 가능한 서비스 목록 확인

```bash
make docker-shell
# 컨테이너 내부에서
./scripts/list_services.sh
```

## 사용법

### Docker 이미지 빌드

```bash
make docker-build
```

### 모든 서비스 코드 생성

```bash
make gen
```

### 변경된 서비스만 코드 생성

```bash
make gen-changed
```

### Docker 컨테이너에서 쉘 접근

```bash
make docker-shell
```

## 새 서비스 추가하기

1. `proto/services/` 하위에 새 디렉토리 생성
   ```bash
   mkdir -p proto/services/newservice
   ```

2. proto 파일 작성
   ```protobuf
   syntax = "proto3";
   
   package apis.v1.newservice;
   
   option java_package = "com.kkdeok.idl.apis.v1.newservice";
   option java_multiple_files = true;
   option java_outer_classname = "NewServiceProto";
   
   option go_package = "gen/go/apis/v1/newservice;newservice";
   
   service NewService {
     rpc DoSomething(NewServiceRequest) returns (NewServiceResponse);
   }
   
   message NewServiceRequest {
     string data = 1;
   }
   
   message NewServiceResponse {
     string result = 1;
   }
   ```

3. 코드 생성
   ```bash
   make gen
   ```

## 생성된 코드 사용하기

### Java

생성된 코드는 GitHub Packages에 자동으로 배포됩니다.

```xml
<!-- pom.xml -->
<repositories>
    <repository>
        <id>github</id>
        <url>https://maven.pkg.github.com/kkdeok/idl</url>
    </repository>
</repositories>

<dependencies>
    <dependency>
        <groupId>com.nextsecurities.idl</groupId>
        <artifactId>idl-search-v1</artifactId>
        <version>0.0.1</version>
    </dependency>
</dependencies>
```

```java
import com.kkdeok.idl.apis.v1.search.SearchProto.SearchRequest;
import com.kkdeok.idl.apis.v1.search.SearchProto.SearchResponse;

SearchRequest request = SearchRequest.newBuilder()
    .setQuery("test")
    .build();
```

### Go

```go
import (
    "gen/go/apis/v1/search"
)

request := &search.SearchRequest{
    Query: "test",
}
```

## CI/CD

`main` 브랜치에 푸시하면 GitHub Actions가 자동으로:
1. 변경된 서비스 감지
2. 코드 생성 및 검증
3. 서비스별 버전 태그 생성
4. GitHub Packages에 Java 패키지 배포

서비스별 버전은 `{service}-v{version}` 형식으로 관리됩니다 (예: `search-v0.0.1`).

## 버전 관리

- 각 서비스는 독립적으로 버전 관리됩니다
- Breaking change가 필요한 경우 새 버전 디렉토리 생성 (예: `services/search/v2/`)

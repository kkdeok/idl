# IDL 저장소

이 저장소는 Protocol Buffers 정의를 관리하고, 여러 서비스에서 Java, Golang, Python으로 사용할 수 있는 소스코드를 생성합니다.

## 프로젝트 구조

```
idl/
├── proto/
│   ├── common/                    # 공통 메시지 및 타입
│   │   └── common.proto           # 공통 응답, 에러 등
│   └── services/                  # 서비스별 proto 정의
│       ├── hello/                 # hello 서비스
│       │   └── hello.proto
│       ├── user/                  # user 서비스 (예시)
│       │   └── user.proto
│       └── order/                 # order 서비스 (예시)
│           └── order.proto
├── gen/                           # 생성된 코드 (gitignore)
│   ├── java/
│   │   └── apis/
│   │       └── v1/
│   │           ├── common/        # 공통 코드
│   │           └── hello/         # hello 서비스 코드
│   ├── go/
│   │   └── apis/
│   │       └── v1/
│   │           ├── common/       # 공통 코드
│   │           └── hello/         # hello 서비스 코드
│   └── python/
│       └── apis/
│           └── v1/
│               ├── common/        # 공통 코드
│               └── hello/          # hello 서비스 코드
└── Makefile                       # 코드 생성 스크립트 (유일한 빌드 도구)
```

## 구조 설계 원칙

### 1. 서비스별 분리
- 각 서비스는 `proto/services/{service_name}/` 디렉토리에 정의
- 서비스별로 독립적인 패키지와 네임스페이스 사용
- 서비스 간 의존성 최소화

### 2. 공통 메시지 관리
- `proto/common/` 디렉토리에 공통으로 사용되는 타입과 메시지 정의
- 예: Error, Status 등
- 모든 서비스에서 import하여 사용 가능
- 각 서비스는 자체 Request/Response 메시지를 정의 (공통 Response 래퍼 없음)

### 3. 확장성
- 새로운 서비스 추가 시 `proto/services/` 하위에 디렉토리만 추가
- 기존 서비스에 영향 없이 확장 가능

## 사전 요구사항

**중요**: 이 저장소는 **Makefile만으로 코드 생성**이 가능합니다. `build.gradle`, `go.mod`, `requirements.txt` 같은 의존성 파일은 필요 없습니다. 이 파일들은 생성된 코드를 사용하는 각 프로젝트에서 관리하면 됩니다.

### 필수 (모든 언어 공통)
- **Protocol Buffers Compiler (protoc)** 설치 필요
  - macOS: `brew install protobuf`
  - Linux: `apt-get install protobuf-compiler` 또는 `yum install protobuf-compiler`
  - Windows: https://github.com/protocolbuffers/protobuf/releases

### 언어별 추가 요구사항

코드 생성에 필요한 환경은 생성하려는 언어에 따라 다릅니다:

#### Java 코드 생성
- **protoc만 필요** (Java JDK 불필요)
- 생성된 코드를 사용하려면 Java 환경 필요

#### Golang 코드 생성
- **protoc + protoc-gen-go 플러그인** 필요
- Go 환경이 설치되어 있어야 함 (protoc-gen-go 설치용)
  ```bash
  go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
  ```
  
  설치 후 GOPATH/bin이 PATH에 포함되어 있는지 확인:
  ```bash
  export PATH=$PATH:$(go env GOPATH)/bin
  # 또는 ~/.zshrc 또는 ~/.bashrc에 추가
  echo 'export PATH=$PATH:$(go env GOPATH)/bin' >> ~/.zshrc
  ```

#### Python 코드 생성
- **protoc만 필요** (Python 환경 불필요)
- 생성된 코드를 사용하려면 Python 환경 필요

### 요약

| 언어 | 코드 생성에 필요한 것 | 코드 사용에 필요한 것 |
|------|---------------------|---------------------|
| Java | protoc | Java JDK + protobuf-java 라이브러리 |
| Go | protoc + protoc-gen-go (Go 환경 필요) | Go 환경 + google.golang.org/protobuf |
| Python | protoc | Python 환경 + protobuf 패키지 |

**중요**: 코드를 생성하는 것과 생성된 코드를 사용하는 것은 다릅니다.
- **생성**: Makefile + protoc (+ 언어별 플러그인) - 이 저장소에서만 필요
- **사용**: 해당 언어의 런타임 환경 + 의존성 라이브러리 - 각 프로젝트에서 관리

## 사용법

### 모든 서비스의 모든 언어 코드 생성
```bash
make all
```

### 개별 언어 코드 생성
```bash
make generate-java    # Java 코드만 생성
make generate-go      # Golang 코드만 생성
make generate-python  # Python 코드만 생성
```

### 특정 서비스만 생성
```bash
make generate-service SERVICE=hello
```

### 사용 가능한 서비스 목록 보기
```bash
make list-services
```

### Java JAR 파일 생성
```bash
make package-java          # 기본 버전으로 패키징
./scripts/package-java.sh 1.0.0  # 특정 버전으로 패키징
```

### 생성된 파일 정리
```bash
make clean
```

### 도움말 보기
```bash
make help
```

## Proto 파일 구조

### 공통 메시지 (common/common.proto)

여러 서비스에서 공통으로 사용되는 타입과 메시지를 정의합니다.

- **Status**: 공통 응답 상태 enum
- **Error**: 공통 에러 메시지

각 서비스는 자체 Request/Response 메시지를 정의하며, 필요시 `common.Error`를 포함할 수 있습니다.

### 서비스별 Proto (services/{service}/)

각 서비스별로 독립적인 proto 파일을 정의합니다.

#### hello 서비스 (services/hello/hello.proto)

- **HelloRequest**: `name` 필드를 포함
- **HelloResponse**: `message` 필드를 포함

## 새 서비스 추가하기

1. `proto/services/` 하위에 새 디렉토리 생성
   ```bash
   mkdir -p proto/services/newservice
   ```

2. proto 파일 작성
   ```protobuf
   syntax = "proto3";
   
   package newservice;
   
   import "common/common.proto";
   
   option go_package = "github.com/kkdeok/idl/gen/go/apis/v1/newservice";
   option java_package = "com.kkdeok.idl.gen.apis.v1.newservice";
   option java_outer_classname = "NewServiceProto";
   
   message NewServiceRequest {
     string data = 1;
   }
   
   message NewServiceResponse {
     string result = 1;
   }
   ```

3. 코드 생성
   ```bash
   make all
   # 또는 특정 서비스만
   make generate-service SERVICE=newservice
   ```

## 생성된 코드 사용 예시

각 서비스는 독립적인 패키지/모듈로 생성되므로, 필요한 서비스만 import하여 사용할 수 있습니다.

### Java - 서비스 레벨 Import

```java
// hello 서비스만 사용하는 경우
import com.kkdeok.idl.gen.apis.v1.hello.HelloProto.HelloRequest;
import com.kkdeok.idl.gen.apis.v1.hello.HelloProto.HelloResponse;

HelloRequest request = HelloRequest.newBuilder()
    .setName("World")
    .build();

// 공통 타입이 필요한 경우에만 import
import com.kkdeok.idl.gen.apis.v1.common.CommonProto.Error;
import com.kkdeok.idl.gen.apis.v1.common.CommonProto.Status;

// 다른 서비스 사용 예시 (user 서비스가 있다면)
import com.kkdeok.idl.gen.apis.v1.user.UserProto.UserRequest;
```

### Golang - 서비스 레벨 Import

```go
package main

// hello 서비스만 사용하는 경우
import (
    "github.com/kkdeok/idl/gen/go/apis/v1/hello"
)

func main() {
    request := &hello.HelloRequest{
        Name: "World",
    }
    // ...
}

// 공통 타입이 필요한 경우에만 import
import (
    "github.com/kkdeok/idl/gen/go/apis/v1/common"
    "github.com/kkdeok/idl/gen/go/apis/v1/hello"
)

// 다른 서비스 사용 예시 (user 서비스가 있다면)
import (
    "github.com/kkdeok/idl/gen/go/apis/v1/user"
)
```

### Python - 서비스 레벨 Import

```python
# hello 서비스만 사용하는 경우
from gen.python.apis.v1.hello import hello_pb2

request = hello_pb2.HelloRequest(name="World")

# 공통 타입이 필요한 경우에만 import
from gen.python.apis.v1 import common_pb2
from gen.python.apis.v1.hello import hello_pb2

# 다른 서비스 사용 예시 (user 서비스가 있다면)
from gen.python.apis.v1.user import user_pb2
```

### 서비스별 독립적 사용

각 서비스는 완전히 독립적인 패키지/모듈로 생성되므로:

- **필요한 서비스만 import**: 사용하지 않는 서비스는 import하지 않아도 됩니다
- **의존성 최소화**: 각 프로젝트는 필요한 서비스만 의존하면 됩니다
- **명확한 네임스페이스**: `services.{service_name}` 패키지로 명확하게 구분됩니다

## 프로젝트에서 사용하기

각 서비스 프로젝트에서 GitHub에 푸시된 IDL 저장소의 생성된 코드를 Maven/Gradle 의존성으로 추가하여 사용할 수 있습니다.

### Java 프로젝트에서 사용

#### 방법 1: JitPack 사용 (가장 간단, 권장)

JitPack을 사용하면 GitHub 저장소를 직접 Maven 의존성으로 사용할 수 있습니다.

**사전 준비:**
1. 생성된 코드를 커밋하거나, GitHub Actions로 자동 생성하도록 설정
2. JitPack은 `make install`을 실행하여 코드를 생성하고 JAR를 만듭니다
3. `jitpack.yml` 파일은 선택사항입니다 (없어도 `make install`로 동작)

**Gradle 프로젝트 - 서비스별 의존성:**

```gradle
// build.gradle
repositories {
    mavenCentral()
    maven { url 'https://jitpack.io' }
}

dependencies {
    // Protocol Buffers Java 라이브러리
    implementation 'com.google.protobuf:protobuf-java:4.25.1'
    
    // Common 타입 (필요한 경우)
    implementation 'com.github.kkdeok.idl:idl-common:main-SNAPSHOT'
    
    // 특정 서비스만 사용 (예: hello 서비스)
    implementation 'com.github.kkdeok.idl:idl-hello:main-SNAPSHOT'
    
    // 다른 서비스도 필요하면 추가
    // implementation 'com.github.kkdeok.idl:idl-user:main-SNAPSHOT'
    
    // 또는 전체 서비스를 한번에 (권장하지 않음)
    // implementation 'com.github.kkdeok.idl:idl:main-SNAPSHOT'
}
```

**Maven 프로젝트 - 서비스별 의존성:**

```xml
<!-- pom.xml -->
<repositories>
    <repository>
        <id>jitpack.io</id>
        <url>https://jitpack.io</url>
    </repository>
</repositories>

<dependencies>
    <!-- Protocol Buffers Java 라이브러리 -->
    <dependency>
        <groupId>com.google.protobuf</groupId>
        <artifactId>protobuf-java</artifactId>
        <version>4.25.1</version>
    </dependency>
    
    <!-- Common 타입 (필요한 경우) -->
    <dependency>
        <groupId>com.github.kkdeok.idl</groupId>
        <artifactId>idl-common</artifactId>
        <version>main-SNAPSHOT</version>
    </dependency>
    
    <!-- 특정 서비스만 사용 (예: hello 서비스) -->
    <dependency>
        <groupId>com.github.kkdeok.idl</groupId>
        <artifactId>idl-hello</artifactId>
        <version>main-SNAPSHOT</version>
    </dependency>
</dependencies>
```

**JitPack 사용 시:**
- JitPack이 자동으로 `build.gradle`을 실행하여 JAR를 생성합니다
- 생성된 코드(`gen/`)가 저장소에 커밋되어 있어야 합니다
- 또는 GitHub Actions를 사용하여 자동으로 코드를 생성하고 커밋할 수 있습니다

#### 방법 2: GitHub Packages 사용

GitHub Packages를 사용하여 Maven 저장소로 배포할 수 있습니다.

**IDL 저장소에 `build.gradle` 추가:**

```gradle
// idl/build.gradle
plugins {
    id 'java'
    id 'maven-publish'
}

group = 'com.kkdeok.idl'
version = '1.0.0'

repositories {
    mavenCentral()
}

dependencies {
    implementation 'com.google.protobuf:protobuf-java:4.25.1'
}

sourceSets {
    main {
        java {
            srcDirs = ['gen/java/apis/v1']
        }
    }
}

publishing {
    publications {
        maven(MavenPublication) {
            from components.java
        }
    }
    repositories {
        maven {
            name = "GitHubPackages"
            url = uri("https://maven.pkg.github.com/kkdeok/idl")
            credentials {
                username = project.findProperty("gpr.user") ?: System.getenv("GITHUB_ACTOR")
                password = project.findProperty("gpr.token") ?: System.getenv("GITHUB_TOKEN")
            }
        }
    }
}
```

**사용하는 프로젝트에서:**

```gradle
// build.gradle
repositories {
    mavenCentral()
    maven {
        name = "GitHubPackages"
        url = uri("https://maven.pkg.github.com/kkdeok/idl")
        credentials {
            username = project.findProperty("gpr.user") ?: System.getenv("GITHUB_USERNAME")
            password = project.findProperty("gpr.token") ?: System.getenv("GITHUB_TOKEN")
        }
    }
}

dependencies {
    implementation 'com.google.protobuf:protobuf-java:4.25.1'
    implementation 'com.kkdeok.idl:idl:1.0.0'
}
```

#### 방법 3: 로컬 개발용 (Git Submodule)

로컬 개발 시에는 Git Submodule을 사용할 수 있습니다:

```bash
# 서비스 프로젝트에서
git submodule add <idl-repo-url> idl
cd idl && make all
```

그리고 `build.gradle`:
```gradle
sourceSets {
    main {
        java {
            srcDirs += ['idl/gen/java/apis/v1']
        }
    }
}
```

**참고**: 이 방법은 로컬 개발용입니다. 원격 Maven 의존성으로 사용하려면 JitPack이나 GitHub Packages를 사용하세요.

### Go 프로젝트에서 사용

```go
// 각 프로젝트의 go.mod에서
module your-project

require (
    github.com/kkdeok/idl v0.0.0
    google.golang.org/protobuf v1.31.0
)

replace github.com/kkdeok/idl => ../idl
```

그리고 코드에서:
```go
import (
    "github.com/kkdeok/idl/gen/go/apis/v1/hello"
    "github.com/kkdeok/idl/gen/go/apis/v1/common"
)
```

### Python 프로젝트에서 사용

```python
# requirements.txt
protobuf>=4.25.0
```

그리고 Python 경로에 IDL 저장소 추가:
```bash
export PYTHONPATH=$PYTHONPATH:/path/to/idl/gen/python
```

또는 프로젝트 내에서:
```python
import sys
sys.path.insert(0, '../idl/gen/python')

from gen.python.apis.v1.hello import hello_pb2
```

**참고**: IDL 저장소 자체에는 `build.gradle`, `go.mod`, `requirements.txt` 같은 의존성 파일이 필요 없습니다. 코드 생성은 Makefile과 스크립트(`scripts/package-java.sh`)만으로 가능하며, 생성된 코드를 사용하는 각 프로젝트에서 필요한 의존성 라이브러리를 관리하면 됩니다.

## 버전 관리 전략

- 각 서비스는 독립적으로 버전 관리 가능
- 공통 메시지는 하위 호환성을 유지하며 변경
- Breaking change가 필요한 경우 새 버전 디렉토리 생성 (예: `services/hello/v2/`)

# protoc-gen-go 설치 가이드

## 설치 방법

### 1. protoc-gen-go 설치

터미널에서 다음 명령어를 실행하세요:

```bash
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
```

이 명령어는 `$(go env GOPATH)/bin` 디렉토리에 `protoc-gen-go` 바이너리를 설치합니다.

### 2. PATH 설정

설치 후 `protoc-gen-go`를 사용하려면 GOPATH/bin이 PATH에 포함되어 있어야 합니다.

#### 현재 세션에만 적용 (임시)
```bash
export PATH=$PATH:$(go env GOPATH)/bin
```

#### 영구적으로 설정 (권장)

**zsh 사용 시 (~/.zshrc):**
```bash
echo 'export PATH=$PATH:$(go env GOPATH)/bin' >> ~/.zshrc
source ~/.zshrc
```

**bash 사용 시 (~/.bashrc):**
```bash
echo 'export PATH=$PATH:$(go env GOPATH)/bin' >> ~/.bashrc
source ~/.bashrc
```

### 3. 설치 확인

다음 명령어로 설치가 제대로 되었는지 확인하세요:

```bash
protoc-gen-go --version
```

또는:

```bash
which protoc-gen-go
```

## 문제 해결

### 설치가 안 되는 경우

1. **Go가 제대로 설치되어 있는지 확인:**
   ```bash
   go version
   ```

2. **네트워크 문제가 있는 경우:**
   - 프록시 설정 확인
   - Go 모듈 프록시 설정:
     ```bash
     go env -w GOPROXY=https://proxy.golang.org,direct
     ```

3. **GOPATH 확인:**
   ```bash
   go env GOPATH
   ```

### PATH가 설정되지 않은 경우

터미널을 새로 열거나 `source ~/.zshrc` (또는 `source ~/.bashrc`)를 실행하세요.

## 설치 후 테스트

설치가 완료되면 다음 명령어로 테스트할 수 있습니다:

```bash
make generate-go
```

또는:

```bash
make all
```


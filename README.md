# IDL Repository

A repository for managing Protocol Buffers definitions and generating Go and Java code.

## Project Structure

```
idl/
├── proto/
│   └── services/              # Service-specific proto definitions
│       └── search/
│           └── search.proto
├── gen/                       # Generated code
│   ├── go/
│   │   └── apis/v1/
│   │       └── search/
│   └── java/
│       └── apis/v1/
│           └── search/
├── scripts/                   # Code generation and deployment scripts
├── docker/                    # Docker build environment
└── Makefile                   # Docker-based build commands
```

## Prerequisites

- Docker and Docker Compose
- Git

All code generation runs inside Docker containers, so you don't need to install protoc, Go, or Java locally.

## Getting Started

Follow these steps to get started with the project:

1. Clone the repository
   ```bash
   git clone <repository-url>
   cd idl
   ```

2. Build Docker image
   ```bash
   make docker-build
   ```

3. Generate code
   ```bash
   make gen
   ```

4. Verify generated code
   ```bash
   ls -la gen/go/apis/v1/
   ls -la gen/java/apis/v1/
   ```

## Run on your local

How to generate and test code in your local development environment.

### 1. Build Docker image (first time only)

```bash
make docker-build
```

This command builds a development environment image using `docker/Dockerfile`. The image includes all necessary tools such as protoc, Go, Java, and Maven.

### 2. Generate code

#### Generate code for changed services only (default)

```bash
make gen
```

This command detects changed services by comparing proto and gen directories with the previous commit, and generates Go and Java code only for those services.

#### Generate code for all services

```bash
make gen-all
```

Generates Go and Java code for all services. The generated code is stored in the `gen/` directory.

### 3. Publish services (Release)

#### Publish changed services only (default)

```bash
export GITHUB_TOKEN="your_github_token"
export GITHUB_REPOSITORY="your_username/idl"  # 예: kkdeok/idl
make publish
```

This command:
- Detects changed services by comparing proto and gen directories with the previous commit
- Creates and pushes git tags for Go packages (format: `{service}-v{version}`)
- Publishes Java packages to GitHub Packages

#### Publish all services

```bash
export GITHUB_TOKEN="your_github_token"
export GITHUB_REPOSITORY="your_username/idl"
make publish-all
```

**Note:** 
- `GITHUB_TOKEN` is required for pushing tags and publishing to GitHub Packages
- You can create a Personal Access Token (PAT) with `repo` and `write:packages` permissions
- `GITHUB_REPOSITORY` should be in the format `owner/repo` (e.g., `kkdeok/idl`)

### 4. Work directly in Docker container

To run commands directly inside the container:

```bash
make docker-shell
```

Inside the container, you can run scripts directly such as `./scripts/gen_go.sh` or `./scripts/gen_java.sh`.

## Adding a New Service

1. Create a new directory under `proto/services/`
   ```bash
   mkdir -p proto/services/newservice
   ```

2. Write proto file
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

3. Generate code
   ```bash
   make gen
   ```

## Using Generated Code

### Java

Generated code is automatically published to GitHub Packages.

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

## Local Development Workflow

### Complete workflow: Generate and Publish

1. **Build Docker image** (first time only)
   ```bash
   make docker-build
   ```

2. **Modify proto files** in `proto/services/{service}/`

3. **Generate code** for changed services
   ```bash
   make gen
   ```
   Or generate for all services:
   ```bash
   make gen-all
   ```

4. **Commit and push changes**
   ```bash
   git add .
   git commit -m "Update proto files"
   git push
   ```

5. **Publish** changed services (requires GitHub token)
   ```bash
   export GITHUB_TOKEN="your_github_token"
   export GITHUB_REPOSITORY="your_username/idl"
   make publish
   ```

### Environment Variables for Publishing

- `GITHUB_TOKEN`: GitHub Personal Access Token with `repo` and `write:packages` permissions
- `GITHUB_REPOSITORY`: Repository in format `owner/repo` (e.g., `kkdeok/idl`)
- `BASE_SHA` (optional): Base commit SHA for comparison (defaults to previous commit)
- `HEAD_SHA` (optional): Head commit SHA for comparison (defaults to `HEAD`)

## CI/CD

When you push to the `main` branch, GitHub Actions automatically:
1. Detects changed services
2. Generates and validates code
3. Creates service-specific version tags
4. Publishes Java packages to GitHub Packages

Service versions are managed in the format `{service}-v{version}` (e.g., `search-v0.0.1`).

## Version Management

- Each service is versioned independently
- For breaking changes, create a new version directory (e.g., `services/search/v2/`)

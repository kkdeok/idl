FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    git \
    protobuf-compiler \
    openjdk-17-jdk-headless \
    maven \
    && rm -rf /var/lib/apt/lists/*

# Go
ENV GO_VERSION=1.22.1
RUN curl -fsSL https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz \
    | tar -C /usr/local -xz

ENV GOPATH=/go
ENV PATH="/usr/local/go/bin:/go/bin:${PATH}"

# Go protoc plugins
RUN go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.34.2 \
 && go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.4.0

# gRPC Java plugin
ENV GRPC_JAVA_VERSION=1.68.0
RUN curl -fsSL -o /usr/local/bin/protoc-gen-grpc-java \
    https://repo1.maven.org/maven2/io/grpc/protoc-gen-grpc-java/${GRPC_JAVA_VERSION}/protoc-gen-grpc-java-${GRPC_JAVA_VERSION}-linux-x86_64.exe \
 && chmod +x /usr/local/bin/protoc-gen-grpc-java

# Workdir
WORKDIR /workspace

# Convenience: ensure scripts are executable when image runs (repo에서도 x권한 커밋 권장)
CMD ["bash"]

FROM bufbuild/buf:latest

# Install protoc.
RUN apk add --no-cache protobuf-dev

# Install openjdk17-jdk, maven, python3, pip, bash, and curl
RUN apk add --no-cache openjdk17-jdk maven python3 py3-pip bash curl

# Verify installations.
RUN buf --version
RUN protoc --version
RUN mvn --version
RUN python3 --version
RUN pip3 --version
RUN curl --version

# Set working directory.
WORKDIR /workspace

# Override ENTRYPOINT from bufbuild/buf image
ENTRYPOINT []
FROM ubuntu:22.04

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y wget build-essential git python3 python3-dev

# Install protobuf
RUN git clone https://github.com/protocolbuffers/protobuf/ --depth 1 --branch v29.3
WORKDIR /protobuf

# Install bazel
RUN wget https://github.com/bazelbuild/bazelisk/releases/download/v1.25.0/bazelisk-amd64.deb
RUN apt-get install -y ./bazelisk-amd64.deb
RUN rm bazelisk-amd64.deb
RUN bazel --version

# Run the standard Python test
RUN bazel test --verbose_failures //python:conformance_test

# Install betterproto in a virtual environment
WORKDIR /protobuf/conformance
RUN apt-get install -y python3-venv python3-pip
RUN python3 -m venv .venv
RUN ./.venv/bin/pip install betterproto2-compiler grpcio-tools

# Compile the test files
ENV PATH="/protobuf/conformance/.venv/bin:$PATH"
RUN mkdir conformance && python -m grpc_tools.protoc -I . --python_betterproto2_out=conformance conformance.proto
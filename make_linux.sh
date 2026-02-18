#!/usr/bin/env bash
set -e

OUTPUT_DIR="$(pwd)/pkg"
mkdir -p "$OUTPUT_DIR"

echo "==> Building Nomad for linux/amd64 via Docker..."

docker run --rm \
  --platform linux/amd64 \
  -v "$(pwd)":/build \
  -w /build \
  -e TARGETS=linux_amd64 \
  golang:1.24.13-alpine \
  sh -c "
    apk add --no-cache git make bash gcc musl-dev curl zip linux-headers && \
    \
    echo '==> Installing Node 20...' && \
    curl -fsSL https://unofficial-builds.nodejs.org/download/release/v20.20.0/node-v20.20.0-linux-x64-musl.tar.xz -o /tmp/node.tar.xz && \
    tar -xJf /tmp/node.tar.xz -C /usr/local --strip-components=1 && \
    node --version && npm --version && \
    npm install -g yarn && yarn --version && \
    \
    echo '==> Running make bootstrap...' && \
    make bootstrap && \
    echo '==> Running make dev...' && \
    make dev && \
    echo '==> Running make prerelease...' && \
    make prerelease && \
    echo '==> Running make release...' && \
    make release
  "

echo ""
echo "==> Done! Artifacts in: $OUTPUT_DIR"
ls -lh "$OUTPUT_DIR/" 2>/dev/null || true

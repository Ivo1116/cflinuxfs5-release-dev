#!/usr/bin/env bash
set -euo pipefail
STACK=$1
VERSION=$2

cd "$STACK-release"
mkdir -p blobs/rootfs
cp "../rootfs-artifacts/${STACK}-${VERSION}.tar.gz" \
  "blobs/rootfs/${STACK}-${VERSION}.tar.gz"
echo "Rootfs blob ready: blobs/rootfs/${STACK}-${VERSION}.tar.gz"

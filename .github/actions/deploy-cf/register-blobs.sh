#!/usr/bin/env bash
set -euo pipefail
STACK=$1
VERSION=$2

cd "$STACK-release"

GO_BLOB_FILENAME=$(cat .go_blob_name)

# 1. Remove old Golang blob entries from blobs.yml (yq v3 syntax)
if [[ -f config/blobs.yml ]]; then
  # List all keys, filter those starting with golang-1-linux/, and delete them
  for key in $(yq r config/blobs.yml --printMode p | grep '^golang-1-linux/'); do
    yq d -i config/blobs.yml "$key"
  done
fi

# 2. Remove old final build records for golang-1-linux
rm -rf .final_builds/packages/golang-1-linux

# 3. Register new blobs
bosh add-blob "blobs/golang-1-linux/$GO_BLOB_FILENAME" \
  "golang-1-linux/$GO_BLOB_FILENAME"

bosh add-blob "blobs/rootfs/${STACK}-${VERSION}.tar.gz" \
  "rootfs/${STACK}-${VERSION}.tar.gz"

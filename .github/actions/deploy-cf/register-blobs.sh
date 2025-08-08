#!/usr/bin/env bash
set -euo pipefail
STACK=$1
VERSION=$2

cd "$STACK-release"

GO_BLOB_FILENAME=$(cat .go_blob_name)

# 1. Remove old Golang blob entries
if [[ -f config/blobs.yml ]]; then
  yq eval 'with_entries(select(.key | test("^golang-1-linux/") | not))' \
    -i config/blobs.yml
fi

# 2. Remove old final build records
rm -rf .final_builds/packages/golang-1-linux

# 3. Register new blobs
bosh add-blob "blobs/golang-1-linux/$GO_BLOB_FILENAME" \
  "golang-1-linux/$GO_BLOB_FILENAME"

bosh add-blob "blobs/rootfs/${STACK}-${VERSION}.tar.gz" \
  "rootfs/${STACK}-${VERSION}.tar.gz"

# 4. Upload blobs
bosh upload-blobs

# 5. Verify Golang blob is present
if ! bosh blobs | grep -q "golang-1-linux/$GO_BLOB_FILENAME"; then
  echo "ERROR: Golang blob not registered correctly!"
  exit 1
fi

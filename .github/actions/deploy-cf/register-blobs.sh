#!/usr/bin/env bash
set -euo pipefail
STACK=$1
VERSION=$2

cd "$STACK-release"

GO_BLOB_FILENAME=$(cat .go_blob_name)

# 1. Remove old Golang blob entries from blobs.yml
if [[ -f config/blobs.yml ]]; then
  yq -i 'with_entries(select(.key | startswith("golang-1-linux/") | not))' config/blobs.yml
fi

# 2. Remove old final build records for golang-1-linux
rm -rf .final_builds/packages/golang-1-linux

# 3. Register new blobs
bosh add-blob "blobs/golang-1-linux/$GO_BLOB_FILENAME" "golang-1-linux/$GO_BLOB_FILENAME"
bosh add-blob "blobs/rootfs/${STACK}-${VERSION}.tar.gz" "rootfs/${STACK}-${VERSION}.tar.gz"

# 4. Update spec to match the Go blob
yq eval -i ".files = [\"golang-1-linux/$GO_BLOB_FILENAME\"]" packages/golang-1-linux/spec

# 5. Sync blobs locally
bosh sync-blobs

echo "Blobs registered and synced."

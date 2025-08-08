#!/usr/bin/env bash
set -euo pipefail
STACK=$1
VERSION=$2

cd "$STACK-release"

GO_BLOB_FILENAME=$(cat .go_blob_name)

# Remove old Golang blob entry
yq -i 'del(.["golang-1-linux/"])' config/blobs.yml || true

# Register blobs
bosh add-blob "blobs/golang-1-linux/$GO_BLOB_FILENAME" "golang-1-linux/$GO_BLOB_FILENAME"
bosh add-blob "blobs/rootfs/${STACK}-${VERSION}.tar.gz" "rootfs/${STACK}-${VERSION}.tar.gz"

# Update spec to match the Go blob
yq eval -i ".files = [\"golang-1-linux/$GO_BLOB_FILENAME\"]" packages/golang-1-linux/spec

# Sync blobs locally
bosh sync-blobs

echo "Blobs registered and synced."

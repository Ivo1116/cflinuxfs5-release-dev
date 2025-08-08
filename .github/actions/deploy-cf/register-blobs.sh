#!/usr/bin/env bash
set -euo pipefail
STACK=$1
VERSION=$2

cd "$STACK-release"

GO_BLOB_FILENAME=$(cat .go_blob_name)

echo "=== Cleaning old Golang blob entries from blobs.yml ==="
if [[ -f config/blobs.yml ]]; then
  # Remove any existing golang-1-linux entries
  yq eval 'with_entries(select(.key | test("^golang-1-linux/") | not))' \
    -i config/blobs.yml
fi

echo "=== Removing old final build records for golang-1-linux ==="
rm -rf .final_builds/packages/golang-1-linux

echo "=== Adding new Golang blob: $GO_BLOB_FILENAME ==="
bosh add-blob "blobs/golang-1-linux/$GO_BLOB_FILENAME" \
  "golang-1-linux/$GO_BLOB_FILENAME"

echo "=== Adding rootfs blob: ${STACK}-${VERSION}.tar.gz ==="
bosh add-blob "blobs/rootfs/${STACK}-${VERSION}.tar.gz" \
  "rootfs/${STACK}-${VERSION}.tar.gz"

echo "=== Uploading blobs to blobstore ==="
bosh upload-blobs

echo "=== Verifying Golang blob is registered ==="
if ! bosh blobs | grep -q "golang-1-linux/$GO_BLOB_FILENAME"; then
  echo "ERROR: Golang blob not registered in blobs.yml!"
  exit 1
fi

echo "=== Committing updated blobs.yml and .final_builds ==="
git config --global user.email "ci-bot@example.com"
git config --global user.name "CI Bot"
git add config/blobs.yml .final_builds
git commit -m "Update Golang blob to $GO_BLOB_FILENAME" || echo "No changes to commit"

echo "=== register-blobs.sh completed successfully ==="

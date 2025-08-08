#!/usr/bin/env bash
set -euo pipefail

STACK=$1
VERSION=$2

ROOTFS_REPO="$STACK-release"
GO_BLOB_FILENAME=$(cat "$ROOTFS_REPO/.go_blob_name")
GO_BLOB_PATH="$(pwd)/$ROOTFS_REPO/blobs/golang-1-linux/$GO_BLOB_FILENAME"
ROOTFS_BLOB_PATH="$(pwd)/$ROOTFS_REPO/blobs/rootfs/${STACK}-${VERSION}.tar.gz"

echo "=== Starting multi-repo Golang + Rootfs blob update ==="
echo "Golang blob: $GO_BLOB_FILENAME"
echo "Rootfs blob: ${STACK}-${VERSION}.tar.gz"

# --- Function to update a repo ---
update_repo() {
  local repo_path="$1"
  echo "=== Updating Golang blob in repo: $repo_path ==="
  cd "$repo_path"

  # Ensure spec file exists
  mkdir -p packages/golang-1-linux
  cat >packages/golang-1-linux/spec <<EOF
---
name: golang-1-linux
files:
- golang-1-linux/$GO_BLOB_FILENAME
EOF

  # Remove old spec.lock if present
  rm -f packages/golang-1-linux/spec.lock

  # Remove old Golang blob entries
  if [[ -f config/blobs.yml ]]; then
    yq eval 'with_entries(select(.key | test("^golang-1-linux/") | not))' -i config/blobs.yml
  fi

  # Add new Golang blob
  bosh add-blob "$GO_BLOB_PATH" "golang-1-linux/$GO_BLOB_FILENAME"

  # If this is the rootfs repo, also update the rootfs blob
  if [[ "$repo_path" == "$ROOTFS_REPO" ]]; then
    echo "=== Updating rootfs blob in $repo_path ==="
    # Remove old rootfs entry
    if [[ -f config/blobs.yml ]]; then
      yq eval "del(.\"rootfs/${STACK}-${VERSION}.tar.gz\")" -i config/blobs.yml
    fi
    bosh add-blob "$ROOTFS_BLOB_PATH" "rootfs/${STACK}-${VERSION}.tar.gz"
  fi

  # Upload blobs
  bosh upload-blobs

  # Commit changes
  git config --global user.email "ci-bot@example.com"
  git config --global user.name "CI Bot"
  git add packages/golang-1-linux/spec config/blobs.yml
  if [[ -d .final_builds ]]; then
    git add .final_builds
  fi
  git commit -m "Update golang-1-linux to $GO_BLOB_FILENAME" || echo "No changes to commit"

  cd - >/dev/null
}

# --- Find all repos with golang-1-linux package ---
for repo in $(find . -type d -path "*/packages/golang-1-linux" | sed 's|/packages/golang-1-linux||' | sort -u); do
  # Skip the root directory
  if [[ "$repo" == "." ]]; then
    continue
  fi
  update_repo "$repo"
done

echo "=== Blob update complete ==="

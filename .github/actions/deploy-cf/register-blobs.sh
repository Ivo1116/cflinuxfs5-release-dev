#!/usr/bin/env bash
set -euo pipefail
STACK=$1
VERSION=$2

GO_BLOB_FILENAME=$(cat "$STACK-release/.go_blob_name")

# Find all repos with golang-1-linux package
for repo in $(find . -type d -path "*/packages/golang-1-linux" | sed 's|/packages/golang-1-linux||'); do
  echo "=== Updating Golang blob in repo: $repo ==="
  cd "$repo"

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

  # Add new blob
  bosh add-blob "../$STACK-release/blobs/golang-1-linux/$GO_BLOB_FILENAME" \
    "golang-1-linux/$GO_BLOB_FILENAME"

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
done

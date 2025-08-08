ROOTFS_REPO="$STACK-release"
GO_BLOB_FILENAME=$(cat "$ROOTFS_REPO/.go_blob_name")
GO_BLOB_PATH="$(pwd)/$ROOTFS_REPO/blobs/golang-1-linux/$GO_BLOB_FILENAME"

for repo in $(find . -type d -path "*/packages/golang-1-linux" | sed 's|/packages/golang-1-linux||' | sort -u); do
  # Skip the root directory
  if [[ "$repo" == "." ]]; then
    continue
  fi

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

  # Add new blob from rootfs repo
  bosh add-blob "$GO_BLOB_PATH" "golang-1-linux/$GO_BLOB_FILENAME"

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

#!/usr/bin/env bash
set -euo pipefail
STACK=$1

cd "$STACK-release"
mkdir -p blobs/golang-1-linux

LATEST_GO_FILE=$(curl -s https://go.dev/dl/?mode=json |
  jq -r '.[] | select(.stable == true) | .files[] | select(.os == "linux" and .arch == "amd64" and .kind == "archive") | .filename' | head -n 1)

if [[ -z "$LATEST_GO_FILE" ]]; then
  echo "WARNING: Could not detect latest Go version, using fallback"
  LATEST_GO_FILE="go1.21.8.linux-amd64.tar.gz"
fi

curl -L --fail -o "blobs/golang-1-linux/$LATEST_GO_FILE" "https://go.dev/dl/$LATEST_GO_FILE"
echo "$LATEST_GO_FILE" >.go_blob_name
echo "Go blob ready: blobs/golang-1-linux/$LATEST_GO_FILE"

#!/usr/bin/env bash
set -euo pipefail

BUILDPACKS_CI_PATH="$1"
NEW_CVES_PATH="$2"
CFLINUXFS5_PATH="$3"

# Optional: DockerHub login if needed for private images
if [[ -n "${DOCKERHUB_USERNAME:-}" && -n "${DOCKERHUB_PASSWORD:-}" ]]; then
  echo "Logging in to DockerHub..."
  echo "$DOCKERHUB_PASSWORD" | docker login -u "$DOCKERHUB_USERNAME" --password-stdin
fi

# Copy new-cves to output-new-cves (mimic Concourse output)
rsync -a "$NEW_CVES_PATH/" output-new-cves/

# Install Ruby dependencies
cd "$BUILDPACKS_CI_PATH"
bundle install

# Run the Ruby script (adapted to accept stack as argument)
if [ -f "./tasks/check-for-new-rootfs-cves-cflinuxfs4/run.rb" ]; then
  bundle exec ./tasks/check-for-new-rootfs-cves-cflinuxfs4/run.rb cflinuxfs5
else
  echo "ERROR: Ruby script not found!"
  exit 1
fi
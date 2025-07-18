#!/usr/bin/env bash
set -euo pipefail

CFLINUXFS5_RELEASE_PATH="$1"
GOLANG_RELEASE_PATH="$2"
GIT_USER_NAME="$3"
GIT_USER_EMAIL="$4"
PACKAGES="$5"
PACKAGES_TO_REMOVE="$6"
PRIVATE_YML="$7"
RELEASE_DIR="$8"

cd "$CFLINUXFS5_RELEASE_PATH/$RELEASE_DIR"

git config user.name "$GIT_USER_NAME"
git config user.email "$GIT_USER_EMAIL"

for package_to_remove in $(echo "$PACKAGES_TO_REMOVE" | jq -r '.[]'); do
  rm -rf "packages/$package_to_remove"
done

echo "$PRIVATE_YML" > config/private.yml

for package in $(echo "$PACKAGES" | jq -r '.[]'); do
  bosh vendor-package "$package" "$GOLANG_RELEASE_PATH"
done

if [ -z "$(git status --porcelain)" ]; then
  echo "No changes to commit."
  exit 0
fi

git add -A

package_list=$(echo "$PACKAGES" | jq -r 'join(", ")')
first_package=$(echo "$PACKAGES" | jq -r '.[0]')
first_version=$(cat "$GOLANG_RELEASE_PATH/packages/$first_package/version")
git commit -m "Update $package_list packages to $first_version from golang-release

Removed: $(echo "$PACKAGES_TO_REMOVE" | jq -r '. | join(", ")')"
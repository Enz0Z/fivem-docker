#!/bin/sh
# Commits the changes left by update.sh, one commit per upstream that moved.
# Prints "legacy=true" / "enhanced=true" for each image that needs a rebuild.
set -eu
cd "$(dirname "$0")"

legacy=false
enhanced=false

for edition in legacy enhanced; do
    git diff --quiet -- "$edition.env" && continue
    old=$(git show "HEAD:$edition.env" | sed -n 's/^FIVEM_NUM=//p')
    new=$(sed -n 's/^FIVEM_NUM=//p' "$edition.env")
    git commit -q -m "build: bump $edition $old -> $new" -- "$edition.env"
    eval "$edition=true"
done

if ! git diff --quiet -- Dockerfile; then
    old=$(git show HEAD:Dockerfile | sed -n 's/^ARG DATA_VER=//p' | cut -c1-7)
    new=$(sed -n 's/^ARG DATA_VER=//p' Dockerfile | cut -c1-7)
    git commit -q -m "build: bump cfx-server-data $old -> $new" -- Dockerfile
    legacy=true
    enhanced=true
fi

[ "$legacy" = true ] && echo "legacy=true"
[ "$enhanced" = true ] && echo "enhanced=true"
exit 0

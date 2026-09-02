#!/bin/sh
# Bumps FIVEM_NUM/FIVEM_VER/DATA_VER in the Dockerfile to the latest upstream artifacts.
set -eu
cd "$(dirname "$0")"

# ponytail: grep instead of jq so it runs anywhere (CI runner, Git Bash, busybox)
ver=$(curl -fsSL https://changelogs-live.fivem.net/api/changelog/versions/linux/server \
    | grep -o '"recommended_download":"[^"]*"' | grep -o '[0-9]*-[0-9a-f]*/fx' | cut -d/ -f1)
num=${ver%%-*}
data=$(curl -fsSL https://api.github.com/repos/citizenfx/cfx-server-data/commits/master \
    | grep -m1 -o '"sha": *"[0-9a-f]\{40\}"' | grep -o '[0-9a-f]\{40\}')

[ -n "$ver" ] && [ -n "$num" ] && [ -n "$data" ] || { echo "failed to resolve versions" >&2; exit 1; }

sed -i "s/^ARG FIVEM_NUM=.*/ARG FIVEM_NUM=$num/; s/^ARG FIVEM_VER=.*/ARG FIVEM_VER=$ver/; s/^ARG DATA_VER=.*/ARG DATA_VER=$data/" Dockerfile
echo "FiveM $ver, cfx-server-data $data"

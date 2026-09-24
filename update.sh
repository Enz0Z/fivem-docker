#!/bin/sh
# Bumps legacy.env / enhanced.env / DATA_VER to the latest upstream artifacts.
set -eu
cd "$(dirname "$0")"

# ponytail: grep instead of jq so it runs anywhere (CI runner, Git Bash, busybox)
legacy=$(curl -fsSL https://changelogs-live.fivem.net/api/changelog/versions/linux/server \
    | grep -o '"recommended_download":"[^"]*"' | grep -o 'https://[^"]*')
legacy_num=$(echo "$legacy" | grep -o '/[0-9]*-[0-9a-f]*/fx' | cut -d- -f1 | tr -d /)

# Enhanced has no public JSON feed; the docs download page embeds the current build in its Next.js data
enhanced=$(curl -fsSL https://docs.fivem.net/docs/server-download/ \
    | grep -o '"displayName":"cfx-server_linux_x64.tar.xz","subtitle":"build [0-9]*","downloadURL":"[^"]*"')
enhanced_num=$(echo "$enhanced" | grep -o 'build [0-9]*' | cut -d' ' -f2)
enhanced_url=$(echo "$enhanced" | grep -o 'https://[^"]*')

data=$(curl -fsSL https://api.github.com/repos/citizenfx/cfx-server-data/commits/master \
    | grep -m1 -o '"sha": *"[0-9a-f]\{40\}"' | grep -o '[0-9a-f]\{40\}')

[ -n "$legacy" ] && [ -n "$legacy_num" ] && [ -n "$enhanced_url" ] && [ -n "$enhanced_num" ] && [ -n "$data" ] \
    || { echo "failed to resolve versions" >&2; exit 1; }

printf 'FIVEM_NUM=%s\nFIVEM_URL=%s\n' "$legacy_num" "$legacy" > legacy.env
printf 'FIVEM_NUM=%s\nFIVEM_URL=%s\n' "$enhanced_num" "$enhanced_url" > enhanced.env
sed -i "s/^ARG DATA_VER=.*/ARG DATA_VER=$data/" Dockerfile
echo "legacy $legacy_num & enhanced $enhanced_num"

#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

if sed --version 2>/dev/null | grep -q "GNU sed"; then
    SED="sed"
elif gsed --version 2>/dev/null | grep -q "GNU sed"; then
    SED="gsed"
fi

cd "$(dirname "${BASH_SOURCE[0]}")/.."
set -x

_VERSION=$(curl --silent https://api.github.com/repos/vectordotdev/vector/releases/latest \
  | grep -oE "tag_name\": *\".{1,15}\"," \
  | ${SED:-sed} 's/tag_name\": *\"v//;s/\",//')

# make MacOS sed happy
${SED:-sed} -E -i.bak "s/([0-9]+)\.([0-9]+)\.([0-9]+)-distroless-libc/${_VERSION}-distroless-libc/" charts/vector/Chart.yaml
rm -f "charts/vector/Chart.yaml.bak"

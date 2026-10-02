#!/usr/bin/env bash
# Usage: release-vector-version.sh <vector version, e.g. 0.59.0>
set -euo pipefail
IFS=$'\n\t'

_VERSION=${1:?Usage: $0 <vector version, e.g. 0.59.0>}
[[ "$_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || {
  echo "Vector version must be major.minor.patch: $_VERSION" >&2
  exit 1
}

if sed --version 2>/dev/null | grep -q "GNU sed"; then
    SED="sed"
elif gsed --version 2>/dev/null | grep -q "GNU sed"; then
    SED="gsed"
fi

cd "$(dirname "${BASH_SOURCE[0]}")/.."
set -x

${SED:-sed} -E -i "s/([0-9]+)\.([0-9]+)\.([0-9]+)-distroless-libc/$_VERSION-distroless-libc/" charts/vector/Chart.yaml

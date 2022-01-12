#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

cd "$(dirname "${BASH_SOURCE[0]}")/.."
set -x

_chart_version=$(yq eval .version "charts/vector/Chart.yaml")
git cliff --config .github/cliff.toml -t "vector-$_chart_version" -p CHANGELOG.md -u

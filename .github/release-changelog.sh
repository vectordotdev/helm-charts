#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

cd "$(dirname "${BASH_SOURCE[0]}")/.."
set -x

_chart_version=$(yq eval .version "charts/vector/Chart.yaml")
git cliff --config .github/cliff.toml --tag "vector-$_chart_version" --prepend CHANGELOG.md --unreleased

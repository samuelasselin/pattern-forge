#!/usr/bin/env bash
# detect-deps.sh — scan a directory for known dependency files and output JSON
# Usage: detect-deps.sh [directory]
# Outputs a JSON array of { file, ecosystem, path } objects.
# No external dependencies (no jq required).

set -euo pipefail

TARGET_DIR="${1:-.}"

# Resolve to an absolute path (works on both macOS and Linux)
if command -v realpath >/dev/null 2>&1; then
  TARGET_DIR="$(realpath "$TARGET_DIR")"
else
  # Fallback: use pwd-based resolution
  TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"
fi

# Each entry: "filename|ecosystem"
KNOWN_DEPS=(
  "package.json|node"
  "Gemfile|ruby"
  "requirements.txt|python"
  "pyproject.toml|python"
  "Pipfile|python"
  "Cargo.toml|rust"
  "go.mod|go"
  "composer.json|php"
  "build.gradle|java"
  "build.gradle.kts|java"
  "pom.xml|java"
  "pubspec.yaml|dart"
  "Package.swift|swift"
  "mix.exs|elixir"
)

# Build JSON manually — no jq dependency
json_entries=()

for entry in "${KNOWN_DEPS[@]}"; do
  dep_file="${entry%%|*}"
  ecosystem="${entry##*|}"
  full_path="${TARGET_DIR}/${dep_file}"

  if [ -f "$full_path" ]; then
    # Escape backslashes and double-quotes in each field (defensive, paths
    # shouldn't normally contain these but correctness matters).
    escaped_file="${dep_file//\\/\\\\}"
    escaped_file="${escaped_file//\"/\\\"}"

    escaped_eco="${ecosystem//\\/\\\\}"
    escaped_eco="${escaped_eco//\"/\\\"}"

    escaped_path="${full_path//\\/\\\\}"
    escaped_path="${escaped_path//\"/\\\"}"

    json_entries+=(
      "  {
    \"file\": \"${escaped_file}\",
    \"ecosystem\": \"${escaped_eco}\",
    \"path\": \"${escaped_path}\"
  }"
    )
  fi
done

# Output the JSON array
if [ "${#json_entries[@]}" -eq 0 ]; then
  echo "[]"
else
  echo "["
  for i in "${!json_entries[@]}"; do
    if [ "$i" -lt $(( ${#json_entries[@]} - 1 )) ]; then
      echo "${json_entries[$i]},"
    else
      echo "${json_entries[$i]}"
    fi
  done
  echo "]"
fi

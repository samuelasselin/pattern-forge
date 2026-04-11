#!/usr/bin/env bash
# check-deps.sh — SessionStart hook for pattern-forge
# Checks whether the project is initialized and whether dependencies have drifted.
# No external dependencies (no jq required).

set -euo pipefail

# The hook runs in the user's project directory.
CWD="${1:-.}"

DESIGN_CHOICES="${CWD}/.claude/pattern-forge/design-choices.json"
DETECTION_REPORT="${CWD}/.claude/pattern-forge/detection-report.json"
HISTORY="${CWD}/.claude/pattern-forge/history.json"

# ---------------------------------------------------------------------------
# Check 1 — Not initialized
# ---------------------------------------------------------------------------
if [ ! -f "$DESIGN_CHOICES" ]; then
  printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"This project has not been initialized with pattern-forge yet. The user can run /pattern-forge:init to set up conventions and design patterns for this codebase."}}\n'
  exit 0
fi

# ---------------------------------------------------------------------------
# Check 2 — Dependency drift
# ---------------------------------------------------------------------------

# We need both support files to perform the drift check; silently skip if missing.
if [ ! -f "$DETECTION_REPORT" ] || [ ! -f "$HISTORY" ]; then
  exit 0
fi

# -- Helper: read a bare string value from simple JSON (no jq) ---------------
# Usage: json_get_value <file> <key>
# Works for top-level string fields like: "ecosystem": "node"
json_get_value() {
  local file="$1"
  local key="$2"
  grep -o "\"${key}\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" "$file" \
    | head -1 \
    | sed 's/.*"[^"]*"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/'
}

# -- Read ecosystem and dependency_file from detection-report.json -----------
ecosystem="$(json_get_value "$DETECTION_REPORT" "ecosystem")"
dependency_file="$(json_get_value "$DETECTION_REPORT" "dependency_file")"

if [ -z "$ecosystem" ] || [ -z "$dependency_file" ]; then
  exit 0
fi

dep_path="${CWD}/${dependency_file}"
if [ ! -f "$dep_path" ]; then
  exit 0
fi

# -- Extract the snapshot deps from history.json ----------------------------
# The dependency_snapshot field looks like:
#   "dependency_snapshot": ["dep1", "dep2", ...]
# We extract everything between the brackets of that array.
snapshot_block="$(
  awk '
    /\"dependency_snapshot\"/ { found=1 }
    found {
      buf = buf $0
      if (gsub(/\[/, "[", buf) > 0 && gsub(/\]/, "]", buf) > 0) { print buf; exit }
    }
  ' "$HISTORY"
)"

# Pull out each quoted string from the snapshot array.
snapshot_deps=()
while IFS= read -r dep; do
  [ -n "$dep" ] && snapshot_deps+=("$dep")
done < <(
  printf '%s\n' "$snapshot_block" \
    | grep -o '"[^"]*"' \
    | grep -v '"dependency_snapshot"' \
    | sed 's/"//g'
)

# -- Extract current deps from the actual dependency file -------------------
current_deps=()

case "$ecosystem" in
  node)
    # Capture keys from the "dependencies" and "devDependencies" objects.
    # Lines look like:   "react": "^18.0.0",
    in_deps_block=0
    while IFS= read -r line; do
      # Detect start of dependencies / devDependencies blocks
      if printf '%s\n' "$line" | grep -qE '"(dependencies|devDependencies)"[[:space:]]*:'; then
        in_deps_block=1
        continue
      fi
      # Detect end of the block (closing brace)
      if [ "$in_deps_block" -eq 1 ] && printf '%s\n' "$line" | grep -qE '^[[:space:]]*\}'; then
        in_deps_block=0
        continue
      fi
      # Inside a block: extract the package name (the key)
      if [ "$in_deps_block" -eq 1 ]; then
        dep="$(printf '%s\n' "$line" | sed -n 's/[[:space:]]*"\([^"]*\)"[[:space:]]*:.*/\1/p')"
        [ -n "$dep" ] && current_deps+=("$dep")
      fi
    done < "$dep_path"
    ;;

  ruby)
    # Lines look like: gem 'name' or gem "name"
    while IFS= read -r line; do
      dep="$(printf '%s\n' "$line" | sed -n "s/^[[:space:]]*gem[[:space:]]*['\"]\\([^'\"]*\\)['\"].*/\\1/p")"
      [ -n "$dep" ] && current_deps+=("$dep")
    done < "$dep_path"
    ;;

  python)
    # requirements.txt: lines like package==1.0 or package>=1.0 or just package
    while IFS= read -r line; do
      # Strip comments and blank lines
      line="$(printf '%s\n' "$line" | sed 's/#.*//' | sed 's/[[:space:]]//g')"
      [ -z "$line" ] && continue
      # Skip options lines (start with -)
      printf '%s\n' "$line" | grep -q '^-' && continue
      # Extract the package name (everything before a version specifier or bracket)
      dep="$(printf '%s\n' "$line" | sed 's/[>=<!;[].*//' | sed 's/[[:space:]]//g')"
      [ -n "$dep" ] && current_deps+=("$dep")
    done < "$dep_path"
    ;;

  go)
    # go.mod require block lines look like:
    #   github.com/some/module v1.2.3
    in_require=0
    while IFS= read -r line; do
      if printf '%s\n' "$line" | grep -qE '^require[[:space:]]*\('; then
        in_require=1
        continue
      fi
      if [ "$in_require" -eq 1 ] && printf '%s\n' "$line" | grep -qE '^\)'; then
        in_require=0
        continue
      fi
      # Single-line require (outside a block): require module v1.2.3
      if printf '%s\n' "$line" | grep -qE '^require[[:space:]]+[^(]'; then
        dep="$(printf '%s\n' "$line" | sed 's/^require[[:space:]]*//' | awk '{print $1}')"
        [ -n "$dep" ] && current_deps+=("$dep")
        continue
      fi
      if [ "$in_require" -eq 1 ]; then
        # Skip blank lines and comments
        trimmed="$(printf '%s\n' "$line" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*\/\/.*//')"
        [ -z "$trimmed" ] && continue
        dep="$(printf '%s\n' "$trimmed" | awk '{print $1}')"
        [ -n "$dep" ] && current_deps+=("$dep")
      fi
    done < "$dep_path"
    ;;

  *)
    # Unknown ecosystem — silently skip drift check
    exit 0
    ;;
esac

# -- Compare snapshot vs current --------------------------------------------
# Build associative-map-style comparison using sorted lists.

added=()
removed=()

# Find items in current but not in snapshot (added)
for dep in "${current_deps[@]}"; do
  found=0
  for snap in "${snapshot_deps[@]}"; do
    if [ "$dep" = "$snap" ]; then
      found=1
      break
    fi
  done
  [ "$found" -eq 0 ] && added+=("$dep")
done

# Find items in snapshot but not in current (removed)
for snap in "${snapshot_deps[@]}"; do
  found=0
  for dep in "${current_deps[@]}"; do
    if [ "$snap" = "$dep" ]; then
      found=1
      break
    fi
  done
  [ "$found" -eq 0 ] && removed+=("$snap")
done

# No drift — silent exit
if [ "${#added[@]}" -eq 0 ] && [ "${#removed[@]}" -eq 0 ]; then
  exit 0
fi

# -- Build the context message -----------------------------------------------
added_str=""
removed_str=""

if [ "${#added[@]}" -gt 0 ]; then
  added_str="Added: $(IFS=', '; echo "${added[*]}")"
fi

if [ "${#removed[@]}" -gt 0 ]; then
  removed_str="Removed: $(IFS=', '; echo "${removed[*]}")"
fi

if [ -n "$added_str" ] && [ -n "$removed_str" ]; then
  diff_str="${added_str}. ${removed_str}."
elif [ -n "$added_str" ]; then
  diff_str="${added_str}."
else
  diff_str="${removed_str}."
fi

printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"Dependencies have changed since the last pattern-forge run. %s The user can run /pattern-forge:update to review new pattern suggestions."}}\n' \
  "$diff_str"

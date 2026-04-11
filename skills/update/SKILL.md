---
name: update
description: Use when dependencies have changed in the project (added or removed packages) to update the conventions-enforcing agent with new patterns. Also triggered when SessionStart detects dependency drift.
---

# Update Conventions

Re-scan the project dependencies, compare against the existing configuration, and propose changes to the conventions agent. The user approves or rejects each change individually.

## Prerequisites

The project must have been initialized with pattern-forge. These files must exist:
- `.claude/pattern-forge/design-choices.json`
- `.claude/pattern-forge/detection-report.json`
- `.claude/pattern-forge/history.json`

If any are missing, tell the user to run `/pattern-forge:init` first.

## Step 1: Re-Run Detection

Perform the same analysis as the detect skill:

1. Run the dependency detection script:
   ```bash
   bash "${CLAUDE_PLUGIN_ROOT}/scripts/detect-deps.sh" "$(pwd)"
   ```
2. Read the primary dependency file
3. Parse all dependencies
4. Analyze in three tiers (A: dependency-driven, B: complementary, C: best practices)

Save the new detection report to `.claude/pattern-forge/detection-report.json` (overwriting the previous one).

## Step 2: Compute the Diff

Compare the new detection against the existing state:

### Dependencies Diff
Read the last `dependency_snapshot` from `history.json` and compare with current dependencies.
- **Added dependencies**: New packages that weren't in the last snapshot
- **Removed dependencies**: Packages in the last snapshot that are no longer installed

### Pattern Diff
Compare newly proposed patterns against existing `design-choices.json`:
- **New patterns**: Patterns proposed now that weren't in the previous choices (from new deps or new combos)
- **Orphaned patterns**: Existing patterns whose required dependencies have been removed
- **Unchanged patterns**: Patterns that are still valid with current deps

### Rejection Re-Evaluation
Read `.claude/pattern-forge/rejections.json` (if exists). For each rejection:
- Check if the current dependency set is a **strict superset** of the rejection's `dependency_context`
- If new relevant dependencies were added → the pattern is eligible for re-proposal
- If the dependency context is unchanged → the rejection stands, do not re-propose

## Step 3: Present Changes to User

If no changes are detected (no new deps, no removed deps, no new patterns), report: "Everything is up to date. No new patterns to suggest." and exit.

Otherwise, present each proposed change individually. Do NOT batch them.

### For New Patterns:

```
**New pattern available: [Pattern Name]**
Category: [Category]
Triggered by: [which new dependencies or combinations]

[Explain the pattern in 2-3 sentences]
[Explain why this combination of libraries makes this pattern valuable]

Would you like to adopt this pattern?
```

### For Re-Proposed (Previously Rejected) Patterns:

```
**Pattern worth reconsidering: [Pattern Name]**
Category: [Category]
Previously rejected when you had: [old dependency context]
Now you also have: [new dependencies]

[Explain why the new dependency changes the calculus]
[Explain what the pattern looks like with the full library set]

Would you like to adopt this pattern now?
```

### For Orphaned Patterns:

```
**Pattern may need attention: [Pattern Name]**
Category: [Category]
Depends on: [removed dependency]

[Explain that the dependency was removed]
[Suggest alternatives or ask if the pattern should be removed]

Remove this pattern from conventions?
```

Wait for the user's response to each change before presenting the next one.

## Step 4: Record Decisions

For each change:
- **Accepted new pattern**: Add to `design-choices.json`
- **Rejected new pattern**: Add to `rejections.json` with current `dependency_context`
- **Accepted re-proposal**: Move from `rejections.json` to `design-choices.json`
- **Re-rejected re-proposal**: Update the rejection entry with the new `dependency_context`
- **Accepted orphan removal**: Remove from `design-choices.json`
- **Kept orphan**: Leave in `design-choices.json` (user may have a replacement planned)

Update `rejections.json` with any new rejections:

```json
{
  "pattern_id": "pattern-id",
  "rejected_at": "ISO 8601 timestamp",
  "dependency_context": ["sorted", "current", "dep", "list"],
  "reason_given": "user's reason if provided, or 'Declined without reason'"
}
```

## Step 5: Regenerate (If Changes Accepted)

If any changes were accepted:

1. Update `design-choices.json` with the new pattern set and updated `dependency_snapshot`
2. Regenerate the three outputs using the same logic as the generate skill:
   - `.claude/agents/conventions-enforcer.md` — regenerated with full pattern set
   - `CLAUDE.md` — pattern-forge section replaced between markers
   - `.claude/settings.local.json` — hook preserved as-is (doesn't change)
3. Append a new run to `history.json`:

```json
{
  "type": "update",
  "timestamp": "ISO 8601 timestamp",
  "dependency_snapshot": ["current", "sorted", "deps"],
  "patterns_added": ["new-pattern-ids"],
  "patterns_removed": ["removed-pattern-ids"],
  "patterns_rejected": ["rejected-pattern-ids"]
}
```

## Step 6: Summary

After all changes are processed:

1. Summarize what changed:
   - Patterns added
   - Patterns removed
   - Patterns rejected (saved for future re-evaluation)
   - Patterns unchanged
2. List the files that were regenerated
3. "Conventions updated. The agent will enforce the new patterns on your next prompt."

If nothing was accepted: "No changes applied. Your conventions remain unchanged."

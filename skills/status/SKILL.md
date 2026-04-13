---
name: status
description: Use to check the current state of pattern-forge in this project. Shows active patterns, health checks, and drift detection. Pass --full as argument for detailed conventions with code examples.
---

# Pattern Forge Status

Display the current state of pattern-forge in this project: active patterns, health checks, and dependency drift detection.

## Arguments

- No arguments: Quick summary (one-liner per pattern, health checks)
- `--full` (`$ARGUMENTS` contains "--full"): Detailed report with full convention rules and code examples

## Not Initialized

If `.claude/pattern-forge/design-choices.json` does not exist, display:

```
Pattern Forge — Not Initialized

This project has not been set up with pattern-forge yet.
Run /pattern-forge:init to detect dependencies and set up conventions.
```

Then stop. Do not proceed with health checks.

## Quick Summary (default)

Read these files and compile the health check:

1. **Design choices** — Read `.claude/pattern-forge/design-choices.json` for the pattern list and `last_updated` date
2. **Detection report** — Read `.claude/pattern-forge/detection-report.json` for `ecosystem`, `framework`, `framework_version`, and dependency count (count keys in `dependencies` object)
3. **History** — Read `.claude/pattern-forge/history.json` for the last run's timestamp
4. **Context7 MCP** — Check availability by calling `resolve-library-id` with the query "react". Report available or unavailable.
5. **Hook status** — Read `.claude/settings.json` and check if a `UserPromptSubmit` hook containing "conventions-enforcer" exists. Report active or missing.
6. **Drift check** — Run `bash "${CLAUDE_PLUGIN_ROOT}/scripts/check-deps.sh"` and parse the output. If it reports added/removed dependencies, show drift warning. If silent, report no drift.
7. **Migration heuristic** — For each active pattern in `design-choices.json`, do a lightweight glob based on the pattern's category:
   - Forms & Validation → `**/*{form,Form}*.{ts,tsx,js,jsx,vue}`
   - API Layer → `**/{api,services}/**`
   - UI Components → `**/components/**`
   - Testing → `**/*.{test,spec}.{ts,tsx,js,jsx}`
   - File Organization → top-level project directory listing
   - Other categories → skip (heuristic not available)

   Exclude `node_modules`, `.git`, `dist`, `build`, `.next`, `vendor`, `target`, `.venv`, `__pycache__`.

   If matching files exist for a pattern, count it toward the migration heuristic. Report: "N patterns may have legacy code" where N is the count. If zero, report "No migrations indicated."

   This is a lightweight signal only — users run `/pattern-forge:migrate` for actual analysis.

Present the results in this format:

```
Pattern Forge — Health Check
═══════════════════════════════

Status:        ✅ Initialized
Last updated:  [date from history.json]
Ecosystem:     [ecosystem] ([framework] [version])
Dependencies:  [count] tracked

Context7 MCP:  ✅ Available | ❌ Not available
Hook:          ✅ Active in .claude/settings.json | ❌ Missing
Drift:         ✅ No changes | ⚠️ [N] dependencies added, [M] removed
Migrations:    ✅ No migrations indicated | ⚠️ [N] patterns may have legacy code

Active Patterns ([count]):
  • [Category]    → [choice summary]
  • [Category]    → [choice summary]
  • ...
```

If drift is detected, add: `Run /pattern-forge:update to review new pattern suggestions.`
If hook is missing, add: `Run /pattern-forge:generate to set up the enforcement hook.`
If context7 is unavailable, add: `Install context7 MCP: https://github.com/upstash/context7`
If migrations are indicated, add: `Run /pattern-forge:migrate to generate a refactor plan.`

Always end with: `Run /pattern-forge:status --full for detailed conventions with code examples.`

## Full Report (--full flag)

Display everything from the quick summary, PLUS for each active pattern:

1. Read `.claude/agents/conventions-enforcer.md`
2. For each pattern in `design-choices.json`:
   - **Pattern name and category**
   - **Source**: dependency-driven, industry-best-practice, or user-custom
   - **Libraries involved**: from `details.libraries`
   - **Documentation-backed**: yes/no (from `detection-report.json` if the `documentation_backed` field exists)
   - **Rules**: from `details.rules`
   - **Code examples**: extract the relevant convention section from the agent file

Present each pattern in a readable format:

```
### [Category]: [Choice]
Source: [dependency-driven | industry-best-practice | user-custom]
Libraries: [lib1, lib2]
Documentation: ✅ Backed by context7 docs | ⚠️ Based on training knowledge

Rules:
  - [rule 1]
  - [rule 2]

Example:
  [code example from agent file]
```

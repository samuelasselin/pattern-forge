---
name: migrate
description: Use to generate a migration plan that refactors existing code to match a chosen pattern-forge pattern. Run after /pattern-forge:init when you want to align legacy code with new conventions. Accepts an optional pattern ID argument.
---

# Generate a Migration Plan

Scan the codebase for code that uses a different pattern than the one chosen during design, and produce a self-contained markdown plan that refactors it.

## Prerequisites

Verify that `.claude/pattern-forge/design-choices.json` exists. If it does not exist, display:

```
Pattern Forge has not been initialized for this project.
Run /pattern-forge:init first.
```

Then stop.

## Step 1: Pattern Selection

If `$ARGUMENTS` contains a pattern ID that matches an entry in `design-choices.json`, use that pattern. Skip to Step 2.

Otherwise, read `.claude/pattern-forge/design-choices.json` and present all active patterns as a numbered list:

```
Which pattern to migrate?
  1. [Category] → [choice]
  2. [Category] → [choice]
  ...
```

Wait for the user's selection.

## Step 2: Targeted Codebase Scan

Use the pattern's category and `details` from `design-choices.json` to decide what to look for. Use file globs and targeted reads — do NOT read every file in the project.

Common scan strategies by category:

| Category | Glob / Search |
|----------|---------------|
| Forms & Validation | `**/*{form,Form}*.{ts,tsx,js,jsx,vue}`, files importing form libraries |
| API Layer / Data Fetching | `**/{api,services,lib}/**`, grep for `fetch(`, `axios.`, `get(`, `post(` |
| State Management | Files with `useState`, `useReducer`, store imports |
| UI Components | `**/components/**` |
| Error Handling | Files with `try {`, `catch`, error boundary imports |
| File Organization | Top-level project tree structure |
| Testing Strategy | `**/*.{test,spec}.{ts,tsx,js,jsx,py,rb}` |
| Authentication | Files with auth-related imports or middleware |

Always exclude these paths from scanning: `node_modules`, `.git`, `dist`, `build`, `.next`, `vendor`, `target`, `.venv`, `__pycache__`.

If the pattern's category is not in the table above, use your judgment based on the pattern `details` to decide what to look for.

## Step 3: Identify Mismatches

For each relevant file found:

1. Read the file (or the relevant section)
2. Determine if it follows the chosen pattern
3. If not, classify the gap:
   - **Minor**: small diff (a few lines), e.g., switching from inline fetch to the centralized API client
   - **Moderate**: restructure needed, e.g., extracting a hook into a Provider
   - **Full rewrite**: file uses a fundamentally different approach

Skip files that already match the pattern.

## Step 4: Generate Migration Plan

Determine the plan file path: `.claude/pattern-forge/migrations/YYYY-MM-DD-[pattern-id].md` where `YYYY-MM-DD` is today's date and `[pattern-id]` is the pattern's `id` field.

Create the `.claude/pattern-forge/migrations/` directory if it does not exist. If the plan file already exists, overwrite it (the user has either finished executing the prior plan or wants a fresh one).

Write the plan using this exact structure:

````markdown
# Migration Plan: [Pattern Name]

**Generated:** YYYY-MM-DD
**Pattern ID:** [pattern-id]
**Category:** [category from design-choices.json]
**Target pattern:** [choice description from design-choices.json]
**Files to migrate:** N
**Estimated effort:** [X minor, Y moderate, Z full rewrites]

---

## Execution Instructions

> **IMPORTANT:** For each file migration below, you MUST launch the conventions-enforcer agent (from `.claude/agents/`) to validate the migrated code matches all project conventions. Do NOT skip this step. If the enforcer flags issues, fix them before moving to the next file.

Execute migrations in the order listed — dependencies first, then dependents.

If you are an AI agent executing this plan, use the `superpowers:executing-plans` skill to walk through the checklist systematically.

---

## Pre-migration Checklist

- [ ] All tests pass on current code
- [ ] Working tree is clean (commit or stash pending changes)
- [ ] Current branch is a feature branch (not main)

---

## Migrations

### 1. [relative file path]

**Current pattern:** [one-line description of what the file does now]
**Target pattern:** [how it should look per the chosen convention]
**Effort:** [minor | moderate | full rewrite]

**Before:**
```[language]
[actual code excerpt from the file — the relevant section, not the whole file]
```

**After:**
```[language]
[proposed refactored code matching the chosen pattern]
```

**Steps:**
- [ ] [Concrete first step specific to this file]
- [ ] [Concrete second step]
- [ ] [Run relevant tests if they exist — be specific about the command]
- [ ] Launch conventions-enforcer agent to validate the migrated files
- [ ] Commit: `refactor(scope): [description]`

### 2. [next file path]
[...same structure...]

---

## Post-migration Checklist

- [ ] All tests pass
- [ ] Manual smoke test of affected features
- [ ] Update CLAUDE.md if any new utilities were introduced
- [ ] Final conventions-enforcer agent pass over all modified files
````

## Step 5: Order the Migrations

Before writing the plan, order the migrations so that dependencies are migrated before their consumers:

1. Shared utilities and hooks → migrate first
2. Providers and contexts → migrate second
3. Components that consume those → migrate last

This ensures the codebase compiles and tests pass throughout the migration.

## Step 6: Present Summary to User

After writing the plan, tell the user:

1. Number of files included in the plan
2. Effort breakdown (e.g., "3 minor edits, 2 moderate refactors, 1 full rewrite")
3. Absolute path to the generated plan file
4. Next steps: "Review the plan, then execute it when ready. You can ask Claude to execute it via `superpowers:executing-plans`, or migrate files manually. The plan requires the conventions-enforcer agent to validate each migration."

If no mismatches were found, tell the user: "All relevant files already match the [pattern name] pattern. No migration needed." Do NOT create a plan file in that case.

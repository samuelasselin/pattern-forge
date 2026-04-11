---
name: init
description: Use to set up pattern-forge for a new project. Runs the full setup flow — detects dependencies, walks through pattern selection, and generates the conventions agent. Run this once when starting a new project.
---

# Initialize Pattern Forge

Run the complete setup flow for a new project. This chains three steps:

1. **Detect** — Scan dependencies and propose patterns
2. **Design** — Interactive wizard to choose patterns per category
3. **Generate** — Produce the conventions agent, CLAUDE.md, and hook

## Before Starting

Check if `.claude/pattern-forge/design-choices.json` already exists. If it does, warn the user:

"This project has already been initialized with pattern-forge. Running init again will overwrite your existing design choices. If you want to update conventions after adding dependencies, use `/pattern-forge:update` instead. Continue with a fresh init?"

Wait for confirmation before proceeding. If the user declines, exit.

## Flow

### Phase 1: Detect

Follow the complete detect skill instructions:

1. Run `bash "${CLAUDE_PLUGIN_ROOT}/scripts/detect-deps.sh" "$(pwd)"` to find dependency files
2. If no files found, ask what ecosystem the user is targeting
3. If multiple ecosystems, ask which is primary
4. Read and parse the primary dependency file
5. Analyze in three tiers (dependency-driven patterns, complementary suggestions, best practices)
6. Save detection report to `.claude/pattern-forge/detection-report.json`
7. Present a summary of findings

**Transition:** "Now let's choose which patterns to adopt for this project."

### Phase 2: Design

Follow the complete design skill instructions:

1. Load the detection report
2. Group patterns by category
3. Present each category one at a time:
   - Explain 2-3 approaches with trade-offs
   - Include complementary library suggestions where relevant
   - Wait for the user's choice
   - Record the choice
4. Present any remaining library suggestions
5. Save design choices to `.claude/pattern-forge/design-choices.json`

**Transition:** "Great choices. Let me generate the conventions agent."

### Phase 3: Generate

Follow the complete generate skill instructions:

1. Read the design choices
2. Generate the conventions agent at `.claude/agents/conventions-enforcer.md`
3. Append/create the CLAUDE.md conventions section
4. Create/merge the UserPromptSubmit hook in `.claude/settings.local.json`
5. Create the initial `history.json` entry

**Completion:** Present the summary of generated files and confirm setup is complete.

"Pattern Forge setup complete! Your conventions agent is ready. From now on, Claude will validate all code against your chosen patterns. Run `/pattern-forge:update` whenever you add or remove dependencies."

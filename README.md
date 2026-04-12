# Pattern Forge

**Keep your codebase consistent from day one.** Pattern Forge scans your project's dependencies, looks up real documentation via [Context7 MCP](https://github.com/upstash/context7), and proposes the best design patterns for your specific stack. Once you pick your conventions, it generates an agent that enforces them on every prompt — for you and your entire team.

Instead of relying solely on AI training data (which can be outdated or miss library-specific patterns), Pattern Forge queries current documentation for each key dependency. This means the conventions it proposes are backed by what the library authors actually recommend, not what Claude thinks it remembers.

## Features

- **Documentation-backed** — Queries real library docs via Context7 MCP before proposing patterns, not just AI training data
- **Framework-agnostic** — Works with Node.js, Ruby, Python, Rust, Go, PHP, Java, Dart, Swift
- **Interactive** — Wizard-style Q&A, one category at a time, you control every decision
- **Team-wide enforcement** — Hook is committed to git, so every teammate gets convention enforcement automatically
- **Living conventions** — Re-runnable with smart diffing and context-aware re-proposals
- **Dependency suggestions** — Recommends complementary libraries based on your stack

## Skills

| Skill | Command | Purpose |
|-------|---------|---------|
| init | `/pattern-forge:init` | First-time setup: detect → design → generate |
| detect | `/pattern-forge:detect` | Scan dependencies and propose patterns |
| design | `/pattern-forge:design` | Interactive pattern selection wizard |
| generate | `/pattern-forge:generate` | Produce agent + hook + CLAUDE.md |
| update | `/pattern-forge:update` | Detect changes, review and approve updates |
| status | `/pattern-forge:status` | Health check, active patterns, drift detection |

## Installation

In Claude Code, run:

```
/plugin marketplace add samuelasselin/pattern-forge
/plugin install pattern-forge@samuelasselin-pattern-forge
```

To update to the latest version:

```
/plugin marketplace update samuelasselin-pattern-forge
```

## Prerequisites

Pattern Forge requires the **Context7 MCP server** for documentation-backed pattern detection.

Install it by adding context7 to your Claude Code MCP config:
- context7 — https://github.com/upstash/context7

The plugin will check for context7 availability on every run and provide install instructions if missing.

## Quick Start

1. Create your project and install your base dependencies
2. Run `/pattern-forge:init`
3. Answer the pattern selection questions
4. Start coding — the conventions agent validates your work automatically

## What It Generates

- `.claude/agents/conventions-enforcer.md` — Tailored agent with your chosen patterns
- `CLAUDE.md` — Appended conventions section for passive context
- `.claude/settings.json` — UserPromptSubmit hook for automatic enforcement (committed to git for team sharing)

## Updating

When you add or remove dependencies, run `/pattern-forge:update`. The plugin also detects dependency drift automatically on session start and reminds you to update.

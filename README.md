# Pattern Forge

A Claude Code plugin that detects your project's installed dependencies, proposes tailored design patterns and industry best practices, and generates a conventions-enforcing agent to keep your codebase consistent.

## Features

- **Framework-agnostic** — Works with Node.js, Ruby, Python, Rust, Go, PHP, Java, Dart, Swift
- **AI-powered** — Claude analyzes your dependencies at runtime, no static pattern database
- **Interactive** — Wizard-style Q&A, one category at a time, you control every decision
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

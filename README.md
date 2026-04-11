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

## Quick Start

/plugin marketplace add samuelasselin/pattern-forge

1. Create your project and install your base dependencies
2. Run `/pattern-forge:init`
3. Answer the pattern selection questions
4. Start coding — the conventions agent validates your work automatically

## What It Generates

- `.claude/agents/conventions-enforcer.md` — Tailored agent with your chosen patterns
- `CLAUDE.md` — Appended conventions section for passive context
- `.claude/settings.local.json` — UserPromptSubmit hook for automatic enforcement

## Updating

When you add or remove dependencies, run `/pattern-forge:update`. The plugin also detects dependency drift automatically on session start and reminds you to update.

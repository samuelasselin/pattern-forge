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
| migrate | `/pattern-forge:migrate` | Generate refactor plan to align existing code with chosen patterns |

## Tutorial: Using Pattern Forge From Start to Finish

Follow these steps in order. Each one builds on the previous.

### Step 1 — Install the plugin (once)

In Claude Code:

```
/plugin marketplace add samuelasselin/pattern-forge
/plugin install pattern-forge@samuelasselin-pattern-forge
```

Also install the **Context7 MCP server** (required for documentation lookups):
- https://github.com/upstash/context7

### Step 2 — Set up your project (once per project)

From inside any project directory — **new or existing** — run:

```
/pattern-forge:init
```

Pattern Forge reads whatever's already installed (`package.json`, `Gemfile`, `pyproject.toml`, `Cargo.toml`, etc.), so there's no prep required. If you're starting fresh, scaffold the project first (e.g. `pnpm create next-app@latest my-app && cd my-app`) and install your base dependencies — then run `init`. If you're opening an existing repo, just `cd` into it and run `init` as-is.

`init` walks you through the full setup:

1. **Detects** your dependencies
2. **Looks up real docs** via Context7 for your key libraries
3. **Asks you questions** one category at a time (forms, API layer, UI, etc.)
4. **Generates** three files:
   - A conventions-enforcer agent in `.claude/agents/`
   - A conventions section in `CLAUDE.md`
   - An auto-enforcement hook in `.claude/settings.json` (committable to git)

Commit these files so your whole team gets the conventions. If you ran `init` on a codebase that already has source files and want to bring existing code into line with your new patterns, see Step 4 (`/pattern-forge:migrate`).

### Step 3 — Start coding

Just write code normally. Every prompt you send, the enforcement hook automatically launches the conventions-enforcer agent to validate your work against the patterns you chose. No extra commands needed.

### Step 4 — Align your existing code (if any)

If you ran `/pattern-forge:init` on a project that already had code, run:

```
/pattern-forge:migrate
```

Pick a pattern you chose during setup. The plugin scans your existing code, identifies files using a different pattern, and writes a step-by-step **migration plan** to `.claude/pattern-forge/migrations/`. Each migration includes before/after code, concrete steps, and an instruction to validate with the conventions-enforcer agent.

You then execute the plan at your pace — manually or by asking Claude to run it.

### Step 5 — Check status any time

```
/pattern-forge:status
```

Shows a health check:
- Active patterns
- Is the enforcement hook in place?
- Is Context7 MCP available?
- Have dependencies changed since last run?
- Are there patterns with legacy code that could be migrated?

Add `--full` for detailed conventions with code examples: `/pattern-forge:status --full`

### Step 6 — Update when dependencies change

When you add or remove dependencies (e.g., `pnpm add zod`), run:

```
/pattern-forge:update
```

It re-scans, compares against your existing conventions, and proposes new patterns from the new libraries. You approve or reject each change individually.

The plugin also detects dependency drift automatically when you start a Claude Code session and reminds you to run update.

---

### Advanced: Run individual phases

`/pattern-forge:init` chains three skills together. You can also run them separately:

- `/pattern-forge:detect` — just scan dependencies and propose patterns
- `/pattern-forge:design` — just the interactive wizard (requires detect first)
- `/pattern-forge:generate` — just generate the agent/hook/CLAUDE.md (requires design first)

Most users only need `init`, `status`, `update`, and `migrate`.

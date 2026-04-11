---
name: detect
description: Use when starting a new project setup or when you need to scan a project's dependencies. Detects installed libraries, suggests complementary packages, and proposes design patterns based on the detected stack.
---

# Detect Dependencies & Propose Patterns

Scan the current project's dependency files, identify the ecosystem and framework, and produce a structured analysis with three tiers: dependency-driven patterns, complementary library suggestions, and industry best practices.

## Step 1: Scan for Dependency Files

Run the detection script to find dependency files in the current project:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/detect-deps.sh" "$(pwd)"
```

The script outputs a JSON array of found dependency files with their ecosystems.

**If no files found:** Ask the user what ecosystem they're targeting. Do not guess — the user may be starting from scratch.

**If multiple ecosystems found:** Ask the user which is the primary ecosystem. Example: "I found both package.json (Node.js) and requirements.txt (Python). Which is the primary ecosystem for this project?"

## Step 2: Read and Parse Dependencies

Read the primary dependency file and extract:
- All dependency names and versions
- Dev dependencies (if applicable)
- The framework (e.g., Next.js, Rails, Django)
- The framework version

**Ecosystem-specific parsing:**

| Ecosystem | File | Dependencies location |
|-----------|------|----------------------|
| Node.js | `package.json` | `dependencies` + `devDependencies` keys |
| Ruby | `Gemfile` | `gem 'name'` lines |
| Python | `requirements.txt` | One package per line |
| Python | `pyproject.toml` | `[project] dependencies` array |
| Rust | `Cargo.toml` | `[dependencies]` section |
| Go | `go.mod` | `require` block |
| PHP | `composer.json` | `require` + `require-dev` keys |
| Java | `build.gradle` | `dependencies` block |
| Dart | `pubspec.yaml` | `dependencies` key |

## Step 3: Analyze in Three Tiers

Using your knowledge of the detected ecosystem and libraries, produce analysis in three tiers:

### Tier A: Dependency-Driven Patterns

Look at the specific combination of installed libraries and identify design patterns that work well with them. Focus on how the libraries interact, not just individual library usage.

Examples:
- `react-hook-form` + `flowbite-react` → Provider/Context pattern for forms with UI components
- `@tanstack/react-query` + `react-toastify` → Mutation wrapper pattern with toast notifications
- `rails` + `devise` + `pundit` → Service object + policy authorization pattern
- `django` + `django-rest-framework` + `celery` → Serializer + async task pattern

### Tier B: Complementary Library Suggestions

Identify gaps in the stack where a complementary library would unlock better patterns or solve common problems:

- Has form library but no validation → suggest schema validation (zod, yup, dry-validation)
- Has data fetching but no caching strategy → suggest caching library
- Has UI framework but no icon library → suggest icon set
- Has API framework but no documentation → suggest OpenAPI/Swagger tooling

For each suggestion, explain:
1. What library you're suggesting
2. Why it complements existing dependencies
3. What pattern it would enable

### Tier C: Industry Best Practices

Regardless of dependency count, always propose best practices for the detected framework. These are patterns every project should consider:

- **File organization** — Feature-based vs layer-based, colocation strategy
- **Error handling** — Error boundaries, global error handlers, error types
- **API layer** — Centralized client, request/response types, error mapping
- **State management** — When to use local vs global state
- **Testing strategy** — What to test, how to structure test files
- **Type safety** — Strict types, avoiding `any`, type separation patterns

For bare frameworks with few dependencies, Tier C should be the primary output. Lean into framework-specific conventions heavily.

## Step 4: Save Detection Report

Create the directory `.claude/pattern-forge/` if it doesn't exist, then save the structured report to `.claude/pattern-forge/detection-report.json`.

The report must follow this schema:

```json
{
  "timestamp": "ISO 8601 timestamp",
  "ecosystem": "node|ruby|python|rust|go|php|java|dart|swift|elixir|dotnet",
  "framework": "detected framework name (e.g., next, rails, django)",
  "framework_version": "detected version or unknown",
  "dependency_file": "relative path to primary dependency file",
  "dependencies": {
    "package-name": "version-string"
  },
  "suggested_libraries": [
    {
      "name": "library-name",
      "reason": "Why this library complements the current stack",
      "complements": ["existing-dep-1", "existing-dep-2"]
    }
  ],
  "proposed_patterns": [
    {
      "id": "kebab-case-pattern-id",
      "category": "Category Name",
      "tier": "A|B|C",
      "dependencies_involved": ["dep1", "dep2"],
      "summary": "One-line description of the pattern"
    }
  ]
}
```

## Step 5: Present Results to User

After saving the report, present a summary to the user:

1. **Ecosystem & framework** detected
2. **Dependencies found** (count and key libraries)
3. **Patterns proposed** (grouped by tier, with short descriptions)
4. **Libraries suggested** (with reasons)

End with: "Detection complete. Run `/pattern-forge:design` to choose your patterns, or `/pattern-forge:init` if you haven't started the full setup yet."

## After Creating

Commit with: `git add skills/detect/SKILL.md && git commit -m "feat: add detect skill for dependency scanning and pattern proposal"`

Work from: /Users/samuelasselin/pattern-forge

---
name: design
description: Use after running detect to interactively select design patterns for your project. Presents patterns by category in a wizard-style Q&A, one question at a time.
---

# Interactive Pattern Design

Present detected patterns to the user by category, one at a time. The user picks their preferred approach for each category. Record all choices for the generate skill.

## Prerequisites

The detection report must exist at `.claude/pattern-forge/detection-report.json`. If it doesn't exist, tell the user to run `/pattern-forge:detect` first.

## Step 1: Load State

Read these files:
- `.claude/pattern-forge/detection-report.json` — the detection report (required)
- `.claude/pattern-forge/rejections.json` — previous rejections (optional, may not exist)

From the detection report, collect all `proposed_patterns` and `suggested_libraries`.

If `rejections.json` exists, filter out patterns whose `pattern_id` matches a rejection AND whose `dependency_context` has NOT changed (i.e., no new relevant dependencies were added since the rejection). Patterns with changed dependency context should be re-proposed with an explanation of why they're worth reconsidering.

## Step 2: Group Patterns by Category

Organize the proposed patterns into categories. Common categories include:
- State Management
- Forms & Validation
- API Layer / Data Fetching
- UI Components
- Error Handling
- File Organization
- Testing Strategy
- Authentication & Authorization
- Notifications & Feedback
- Date & Time Handling
- Internationalization

Only present categories that have at least one proposed pattern. The categories should adapt to the ecosystem — a Rails project won't have "State Management" in the React sense, but may have "Service Layer" or "Background Jobs" instead.

## Step 3: Present Each Category

For each category, present ONE question at a time. Do not present multiple categories in a single message.

For each category:

1. **Name the category** clearly
2. **Present 2-3 approaches** with trade-offs. Include:
   - A brief description of each approach
   - Which dependencies it leverages (if any)
   - Pros and cons
   - Your recommendation and why
3. **If a complementary library was suggested** for this category, include an approach that uses it and explain what it adds
4. **Wait for the user's choice** before moving to the next category

The user can:
- Pick one of the proposed approaches
- Describe a different approach they prefer
- Skip the category entirely (no pattern enforced for it)

Record each choice with:
- `id`: kebab-case identifier for the pattern
- `category`: the category name
- `choice`: description of what the user chose
- `source`: `"dependency-driven"` if based on specific deps, `"industry-best-practice"` if a general convention, `"user-custom"` if the user described their own approach
- `details`: any additional context about the choice (libraries involved, specific rules)

## Step 4: Library Suggestions

After all pattern categories are presented, if there were complementary library suggestions that weren't covered in a category, present them:

"Based on your stack, these additional libraries might be useful:"
- Library name — reason, what it enables

The user can accept or decline each suggestion. Accepted suggestions should be noted in the design choices (they inform the generated agent about tools available in the stack).

## Step 5: Save Design Choices

Save to `.claude/pattern-forge/design-choices.json`:

```json
{
  "last_updated": "ISO 8601 timestamp",
  "dependency_snapshot": ["sorted", "list", "of", "current", "dependencies"],
  "patterns": [
    {
      "id": "pattern-id",
      "category": "Category Name",
      "choice": "Description of the chosen approach",
      "source": "dependency-driven|industry-best-practice|user-custom",
      "details": {
        "libraries": ["relevant-lib-1"],
        "rules": ["specific rule 1", "specific rule 2"],
        "examples": "optional code example or reference"
      }
    }
  ],
  "accepted_library_suggestions": [
    {
      "name": "library-name",
      "reason": "Why it was suggested"
    }
  ]
}
```

## Step 6: Confirm and Next Steps

After all categories are complete:

1. Summarize the choices made (one line per category)
2. Note any skipped categories
3. End with: "Design choices saved. Run `/pattern-forge:generate` to create the conventions agent, or continue with `/pattern-forge:init` if you're in the full setup flow."

## Key Principles

- **One question at a time** — Never present multiple categories in a single message
- **Always offer a skip option** — The user should never feel forced into a pattern
- **Explain trade-offs honestly** — Don't oversell any approach
- **Respect prior rejections** — Don't re-propose patterns with unchanged dependency context
- **Adapt to the ecosystem** — Use terminology and patterns appropriate to the detected stack

## After Creating

Commit with: `git add skills/design/SKILL.md && git commit -m "feat: add design skill for interactive pattern selection wizard"`

Work from: /Users/samuelasselin/pattern-forge

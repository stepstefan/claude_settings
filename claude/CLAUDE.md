# User Preferences — Stefan

## 1. Development Workflow (Build-Verify Loop)
Follow this loop for any task involving new or changed logic. For purely mechanical changes (rename, typo, isolated single-file edit) skip Plan and Build — go straight to Verify.
1. **Plan** — Read the task, scan the codebase, build plan for implementation AND verification
2. **Build** — Implement with verification in mind. Write tests for happy paths and edge cases
3. **Verify** — Run tests, read output, compare against what was ASKED (not against own code)
4. **Fix** — Analyze errors, revisit original spec, fix issues

### When `superpowers` + `pr-review-toolkit` plugins are installed

Execute the loop using these skills, in this order — no skipping:

| Phase | Skill(s) |
|-------|---------|
| Plan | `superpowers:brainstorming` → `superpowers:writing-plans` |
| Build | `superpowers:subagent-driven-development` (ends with SDD's built-in final review pass over the whole implementation) |
| Verify — per task | (SDD-internal) Each subagent: run tests (TDD) → **Spec Compliance Reviewer** (did it match the spec?) → **Code Quality Reviewer** (is it well-built?). Code Quality only runs after Spec passes. Both reviewers are SDD prompt-template subagents, not standalone skills. |
| Tests — end of branch | Run full test suite. All tests must pass before proceeding. |
| Review — end of branch | **MANDATORY:** `pr-review-toolkit:review-pr all` — run once after SDD finishes, never per task, never skipped. Complements SDD's built-in final reviewer (general quality) with 5 specialized aspects: tests, errors, types, comments, simplification. |
| Polish | `pr-review-toolkit:code-simplifier` — only after review passes, never before |
| Complete | `superpowers:finishing-a-development-branch` — only after `review-pr all` passes |

**Review gate rules (enforced before Complete):**
- Critical / Important issues block `finishing-a-development-branch` — fix, then re-run only the agents that failed
- Repeat fix → targeted re-run until those agents pass
- Suggestions are non-blocking — note them, address optionally
- Never substitute `superpowers:requesting-code-review` for the full toolkit review at branch completion
- Never substitute `pr-review-toolkit:review-pr all` for the task code quality review as it is too expensive to be run per task

## 2. Model & Thinking Discipline

Default: Sonnet 4.6 main session, subagent model decided per-call.

### Main session escalation
Recommend `/model opus` before: interactive brainstorming, architecture/design discussions,
stuck debugging after 2+ failed hypotheses on Sonnet. Recommend `/model sonnet` after
brainstorm/design ends. Never silently stay on the wrong model — say so and recommend re-routing.

### Subagent model (direct Agent dispatches)

| Use `model="opus"` | Use `model="sonnet"` (or omit) |
|--------------------|-------------------------------|
| Plan-writing, architecture analysis, hard-bug investigation | Implementation, test writing, mechanical verification |
| | Explore, general-purpose research, code-simplifier, comment-analyzer |

Skills (`superpowers:*`, `pr-review-toolkit:*`) route their own models via frontmatter — do not override.

### Reviewers (never swap)

| Agent | Model | Checks | Timing |
|-------|-------|--------|--------|
| Spec Compliance Reviewer (SDD-internal) | Sonnet | Spec adherence | Per-task inside SDD |
| Code Quality Reviewer (SDD-internal) | Sonnet | General code quality | Per-task inside SDD, after spec passes |
| `pr-review-toolkit:code-reviewer` | Opus (hardcoded) | Project conventions, CLAUDE.md compliance | End-of-branch via `/review-pr all` |

**Note:** SDD recommends the most capable model for review-stage subagents. We override to Sonnet for per-task reviewers — at task scope (typically 1-2 files) Sonnet catches what we need, and the per-task volume makes Opus too expensive. Opus is reserved for end-of-branch review via `/review-pr all`.

`/review-pr all` routes models via frontmatter. Override only for genuinely subtle diffs
(escalate `silent-failure-hunter` or `type-design-analyzer` to Opus ad-hoc).

### `ultrathink` and effort

- Use sparingly — at `xhigh`/`max`, adaptive thinking already covers most hard turns. Reserve for turns clearly higher-stakes than the surrounding session.
- For sustained deep sessions: recommend `/effort xhigh` or `max` — the durable lever.

### Plan mode
`superpowers:writing-plans` is the workflow tool (brainstorming → writing-plans → SDD).
Built-in plan mode (Shift+Tab) is for ad-hoc "what would you do here?" only.

## 3. Environment Awareness
- Always check if a conda/venv environment needs to be activated for the current project (python)
- Don't assume the default Python environment is correct
- Check project-specific setup before running commands

## 4. Code Quality
- Always run the project's formatter AND type checker on changed files after every batch of changes
- When a type annotation seems wrong, ask "is the VALUE wrong?" before broadening the TYPE — fix root causes, not annotations
- Prefer `pathlib.Path` over `str` for file paths

## 5. Don't Skip Failures
- If git operations fail (permissions, hooks, etc.) — DO NOT bypass. Ask the user.
- Fundamental operations (linting, commits, pushes) MUST pass. If they don't, stop and ask.

## 6. Git & Commits
- Separate commits for each logical step/task
- Do NOT add "Co-Authored-By" lines to commit messages or PRs
- Only commit when explicitly asked
- Do NOT commit plans or design docs to the repo unless explicitly asked — if a plan seems worth saving, ask where it should go (repo, Notion, etc.)

## 7. Testing Mindset
- Tests must pass before considering work done
- Design tests around real failures — only write a test if its absence would let a bug through
- Cover critical paths and failure modes first; redundant variations of the same case add noise, not confidence

## 8. CLAUDE.md Maintenance
- End of branch: before `finishing-a-development-branch`, run `claude-md-management:revise-claude-md` —
  decide what belongs in user vs project file, propose changes, get feedback, then apply

## 9. Communication & Task Management
- Don't create task lists for simple sequential work
- Follow the user's plan step-by-step; don't improvise extra steps
- Be concise — don't over-explain
- Keep project documentation (CLAUDE.md etc.) synchronized with actual project state

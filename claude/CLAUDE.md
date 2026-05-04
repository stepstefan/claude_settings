# User Preferences — Stefan

## 1. Development Workflow (Build-Verify Loop)
Every feature/task must follow this loop:
1. **Plan** — Read the task, scan the codebase, build plan for implementation AND verification
2. **Build** — Implement with verification in mind. Write tests for happy paths and edge cases
3. **Verify** — Run tests, read output, compare against what was ASKED (not against own code)
4. **Fix** — Analyze errors, revisit original spec, fix issues

### When `superpowers` + `pr-review-toolkit` plugins are installed

Execute the loop using these skills, in this order — no skipping:

| Phase | Skill(s) |
|-------|---------|
| Plan | `superpowers:brainstorming` → `superpowers:writing-plans` |
| Build | `superpowers:subagent-driven-development` |
| Verify — per task | Each subagent: run tests (TDD) → **Spec Compliance Reviewer** (did it match the spec?) → **Code Quality Reviewer** (is it well-built?). Code Quality only runs after Spec passes. |
| Tests — end of branch | Run full test suite. All tests must pass before proceeding. |
| Review — end of branch | **MANDATORY:** `pr-review-toolkit:review-pr all` — run once, never per task, never skipped |
| Polish | `pr-review-toolkit:code-simplifier` — only after review passes, never before |
| Complete | `superpowers:finishing-a-development-branch` |

**Review gate rules (enforced before Complete):**
- Critical / Important issues block `finishing-a-development-branch` — fix, then re-run only the agents that failed
- Repeat fix → targeted re-run until those agents pass
- Suggestions are non-blocking — note them, address optionally
- Never substitute `superpowers:requesting-code-review` for the full toolkit review at branch completion
- Never substitute `pr-review-toolkit:review-pr all` for the task code quality review as it is too expensive to be run per task

## 2. Model & Thinking Discipline
Default: Sonnet 4.6 main session, thinking off, subagent model decided per-call.

### Main session escalation
Before starting any of these, tell user "Recommend `/model opus` — reason: <one line>":
- Interactive brainstorming for a non-trivial feature/refactor
- Architecture or design discussion
- Stuck debugging after 2+ failed hypotheses on Sonnet

After the brainstorm/design phase ends, tell user "Recommend `/model sonnet`."

Never silently stay on Sonnet for a clearly hard interactive task. Never silently stay on Opus once the design phase is over. If mid-task my model estimate was wrong (Sonnet thrashing or Opus on trivia), say so explicitly and recommend re-routing.

### Two code-reviewer agents (important distinction)
- `superpowers:code-reviewer` — `model: inherit` (Sonnet). Checks plan alignment and general quality. Used per-task inside `subagent-driven-development`.
- `pr-review-toolkit:code-reviewer` — `model: opus` (hardcoded). Checks project conventions and CLAUDE.md compliance. Used end-of-branch via `/review-pr all`.
These are complementary: different questions, different timing, different models. Never swap one for the other.

### Subagent model (my call, no user prompt)
Pass `model="opus"` when dispatching:
- Plan-writing, architecture analysis, hard-bug investigation

Pass `model="sonnet"` (or omit) for:
- Implementation from plan, test writing, mechanical verification
- `Explore` agent, `general-purpose` research, code-simplifier, comment-analyzer
- `superpowers:code-reviewer` always — whether inside SDD or ad-hoc (Opus code review is exclusively `pr-review-toolkit:code-reviewer` at end-of-branch)

`/review-pr all` routes correctly via frontmatter (`pr-review-toolkit:code-reviewer` is Opus-locked, others inherit Sonnet). Don't override unless a specific PR genuinely earns it (e.g., very subtle error-handling diff → escalate `silent-failure-hunter` to Opus).

### Thinking injection (always-on for specific phases)
- **Brainstorming**: at the start of every brainstorming session, tell user to append `think hard` to their messages (thinking is user-triggered in main session).
- **Plan-writing subagent**: always inject `think hard` into the subagent prompt.
- **`silent-failure-hunter`**: always inject `think hard` into the subagent prompt.

### Thinking budget (user's call, I recommend)
- Recommend `think hard` for: subtle correctness, tradeoff analysis, non-trivial diff review.
- Recommend `ultrathink` for: deep multi-hypothesis debugging, hard architecture decisions.
- Don't recommend thinking for mechanical tasks. State the reason in one line.

### Built-in plan mode vs `writing-plans` skill
Built-in plan mode (Shift+Tab) and `superpowers:writing-plans` are orthogonal mechanisms. In the superpowers workflow, use `brainstorming → writing-plans → subagent-driven-development` and ignore Shift+Tab. Built-in plan mode is for ad-hoc "what would you do here?" outside that workflow.

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
- When implementing a feature, always think: how can and should this be tested?
- Write tests for both happy paths and edge cases
- Tests must pass before considering work done

## 8. Communication & Task Management
- Don't create task lists for simple sequential work
- Follow the user's plan step-by-step; don't improvise extra steps
- Be concise — don't over-explain
- Keep project documentation (CLAUDE.md etc.) synchronized with actual project state

## 9. Docstring Convention
- Triple quotes with newline for class/method docstrings (python)

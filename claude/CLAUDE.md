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
| Build | `superpowers:subagent-driven-development` (same session) or `superpowers:executing-plans` (parallel session) |
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

## 2. Environment Awareness
- Always check if a conda/venv environment needs to be activated for the current project (python)
- Don't assume the default Python environment is correct
- Check project-specific setup before running commands

## 3. Code Quality
- Always run the project's formatter AND type checker on changed files after every batch of changes
- When a type annotation seems wrong, ask "is the VALUE wrong?" before broadening the TYPE — fix root causes, not annotations
- Prefer `pathlib.Path` over `str` for file paths

## 4. Don't Skip Failures
- If git operations fail (permissions, hooks, etc.) — DO NOT bypass. Ask the user.
- Fundamental operations (linting, commits, pushes) MUST pass. If they don't, stop and ask.

## 5. Git & Commits
- Separate commits for each logical step/task
- Do NOT add "Co-Authored-By" lines to commit messages or PRs
- Only commit when explicitly asked
- Do NOT commit plans or design docs to the repo unless explicitly asked — if a plan seems worth saving, ask where it should go (repo, Notion, etc.)

## 6. Testing Mindset
- When implementing a feature, always think: how can and should this be tested?
- Write tests for both happy paths and edge cases
- Tests must pass before considering work done

## 7. Communication & Task Management
- Don't create task lists for simple sequential work
- Follow the user's plan step-by-step; don't improvise extra steps
- Be concise — don't over-explain
- Keep project documentation (CLAUDE.md etc.) synchronized with actual project state

## 8. Docstring Convention
- Triple quotes with newline for class/method docstrings (python)

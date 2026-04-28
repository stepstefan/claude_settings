---
description: Scaffold a new project with environment setup, linting, git config, and CLAUDE.md. Run this in an empty folder.
---

# Init Project

You are setting up a brand new project from scratch. Follow this workflow step by step. **Do not skip steps. Do not assume answers — always ask the user.**

## Step 0: Safety Check

Before anything else, check if the current directory is empty (this includes also hidden files like `.git`).
- If **not empty**, warn the user and ask what they want to do: abort, or continue anyway. Default to abort.
- The **project name** is the name of the current directory. Confirm it with the user.

## Step 1: Project Description

Ask the user for:
- **Short description** (1-2 sentences describing what the project does)

## Step 2: Language & Frameworks

Ask the user:
- **Primary language** (e.g., Python, TypeScript, C++, etc.)
- **Key frameworks or libraries** they plan to use (e.g., FastAPI, React, PyTorch, etc.)

## Step 3: Environment Setup

Ask the user how they want to manage their development environment. Present these options:

1. **Host** — bare metal, no containerization or env manager
2. **Conda/Mamba** — isolated conda environment with `environment.yml`
3. **Docker** — containerized dev environment with `Dockerfile` and `.devcontainer/` for VS Code

Based on their choice:

### If Host:
- No special env files needed
- Note any system dependencies in the README

### If Conda/Mamba:
- Create `environment.yml` with:
  - The project name as the env name
  - Appropriate Python/language version
  - Any frameworks mentioned in Step 2 as dependencies
  - Common dev dependencies (e.g., pytest, ipython for Python projects)
- Add conda activation instructions to README

### If Docker:
- Create a `Dockerfile` appropriate for the chosen language
- Create `.devcontainer/devcontainer.json` with:
  - Appropriate base image
  - VS Code extensions for the chosen language (from Step 4)
  - Port forwarding if relevant
  - Post-create commands for dependency installation
- Create `docker-compose.yml` if the project will need services (ask the user)

## Step 4: Linting & Formatting

Based on the language chosen in Step 2, **suggest** a sensible default set of linting and formatting tools. Present the recommended choice first, then mention alternatives. Let the user confirm or adjust.

**All tools must be configured with a max line length of 130.**

Suggested defaults by language:

### Python:
- **Formatter:** ruff format (alternatives: black, autopep8, yapf)
- **Linter:** ruff (alternatives: flake8, pylint)
- **Type checker:** pyright (alternatives: mypy)
- **VS Code extensions:**
  - ms-python.python
  - donjayamanne.python-extension-pack
  - ms-python.vscode-pylance
  - Extension for the chosen formatter (e.g., charliermarsh.ruff for ruff)

### TypeScript / JavaScript:
- **Formatter:** prettier (alternatives: biome)
- **Linter:** eslint (alternatives: biome)
- **VS Code extensions:** dbaeumer.vscode-eslint, esbenp.prettier-vscode

### C++:
- **Formatter:** clang-format
- **Linter:** clang-tidy, cpplint
- **Build system:** CMake (alternatives: Meson, Bazel)
- **VS Code extensions:**
  - ms-vscode.cpptools
  - ms-vscode.cpptools-extension-pack
  - ms-vscode.cmake-tools
  - josetr.cmake-language-support-vscode
  - twxs.cmake
  - mine.cpplint
  - fredericbonnet.cmake-test-adapter

### Other languages:
- Research and suggest appropriate tools for the language

After confirming with the user, create:
- Language-specific config files (e.g., `ruff.toml` with `line-length = 130`, `.prettierrc` with `printWidth: 130`, `.clang-format` with `ColumnLimit: 130`, etc.)
- `.vscode/settings.json` with:
  - Format on save enabled
  - Default formatter set
  - Linter integration configured
- `.vscode/extensions.json` with recommended extensions, always including these **default extensions** alongside the language-specific ones:
  - github.copilot-chat
  - anthropic.claude-code (Claude Code extension)
  - streetsidesoftware.code-spell-checker
  - znck.grammarly
  - bierner.markdown-mermaid
  - hbenl.vscode-test-explorer

## Step 5: Git Setup

Initialize git and create:
- `.gitignore` tailored to the language, framework, and environment choice:
  - Language-specific ignores (e.g., `__pycache__/`, `node_modules/`, `build/`)
  - Environment-specific ignores (e.g., `.env`, conda env files, docker volumes)
- `.vscode/extensions.json` and `.vscode/settings.json` should be committed (do NOT gitignore them)
- Make an initial commit with message: `chore: initial project scaffold`

## Step 6: CLAUDE.md

Create a `CLAUDE.md` file at the project root that includes:
- Project name and description (from Step 1)
- Language and frameworks (from Step 2)
- Environment setup instructions (how to activate/start the dev environment)
- Linting and formatting conventions (what tools are used, how to run them)
- Project structure overview (directories created so far)
- Any coding conventions implied by the chosen tools

## Step 7: Build & Verify Environment

This step only applies if the user chose Conda/Mamba or Docker in Step 3.

### If Conda/Mamba:
- Run `conda env create -f environment.yml` (or `mamba env create -f environment.yml`)
- Activate the environment
- Verify that all dependencies are installed and importable
- If any errors occur, fix `environment.yml` and retry until the build succeeds
- Run the linter/formatter to verify they work (e.g., `ruff check .`, `ruff format --check .`)

### If Docker:
- Run `docker build -t <project-name> .`
- If using devcontainer, verify `.devcontainer/devcontainer.json` is valid
- If any build errors occur, fix the Dockerfile and retry until the build succeeds
- Verify that language runtime and dependencies are available inside the container
- Run the linter/formatter inside the container to verify they work

Important check in some cases might be to check if GPU dependencies are installed and work. Examples of these might be CUDA and pytorch with CUDA support. It is known to happen that some libs fall back to CPU only version, and having CUDA support can be critical.
If not sure, ask user if CUDA support is critical.
If there are necessary changes on host machine to enable CUDA support (e.g. installing drivers), abort and give user recomendations.

**Do not move on until the environment builds and verifies successfully. Fix all issues.**

## Final Summary

After completing all steps, print a summary:
- Project name and location
- Environment type and how to activate/start it
- Linting/formatting tools configured (and that line length is set to 130)
- Files created
- Next steps the user might want to take

---

**Important guidelines:**
- Always wait for user responses between steps. Never batch all questions at once.
- Keep suggestions opinionated but adjustable — present the recommended default clearly, then mention alternatives.
- Create files with sensible, minimal defaults — don't over-engineer the initial setup.
- Use the latest stable versions of all tools and dependencies.
- Max line length of 130 must be set in every formatting/linting config file.
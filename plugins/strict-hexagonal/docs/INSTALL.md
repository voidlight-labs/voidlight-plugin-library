# Installation Guide

Quick install Voidlight skills to your AI coding agent.

## Prerequisites

- `curl` or `wget` (for `install.sh`)
- Python 3.6+ (for `install.py` fallback)
- Internet connection to download from GitHub raw

## Quick Start

### One-liner (Linux/macOS/WSL)

```bash
curl -sL https://raw.githubusercontent.com/voidlight-labs/voidlight-plugin-library/main/install.sh | bash -s -- python-craft
```

### One-liner (Cross-platform, including Windows)

```bash
python -c "$(curl -sL https://raw.githubusercontent.com/voidlight-labs/voidlight-plugin-library/main/install.py)" python-craft
```

> **Security note:** Both scripts are read-only. They only download `.md` files and write them to your agent's skill directory. No `sudo`, no `rm -rf`, no arbitrary code execution. If you prefer, download and inspect first:
> ```bash
> curl -sL ... > install.sh && cat install.sh && bash install.sh python-craft
> ```

## Available Skills

| Skill | Target |
|---|---|
| `java-craft` | Java (Spring Boot, Quarkus) |
| `python-craft` | Python (FastAPI) |
| `rust-craft` | Rust (Axum, Actix) |
| `typescript-craft` | Backend TypeScript (Express, Fastify) |
| `nuxt-craft` | Nuxt 3/4, Vue 3 |
| `nextjs-craft` | Next.js App Router |
| `prd-craft` | PRD-first gate with subagent routing by task size |
| `craft-router` | Task → language-craft skill routing |

## Per-Agent Installation

### OpenCode

**Auto-detect** (if `~/.agents/skills/` exists):

```bash
curl -sL ... | bash -s -- python-craft
```

**Result:** `~/.agents/skills/python-craft/SKILL.md`

Install all skills:

```bash
curl -sL ... | bash -s -- --all
```

### Kimi Code CLI

**Auto-detect** (if `~/.kimi-code/skills/` exists or `kimi` command found):

```bash
curl -sL ... | bash -s -- python-craft
```

**Result:** `~/.kimi-code/skills/python-craft/SKILL.md`

### Gemini CLI

Gemini uses hierarchical context files (`GEMINI.md`). The installer appends the skill to your global context file.

```bash
curl -sL ... | bash -s -- --agent gemini python-craft
```

**Result:** Appended to `~/.gemini/GEMINI.md`

**Project-level install:**

If you want the skill only for a specific project, manually create `GEMINI.md` in your project root and paste the skill content, or use the `@file.md` import syntax:

```markdown
# My Project

@~/.gemini/voidlight-python-craft.md
```

### Claude (Project)

For Claude projects, the installer generates a `CLAUDE.md` file in your project root.

```bash
curl -sL ... | bash -s -- --agent claude python-craft
```

**Result:** `CLAUDE.md` in current directory

**For Claude Web UI:** Use `--agent claude` without a project directory. The script outputs the skill content to stdout for copy-paste.

### GitHub Copilot (Codex)

For Copilot, the installer generates `.github/copilot-instructions.md`.

```bash
curl -sL ... | bash -s -- --agent codex python-craft
```

**Result:** `.github/copilot-instructions.md`

## Command Reference

### `install.sh` / `install.py`

| Command | Description |
|---|---|
| `install.sh SKILL` | Install single skill (auto-detect agent) |
| `install.sh --all` | Install all 8 skills |
| `install.sh --update SKILL` | Update/reinstall a skill |
| `install.sh --list` | List installed Voidlight skills |
| `install.sh --remove SKILL` | Remove a skill from all agents |
| `install.sh --agent AGENT SKILL` | Force specific agent target |
| `install.sh --force` | Overwrite without prompting |
| `install.sh --help` | Show help |

### Agent `--agent` values

| Value | Target |
|---|---|
| `opencode` | `~/.agents/skills/{skill}/SKILL.md` |
| `kimi` | `~/.kimi-code/skills/{skill}/SKILL.md` |
| `gemini` | `~/.gemini/GEMINI.md` (append) |
| `claude` | `CLAUDE.md` (project root) |
| `codex` | `.github/copilot-instructions.md` |

## Examples

### Install all skills for OpenCode

```bash
curl -sL https://raw.githubusercontent.com/voidlight-labs/voidlight-plugin-library/main/install.sh | bash -s -- --all
```

### Update a specific skill

```bash
curl -sL ... | bash -s -- --update python-craft
```

### List installed skills

```bash
curl -sL ... | bash -s -- --list
```

### Remove a skill

```bash
curl -sL ... | bash -s -- --remove python-craft
```

### Force overwrite (for CI/automation)

```bash
curl -sL ... | bash -s -- --force python-craft
```

## Troubleshooting

### "Neither curl nor wget found"

Install `curl` or `wget` using your package manager:

```bash
# Ubuntu/Debian
sudo apt-get install curl

# macOS
brew install curl

# Or use the Python installer instead
python -c "$(curl -sL ...)" python-craft
```

### "Failed to download"

- Check your internet connection
- GitHub may be rate-limiting raw requests. Wait a moment and retry
- Alternatively, clone the repo and install from local path

### "Agent not detected"

The installer auto-detects your agent environment. If it fails, use `--agent` explicitly:

```bash
curl -sL ... | bash -s -- --agent opencode python-craft
```

### Manual install (fallback)

If scripts don't work, manually copy the skill file:

```bash
# Download skill
curl -sL https://raw.githubusercontent.com/voidlight-labs/voidlight-plugin-library/main/skills/python-craft/SKILL.md > python-craft.md

# OpenCode: copy to skill directory
mkdir -p ~/.agents/skills/python-craft
cp python-craft.md ~/.agents/skills/python-craft/SKILL.md

# Kimi: copy to skill directory
mkdir -p ~/.kimi-code/skills/python-craft
cp python-craft.md ~/.kimi-code/skills/python-craft/SKILL.md

# Gemini: append to GEMINI.md
cat python-craft.md >> ~/.gemini/GEMINI.md

# Claude: create CLAUDE.md
cp python-craft.md CLAUDE.md

# Copilot: create copilot-instructions.md
mkdir -p .github
cp python-craft.md .github/copilot-instructions.md
```

## Security

- **No `sudo` required:** The script only writes to your home directory
- **No destructive operations:** No `rm -rf`, no system modifications
- **Prompt before overwrite:** Unless `--force` is passed, you'll be asked before overwriting existing skills
- **Transparent:** You can download the script first and inspect it:
  ```bash
  curl -sL ... > install.sh && cat install.sh
  ```
- **Read-only:** The script only downloads `.md` files from GitHub and places them in the correct location

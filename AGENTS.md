# Voidlight Plugin Library — AGENTS.md

## Repo Type

Documentation/knowledge repo, not a code project. No build system, no CI/CD, no test suite. The only executable code is the benchmark runner inside the strict-hexagonal plugin.

## Repository Layout

This repo is a plugin library. Plugin catalogs are dual and kept in sync: root `marketplace.json` (ZCode native format) and `.claude-plugin/marketplace.json` (Claude Code format); each folder under `plugins/` is a self-contained, installable agent plugin (dual manifests: `.zcode-plugin/plugin.json` for ZCode, `.claude-plugin/plugin.json` for Claude Code, kept in sync).

## Directory Map

| Path | What |
|------|------|
| `marketplace.json` | Root plugin catalog (ZCode native format). Single entry point for listing plugins. |
| `.claude-plugin/marketplace.json` | Plugin catalog for Claude Code. Mirrors the root catalog: same plugins, `name`, `version`, `description`, relative `source`, `icon`. |
| `README.md`, `CONTRIBUTING.md` | Library-level docs: plugin table, how to add a plugin. |
| `plugins/strict-hexagonal/` | The original skill library, now packaged as the strict-hexagonal plugin. |

### Inside `plugins/strict-hexagonal/`

| Path | What |
|------|------|
| `.zcode-plugin/plugin.json`, `.claude-plugin/plugin.json` | Plugin manifests. The manifest `version` is the single source of truth; skill frontmatters carry the same version under `metadata.version`. |
| `assets/icon.png` | Plugin icon (512x512 PNG). Referenced by both catalogs via the `raw.githubusercontent.com/.../main/...` URL. |
| `skills/{name}/SKILL.md` | One per skill (8 total: 6 craft, 2 process). Self-contained AI skill specs loaded by agents. |
| `agents/{persona}.md` | 7 persona definitions (architect, smith, smith-low/med/high, surveyor, explorer). Subagent identity specs. Shipped as undeclared files: the ZCode manifest has no agents component. |
| `benchmark/benchmark.py` | Python script evaluating AI-generated code against skill rules. |
| `benchmark/scenarios/{lang}/scenario-{NN}-{difficulty}.md` | 30 total (5 per craft skill). Input files for the benchmark. |
| `docs/INSTALL.md` | Install targets and options. |
| `install.sh` / `install.py` | Installers. Download skills via `raw.githubusercontent.com/<owner>/<repo>/main/plugins/strict-hexagonal/skills/...`. |
| `SKILL_TEMPLATE.md` | Canonical template for creating new skills. |
| `README.md` / `CONTRIBUTING.md` | Plugin-level docs and validation rules. |

## Commands

```bash
# Run benchmark (all skills)
cd plugins/strict-hexagonal/benchmark && pip install -r requirements.txt && python benchmark.py

# Run single skill
python benchmark.py --skill python-craft

# Output formats
python benchmark.py --format json
python benchmark.py --format csv
```

Benchmark scenarios live in `plugins/strict-hexagonal/benchmark/scenarios/{lang}/`. Requires `pyyaml` and `markdown`.

## Skill File Anatomy

Two skill categories live in the strict-hexagonal plugin:

- **Craft skills** (`{lang}-craft`): must match the canonical anatomy exactly:
  - Valid YAML frontmatter (`name`, `description`, plus `metadata.version`, `metadata.author`, `metadata.applyTo`, `metadata.tags`)
  - 10 Mandatory Rules with 10 sub-rules each
  - 15 Forbidden Patterns
  - 6-step Thinking Protocol
  - 10 Response Rules
  - 8 Context Awareness items
  - Scoring Rubric (7 categories, 100 points)
  - Minimum 2 complete 2-layer architecture examples

  The canonical reference is `skills/python-craft/SKILL.md`. When creating a new craft skill, start from `SKILL_TEMPLATE.md`.

- **Process skills** (`prd-craft`, `craft-router`): thinner instruction skills (gates, checklists, output contracts, routing). No rules-and-rubric anatomy required; no benchmark scenarios required (benchmark.py only covers craft skills). Frontmatter convention is the same.

## Architecture Principle (2-Layer)

Every craft skill enforces this split:
- **Domain Layer** (`domain/`): Pure standard library only. Zero framework imports.
- **Infrastructure Layer** (`infrastructure/`): Framework code allowed. Implements domain ports.

This is documented in the plugin's `README.md` and `CONTRIBUTING.md`. Do not repeat it in agent responses — the skill files already define it.

## Validation Rules (from the plugin's CONTRIBUTING.md)

New skills or edits must pass:
- Valid YAML frontmatter
- All 7 required sections present
- Minimum 5 rules
- `DOMAIN LAYER` / `INFRASTRUCTURE LAYER` banners in examples
- Domain layer examples have zero framework imports
- 5 benchmark scenarios (2 Easy, 2 Medium, 1 Hard)

## What Skills Apply To

| Skill File | `applyTo` | Framework(s) |
|---|---|---|
| `java-craft` | `**/*.java` | Spring Boot, Quarkus |
| `python-craft` | `**/*.py` | FastAPI |
| `rust-craft` | `**/*.rs` | Axum, Actix |
| `typescript-craft` | `**/*.ts` | Backend TypeScript: Express, Fastify |
| `nuxt-craft` | `**/*.{vue,ts}` | Nuxt 3, Vue 3 |
| `nextjs-craft` | `**/*.{tsx,ts}` | Next.js App Router |
| `prd-craft` | `**/*` | None (process skill, invoked at chat start) |
| `craft-router` | `**/*` | None (process skill, invoked during prd-craft routing) |

## Versioning

- The strict-hexagonal plugin is at `4.0.0` (source of truth: `plugins/strict-hexagonal/.zcode-plugin/plugin.json`). Keep both manifests, skill frontmatters, and the `version` on both catalog entries in sync.
- The voidlight-soul plugin is at `1.1.0` (same sync rule; source of truth: `plugins/voidlight-soul/.zcode-plugin/plugin.json`). Its skills: `soul-write`, `soul-split`, `soul-audit`, `markdown-to-vdl`.
- The GitHub repository is `voidlight-labs/voidlight-plugin-library`.

## Notes

- In Next.js or Nuxt projects, use the framework skill instead of `typescript-craft`; the latter is backend-only.
- No CI workflows. No pre-commit hooks.
- The repo does not contain actual application code — only markdown specifications.
- When adding a benchmark scenario, place it in the correct `plugins/strict-hexagonal/benchmark/scenarios/{lang}/` directory.
- New plugins go in `plugins/<name>/` with entries in both catalogs (root `marketplace.json` and `.claude-plugin/marketplace.json`).
- `markdown-to-vdl` lives in `plugins/voidlight-soul/` (moved from strict-hexagonal at strict-hexagonal 4.0.0): VDL is the document language of Voidlight Soul, so the converter belongs there. `craft-router` no longer routes to it.

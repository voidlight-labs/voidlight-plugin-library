# Strict Hexagonal: AI Coding Agent Skills for Clean Architecture

![Version](https://img.shields.io/badge/version-4.0.0-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Status](https://img.shields.io/badge/status-active-brightgreen)
![Skills](https://img.shields.io/badge/skills-8-blueviolet)
![Benchmark](https://img.shields.io/badge/benchmark_scenarios-30-orange)

**Strict Hexagonal** is a Voidlight plugin and a collection of 8 production-grade **AI coding agent skills** that enforce strict **2-layer clean architecture** (pure domain, framework infrastructure) across Java, Python, Rust, TypeScript, Nuxt, and Next.js, installable as a plugin in **Claude Code**, **ZCode**, **OpenCode**, and other AI coding agents. Also included: a **prd-craft** process skill (PRD-first gate with subagent routing by task size), 3 **agent personas** (architect, smith, surveyor), and a 30-scenario **benchmark suite** that scores AI-generated code against the skill rules.

## Why

AI code generators produce working code that quietly violates architecture discipline: frameworks leak into domain logic, value objects become anemic, and SRP erodes under feature pressure. Each Voidlight skill acts as a senior architecture reviewer inside your AI agent: it classifies every request into a **domain layer** (standard library only, zero framework imports) and an **infrastructure layer** (frameworks, transports, persistence), then generates or reviews code against a 100-point scoring rubric.

## Table of Contents

- [Available Skills](#available-skills)
- [Architecture Principle](#architecture-principle-2-layer-pragmatic-clean-architecture)
- [Install as a Plugin](#install-as-a-plugin-claude-code-zcode)
- [Quick Install (Non-Plugin Agents)](#quick-install-non-plugin-agents-opencode-kimi-gemini-copilot)
- [Agent Personas](#agent-personas)
- [Quick Start](#quick-start)
- [Benchmark](#benchmark)
- [Contributing](#contributing)
- [FAQ](#faq)
- [License](#license)

## Available Skills

| Skill | Applies To | Frameworks | Focus |
|---|---|---|---|
| [`java-craft`](skills/java-craft/SKILL.md) | `**/*.java` | Spring Boot, Quarkus | Domain purity, Value Objects, Ports & Adapters |
| [`python-craft`](skills/python-craft/SKILL.md) | `**/*.py` | FastAPI, SQLAlchemy 2.x | Standard-library-only domain, typed infrastructure |
| [`rust-craft`](skills/rust-craft/SKILL.md) | `**/*.rs` | Axum, Actix | Idiomatic Rust, explicit contracts, crate boundaries |
| [`typescript-craft`](skills/typescript-craft/SKILL.md) | `**/*.ts` | Express, Fastify (backend) | Strict contracts, validated boundaries, no `any` |
| [`nuxt-craft`](skills/nuxt-craft/SKILL.md) | `**/*.{vue,ts}` | Nuxt 3/4, Vue 3 | SSR-safe layering, version-aware practices |
| [`nextjs-craft`](skills/nextjs-craft/SKILL.md) | `**/*.{tsx,ts}` | Next.js App Router | Server/client split, dependency-free domain |
| [`prd-craft`](skills/prd-craft/SKILL.md) | `**/*` (process skill) | — | PRD-first gate: interview, PRD artifact, approval gate, subagent routing by task size |
| [`craft-router`](skills/craft-router/SKILL.md) | `**/*` (process skill) | — | Task → {lang}-craft skill routing by file glob, manifest, and framework markers |

The six language-craft skills ship with: 10 mandatory rules (10 sub-rules each), 15 forbidden patterns, a 6-step thinking protocol, 10 response rules, 8 context-awareness checks, a 7-category scoring rubric (100 points), and complete 2-layer architecture examples. The two process skills (`prd-craft`, `craft-router`) are thinner instruction skills: gates, checklists, and output contracts instead of rules-and-rubric.

## Architecture Principle: 2-Layer Pragmatic Clean Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    DOMAIN LAYER (Inbound)                    │
│                     Pure Native Only                        │
│                                                              │
│  domain/entity          → Domain entities, value objects    │
│  domain/usecase         → Use cases, application services   │
│  domain/port            → Repository interfaces             │
│  domain/exception       → Domain-specific exceptions        │
│  domain/event           → Domain events                    │
│  domain/service         → Domain services (pure logic)     │
│                                                              │
│  RULES:                                                      │
│  • Compiles with ONLY the language standard library          │
│  • ZERO framework imports                                    │
│  • ZERO external library imports                             │
│  • Pure functions for business logic                         │
│  • Entities are self-validating, never anemic                │
│  • Exceptions are domain-specific, not framework-specific   │
└─────────────────────────────────────────────────────────────┘
                              │
                              │
┌─────────────────────────────────────────────────────────────┐
│              INFRASTRUCTURE LAYER (Outbound)                 │
│              Frameworks and Libraries Allowed               │
│                                                              │
│  infrastructure/persistence  → DB adapters, ORM             │
│  infrastructure/rest         → REST controllers, routes     │
│  infrastructure/external     → HTTP clients, third-party    │
│  infrastructure/config       → Framework config, DI         │
│                                                              │
│  RULES:                                                      │
│  • Implements domain ports                                   │
│  • Contains ALL framework code                               │
│  • Handles all I/O operations                                │
│  • Never puts business logic here                            │
└─────────────────────────────────────────────────────────────┘
```

One dependency direction: **infrastructure depends on domain, never the reverse.**

## Install as a Plugin (Claude Code, ZCode)

This repo ships as a standard agent plugin with a canonical manifest (`.claude-plugin/plugin.json`). Install it from this GitHub repository or point your agent at the repo path, and the harness picks up everything under `skills/` and `agents/` automatically.

## Quick Install (Non-Plugin Agents: OpenCode, Kimi, Gemini, Copilot)

One-liner install for agents without plugin support:

```bash
curl -sL https://raw.githubusercontent.com/voidlight-labs/voidlight-plugin-library/main/install.sh | bash -s -- python-craft
```

Or with Python (cross-platform, including Windows):

```bash
python -c "$(curl -sL https://raw.githubusercontent.com/voidlight-labs/voidlight-plugin-library/main/install.py)" python-craft
```

### Install all skills

```bash
curl -sL ... | bash -s -- --all
```

### Per-agent quick install

| Agent | Command | Install Target |
|---|---|---|
| **OpenCode** | `bash install.sh python-craft` | `~/.agents/skills/python-craft/SKILL.md` |
| **Kimi Code CLI** | `bash install.sh python-craft` | `~/.kimi-code/skills/python-craft/SKILL.md` |
| **Gemini CLI** | `bash install.sh --agent gemini python-craft` | `~/.gemini/GEMINI.md` (append) |
| **Claude** (project) | `bash install.sh --agent claude python-craft` | `CLAUDE.md` (project root) |
| **GitHub Copilot** | `bash install.sh --agent codex python-craft` | `.github/copilot-instructions.md` |

Both installers are read-only (no `sudo`, no `rm -rf`, no arbitrary code execution) and prompt before overwriting. For detailed options, see [docs/INSTALL.md](docs/INSTALL.md).

## Agent Personas

Three structured agent identities that enforce the 2-layer discipline at the orchestration level, plus specialized subagents for the prd-craft routing flow:

| Persona | Role |
|---|---|
| [`architect`](agents/architect.md) | Cross-language design layer: decision matrices, contracts, stack selection. Never writes implementation code. Activates only after a prd-craft PRD is approved. |
| [`smith`](agents/smith.md) | Surgical coder (generic): implements design artifacts, verifies builds and tests, reports results faithfully. Routes labeled tasks to the smith tiers. |
| [`surveyor`](agents/surveyor.md) | Read-only auditor: reviews architecture compliance, SRP adherence, and code quality. |
| [`explorer`](agents/explorer.md) | Read-only explorer: locates symbols, maps structure, reports facts with file:line references. Never edits, builds, or tests. |
| [`smith-low`](agents/smith-low.md) / [`smith-med`](agents/smith-med.md) / [`smith-high`](agents/smith-high.md) | Implementation tiers by complexity score (0-4 / 5-8 / 9-15): verbatim single-component execution → multi-file feature work → cross-module solution-finding. |

The smith tiers are sized by a 5-dimension complexity matrix (Decision Density, Dependency Surface, Blast Radius, Verification Difficulty, Residual Ambiguity), defined in [`prd-craft`](skills/prd-craft/SKILL.md) and applied by [`craft-router`](skills/craft-router/SKILL.md) when routing tasks.

## Quick Start

1. **Install** the skill for your stack (plugin or one-liner above).
2. **Prompt your agent** normally, the skill auto-applies to matching files (`applyTo` glob per skill).
3. **Review**: every response ends with a self-score against the 100-point rubric.

## Benchmark

A rule-based benchmark suite evaluates AI-generated code against skill rules: **30 scenarios** (5 per skill: 2 Easy, 2 Medium, 1 Hard) scoring SRP compliance, naming, type safety, 2-layer architecture, domain purity, and forbidden-pattern avoidance.

```bash
# Run benchmark (all skills)
cd benchmark && pip install -r requirements.txt && python benchmark.py

# Run single skill
python benchmark.py --skill python-craft

# Output formats
python benchmark.py --format json
python benchmark.py --format csv
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). New skills start from [SKILL_TEMPLATE.md](SKILL_TEMPLATE.md) and must pass the frontmatter and structure validation rules.

## FAQ

**Which AI agents are supported?**
Any harness that loads markdown skills: Claude Code and ZCode (as a plugin), OpenCode, Kimi Code CLI, Gemini CLI, and GitHub Copilot (via the install scripts).

**Does this work with frameworks I already use?**
Yes, skills are framework-aware, not framework-hostile. The domain layer stays framework-free; your Spring Boot, FastAPI, Axum, Express, Nuxt, or Next.js code lives in the infrastructure layer.

**How is this different from a style guide?**
Skills are executable instructions for AI agents: they include decision protocols, forbidden patterns, self-scoring, and context detection, not just conventions for humans to read.

**Can I use just one skill?**
Yes. Each skill is self-contained in a single `SKILL.md` with no cross-dependencies.

## License

MIT License. Copyright Voidlight

---

**Born from the void, Guided by the light.**

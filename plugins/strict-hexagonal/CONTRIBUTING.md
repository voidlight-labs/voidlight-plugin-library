# Contributing to Voidlight Skill Library

Thank you for your interest in contributing. This document outlines the process for proposing new skills and updating existing ones.

## How to Propose a New Skill

Two categories (see AGENTS.md, "Skill File Anatomy"):

- **Craft skills** (`{lang}-craft`): follow the full checklist below.
- **Process skills** (e.g. `prd-craft`): thinner instruction skills. Requirements: canonical frontmatter (see Validation Requirements) and a clear gate/checklist/output contract. Rules-and-rubric anatomy and benchmark scenarios do not apply.

### Craft skill checklist

1. **Start from the template**: Copy `SKILL_TEMPLATE.md` and fill in all sections.
2. **Follow the golden template**: Read `skills/python-craft/SKILL.md` as the canonical reference.
3. **Mirror the structure exactly**:
   - 10 Mandatory Rules with 10 sub-rules each
   - 15 Forbidden Patterns
   - 6-step Thinking Protocol
   - 10 Response Rules
   - 8 Context Awareness items
   - Scoring Rubric with 7 categories, 100 points
4. **Include complete 2-layer architecture examples**.
5. **Add 5 benchmark scenarios** (2 Easy, 2 Medium, 1 Hard).

## Validation Requirements

Frontmatter requirements apply to all skills. The remaining checks apply to craft skills only.
- Valid YAML frontmatter with canonical top-level fields: `name` (must equal the skill directory name) and `description` (trigger-oriented, ends with a "Use when..." sentence)
- `version`, `author`, `applyTo`, and `tags` nested under `metadata:`, with `version` matching `.claude-plugin/plugin.json`
- All 7 required sections present
- Minimum 5 rules
- DOMAIN/INFRASTRUCTURE LAYER in examples
- Domain layer has zero framework imports
- 5 benchmark scenarios (2 Easy, 2 Medium, 1 Hard)

## 2-Layer Architecture

- **Domain Layer**: Pure native, zero framework imports
- **Infrastructure Layer**: Framework code allowed, implements domain ports

## License

MIT — see README.md

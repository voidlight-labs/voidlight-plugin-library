# Contributing to voidlight-soul

## Identity and Versioning

- The plugin is `voidlight-soul`; the folder name and both manifest `name` fields must match.
- The `.zcode-plugin/plugin.json` `version` is the single source of truth. On any change, bump it and update: `.claude-plugin/plugin.json`, both catalog entries, and every skill's `metadata.version`.
- Both catalogs (root `marketplace.json` and `.claude-plugin/marketplace.json`) must carry the same `name`, `version`, `description`, relative `source`, and `icon` URL as the manifest.

## Anti-Drift Rules

1. `references/` contains interface contracts only (flag grammar, claim packet, verdict mapping, tag legend, dalil block shapes). Pipeline internals (tafsir pipeline, isnad audit steps, tag definitions) live only in the personas. If you change a persona's pipeline, check the matching reference file still agrees; if you change a contract, check both personas still conform.
2. Persona bodies are self-contained by design. Never replace a persona section with a pointer to `references/`.
3. Never restate a contract's mapping tables inside a skill; skills say "ikuti `references/pipeline-contract.md`".

## Persona Sync

- `agents/*.md` in this repo is the canonical source. The maintainer's `~/.zcode/agents/` copies are installed instances; after editing a persona here, re-copy it there (strip nothing; the repo copies have no `model:` field).
- When editing personas, change ONLY what the edit requires. In particular, do not normalize their dash usage or reword descriptions.

## Validation Checklist

Run before committing any change:

```bash
# 1. JSON validity + cross-consistency: 4 JSON files parse; name/version/
#    description identical across manifest and both catalogs.
# 2. Frontmatter parses for all skills and agents
python3 - <<'EOF'
import yaml, glob
for p in glob.glob("plugins/voidlight-soul/skills/*/SKILL.md") + glob.glob("plugins/voidlight-soul/agents/*.md"):
    fm = yaml.safe_load(open(p).read().split("---")[1])
    assert fm.get("name") and fm.get("description"), p
    print(p, fm["name"])
EOF
# 3. No em/en dash in skills, references, and plugin docs (persona copies
#    and the moved markdown-to-vdl are exempt: they preserve their source
#    bytes; clean them in dedicated content passes, not in passing)
grep -rnP '[\x{2014}\x{2013}]' plugins/voidlight-soul/skills plugins/voidlight-soul/references plugins/voidlight-soul/README.md plugins/voidlight-soul/CONTRIBUTING.md --exclude-dir=markdown-to-vdl && echo "FAIL: dash found" || echo "dash OK"
# 4. Icon is 512x512
python3 -c "from PIL import Image; assert Image.open('plugins/voidlight-soul/assets/icon.png').size == (512, 512)"
```

## Skill Conventions

- Frontmatter: `name`, `description` (folded block, trigger-excluding the sibling skills), `metadata.version` (quoted), `metadata.author: Voidlight`, `metadata.applyTo`, `metadata.tags`.
- Body language: Indonesian, persona style. Every skill delegates all writing to `voidlight-scribe` and all verification to `sanad-auditor`; skills never write content or verify claims themselves.
- Dispatch Protocol in every skill: native subagent type first, general-purpose fallback reading `../../agents/<persona>.md` relative to the skill base directory.

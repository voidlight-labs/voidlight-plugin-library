# Voidlight Plugin Library

A library of agent plugins by Voidlight. Each folder under `plugins/` is an installable agent plugin (compatible with Claude Code and ZCode). The catalogs are dual and kept in sync: root `marketplace.json` (ZCode) and `.claude-plugin/marketplace.json` (Claude Code). Install the whole library as a plugin marketplace in either tool, or consume plugins individually.

## Plugins

| Plugin | Path | What |
|---|---|---|
| [strict-hexagonal](plugins/strict-hexagonal/) | `plugins/strict-hexagonal/` | Language-craft skills enforcing strict 2-layer hexagonal architecture (Java, Python, Rust, TypeScript, Nuxt, Next.js) plus the prd-craft/craft-router process skills. |
| [voidlight-soul](plugins/voidlight-soul/) | `plugins/voidlight-soul/` | Voidlight Soul content engine: 4 process skills (soul-write, soul-split, soul-audit, markdown-to-vdl) + 2 subagent personas (voidlight-scribe writer, sanad-auditor provenance auditor) for Divine Alignment Architecture content, VDL conversion, and Islamic source verification. |

## Repository layout

```
voidlight-plugin-library/
├── marketplace.json              # Plugin catalog (ZCode native format)
├── .claude-plugin/marketplace.json  # Plugin catalog (Claude Code format)
├── plugins/
│   ├── strict-hexagonal/         # Craft skills plugin (2-layer hexagonal architecture)
│   │   ├── .zcode-plugin/plugin.json
│   │   ├── .claude-plugin/plugin.json
│   │   ├── assets/               # Icon and visual assets
│   │   ├── skills/               # SKILL.md per skill
│   │   ├── agents/               # Subagent persona definitions
│   │   ├── benchmark/            # Benchmark runner + scenarios
│   │   ├── docs/                 # Plugin docs (INSTALL.md)
│   │   ├── install.sh / install.py
│   │   └── README.md / CONTRIBUTING.md
│   └── voidlight-soul/           # Voidlight Soul content engine (write + audit)
│       ├── .zcode-plugin/plugin.json
│       ├── .claude-plugin/plugin.json
│       ├── assets/               # Icon
│       ├── skills/               # soul-write, soul-split, soul-audit
│       ├── agents/               # voidlight-scribe, sanad-auditor personas
│       ├── references/           # Shared handoff contracts (pipeline, tags, dalil)
│       └── README.md / CONTRIBUTING.md
```

## Installing

### Via plugin marketplace (recommended)

1. In ZCode, open **Plugin Marketplace → Add → Add Plugin Marketplace** and point it at this repository (or your local clone).
2. Install the plugin you want from the market list.

### Via install scripts

Each plugin ships its own installers. From the plugin folder:

```bash
cd plugins/strict-hexagonal
./install.sh            # POSIX (Linux/macOS/WSL)
python install.py       # Cross-platform fallback (Windows, restricted shells)
```

See [plugins/strict-hexagonal/docs/INSTALL.md](plugins/strict-hexagonal/docs/INSTALL.md) for agent targets and options.

## Adding a plugin

1. Create `plugins/<plugin-name>/` with a `.zcode-plugin/plugin.json` (and optionally `.claude-plugin/plugin.json`). The folder name must match the manifest `name`.
2. Add entries to both catalogs (`marketplace.json` and `.claude-plugin/marketplace.json`) with matching `name`, `version`, `description`, a relative `source` path, and an `icon` URL.
3. See [CONTRIBUTING.md](CONTRIBUTING.md).

## Versioning

Each plugin versions independently; the plugin manifest `version` is the single source of truth. See the plugin's own README for its version history.

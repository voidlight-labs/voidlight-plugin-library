# Voidlight Soul: Content Engine for the Divine Alignment Architecture

![Version](https://img.shields.io/badge/version-1.1.0-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Skills](https://img.shields.io/badge/skills-4-blueviolet)
![Agents](https://img.shields.io/badge/agents-2-purple)

**Voidlight Soul** is a Voidlight plugin that turns your AI coding agent into a writing-and-verification engine for the **Voidlight Soul** corpus (Divine Alignment Architecture): one subagent writes corpus-voice content with tagged claims and a strict dalil protocol, the other audits every Islamic source claim (hadith, tafsir, Quran quotations, attributions, Israiliyyat) and returns structured verdicts. Installable in **Claude Code** and **ZCode**.

## Why

Corpus-scale religious content fails in two directions: style drift (the writing stops sounding like the corpus) and source drift (invented hadith numbers, misattributed tafsir, translation drift). This plugin enforces both disciplines at once: a writer persona that never asserts an untagged claim and never invents a dalil, and an auditor persona that never emits a verdict without a named grader and a traceable source.

## Components

| Type | Name | What |
|---|---|---|
| Skill | [`soul-write`](skills/soul-write/SKILL.md) | Full-document drafting: one full-context scribe dispatch, mandatory audit of all `VERIFIKASI_PASCATULIS` flags, merged verdicts. |
| Skill | [`soul-split`](skills/soul-split/SKILL.md) | Large-document workflow: section manifest sidecar, one scribe dispatch per section, per-section audit, assemble + consistency pass. |
| Skill | [`soul-audit`](skills/soul-audit/SKILL.md) | Standalone provenance audit of any claim set, with optional application of corrections to a target file. |
| Skill | [`markdown-to-vdl`](skills/markdown-to-vdl/SKILL.md) | Structured Markdown to VDL (Voidlight Definition Language) conversion: entity inference, relationship extraction, evidence blocks, post-conversion validation. |
| Agent | `voidlight-scribe` | Writer persona for the corpus: `[REVELATION]`/`[SYNTHESIS]`/`[ANALOGY]` tag system, dalil protocol, corpus voice, flags unverified claims for audit. |
| Agent | `sanad-auditor` | Provenance auditor: hadith (matn, isnad, edition numbering), tafsir attribution, asbab al-nuzul, Quran lafz/coordinates/qira'at, scholar quotes, Israiliyyat triage (C1/C2/C3). Structured verdicts with named graders. Not a mufti: no fatwa. |
| Reference | [`references/pipeline-contract.md`](references/pipeline-contract.md) | The scribe-to-auditor handoff: flag grammar, claim packet template, verdict-to-action mapping, merge reporting. |

## Writing Pipeline

```
request ──> soul-write / soul-split
              │
              ├──> voidlight-scribe (write)
              │        └─ flags: [PERLU_VERIFIKASI_SANAD: ...] + VERIFIKASI_PASCATULIS
              ├──> sanad-auditor (audit claims)
              │        └─ verdicts: [V#] SAHIH / DAIF / MAWDU / ATRIBUSI_SALAH / ...
              └──> merge (verdict → action, inline audit notes)
                       └─ report: FIXED / FLAGGED / ESKALASI
```

Boundaries: no fatwa, no halal/haram rulings, no madhhab adjudication. Everything the auditor cannot verify surfaces to you instead of being silently resolved.

## Install as a Plugin

Open **Plugin Marketplace → Add → Add Plugin Marketplace** in Claude Code or ZCode and point it at the [voidlight-plugin-library](https://github.com/voidlight-labs/voidlight-plugin-library) repository, then install **Voidlight Soul** from the market list.

### ZCode native subagent dispatch (optional)

The ZCode plugin manifest has no agents component, so the two personas are not auto-registered as subagent types. The skills work regardless: they fall back to dispatching a general-purpose agent that loads the persona file from the installed plugin. If you prefer native `voidlight-scribe` / `sanad-auditor` subagent types in ZCode, copy the personas once:

```bash
mkdir -p ~/.zcode/agents
curl -fsSL -o ~/.zcode/agents/voidlight-scribe.md https://raw.githubusercontent.com/voidlight-labs/voidlight-plugin-library/main/plugins/voidlight-soul/agents/voidlight-scribe.md
curl -fsSL -o ~/.zcode/agents/sanad-auditor.md   https://raw.githubusercontent.com/voidlight-labs/voidlight-plugin-library/main/plugins/voidlight-soul/agents/sanad-auditor.md
```

This repository is the source of truth; re-copy after plugin updates. If you maintain your own edits in `~/.zcode/agents/`, they will drift: pick one side.

## Usage

- "Nulis satu section tentang niat sebagai lokusi agensi, gaya korpus" → soul-write.
- "Bikin PART baru 5 section, jangan sampai outputnya bengkak" → soul-split.
- "Cek hadits ini beneran riwayat Bukhari nggak sebelum gue posting" → soul-audit.
- "Konversi dokumen Seven Laws ini ke VDL" → markdown-to-vdl.

## Model Pinning

The shipped personas carry no `model` field: subagents inherit your session model. To pin one (as the original author does), add a `model:` line back into your local copy of the persona frontmatter.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Versioning: the manifest `version` is the single source of truth; skill frontmatter `metadata.version` and both catalog entries must match it.

## License

MIT

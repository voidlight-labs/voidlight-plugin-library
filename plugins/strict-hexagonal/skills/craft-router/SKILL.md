---
name: craft-router
description: >-
  Use when routing an approved task or PRD item to the correct language-craft
  skill. Classifies code targets by file glob, manifest, and framework markers,
  applies precedence rules (framework-specific beats language-generic), and
  emits one route entry per task per language. Invoke during the prd-craft
  routing phase, after task sizing, before dispatching to a smith tier.
metadata:
  version: '4.0.0'
  author: Voidlight
  applyTo: '**/*'
  tags: [routing, craft, language, process, voidlight]
---

# Craft Router

Skill proses yang nentuin **{lang}-craft skill mana yang harus di-load** untuk sebuah task, berdasarkan target code-nya. Output-nya satu route entry per task per bahasa — dipakai dispatcher (prd-craft) untuk melengkapi Delegation Map sebelum dispatch ke smith tier.

---

## Kapan Dipakai

- Setelah PRD approved dan task di-sizing (complexity score → smith tier).
- Sebelum dispatch task ke smith tier, **untuk setiap task yang punya code target**.
- Bukan untuk menentukan tier — tier sudah ditentukan. Ini cuma nentukan craft skill-nya.

---

## Decision Table

| Sinyal primer | Sinyal sekunder (manifest / marker) | Craft Skill |
|---|---|---|
| `**/*.java` | `pom.xml`, `build.gradle`, Spring / Quarkus markers | `java-craft` |
| `**/*.py` | `pyproject.toml`, `requirements.txt`, FastAPI import | `python-craft` |
| `**/*.rs` | `Cargo.toml` | `rust-craft` |
| `**/*.ts` (backend) | `package.json` tanpa Next/Nuxt, Express/Fastify import | `typescript-craft` |
| `**/*.{tsx,ts}` | `next.config.*`, `app/` dir, `"next"` di dependencies | `nextjs-craft` |
| `**/*.{vue,ts}` | `nuxt.config.*`, `"nuxt"` di dependencies | `nuxt-craft` |

---

## Precedence Rules

1. **Framework-specific menang atas language-generic.** `**/*.{tsx,ts}` dengan Next.js App Router → `nextjs-craft`, BUKAN `typescript-craft`. Sama untuk Nuxt/Vue.
2. **`typescript-craft` itu backend-only.** Kalau target adalah UI component (`.tsx` / `.vue`) tapi framework-nya ambiguous → tanya user, jangan default ke typescript-craft.
3. **Multi-language task → split.** Satu task yang nyentuh dua bahasa = dua route entry, masing-masing dengan craft skill-nya. Dispatcher yang putusin: tetap satu smith atau dua.
4. **Tanpa code target** (docs, config murni, research) → tidak ada craft skill; route ke `explorer` atau smith tier tanpa craft skill line.

---

## Tie-Breaker

1. Cek manifest / config file di repo (`package.json`, `pom.xml`, `Cargo.toml`, `pyproject.toml`, `next.config.ts`, `nuxt.config.ts`). Manifest beats file extension.
2. Masih ambiguous setelah manifest check → **tanya user**. Jangan tebak. Asumsi yang salah di sini = seluruh Delegation Map salah arah.

---

## Output Format

Satu entry per task per bahasa:

```
[ROUTE: smith-<low|med|high>]
- Task: <dari PRD Task Breakdown>
- Size: <complexity total, e.g. 6/15>
- Craft Skill: <nama skill>
- applyTo: <glob yang match>
- Why: <1 line: sinyal yang menentukan, e.g. "Cargo.toml + **/*.rs">
```

Contoh:

```
[ROUTE: smith-med]
- Task: Add invoice export endpoint
- Size: 6/15
- Craft Skill: python-craft
- applyTo: '**/*.py'
- Why: pyproject.toml with FastAPI, target files under app/
```

Kalau task split multi-language:

```
[ROUTE: smith-med]  (1/2)
- Task: Add auth boundary
- Craft Skill: python-craft
- Why: FastAPI backend under app/auth/
[ROUTE: smith-med]  (2/2)
- Task: Add auth boundary
- Craft Skill: typescript-craft
- Why: Express adapter under adapters/ts/
```

---

## Notes

- Ini skill proses: output adalah route entry, bukan code, bukan rencana implementasi.
- Craft skill yang di-route harus di-load oleh smith tier yang menerima task — route entry yang tidak dibawa ke dispatch = routing gagal.
- Table di atas exhaustive untuk skill yang ada di repo ini. Skill baru = update table ini, jangan bikin routing paralel.

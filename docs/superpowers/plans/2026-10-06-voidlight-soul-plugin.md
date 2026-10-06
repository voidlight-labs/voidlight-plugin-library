# voidlight-soul Plugin Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Package the two user-made subagents (`voidlight-scribe`, `sanad-auditor`) as an installable plugin `voidlight-soul` v1.0.0 with 3 declared process skills (soul-write, soul-split, soul-audit), shared handoff contracts, icon, docs, and dual-catalog entries.

**Architecture:** Thin-orchestrator pattern. Subagent personas stay self-contained under `agents/` (undeclared in ZCode manifest, which has no agents component; auto-discovered by Claude Code). The 3 skills are the only declared component; they only route dispatches, consume scribe flags, and merge auditor verdicts per the shared contract in `references/`. References are interface-only; persona bodies remain the internal authority.

**Tech Stack:** Markdown specs (no build system), YAML frontmatter, JSON manifests, Python 3 stdlib + `pyyaml` for validation, Pillow 12.3.0 for icon generation.

**Spec:** `docs/superpowers/specs/2026-10-06-voidlight-soul-plugin-design.md`

## Global Constraints

- Version is `1.0.0` everywhere: plugin manifests (source of truth), both catalog entries, every skill `metadata.version` (quoted: `'1.0.0'`).
- Zero em dash (`—`) and zero en dash (`–`) in every NEW file. Persona copies are byte-identical to their source except the deleted `model:` line; do NOT "fix" their dashes or edit their bodies in any way.
- NO `git commit` / `git push` anywhere in this plan. Global AGENTS.md forbids committing without an explicit user request. The executing agent skips all VCS write actions; the user commits when they want to.
- Language: skill bodies and `references/` in Indonesian (persona style); plugin `README.md`/`CONTRIBUTING.md` in English (family style with strict-hexagonal).
- All new paths stay inside `plugins/voidlight-soul/` plus two library-level edits (root `README.md`, both catalogs).
- Persona body text is never re-quoted into `references/`; references describe the interface (formats, mappings, rules), personas describe internals (pipelines, protocols).
- Subagent frontmatter keeps: `name`, `description`, `color`, `model` REMOVED, `thoughtLevel`, `tools`, `injectAgentsMd`.
- The exact description string (used in 4 places: 2 manifests, 2 catalogs) is defined once in Task 6 as `DESC`; copy it verbatim, never paraphrase.

---

### Task 1: Scaffold and persona copies

**Files:**
- Create: `plugins/voidlight-soul/.zcode-plugin/plugin.json` (empty placeholder dir only, filled in Task 6)
- Create: `plugins/voidlight-soul/.claude-plugin/plugin.json` (dir only)
- Create: `plugins/voidlight-soul/agents/sanad-auditor.md`
- Create: `plugins/voidlight-soul/agents/voidlight-scribe.md`
- Create: `plugins/voidlight-soul/skills/soul-write/`, `skills/soul-split/`, `skills/soul-audit/`, `references/`, `assets/` (empty dirs)

**Interfaces:**
- Produces: `plugins/voidlight-soul/agents/voidlight-scribe.md` and `agents/sanad-auditor.md` — persona files whose frontmatter parses as YAML, has no `model` key, and whose `name` values are `voidlight-scribe` and `sanad-auditor`. Every later task references these exact paths.

- [ ] **Step 1: Create the directory tree**

```bash
cd /home/khayren/voidlight/labs/voidlight-plugin-library
mkdir -p plugins/voidlight-soul/.zcode-plugin \
         plugins/voidlight-soul/.claude-plugin \
         plugins/voidlight-soul/agents \
         plugins/voidlight-soul/skills/soul-write \
         plugins/voidlight-soul/skills/soul-split \
         plugins/voidlight-soul/skills/soul-audit \
         plugins/voidlight-soul/references \
         plugins/voidlight-soul/assets
```

- [ ] **Step 2: Copy personas, stripping the `model:` line**

```bash
grep -v '^model:' /home/khayren/.zcode/agents/sanad-auditor.md > plugins/voidlight-soul/agents/sanad-auditor.md
grep -v '^model:' /home/khayren/.zcode/agents/voidlight-scribe.system.md > plugins/voidlight-soul/agents/voidlight-scribe.md
```

- [ ] **Step 3: Verify the diff is exactly the one model line per file**

```bash
diff /home/khayren/.zcode/agents/sanad-auditor.md plugins/voidlight-soul/agents/sanad-auditor.md
diff /home/khayren/.zcode/agents/voidlight-scribe.system.md plugins/voidlight-soul/agents/voidlight-scribe.md
```

Expected: each diff shows exactly one deletion, a line starting with `model: account:zai-individual-coding-plan/`. No other differences.

- [ ] **Step 4: Validate frontmatter**

```bash
python3 - <<'EOF'
import yaml
for p, expected_name in [
    ("plugins/voidlight-soul/agents/sanad-auditor.md", "sanad-auditor"),
    ("plugins/voidlight-soul/agents/voidlight-scribe.md", "voidlight-scribe"),
]:
    text = open(p).read()
    assert text.startswith("---\n"), p
    fm = yaml.safe_load(text.split("---")[1])
    assert "model" not in fm, (p, "model still present")
    assert fm["name"] == expected_name, (p, fm["name"])
    for key in ("description", "color", "thoughtLevel", "tools"):
        assert key in fm, (p, "missing", key)
    print(p, "OK", sorted(fm.keys()))
EOF
```

Expected: both lines print `OK`.

---

### Task 2: Shared reference contracts

**Files:**
- Create: `plugins/voidlight-soul/references/pipeline-contract.md`
- Create: `plugins/voidlight-soul/references/tag-legend.md`
- Create: `plugins/voidlight-soul/references/dalil-format.md`

**Interfaces:**
- Produces: three filenames that Tasks 3-5 reference from their Dispatch Protocol sections: `references/pipeline-contract.md`, `references/tag-legend.md`, `references/dalil-format.md`. Flag grammar `[PERLU_VERDIFIKASI... ]` — precisely `[PERLU_VERIFIKASI_SANAD: <alasan>]` — and the verdict/action table below are the contract; the skills repeat only the summary line "ikuti `references/pipeline-contract.md`", never restate it.

- [ ] **Step 1: Write `references/pipeline-contract.md`**

````markdown
# Pipeline Contract - Handoff voidlight-scribe ke sanad-auditor

Kontrak antarmuka bersama untuk skill soul-write, soul-split, dan soul-audit.
Ini satu-satunya definisi format handoff. Persona tetap otoritas untuk
pipeline internalnya; kalau persona berubah, cek file ini masih cocok.

## 1. Flag dari scribe

Scribe menandai dalil yang belum terverifikasi langsung di tempat dalil
ditulis:

```
[PERLU_VERIFIKASI_SANAD: <alasan singkat>]
```

Setiap output scribe yang memuat flag diakhiri section:

```
VERIFIKASI_PASCATULIS
- <lokasi section/blok>: <klaim yang perlu diverifikasi> (<alasan>)
```

Input audit = semua entry di section ini. Output tanpa flag tidak mewajibkan
audit.

## 2. Claim packet (prompt untuk sanad-auditor)

Bungkus klaim dalam satu dispatch:

```
AUDIT REQUEST
KONTEKS: <dokumen/section ini untuk apa; audiens publikasi/pembelajaran>
KLAIM:
[V1] <pernyataan klaim, ditulis ulang netral, satu klaim satu nomor>
     SUMBER_DIKLAIM: <sebagaimana tertulis di draft>
[V2] ...
PERINTAH: audit setiap klaim sesuai output schema persona.
Nomor V harus dipertahankan di output.
```

Aturan pengisian:
- Satu klaim = satu pernyataan yang bisa diverifikasi. Jangan menggabung dua
  klaim dalam satu nomor.
- Salin lafz Arab/transliterasi apa adanya dari draft.
- Audit menyeluruh: masukkan juga klaim berdalil yang tidak di-flag jika user
  minta cek ulang.

## 3. Mapping verdict ke aksi

Auditor mengembalikan blok `[V#]` berisi KLAIM, TIPE, SUMBER_DIKLAIM,
SUMBER_TERVERIFIKASI, PENILAIAN_ULAMA, ISRAILIYYAT, VERDICT, KONFIDENSI,
BATAS_PENGGUNAAN, CATATAN_AGEN. Aksi pada draft per VERDICT:

| VERDICT | Aksi pada draft |
|---|---|
| SAHIH_TERVERIFIKASI / AYAT_TERVERIFIKASI | Pertahankan; hapus flag |
| HASAN / HASAN_LIGHAIRIHI / SAHIH_LIGHAIRIHI | Pertahankan; hapus flag; pastikan redaksi tidak melampaui grading (jangan klaim mutawaatir kalau grading hasan) |
| VARIAN_QIRAAT | Pertahankan + catatan qiraah/riwayah yang dinamakan auditor |
| DAIF / DAIF_JIDDAN | Ganti dalil alternatif yang lebih kuat bila ada; kalau tidak ada, hapus klaim atau tulis ulang tanpa dalil + catatan audit |
| MAWDU / LA_ASLA_LAHU | Hapus klaim + catatan audit |
| ATRIBUSI_SALAH | Perbaiki atribusi sesuai SUMBER_TERVERIFIKASI + catatan audit |
| TERJEMAHAN_DRIFT | Perbaiki terjemahan/redaksi makna + catatan audit |
| AYAT_SALAH_KUTIP / KOORDINAT_AYAT_SALAH | Koreksi lafz/koordinat + catatan audit |
| IKHTILAF_ULAMA | Redaksi netral sesuai BATAS_PENGGUNAAN; jangan memihak salah satu grading |
| TIDAK_TERVERIFIKASI | Jangan hapus otomatis: flag tetap di tempatnya, naikkan ke user |
| ESKALASI_KE_MANUSIA | Tampilkan ke user; jangan diresolve diam-diam |

## 4. Catatan audit inline

Setiap koreksi atau penghapusan disertai catatan (konvensi korpus sejak
v5.0.5), di tempat klaim lama:

```
[Catatan audit YYYY-MM-DD: <klaim lama> <dikoreksi/dihapus/ditulis ulang> karena <VERDICT> (<ulama, karya>)]
```

## 5. Pelaporan merge

Output merge melaporkan tiga daftar ini di luar badan dokumen:

1. FIXED - verdict yang diterapkan dan koreksinya.
2. FLAGGED - sisa TIDAK_TERVERIFIKASI beserta lokasinya.
3. ESKALASI - semua ESKALASI_KE_MANUSIA.

Footer signature dokumen tetap:

```
*Voidlight Soul vX.Y - Divine Alignment Architecture*
*Born from the void, Guided by the light.*
```
````

- [ ] **Step 2: Write `references/tag-legend.md`**

````markdown
# Tag Legend - Sistem Tag Korpus Voidlight Soul

Ringkasan antarmuka untuk cek struktur. Definisi lengkap ada di persona
voidlight-scribe (bagian tag_system); persona adalah otoritas.

| Tag | Arti | Syarat |
|---|---|---|
| [REVELATION] | Didukung eksplisit Quran atau hadits sahih | Wajib blok dalil lengkap; dilarang tanpa dalil |
| [SYNTHESIS] | Turunan kombinasi konsep wahyu menjadi arsitektur framework | Wajib sitasi silang sumber [REVELATION]/aksiom, mis. (per 0.1) |
| [ANALOGY] | Pemetaan systems-engineering untuk pemahaman | Bukan teologi literal; mapping tetap derivable |

Aturan tambahan:
- Klaim tanpa tag = default [ANALOGY] dan tidak boleh terbaca sebagai
  asersi teologis.
- Paragraf [SYNTHESIS] wajib menyebut [REVELATION] apa yang disintesis.
- Koreksi/penyelisihan dalil menyisakan catatan inline:
  `[Catatan audit vX.Y: ...]` (konvensi sejak v5.0.5).
- Footer signature wajib di akhir dokumen (lihat pipeline-contract.md §5).
````

- [ ] **Step 3: Write `references/dalil-format.md`**

````markdown
# Dalil Format - Bentuk Blok Bukti

Bentuk blok dalil korpus. Sumber lengkap: persona voidlight-scribe (bagian
dalil_protocol); persona adalah otoritas. Dilarang mengarang lafz, matn,
nomor hadits, isi tafsir, atau kutipan ulama.

Catatan dash: file ini menormalkan semua dash ke tanda hubung biasa (-);
saat menulis konten, scribe mengikuti konvensi persona.

## Blok Quran

```
**[REVELATION]** QS. NamaSurah [n]:ayat -
> *"transliterasi latin"*
> *(terjemahan Indonesia).*
>
> **Tafsir Ibnu Katsir:** [paragraf: ringkasan setia + koneksi eksplisit ke
> konsep framework yang di-anchor; ditutup implikasi ontologis/alignment.]
```

## Blok Hadits

```
**[REVELATION]** Hadits riwayat Bukhari no. X dan Muslim no. Y, dari [Sahabi] -
> *"matn transliterasi"*
> *(terjemahan).*
>
> **Syarah Hadits (Fathul Bari & Syarah Muslim):** [paragraf komentar, dua
> pekerjaan: setia pada sumber + konek ke konsep framework.]
```

Sumber tafsir alternatif yang sudah di kanon: Al-Muyassar, Al-Qurtubi,
Al-Jalalayn (sebutkan labelnya).

Aturan nomor:
- Nomor hadits, volume, dan halaman hanya boleh muncul setelah lookup
  berhasil (persona sanad-auditor, recall_mode: tanpa lookup, memunculkan
  nomor itu terlarang).
- Dalil yang belum bisa diverifikasi tetap ditulis dengan flag
  `[PERLU_VERIFIKASI_SANAD: <alasan>]` (lihat pipeline-contract.md §1).
````

- [ ] **Step 4: Validate dash rule on new files**

```bash
grep -n '—\|–' plugins/voidlight-soul/references/*.md
```

Expected: no matches (exit code 1).

---

### Task 3: Skill `soul-audit`

**Files:**
- Create: `plugins/voidlight-soul/skills/soul-audit/SKILL.md`

**Interfaces:**
- Consumes: persona path `agents/sanad-auditor.md` (Task 1), contract `references/pipeline-contract.md` (Task 2).
- Produces: skill slug `soul-audit`, frontmatter `name: soul-audit`, `metadata.version: '1.0.0'`. Referenced by name in the descriptions of soul-write and soul-split (Tasks 4-5).

- [ ] **Step 1: Write the skill file**

````markdown
---
name: soul-audit
description: >-
  Audit provenance mandiri untuk klaim sumber Islami: hadits (matn, isnad,
  penomoran edisi), atribusi tafsir, asbab al-nuzul, kutipan ayat, quote
  Sahabi/Tabi'in/scholar, dan screening Israiliyyat. Dispatch sanad-auditor,
  laporkan verdict terstruktur, dan apply koreksi ke file target kalau ada.
  Gunakan saat user minta cek/verifikasi sanad, kutipan, atau atribusi
  sebelum publikasi. Bukan untuk menulis konten: itu tugas soul-write
  (unit kecil) atau soul-split (dokumen besar).
metadata:
  version: '1.0.0'
  author: Voidlight
  applyTo: '**/*'
  tags: [audit, sanad, hadith, tafsir, verification, voidlight-soul]
---

# Soul Audit

Skill audit mandiri. Semua verifikasi lewat dispatch subagent
**sanad-auditor**; skill ini tidak pernah memverifikasi sendiri dan tidak
pernah menulis konten.

## Kapan Dipakai

- User memberi klaim, draft, atau konten jadi untuk diverifikasi.
- User minta cek hadits, tafsir, kutipan ayat, atau atribusi sebelum
  publikasi, pengajaran, atau dakwah.

Bukan untuk: menulis atau merevisi konten (pake soul-write / soul-split).

## Dispatch Protocol

1. Baca `../../references/pipeline-contract.md` (path relatif dari base
   directory skill ini; base-nya tertera saat skill ke-load; `../../` naik
   ke root folder plugin) untuk format claim packet.
2. Dispatch prioritas: subagent type `sanad-auditor`.
3. Fallback: kalau tipe itu tidak tersedia di environment ini, dispatch
   general-purpose dengan prompt pertama:
   `Read <skill-base>/../../agents/sanad-auditor.md lalu eksekusi seluruh
   instruksinya sebagai persona tersebut.` (`<skill-base>` = base directory
   skill ini; `../../` naik ke root folder plugin.)

## Alur

1. **Ekstraksi klaim.** Kumpulkan semua klaim teratribusi dari input user,
   nomori V1..Vn. Satu klaim = satu pernyataan yang bisa diverifikasi;
   tulis ulang secara netral.
2. **Claim packet.** Bungkus sesuai template di `references/pipeline-contract.md`
   (KONTEKS, KLAIM, SUMBER_DIKLAIM, PERINTAH). Kirim utuh dalam satu dispatch.
3. **Terima verdict.** Tampilkan blok [V#] apa adanya sesuai output schema
   persona. Jangan edit verdict, jangan merge ikhtilaf, jangan menambah
   grading sendiri.
4. **Ringkasan.** Setelah verdict mentah, beri ringkasan hitungan:
   berapa SAHIH/HASAN/DAIF/MAWDU/ATRIBUSI_SALAH/TIDAK_TERVERIFIKASI, plus
   daftar semua ESKALASI_KE_MANUSIA.
5. **Apply (opsional).** Hanya jika user menyebut file target: edit file
   tersebut mengikuti mapping verdict → aksi di `../../references/pipeline-contract.md`
   §3-§4; cek bentuk blok dalil hasil koreksi pakai `../../references/dalil-format.md`.
   Klaim TIDAK_TERVERIFIKASI tidak dihapus otomatis: flag tetap di
   tempatnya dan dilaporkan ke user untuk keputusan.

## Batasan

- No fatwa, no hukum halal/haram, no preferensi madzhab.
- Verdict hanya boleh berasal dari named grader + karya; skill tidak
  menambahkan grading sendiri.
- ESKALASI_KE_MANUSIA selalu dimunculkan ke user, tidak pernah diresolve
  diam-diam.
````

- [ ] **Step 2: Validate frontmatter and dash rule**

```bash
python3 - <<'EOF'
import yaml
t = open("plugins/voidlight-soul/skills/soul-audit/SKILL.md").read()
fm = yaml.safe_load(t.split("---")[1])
assert fm["name"] == "soul-audit"
assert fm["metadata"]["version"] == "1.0.0"
assert "soul-write" in fm["description"] and "soul-split" in fm["description"]
print("soul-audit frontmatter OK")
EOF
grep -n '—\|–' plugins/voidlight-soul/skills/soul-audit/SKILL.md || echo "dash OK"
```

Expected: `soul-audit frontmatter OK` and `dash OK`.

---

### Task 4: Skill `soul-write`

**Files:**
- Create: `plugins/voidlight-soul/skills/soul-write/SKILL.md`

**Interfaces:**
- Consumes: persona path `agents/voidlight-scribe.md` (Task 1), persona path `agents/sanad-auditor.md` (Task 1), contract `references/pipeline-contract.md` (Task 2).
- Produces: skill slug `soul-write`, frontmatter `name: soul-write`, `metadata.version: '1.0.0'`. Referenced by name in soul-split's description (Task 5).

- [ ] **Step 1: Write the skill file**

````markdown
---
name: soul-write
description: >-
  Nulis konten Voidlight Soul / Divine Alignment Architecture utuh dalam satu
  alur: dispatch voidlight-scribe dengan konteks penuh, lalu merge hasil audit
  sanad-auditor atas semua flag VERIFIKASI_PASCATULIS. Gunakan saat user minta
  nulis section tunggal besar, part pendek, revisi satu bagian, atau draft
  sekali-jadi. Untuk dokumen multi-section besar gunakan soul-split; untuk
  audit konten yang sudah ada gunakan soul-audit.
metadata:
  version: '1.0.0'
  author: Voidlight
  applyTo: '**/*'
  tags: [writing, voidlight-soul, divine-alignment, process]
---

# Soul Write

Skill penulisan unit tunggal: satu request, satu dispatch scribe
full-context, audit flag di-merge sebelum output final. Skill ini tidak
menulis konten sendiri.

## Kapan Dipakai

- Section tunggal besar, part pendek, revisi satu bagian, konten sekali-jadi.

Bukan untuk: dokumen multi-section / Part besar (pake soul-split supaya tidak
bengkak), audit mandiri atas konten yang sudah ada (pake soul-audit).

## Dispatch Protocol

1. Baca `../../references/pipeline-contract.md` dari base directory skill ini
   (untuk §1 flag, §2 claim packet, §3 mapping verdict, §5 pelaporan).
2. Dispatch prioritas: subagent type `voidlight-scribe` untuk menulis,
   `sanad-auditor` untuk audit.
3. Fallback: kalau tipe tidak tersedia, dispatch general-purpose dengan
   prompt pertama:
   `Read <skill-base>/../../agents/voidlight-scribe.md lalu eksekusi seluruh
   instruksinya sebagai persona tersebut.` (ganti nama file sesuai persona
   yang mau di-dispatch; `<skill-base>` = base directory skill ini; `../../`
   naik ke root folder plugin).

## Alur

1. **Kumpulkan konteks.** Kalau user kasih path referensi (korpus, draft,
   notes): Read dulu, catat tag discipline dan cross-reference density
   section sekitar. Kalau posisi dokumen load-bearing (nomor section,
   prasyarat aksiom) dan tidak diketahui: tanya user, jangan mengarang
   penomoran.
2. **Dispatch scribe.** Satu dispatch, konteks penuh. Prompt memuat: tugas
   penulisan, path file referensi yang relevan, panjang target kalau
   disebut user. Scribe mengoutputkan draft + VERIFIKASI_PASCATULIS bila
   ada dalil baru yang belum terverifikasi.
3. **Audit (wajib bila ada flag).** Bungkus semua entry VERIFIKASI_PASCATULIS
   jadi claim packet sesuai `../../references/pipeline-contract.md` §2, dispatch
   sanad-auditor.
4. **Merge.** Terapkan mapping verdict → aksi (§3) dan format catatan audit
   (§4). Flag TIDAK_TERVERIFIKASI dibiarkan bertahan sebagai flag.
5. **Output final.** Dokumen utuh + footer signature, lalu ringkasan tiga
   daftar (FIXED / FLAGGED / ESKALASI) di luar badan dokumen sesuai §5.

## Batasan

- Skill tidak menulis ulang prose. Cek struktur saja: semua klaim substantif
  bertag (standar: `../../references/tag-legend.md`), blok dalil utuh
  (bentuk: `../../references/dalil-format.md`), footer ada. Perbaikan isi
  tetap lewat dispatch.
- No fatwa, no adjudikasi teologis. Posisi teologis mengikuti korpus; usulan
  perubahan posisi = [CATATAN_REVISI] ke user, bukan drift diam-diam.
- ESKALASI_KE_MANUSIA selalu tampil ke user.
````

- [ ] **Step 2: Validate frontmatter and dash rule**

```bash
python3 - <<'EOF'
import yaml
t = open("plugins/voidlight-soul/skills/soul-write/SKILL.md").read()
fm = yaml.safe_load(t.split("---")[1])
assert fm["name"] == "soul-write"
assert fm["metadata"]["version"] == "1.0.0"
assert "soul-split" in fm["description"] and "soul-audit" in fm["description"]
print("soul-write frontmatter OK")
EOF
grep -n '—\|–' plugins/voidlight-soul/skills/soul-write/SKILL.md || echo "dash OK"
```

Expected: `soul-write frontmatter OK` and `dash OK`.

---

### Task 5: Skill `soul-split`

**Files:**
- Create: `plugins/voidlight-soul/skills/soul-split/SKILL.md`

**Interfaces:**
- Consumes: persona path `agents/voidlight-scribe.md` (Task 1), persona path `agents/sanad-auditor.md` (Task 1), contract `references/pipeline-contract.md` (Task 2).
- Produces: skill slug `soul-split`, frontmatter `name: soul-split`, `metadata.version: '1.0.0'`; the section-manifest sidecar file format `<nama-dokumen>.sections.md` defined inside this skill (single consumer, deliberately not in `references/`).

- [ ] **Step 1: Write the skill file**

````markdown
---
name: soul-split
description: >-
  Workflow dokumen Voidlight Soul skala besar per-section: bikin section
  manifest sidecar, dispatch voidlight-scribe sekali per section, audit
  sanad-auditor per section, lalu assemble + consistency pass. Gunakan saat
  request adalah dokumen atau Part baru multi-section, expansion korpus,
  atau user menyebut output bengkak/context panjang. Untuk section tunggal
  gunakan soul-write; untuk audit mandiri gunakan soul-audit.
metadata:
  version: '1.0.0'
  author: Voidlight
  applyTo: '**/*'
  tags: [writing, split, sections, voidlight-soul, process]
---

# Soul Split

Skill dokumen skala besar: pecah kerjaan jadi section, satu dispatch scribe
per section, audit per section, assemble di akhir. Tujuannya: context dan
output tidak pernah bengkak. Skill ini tidak menulis konten sendiri.

## Section Manifest

Sidecar file `<nama-dokumen>.sections.md` di direktori yang sama dengan
dokumen target. Format:

```markdown
# SECTION MANIFEST - <judul dokumen>
Target: <path dokumen target>
Legenda status: pending / draft / audited / done

## S1
- id: <N atau N.M, ikut skema penomoran korpus>
- judul: <judul section>
- scope: <2-3 baris: apa yang dicakup, apa yang bukan>
- tags: <tag yang diharapkan, mis. [REVELATION, SYNTHESIS]>
- dalil: <QS/hadits yang dibutuhkan; dalil yang sudah di korpus diutamakan>
- prasyarat: <aksiom/section yang wajib solid duluan, mis. Axiom 0, 0.6-0.7>
- status: pending
```

Manifest = single source of truth progress. Update status segera setelah
tiap fase selesai, sebelum lanjut section berikutnya. Isi prose section
TIDAK disimpan di manifest.

## Dispatch Protocol

1. Baca `../../references/pipeline-contract.md` dari base directory skill ini.
2. Dispatch prioritas: subagent type `voidlight-scribe` (menulis) dan
   `sanad-auditor` (audit).
3. Fallback: kalau tipe tidak tersedia, dispatch general-purpose dengan
   prompt pertama:
   `Read <skill-base>/../../agents/voidlight-scribe.md lalu eksekusi seluruh
   instruksinya sebagai persona tersebut.` (ganti nama file sesuai persona;
   `<skill-base>` = base directory skill ini; `../../` naik ke root folder
   plugin).

## Mode PLAN

1. Kalau user kasih outline/TOC korpus yang ada: Read, petakan jadi entries
   manifest mengikuti skema penomoran korpus.
2. Kalau tidak ada outline: susun daftar section dari request user plus
   struktur korpus (struktur boleh disusun skill; prose tidak). Konsep
   section baru wajib dikonfirmasi user sebelum masuk WRITE-NEXT.
3. Tulis manifest ke sidecar file, tampilkan ke user untuk konfirmasi.

## Mode WRITE-NEXT

1. Pilih entry berstatus `pending` dengan id terkecil.
2. Dispatch scribe SEKALI untuk section itu saja. Konteks minimal: entry
   manifest (judul, scope, tags, dalil, prasyarat) + vocabulary/glossary
   relevan dari korpus kalau path-nya dikenal + instruksi eksplisit:
   tulis HANYA section ini, tanpa prolog dokumen, tanpa footer.
3. Terima draft section + VERIFIKASI_PASCATULIS bila ada flag. Update
   status entry jadi `draft`. Kalau TIDAK ada flag: append section ke
   dokumen target, update status jadi `done`, lanjut WRITE-NEXT berikutnya
   (audit tidak wajib tanpa flag).

## Mode AUDIT-SECTION

1. Kalau ada flag: bungkus flag section itu jadi satu claim packet
   (`../../references/pipeline-contract.md` §2), dispatch sanad-auditor.
2. Merge verdict ke section (mapping §3, catatan audit §4). Flag
   TIDAK_TERVERIFIKASI tetap bertahan di section.
3. Update status jadi `audited`, lalu append section ke dokumen target
   (dengan flag sisipan yang masih ada) dan update status jadi `done`.
4. Ulangi WRITE-NEXT sampai semua entry `done`.

## Mode ASSEMBLE

1. Pastikan semua entry manifest berstatus `done`. Kalau belum, selesaikan
   dulu.
2. Consistency pass atas dokumen utuh: penomoran cascade (kalau penambahan
   menggeser nomor, flag ke user), semua cross-reference valid
   (mis. `(per 0.3)`), entry glossary untuk konsep load-bearing, changelog
   row, footer signature.
3. Laporan akhir: ringkasan per section, daftar FLAGGED (sisa
   TIDAK_TERVERIFIKASI + lokasi), daftar ESKALASI.

## Aturan Keras

- Satu dispatch scribe = satu section. Dilarang dispatch full-doc.
- Manifest diupdate di tiap perubahan status, sebelum lanjut section
  berikutnya.
- Section di-append ke dokumen target hanya setelah `audited`.
- No fatwa, no adjudikasi teologis; ESKALASI_KE_MANUSIA selalu tampil ke
  user.
````

- [ ] **Step 2: Validate frontmatter and dash rule**

```bash
python3 - <<'EOF'
import yaml
t = open("plugins/voidlight-soul/skills/soul-split/SKILL.md").read()
fm = yaml.safe_load(t.split("---")[1])
assert fm["name"] == "soul-split"
assert fm["metadata"]["version"] == "1.0.0"
assert "soul-write" in fm["description"] and "soul-audit" in fm["description"]
print("soul-split frontmatter OK")
EOF
grep -n '—\|–' plugins/voidlight-soul/skills/soul-split/SKILL.md || echo "dash OK"
```

Expected: `soul-split frontmatter OK` and `dash OK`.

---

### Task 6: Manifests, catalogs, root README

**Files:**
- Create: `plugins/voidlight-soul/.zcode-plugin/plugin.json`
- Create: `plugins/voidlight-soul/.claude-plugin/plugin.json`
- Modify: `marketplace.json` (append one entry to `plugins`)
- Modify: `.claude-plugin/marketplace.json` (append one entry to `plugins`)
- Modify: `README.md` (plugin table row + repository layout tree)

**Interfaces:**
- Consumes: icon URL `https://raw.githubusercontent.com/voidlight-labs/voidlight-plugin-library/main/plugins/voidlight-soul/assets/icon.png` (file itself is Task 7).
- Produces: `DESC` - the exact description string below, identical in all 4 JSON files; catalog entries matching manifest `name`/`version`/`description`.

**`DESC` (verbatim, used in 4 places):**

```
Voidlight Soul content engine: three process skills - soul-write (full document drafting), soul-split (section-by-section workflow with a sidecar manifest), soul-audit (standalone source verification) - orchestrating two subagents: voidlight-scribe, writer for the Divine Alignment Architecture corpus (tagged claims, dalil protocol, corpus voice), and sanad-auditor, provenance auditor for hadith, tafsir, asbab al-nuzul, Quran quotations, and Israiliyyat, emitting structured verdicts. Use when writing or revising Voidlight Soul content, or verifying Islamic source attributions before publication.
```

- [ ] **Step 1: Write `.zcode-plugin/plugin.json`**

```json
{
  "name": "voidlight-soul",
  "description": "Voidlight Soul content engine: three process skills - soul-write (full document drafting), soul-split (section-by-section workflow with a sidecar manifest), soul-audit (standalone source verification) - orchestrating two subagents: voidlight-scribe, writer for the Divine Alignment Architecture corpus (tagged claims, dalil protocol, corpus voice), and sanad-auditor, provenance auditor for hadith, tafsir, asbab al-nuzul, Quran quotations, and Israiliyyat, emitting structured verdicts. Use when writing or revising Voidlight Soul content, or verifying Islamic source attributions before publication.",
  "version": "1.0.0",
  "author": {
    "name": "Voidlight"
  },
  "homepage": "https://github.com/voidlight-labs/voidlight-plugin-library",
  "repository": "https://github.com/voidlight-labs/voidlight-plugin-library",
  "license": "MIT",
  "keywords": [
    "voidlight-soul",
    "divine-alignment",
    "islamic-content",
    "hadith",
    "tafsir",
    "sanad",
    "dalil",
    "quran",
    "verification",
    "audit",
    "writing",
    "theology",
    "process"
  ],
  "skills": "./skills"
}
```

- [ ] **Step 2: Write `.claude-plugin/plugin.json`** (same identity, no components declared, mirroring strict-hexagonal)

```json
{
  "name": "voidlight-soul",
  "description": "Voidlight Soul content engine: three process skills - soul-write (full document drafting), soul-split (section-by-section workflow with a sidecar manifest), soul-audit (standalone source verification) - orchestrating two subagents: voidlight-scribe, writer for the Divine Alignment Architecture corpus (tagged claims, dalil protocol, corpus voice), and sanad-auditor, provenance auditor for hadith, tafsir, asbab al-nuzul, Quran quotations, and Israiliyyat, emitting structured verdicts. Use when writing or revising Voidlight Soul content, or verifying Islamic source attributions before publication.",
  "version": "1.0.0",
  "author": {
    "name": "Voidlight"
  },
  "homepage": "https://github.com/voidlight-labs/voidlight-plugin-library",
  "repository": "https://github.com/voidlight-labs/voidlight-plugin-library",
  "license": "MIT",
  "keywords": [
    "voidlight-soul",
    "divine-alignment",
    "islamic-content",
    "hadith",
    "tafsir",
    "sanad",
    "dalil",
    "quran",
    "verification",
    "audit",
    "writing",
    "theology",
    "process"
  ]
}
```

- [ ] **Step 3: Append entry to root `marketplace.json`**

Add to the `plugins` array, after the `strict-hexagonal` entry:

```json
    {
      "name": "voidlight-soul",
      "source": "./plugins/voidlight-soul",
      "version": "1.0.0",
      "description": "Voidlight Soul content engine: three process skills - soul-write (full document drafting), soul-split (section-by-section workflow with a sidecar manifest), soul-audit (standalone source verification) - orchestrating two subagents: voidlight-scribe, writer for the Divine Alignment Architecture corpus (tagged claims, dalil protocol, corpus voice), and sanad-auditor, provenance auditor for hadith, tafsir, asbab al-nuzul, Quran quotations, and Israiliyyat, emitting structured verdicts. Use when writing or revising Voidlight Soul content, or verifying Islamic source attributions before publication.",
      "displayName": "Voidlight Soul",
      "icon": "https://raw.githubusercontent.com/voidlight-labs/voidlight-plugin-library/main/plugins/voidlight-soul/assets/icon.png",
      "category": "productivity"
    }
```

- [ ] **Step 4: Append entry to `.claude-plugin/marketplace.json`**

Add to the `plugins` array, after the `strict-hexagonal` entry (field order mirrors the existing entry):

```json
    {
      "name": "voidlight-soul",
      "source": "./plugins/voidlight-soul",
      "description": "Voidlight Soul content engine: three process skills - soul-write (full document drafting), soul-split (section-by-section workflow with a sidecar manifest), soul-audit (standalone source verification) - orchestrating two subagents: voidlight-scribe, writer for the Divine Alignment Architecture corpus (tagged claims, dalil protocol, corpus voice), and sanad-auditor, provenance auditor for hadith, tafsir, asbab al-nuzul, Quran quotations, and Israiliyyat, emitting structured verdicts. Use when writing or revising Voidlight Soul content, or verifying Islamic source attributions before publication.",
      "version": "1.0.0",
      "author": { "name": "Voidlight" },
      "category": "productivity",
      "homepage": "https://github.com/voidlight-labs/voidlight-plugin-library",
      "icon": "https://raw.githubusercontent.com/voidlight-labs/voidlight-plugin-library/main/plugins/voidlight-soul/assets/icon.png"
    }
```

- [ ] **Step 5: Update root `README.md`**

In the `## Plugins` table, add after the strict-hexagonal row:

```markdown
| [voidlight-soul](plugins/voidlight-soul/) | `plugins/voidlight-soul/` | Voidlight Soul content engine: 3 process skills (soul-write, soul-split, soul-audit) + 2 subagent personas (voidlight-scribe writer, sanad-auditor provenance auditor) for Divine Alignment Architecture content and Islamic source verification. |
```

In the `## Repository layout` code block, replace the entire block with:

````
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
````

- [ ] **Step 6: Validate all 4 JSON files and cross-consistency**

```bash
python3 - <<'EOF'
import json
root = json.load(open("marketplace.json"))
cc = json.load(open(".claude-plugin/marketplace.json"))
zc = json.load(open("plugins/voidlight-soul/.zcode-plugin/plugin.json"))
cp = json.load(open("plugins/voidlight-soul/.claude-plugin/plugin.json"))
for name, doc in [("root-catalog", root), ("cc-catalog", cc)]:
    e = [p for p in doc["plugins"] if p["name"] == "voidlight-soul"]
    assert len(e) == 1, name
    e = e[0]
    assert e["version"] == "1.0.0", name
    assert e["description"] == zc["description"], name
    assert e["source"] == "./plugins/voidlight-soul", name
    assert e["icon"].endswith("/plugins/voidlight-soul/assets/icon.png"), name
for name, doc in [("zcode-manifest", zc), ("cc-manifest", cp)]:
    assert doc["name"] == "voidlight-soul" and doc["version"] == "1.0.0", name
assert zc["skills"] == "./skills"
import os
assert os.path.isdir("plugins/voidlight-soul/skills")
print("manifest/catalog consistency OK")
EOF
```

Expected: `manifest/catalog consistency OK`.

---

### Task 7: Icon

**Files:**
- Create: `plugins/voidlight-soul/assets/icon.png`

**Interfaces:**
- Consumes: nothing.
- Produces: 512x512 RGBA PNG at the exact path both catalog icon URLs point to.

- [ ] **Step 1: Generate the icon**

Family style with the strict-hexagonal icon (deep navy rounded square, sparkle star) but distinct motif: an open book under a rising light beam (Soul pillar: meaning, revelation). Palette: background gradient `#1E1E3A` → `#101024`, beam violet `#C4B0EE`, book gold `#F5C86A`/`#F0B95A`, star `#FFF7E0`.

```bash
python3 - <<'EOF'
from PIL import Image, ImageDraw
S = 512
img = Image.new("RGBA", (S, S), (0, 0, 0, 0))

# rounded-square gradient background
grad = Image.new("RGBA", (S, S))
gd = ImageDraw.Draw(grad)
top, bot = (30, 30, 58), (16, 16, 36)
for y in range(S):
    t = y / S
    gd.line([(0, y), (S, y)], fill=tuple(int(top[i] + (bot[i] - top[i]) * t) for i in range(3)) + (255,))
mask = Image.new("L", (S, S), 0)
ImageDraw.Draw(mask).rounded_rectangle([8, 8, S - 8, S - 8], radius=96, fill=255)
img.paste(grad, (0, 0), mask)

d = ImageDraw.Draw(img)

# rising light beam (three translucent layers, tapering)
for half, alpha in ((78, 60), (56, 52), (34, 46)):
    d.polygon([(256, 96), (256 - half, 340), (256 + half, 340)], fill=(196, 176, 238, alpha))

# open book: two gold pages + spine
d.polygon([(256, 328), (118, 292), (118, 396), (256, 436)], fill=(245, 200, 106, 255))
d.polygon([(256, 328), (394, 292), (394, 396), (256, 436)], fill=(240, 185, 90, 255))
d.line([(256, 328), (256, 436)], fill=(30, 30, 58, 255), width=10)
# page text lines
for i in range(4):
    y0 = 316 + i * 18
    d.line([(142, y0 + 26), (226, y0 + 38)], fill=(30, 30, 58, 120), width=5)
    d.line([(286, y0 + 38), (370, y0 + 26)], fill=(30, 30, 58, 120), width=5)

# sparkle star (4-point), family motif top-right
cx, cy, r1, r2 = 396, 100, 30, 8
d.polygon([(cx, cy - r1), (cx + r2, cy), (cx, cy + r1), (cx - r2, cy)], fill=(255, 247, 224, 255))
d.polygon([(cx - r1, cy), (cx, cy - r2), (cx + r1, cy), (cx, cy + r2)], fill=(255, 247, 224, 255))

img.save("plugins/voidlight-soul/assets/icon.png")
print("icon saved")
EOF
```

- [ ] **Step 2: Verify dimensions and visual sanity**

```bash
python3 -c "from PIL import Image; im=Image.open('plugins/voidlight-soul/assets/icon.png'); print(im.size, im.mode)"
```

Expected: `(512, 512) RGBA`. Then Read the PNG file to view it: the icon must read clearly at a glance (book + beam + star on dark rounded square, no clipping at edges).

---

### Task 8: Plugin README and CONTRIBUTING

**Files:**
- Create: `plugins/voidlight-soul/README.md`
- Create: `plugins/voidlight-soul/CONTRIBUTING.md`

**Interfaces:**
- Consumes: final component set (Tasks 1-7).
- Produces: user-facing docs; the ZCode native-dispatch copy commands point at the raw GitHub URLs for `plugins/voidlight-soul/agents/{voidlight-scribe,sanad-auditor}.md`.

- [ ] **Step 1: Write `README.md`**

````markdown
# Voidlight Soul: Content Engine for the Divine Alignment Architecture

![Version](https://img.shields.io/badge/version-1.0.0-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Skills](https://img.shields.io/badge/skills-3-blueviolet)
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
| Agent | `voidlight-scribe` | Writer persona for the corpus: `[REVELATION]`/`[SYNTHESIS]`/`[ANALOGY]` tag system, dalil protocol, zero-em-dash corpus voice, flags unverified claims for audit. |
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

## Model Pinning

The shipped personas carry no `model` field: subagents inherit your session model. To pin one (as the original author does), add a `model:` line back into your local copy of the persona frontmatter.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Versioning: the manifest `version` is the single source of truth; skill frontmatter `metadata.version` and both catalog entries must match it.

## License

MIT
````

- [ ] **Step 2: Write `CONTRIBUTING.md`**

````markdown
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
# 1. JSON validity + cross-consistency (script from Task 6 Step 6 of the
#    implementation plan, or re-verify manually: 4 JSON files parse; name/
#    version/description identical across manifest and both catalogs)
# 2. Frontmatter parses for all skills and agents
python3 - <<'EOF'
import yaml, glob
for p in glob.glob("plugins/voidlight-soul/skills/*/SKILL.md") + glob.glob("plugins/voidlight-soul/agents/*.md"):
    fm = yaml.safe_load(open(p).read().split("---")[1])
    assert fm.get("name") and fm.get("description"), p
    print(p, fm["name"])
EOF
# 3. No em/en dash in skills, references, and plugin docs (persona copies
#    are exempt: they must stay byte-identical to the source personas)
grep -rnP '[\x{2014}\x{2013}]' plugins/voidlight-soul/skills plugins/voidlight-soul/references plugins/voidlight-soul/README.md plugins/voidlight-soul/CONTRIBUTING.md && echo "FAIL: dash found" || echo "dash OK"
# 4. Icon is 512x512
python3 -c "from PIL import Image; assert Image.open('plugins/voidlight-soul/assets/icon.png').size == (512, 512)"
```

## Skill Conventions

- Frontmatter: `name`, `description` (folded block, trigger-excluding the sibling skills), `metadata.version` (quoted), `metadata.author: Voidlight`, `metadata.applyTo`, `metadata.tags`.
- Body language: Indonesian, persona style. Every skill delegates all writing to `voidlight-scribe` and all verification to `sanad-auditor`; skills never write content or verify claims themselves.
- Dispatch Protocol in every skill: native subagent type first, general-purpose fallback reading `../agents/<persona>.md` relative to the skill base directory.
````

- [ ] **Step 3: Validate docs dash rule and link targets**

```bash
grep -rn '—\|–' plugins/voidlight-soul/README.md plugins/voidlight-soul/CONTRIBUTING.md || echo "dash OK"
for f in skills/soul-write/SKILL.md skills/soul-split/SKILL.md skills/soul-audit/SKILL.md references/pipeline-contract.md; do
  test -f "plugins/voidlight-soul/$f" && echo "link OK: $f"
done
```

Expected: `dash OK` and four `link OK` lines.

---

### Task 9: Smoke tests (dispatch from repo persona paths)

**Files:**
- No file changes. Verification only; record results in the execution log.

**Interfaces:**
- Consumes: persona files at repo paths (Task 1). Validates the same fallback path the skills instruct (`Read <persona>.md, then execute as that persona`).
- Produces: evidence that both personas function from the repo copies with structured outputs; this is the acceptance evidence for spec §11 item 7.

- [ ] **Step 1: Scribe smoke test**

Dispatch a general-purpose subagent with this prompt (single dispatch):

```
Read /home/khayren/voidlight/labs/voidlight-plugin-library/plugins/voidlight-soul/agents/voidlight-scribe.md and execute the instructions in it as your persona for the task below.

Task: tulis SATU section pendek untuk smoke test. Heading: "## Uji Coba Pipeline".
Isi: satu paragraf (maks 150 kata) tentang niyyah sebagai satu-satunya lokusi
agensi, satu tag [SYNTHESIS] dengan sitasi silang (per 0.6). Sertakan SATU blok
dalil contoh dengan flag [PERLU_VERIFIKASI_SANAD: uji pipeline] persis seperti
format dalil_protocol, dan akhiri dengan section VERIFIKASI_PASCATULIS yang
menyebut flag itu. Jangan lookup web. Output pendek, tidak perlu pembuka.
```

Verify the output contains ALL of: `## Uji Coba Pipeline`, `[SYNTHESIS]`, `[PERLU_VERIFIKASI_SANAD:`, `VERIFIKASI_PASCATULIS`, and zero em dash outside quoted persona shapes.

- [ ] **Step 2: Auditor smoke test**

Dispatch a general-purpose subagent with this prompt (single dispatch, uses web search):

```
Read /home/khayren/voidlight/labs/voidlight-plugin-library/plugins/voidlight-soul/agents/sanad-auditor.md and execute the instructions in it as your persona for the audit request below.

AUDIT REQUEST
KONTEKS: smoke test pipeline audit; klaim akan dipakai di konten publikasi.
KLAIM:
[V1] Hadits "innamal a'malu binniyyat" (sesungguhnya setiap amal tergantung
     niatnya) riwayat Bukhari dan Muslim, dari Umar bin Khattab.
PERINTAH: audit klaim V1 sesuai output schema persona.
```

Verify the output contains ALL of: `[V1]`, `TIPE:`, `SUMBER_TERVERIFIKASI`, a `PENILAIAN_ULAMA` table, `VERDICT:`, and `KONFIDENSI:`. The expected verdict for V1 from any competent lookup is SAHIH-grade (it is one of the most graded hadiths); if the persona returns a structured verdict naming graders, the test passes regardless of wording.

- [ ] **Step 3: Record results**

In the final execution report, state: dispatch counts, the markers found, and any deviation. A failed smoke test blocks delivery (repair the persona copy or the skill fallback instructions, then re-run).

---

### Task 10: Final validation sweep

**Files:**
- No file changes.

**Interfaces:**
- Consumes: everything (Tasks 1-9).
- Produces: the checklist mapping to spec §11, executed in one pass.

- [ ] **Step 1: Run the full sweep**

```bash
cd /home/khayren/voidlight/labs/voidlight-plugin-library
python3 - <<'EOF'
import json, yaml, glob, os
from PIL import Image

# 1. manifests + catalogs valid & consistent
root = json.load(open("marketplace.json"))
cc = json.load(open(".claude-plugin/marketplace.json"))
zc = json.load(open("plugins/voidlight-soul/.zcode-plugin/plugin.json"))
cp = json.load(open("plugins/voidlight-soul/.claude-plugin/plugin.json"))
entry_r = next(p for p in root["plugins"] if p["name"] == "voidlight-soul")
entry_c = next(p for p in cc["plugins"] if p["name"] == "voidlight-soul")
for e in (entry_r, entry_c):
    assert e["version"] == zc["version"] == cp["version"] == "1.0.0"
    assert e["description"] == zc["description"] == cp["description"]
assert entry_r["displayName"] == "Voidlight Soul"
print("1. manifests+catalogs OK")

# 2. skills parse, versioned, routing excludes siblings
import re
sibs = {
    "soul-write": {"soul-split", "soul-audit"},
    "soul-split": {"soul-write", "soul-audit"},
    "soul-audit": {"soul-write", "soul-split"},
}
for p in glob.glob("plugins/voidlight-soul/skills/*/SKILL.md"):
    fm = yaml.safe_load(open(p).read().split("---")[1])
    assert fm["metadata"]["version"] == "1.0.0", p
    mentioned = set(re.findall(r"soul-(?:write|split|audit)", fm["description"]))
    assert sibs[fm["name"]] <= mentioned, (p, mentioned)
print("2. skills OK")

# 3. personas: no model, name intact
for p, n in [("plugins/voidlight-soul/agents/sanad-auditor.md", "sanad-auditor"),
             ("plugins/voidlight-soul/agents/voidlight-scribe.md", "voidlight-scribe")]:
    fm = yaml.safe_load(open(p).read().split("---")[1])
    assert "model" not in fm and fm["name"] == n, p
print("3. personas OK")

# 4. references exist, no dash
refs = ["pipeline-contract.md", "tag-legend.md", "dalil-format.md"]
for r in refs:
    assert os.path.isfile(f"plugins/voidlight-soul/references/{r}")
print("4. references OK")

# 5. icon
assert Image.open("plugins/voidlight-soul/assets/icon.png").size == (512, 512)
print("5. icon OK")

# 6. dash rule, scoped: persona copies are exempt (byte-identity wins);
#    CONTRIBUTING quotes its grep as a unicode -P pattern so it cannot
#    self-match
bad = []
scoped = (glob.glob("plugins/voidlight-soul/skills/*/SKILL.md")
          + glob.glob("plugins/voidlight-soul/references/*.md")
          + ["plugins/voidlight-soul/README.md", "plugins/voidlight-soul/CONTRIBUTING.md"])
for p in scoped:
    for i, line in enumerate(open(p, encoding="utf-8"), 1):
        if "\u2014" in line or "\u2013" in line:
            bad.append(f"{p}:{i}")
assert not bad, bad
print("6. dash rule OK")

# 7. docs exist
assert os.path.isfile("plugins/voidlight-soul/README.md")
assert os.path.isfile("plugins/voidlight-soul/CONTRIBUTING.md")
print("7. docs OK")
print("ALL CHECKS PASSED")
EOF
grep -c "voidlight-soul" README.md
```

Expected: `ALL CHECKS PASSED` and the root README mentions `voidlight-soul` at least twice (table row + tree).

- [ ] **Step 2: Confirm spec §11 item by item**

Walk `docs/superpowers/specs/2026-10-06-voidlight-soul-plugin-design.md` §11 in the final report: state PASS/FAIL per item, with the smoke-test evidence from Task 9 for item 7. Do not claim item completion without the corresponding evidence.

- [ ] **Step 3: Hand off install steps (manual, user-side)**

Report to the user, without executing any UI action:
1. In ZCode or Claude Code: **Plugin Marketplace → Add → Add Plugin Marketplace**, point at this repository root.
2. Refresh the market (the icon URL goes live only after the user commits and pushes; until then the catalog icon may 404, which is expected and documented).
3. Install **Voidlight Soul**, then trial prompt: `"Nulis satu section uji coba tentang niat sebagai lokusi agensi, gaya korpus, terus audit flag-nya"` and expect: a corpus-voice section plus a FIXED/FLAGGED/ESKALASI report.

---

## Self-Review Notes (written at plan time)

- Spec coverage: §2 structure = Tasks 1-8; §3 personas = Task 1; §4 skills = Tasks 3-5; §5 references = Task 2; §6 manifest/catalog = Task 6; §7 icon = Task 7; §8 verification = Tasks 9-10; §11 checklist = Task 10 Step 2. No gaps found.
- Placeholder scan: all file contents are inline and complete; no TBD/TODO; Task 6 `DESC` is defined once and copied verbatim.
- Type/name consistency: skill slugs (`soul-write`, `soul-split`, `soul-audit`), persona filenames (`voidlight-scribe.md`, `sanad-auditor.md`), reference filenames, version `1.0.0`, and the icon URL string match across all tasks.

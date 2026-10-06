# Design: Plugin `voidlight-soul`

- Tanggal: 2026-10-06
- Status: approved (desain), menunggu review spec
- Repo: `voidlight-labs/voidlight-plugin-library`
- Versi plugin: `1.0.0`

## 1. Ringkasan

Plugin yang mempackage dua subagent buatan user menjadi plugin installable di
voidlight-plugin-library:

- **`voidlight-scribe`** - writer untuk korpus Voidlight Soul / Divine
  Alignment Architecture (tag `[REVELATION]`/`[SYNTHESIS]`/`[ANALOGY]`,
  dalil protocol, corpus voice).
- **`sanad-auditor`** - auditor provenance sumber Islami: hadith, tafsir,
  asbab al-nuzul, kutipan ayat, atribusi Sahabi/scholar, screening
  Israiliyyat. Output verdict terstruktur.

Dikawal **3 skill proses** yang jadi satu-satunya komponen declared di
manifest ZCode:

| Skill | Fungsi | Trigger |
|---|---|---|
| `soul-write` | Nulis dokumen/part utuh, satu dispatch scribe, audit flags di-merge di akhir | "nulis dokumen/part baru, draft sekali-jadi" |
| `soul-split` | Dokumen besar per-section: manifest sidecar, satu dispatch per section, audit per section, assemble | "dokumen multi-section, Part baru korpus, anti-bengkak" |
| `soul-audit` | Audit mandiri atas klaim/konten yang diberikan user; verdict report atau apply ke file target | "cek/verifikasi hadits/tafsir/ayat/atribusi" |

Posisi brand: Pillar 2 Voidlight Soul, "Every system remembers its maker".

## 2. Struktur

```
plugins/voidlight-soul/
├── .zcode-plugin/plugin.json      # identity + "skills": "./skills"
├── .claude-plugin/plugin.json     # identity saja (pattern strict-hexagonal, auto-discover)
├── agents/
│   ├── voidlight-scribe.md        # sumber: ~/.zcode/agents/voidlight-scribe.system.md
│   └── sanad-auditor.md           # sumber: ~/.zcode/agents/sanad-auditor.md
├── skills/
│   ├── soul-write/SKILL.md
│   ├── soul-split/SKILL.md
│   └── soul-audit/SKILL.md
├── references/
│   ├── pipeline-contract.md
│   ├── tag-legend.md
│   └── dalil-format.md
├── assets/icon.png                # 512x512
├── README.md
└── CONTRIBUTING.md
```

## 3. Persona

Sumber: definisi user-level di `~/.zcode/agents/` (tidak diubah, tidak
dihapus - dispatch native ZCode user masih bergantung padanya).

Adaptasi saat copy ke plugin:

1. Hapus field `model:` dari kedua frontmatter (keputusan user: strip model;
   subagent mewarisi model session). Field lain tetap: `name`, `description`,
   `color`, `thoughtLevel`, `tools`, `injectAgentsMd`.
2. File scribe dinamai ulang: `voidlight-scribe.system.md` →
   `agents/voidlight-scribe.md`.
3. Body persona tidak diubah sama sekali. Persona tetap self-contained.

Aturan sync: repo = source of truth. File user-level adalah "installed copy";
README mendokumentasikan cara re-sync (copy ulang setelah edit repo).

## 4. Skill

### 4.1 Aturan umum

- Frontmatter: `name`, `description`, plus `metadata.version` = versi plugin
  (konvensi strict-hexagonal). Bahasa deskripsi: Indonesia, gaya persona.
- Description tiap skill saling exclude trigger agar routing tepat.
- Skill tidak pernah menulis konten sendiri; semua penulisan lewat dispatch
  scribe, semua verifikasi lewat dispatch auditor.
- Dispatch protocol di semua skill: pakai tipe subagent native
  (`voidlight-scribe` / `sanad-auditor`); fallback jika tipe tidak tersedia:
  dispatch general-purpose dengan instruksi Read persona dari path relatif
  folder skill (`../agents/<nama>.md`), lalu eksekusi instruksinya.
- Batasan: no fatwa, no adjudikasi teologis, `ESKALASI_KE_MANUSIA` selalu
  dimunculkan ke user, tidak pernah diam-diam diresolve.

### 4.2 `soul-write`

Alur: request → dispatch scribe (konteks full: referensi file korpus/draft
jika user beri path) → output + `VERIFIKASI_PASCATULIS` → jika ada flag,
dispatch auditor dengan claim packet → merge verdict ke dokumen → dokumen
final + sisa flag dilaporkan.

Cocok untuk: section tunggal besar, part pendek, konten sekali-jadi.

### 4.3 `soul-split`

Workflow 4 mode:

1. **PLAN** - dari request/outline/TOC korpus yang ada, buat **section
   manifest**: sidecar file di sebelah dokumen target (misal
   `PART-IV.sections.md`). Entry: id section (`N.M`), judul, scope 2-3 baris,
   tag yang diharapkan, dalil yang dibutuhkan, status
   (`pending → draft → audited → done`). Format manifest didefinisikan di
   dalam SKILL.md ini (konsumen tunggal, tidak masuk `references/`).
2. **WRITE-NEXT** - ambil section `pending` berikutnya, dispatch scribe
   sekali per section dengan konteks minimal: entry manifest + glossary/
   vocabulary + axiom prasyarat section itu saja.
3. **AUDIT-SECTION** - flag `VERIFIKASI_PASCATULIS` section itu dibawa ke
   auditor (ikuti kontrak `pipeline-contract.md`), verdict di-merge, status
   naik ke `audited`.
4. **ASSEMBLE** - stitch semua section, consistency pass (nomor cascade,
   cross-ref, glossary, changelog row, footer signature), laporan akhir +
   sisa flag.

Aturan keras: satu dispatch scribe = satu section; manifest = single source
of truth progress; section `audited` langsung di-append ke dokumen target.

### 4.4 `soul-audit`

Alur: user beri klaim/draft/konten jadi → ekstrak klaim, nomori V1..Vn →
dispatch auditor → laporan verdict terstruktur (skema output persona); jika
ada file target, verdict di-apply ke dokumen (+ `[Catatan audit vX.Y]` sesuai
konvensi korpus).

## 5. references/ (kontrak antarmuka)

Aturan anti-drift: `references/` hanya berisi **kontrak antarmuka** (yang
lintas skill); pipeline internal tetap otoritas persona. CONTRIBUTING
mendokumentasikan aturan ini.

- **`pipeline-contract.md`** - format flag `[PERLU_VERIFIKASI_SANAD:
  <alasan>]`; bentuk `VERIFIKASI_PASCATULIS`; template claim packet untuk
  dispatch auditor; ringkasan skema verdict `[V#]`; mapping verdict → aksi:
  `MAWDU`/`LA_ASLA_LAHU` → hapus klaim; `ATRIBUSI_SALAH` → perbaiki
  atribusi; `DAIF` → tulis ulang/syaratkan + catatan audit;
  `TERJEMAHAN_DRIFT`/`AYAT_SALAH_KUTIP`/`KOORDINAT_AYAT_SALAH` → koreksi
  lafz/koordinat; `TIDAK_TERVERIFIKASI` → flag tetap + naik ke user;
  aturan merge dan pelaporan sisa flag.
- **`tag-legend.md`** - ringkasan `[REVELATION]`/`[SYNTHESIS]`/`[ANALOGY]`,
  default tag, konvensi `[Catatan audit vX.Y]`, footer signature.
- **`dalil-format.md`** - bentuk block dalil Quran/hadits, label sumber
  tafsir (Ibnu Katsir, Al-Muyassar, Al-Qurtubi, Al-Jalalayn).

## 6. Manifest & katalog

### 6.1 `.zcode-plugin/plugin.json`

Field: `name` (voidlight-soul), `description` (lihat 6.3), `version` (1.0.0),
`author` {name: Voidlight}, `homepage`, `repository` (URL repo), `license`
(MIT), `keywords`, `"skills": "./skills"`. Folder `agents/` TIDAK dideklarasikan
(manifest ZCode tidak punya komponen agents; didokumentasikan di README).

### 6.2 `.claude-plugin/plugin.json`

Identity sama, tanpa deklarasi komponen (pattern strict-hexagonal). Folder
`agents/` auto-discover di Claude Code.

### 6.3 Draft description (manifest + kedua katalog, sama)

> Voidlight Soul content engine: three process skills - soul-write (full
> document drafting), soul-split (section-by-section workflow with a sidecar
> manifest), soul-audit (standalone source verification) - orchestrating two
> subagents: voidlight-scribe, writer for the Divine Alignment Architecture
> corpus (tagged claims, dalil protocol, corpus voice), and sanad-auditor,
> provenance auditor for hadith, tafsir, asbab al-nuzul, Quran quotations,
> and Israiliyyat, emitting structured verdicts. Use when writing or revising
> Voidlight Soul content, or verifying Islamic source attributions before
> publication.

### 6.4 Entry katalog (root `marketplace.json` dan `.claude-plugin/marketplace.json`)

```json
{
  "name": "voidlight-soul",
  "source": "./plugins/voidlight-soul",
  "version": "1.0.0",
  "description": "<sama dengan manifest>",
  "displayName": "Voidlight Soul",
  "icon": "https://raw.githubusercontent.com/voidlight-labs/voidlight-plugin-library/main/plugins/voidlight-soul/assets/icon.png",
  "category": "productivity"
}
```

Root `README.md` ditambah baris plugin di tabel plugin.

## 7. Icon

512x512 PNG, palet Voidlight (latar gelap "void" + cahaya), konsisten gaya
dengan icon strict-hexagonal (dicek saat implementasi). Motif: naskah/gulungan
+ berkas cahaya; aksen warna beda dari strict-hexagonal agar distingtif di
marketplace. Digenerate programatis.

## 8. Verifikasi

1. JSON valid untuk 4 file (2 manifest + 2 katalog); parse frontmatter YAML
   untuk 3 skill + 2 persona.
2. Konsistensi: name/version/description manifest ↔ kedua katalog;
   `metadata.version` skill = versi manifest.
3. Path containment: tidak ada path keluar root plugin.
4. Smoke test dari persona **di repo** (bukan user-level): dispatch
   general-purpose yang Read persona repo (validasi jalur fallback); satu
   mini-write scribe dengan flag dalil disengaja; satu mini-audit auditor
   atas 1-2 klaim nyata; output sesuai skema.
5. Icon: verifikasi dimensi 512x512.
6. UI add market/install = handoff manual ke user; tidak diklaim selesai
   sebelum user konfirmasi.

## 9. Out of scope

- Konten korpus Voidlight Soul itu sendiri (milik user, tidak di-ship).
- Benchmark scenario (process plugin; benchmark.py hanya cover craft skill).
- Installer script (copy manual 2 file didokumentasi; fallback skill
  menutupi kasus tidak-copy).
- Otomasi UI marketplace (add market/install tetap manual).
- Dokumentasi bilingual.

## 10. Risiko & catatan

- Subagent plugin tidak ter-register native di ZCode → fallback via skill
  sudah didesain; native dispatch butuh copy manual ke `~/.zcode/agents/`
  (didokumentasikan).
- Model di-strip → kualitas scribe bergantung model session; README
  mencantumkan cara pin model.
- Drift persona ↔ references → aturan interface-only + checklist CONTRIBUTING.

## 11. Kriteria selesai

1. Kedua manifest valid dan konsisten, versi 1.0.0 di semua tempat.
2. Kedua katalog punya entry; root README punya baris plugin.
3. 3 skill parse; deskripsi routing-nya saling exclude.
4. 2 persona ter-copy, field model hilang, body identik dengan sumber.
5. `references/` berisi 3 file kontrak, tanpa duplikasi pipeline persona.
6. `icon.png` 512x512 ada; URL katalog cocok dengan path push.
7. Smoke test dispatch dari path repo berhasil dengan output sesuai skema.
8. README + CONTRIBUTING plugin ada, memuat sync rule + fallback + aturan
   anti-drift.

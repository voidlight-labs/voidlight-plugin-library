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
  version: '1.2.0'
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
- Section di-append ke dokumen target hanya setelah `audited` (atau langsung
  `done` bila tanpa flag, lihat WRITE-NEXT).
- No fatwa, no adjudikasi teologis; ESKALASI_KE_MANUSIA selalu tampil ke
  user.

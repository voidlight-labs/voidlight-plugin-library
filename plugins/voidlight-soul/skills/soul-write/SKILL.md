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
  version: '1.2.0'
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

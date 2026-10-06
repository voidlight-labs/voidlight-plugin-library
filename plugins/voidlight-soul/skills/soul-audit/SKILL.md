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
  version: '1.1.0'
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
2. **Claim packet.** Bungkus sesuai template di `../../references/pipeline-contract.md`
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

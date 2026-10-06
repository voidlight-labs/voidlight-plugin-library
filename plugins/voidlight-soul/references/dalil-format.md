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

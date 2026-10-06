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

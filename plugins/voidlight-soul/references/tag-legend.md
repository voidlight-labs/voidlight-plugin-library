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

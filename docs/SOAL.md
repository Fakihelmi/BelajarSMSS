# Soal Latihan

Berikut soal dari fixture awal. Kerjakan pada database SupportInterviewLab100.

```text
SOAL LATIHAN (TANPA KUNCI JAWABAN)
Semua soal memakai database ini. Urutkan hasil secara deterministik jika mengambil TOP.

DASAR / PEMANASAN
01. Tampilkan transaksi FAILED, terbaru lebih dahulu; jika waktunya sama, ID terbesar dahulu.
02. Tampilkan transaksi pada 4 November 2026 dengan batas >= awal hari dan < hari berikutnya.
03. Ambil 5 transaksi SUCCESS bernilai terbesar; jika sama, TransactionID terkecil dahulu.
04. Hitung jumlah transaksi untuk masing-masing status.
05. Tampilkan transaksi yang ErrorCode-nya tidak NULL.

MENENGAH / LIVE SQL
06. Tampilkan TransactionID, FullName, ApplicationName, Amount, dan status transaksi.
07. Tampilkan SEMUA pengguna dan jumlah transaksinya, termasuk pengguna tanpa transaksi.
08. Tampilkan pengguna yang belum mempunyai transaksi dengan LEFT JOIN; ulangi memakai NOT EXISTS.
09. Hitung total Amount transaksi SUCCESS per aplikasi; tampilkan aplikasi tanpa transaksi juga.
10. Tampilkan ReferenceNo duplikat beserta jumlahnya, lalu tampilkan detail semua baris terkait.
11. Tampilkan pengguna dengan >= 2 transaksi SUCCESS menggunakan GROUP BY dan HAVING.
12. Hitung jumlah dan persentase FAILED per aplikasi. Sertakan aplikasi tanpa transaksi;
    untuk aplikasi tersebut, persentase 0. Hindari pembagian integer dan pembagian nol.
13. Tampilkan transaksi terakhir SETIAP pengguna menggunakan ROW_NUMBER(); sertakan pengguna
    tanpa transaksi. Jika waktu sama, pilih TransactionID terbesar.
14. Cari transaksi yang Amount-nya di atas rata-rata Amount seluruh transaksi SUCCESS.
15. Buat ringkasan harian: tanggal, total transaksi, jumlah SUCCESS/FAILED/PENDING dengan CASE.

KASUS APPLICATION SUPPORT
16. Tampilkan tiket yang belum RESOLVED/CLOSED dan sudah melewati SLADueAt pada
    waktu acuan 2026-11-07T12:00:00. Urutkan P1 sampai P4, lalu tenggat paling awal.
17. Hitung durasi resolusi dalam menit dan label ON_TIME atau BREACHED untuk tiket
    RESOLVED/CLOSED. Tepat pada tenggat berarti ON_TIME.
18. Hubungkan tiket incident dengan transaksi, pengguna, aplikasi, dan log-nya memakai JOIN.
    Satu transaksi boleh memiliki banyak log; jelaskan kenapa baris hasil dapat bertambah.
19. Ambil log ERROR Payment Gateway pada 4 November 2026 antara pukul 10:00 (inklusif)
    dan 10:10 (eksklusif). Hubungkan dengan transaksi dan tiket jika ada.
20. Berdasarkan nomor 19, tulis catatan eskalasi: waktu, aplikasi, ID transaksi/tiket,
    gejala, bukti, dan pemeriksaan lanjutan. Pisahkan fakta dan dugaan penyebab.

OBJEK DATABASE / LANJUTAN
21. Buat View dbo.vw_OpenTickets berisi tiket OPEN/IN_PROGRESS, pengguna, dan aplikasi.
22. Buat Stored Procedure dbo.usp_GetTransactionsByStatus dengan parameter @Status.
23. Buat Function dbo.fn_ResolutionMinutes(@CreatedAt DATETIME2(0), @ResolvedAt DATETIME2(0))
    yang mengembalikan INT menit; NULL jika belum selesai. Pakai pada query tiket.
24. Jelaskan kandidat index untuk filter ApplicationID + CreatedAt pada Transactions.
    Karena datanya kecil, jangan menyimpulkan peningkatan performa dari waktu eksekusi saja.
25. Rancang langkah SQL Agent Job untuk laporan harian transaksi FAILED: jadwal, query,
    histori kegagalan, dan notifikasi. Cukup desain; SQL Agent bergantung edisi SQL Server.

LATIHAN PERUBAHAN DATA (HANYA DATABASE LAB)
26. Dalam transaksi eksplisit, pilih satu tiket OPEN; ubah ke IN_PROGRESS dengan WHERE
    TicketID; cek @@ROWCOUNT dan hasil SELECT; lalu ROLLBACK agar fixture tetap sama.

RENCANA PEMAKAIAN
Sesi 1: soal 1-5, 30 menit. Sesi 2: soal 6-15, 90 menit.
Sesi 3: soal 16-20, 45 menit. Sesi 4: soal 21-26, 60 menit.
Ucapkan asumsi dan alasan JOIN/filter saat mengerjakan, seperti pada live test.
```

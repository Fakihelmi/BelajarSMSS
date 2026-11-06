USE SupportInterviewLab100;
GO
-- Jalankan satu bagian bila ingin melihat hasilnya secara terpisah.
-- 1. Pilih kolom
SELECT TransactionID, Amount, Status FROM dbo.Transactions;

-- 2. Cari satu referensi bisnis (bisa ada lebih dari satu baris jika referensi duplikat)
SELECT * FROM dbo.Transactions WHERE ReferenceNo = 'REF-0017';

-- 3. Filter dua kondisi
SELECT TransactionID, Amount, Status
FROM dbo.Transactions
WHERE Status = 'SUCCESS' AND Amount > 100000;

-- 4. Pilih beberapa status
SELECT * FROM dbo.Transactions WHERE Status IN ('FAILED', 'PENDING');

-- 5. Cari sebagian nama
SELECT UserID, FullName FROM dbo.Users WHERE FullName LIKE '%a%';

-- 6. Seluruh transaksi pada satu hari, termasuk jamnya
SELECT * FROM dbo.Transactions
WHERE CreatedAt >= '2026-11-04T00:00:00'
  AND CreatedAt < '2026-11-05T00:00:00'
ORDER BY CreatedAt DESC, TransactionID DESC;

-- 7. Lima transaksi terbesar
SELECT TOP (5) TransactionID, Amount, Status
FROM dbo.Transactions ORDER BY Amount DESC, TransactionID ASC;

-- 8. Rekap per status
SELECT Status, COUNT(*) AS JumlahTransaksi
FROM dbo.Transactions GROUP BY Status;

-- 9. Nilai kosong
SELECT * FROM dbo.Transactions WHERE ErrorCode IS NULL;

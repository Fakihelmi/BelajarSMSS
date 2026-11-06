USE SupportInterviewLab100;
GO
-- Nama pengguna dan aplikasi dari transaksi gagal.
-- t, u, a adalah alias tabel; ON menyatakan pasangan kolomnya.
SELECT t.TransactionID, u.FullName, a.ApplicationName, t.Amount, t.Status
FROM dbo.Transactions AS t
INNER JOIN dbo.Users AS u ON u.UserID = t.UserID
INNER JOIN dbo.Applications AS a ON a.ApplicationID = t.ApplicationID
WHERE t.Status = 'FAILED'
ORDER BY t.TransactionID;

-- Pengguna tanpa transaksi: LEFT JOIN mempertahankan pengguna dari tabel kiri.
SELECT u.UserID, u.FullName
FROM dbo.Users AS u
LEFT JOIN dbo.Transactions AS t ON t.UserID = u.UserID
WHERE t.TransactionID IS NULL
ORDER BY u.UserID;

-- Jumlah transaksi semua pengguna, termasuk yang nol.
-- COUNT(t.TransactionID) menghitung transaksi, bukan baris pengguna tanpa pasangan.
SELECT u.UserID, u.FullName, COUNT(t.TransactionID) AS JumlahTransaksi
FROM dbo.Users AS u
LEFT JOIN dbo.Transactions AS t ON t.UserID = u.UserID
GROUP BY u.UserID, u.FullName
ORDER BY u.UserID;

-- Investigasi log ERROR: bukti gejala, bukan kepastian akar penyebab.
SELECT l.LogID, l.LoggedAt, a.ApplicationName,
       t.TransactionID, t.ReferenceNo, t.Status, l.Message
FROM dbo.ApplicationLogs AS l
INNER JOIN dbo.Applications AS a ON a.ApplicationID = l.ApplicationID
LEFT JOIN dbo.Transactions AS t ON t.TransactionID = l.TransactionID
WHERE l.LogLevel = 'ERROR'
  AND l.LoggedAt >= '2026-11-04T10:00:00'
  AND l.LoggedAt < '2026-11-04T10:10:00'
ORDER BY l.LoggedAt, l.LogID;

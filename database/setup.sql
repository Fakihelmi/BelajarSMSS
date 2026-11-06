/*
LATIHAN INTERVIEW FIRST LEVEL SUPPORT - SQL SERVER / SSMS
Data sintetis. Bukan data atau soal resmi PT KANO TEKNOLOGI UTAMA.
TOTAL 100 BARIS: Users 15 + Applications 5 + Transactions 40 + Tickets 25 + ApplicationLogs 15.

CARA PAKAI:
1. Buka file ini di SSMS dan sambungkan ke SQL Server lokal/lab.
2. Akun harus mempunyai izin CREATE DATABASE. SSMS sendiri bukan mesin database.
3. Klik Execute untuk menjalankan seluruh file. GO adalah pemisah batch SSMS.
4. Bisa dijalankan ulang: bila kelima tabel sudah ada, data tetap dipertahankan.
   Bila baru sebagian tabel ada, skrip berhenti tanpa mengubah data.
5. Kerjakan soal di jendela New Query terpisah dengan database latihan ini.

RELASI: Users 1:N Transactions; Applications 1:N Transactions;
Users 1:N Tickets; Applications 1:N Tickets;
Transactions 1:N Tickets dan ApplicationLogs (referensi boleh NULL);
Applications 1:N ApplicationLogs.

KAMUS SINGKAT:
Amount = nilai transaksi dalam rupiah. Waktu = WIB, disimpan tanpa offset.
ReferenceNo = referensi bisnis; sengaja ada duplikasi untuk investigasi.
ResolvedAt = waktu pemulihan; dipertahankan saat tiket CLOSED.
SLADueAt = tenggat penyelesaian fiktif untuk latihan, bukan SLA perusahaan.
P1 paling tinggi. NULL TransactionID = kejadian/permintaan tidak terkait transaksi tertentu.
Untuk soal SLA gunakan waktu acuan tetap 2026-11-07T12:00:00, bukan GETDATE().
Tanggal transaksi: 1-6 November 2026. Aplikasi 5 tidak mempunyai transaksi.
Timeout dalam log adalah gejala; dataset ini belum membuktikan akar penyebabnya.
*/
USE master;
GO
IF DB_ID(N'SupportInterviewLab100') IS NULL
    EXEC(N'CREATE DATABASE SupportInterviewLab100;');
GO
USE SupportInterviewLab100;
GO
IF OBJECT_ID(N'dbo.Users', N'U') IS NULL
AND OBJECT_ID(N'dbo.Applications', N'U') IS NULL
AND OBJECT_ID(N'dbo.Transactions', N'U') IS NULL
AND OBJECT_ID(N'dbo.Tickets', N'U') IS NULL
AND OBJECT_ID(N'dbo.ApplicationLogs', N'U') IS NULL
BEGIN
    EXEC sys.sp_executesql N'SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRY
BEGIN TRANSACTION;

CREATE TABLE dbo.Users (
    UserID INT PRIMARY KEY, FullName NVARCHAR(60) NOT NULL, Department NVARCHAR(30) NOT NULL, Email NVARCHAR(100) NOT NULL
);

CREATE TABLE dbo.Applications (
    ApplicationID INT PRIMARY KEY, ApplicationName NVARCHAR(80) NOT NULL, LinuxServiceName VARCHAR(60) NOT NULL
);

CREATE TABLE dbo.Transactions (
    TransactionID INT PRIMARY KEY, ReferenceNo VARCHAR(30) NOT NULL,
    UserID INT NOT NULL REFERENCES dbo.Users(UserID),
    ApplicationID INT NOT NULL REFERENCES dbo.Applications(ApplicationID),
    Amount DECIMAL(18,2) NOT NULL CHECK (Amount >= 0),
    Status VARCHAR(10) NOT NULL CHECK (Status IN (''SUCCESS'',''FAILED'',''PENDING'')),
    CreatedAt DATETIME2(0) NOT NULL, ErrorCode VARCHAR(40) NULL
);

CREATE TABLE dbo.Tickets (
    TicketID INT PRIMARY KEY, UserID INT NOT NULL REFERENCES dbo.Users(UserID),
    ApplicationID INT NOT NULL REFERENCES dbo.Applications(ApplicationID),
    TransactionID INT NULL REFERENCES dbo.Transactions(TransactionID),
    TicketType VARCHAR(20) NOT NULL CHECK (TicketType IN (''INCIDENT'',''SERVICE_REQUEST'',''PROBLEM'')),
    Priority VARCHAR(2) NOT NULL CHECK (Priority IN (''P1'',''P2'',''P3'',''P4'')),
    Status VARCHAR(15) NOT NULL CHECK (Status IN (''OPEN'',''IN_PROGRESS'',''RESOLVED'',''CLOSED'')),
    Title NVARCHAR(150) NOT NULL, CreatedAt DATETIME2(0) NOT NULL,
    SLADueAt DATETIME2(0) NOT NULL, ResolvedAt DATETIME2(0) NULL,
    CHECK (SLADueAt >= CreatedAt), CHECK (ResolvedAt IS NULL OR ResolvedAt >= CreatedAt),
    CHECK ((Status IN (''RESOLVED'',''CLOSED'') AND ResolvedAt IS NOT NULL)
        OR (Status IN (''OPEN'',''IN_PROGRESS'') AND ResolvedAt IS NULL))
);

CREATE TABLE dbo.ApplicationLogs (
    LogID INT PRIMARY KEY, ApplicationID INT NOT NULL REFERENCES dbo.Applications(ApplicationID),
    TransactionID INT NULL REFERENCES dbo.Transactions(TransactionID),
    LogLevel VARCHAR(5) NOT NULL CHECK (LogLevel IN (''INFO'',''WARN'',''ERROR'')),
    LoggedAt DATETIME2(0) NOT NULL, Message NVARCHAR(250) NOT NULL
);

-- Users: 15 baris
INSERT INTO dbo.Users VALUES
(1, N''Andi'', N''Finance'', N''user01@example.com''),
(2, N''Budi'', N''Operations'', N''user02@example.com''),
(3, N''Citra'', N''Sales'', N''user03@example.com''),
(4, N''Dewi'', N''Finance'', N''user04@example.com''),
(5, N''Eka'', N''IT'', N''user05@example.com''),
(6, N''Farhan'', N''Operations'', N''user06@example.com''),
(7, N''Gita'', N''HR'', N''user07@example.com''),
(8, N''Hana'', N''Sales'', N''user08@example.com''),
(9, N''Indra'', N''Finance'', N''user09@example.com''),
(10, N''Joko'', N''IT'', N''user10@example.com''),
(11, N''Karina'', N''HR'', N''user11@example.com''),
(12, N''Lina'', N''Operations'', N''user12@example.com''),
(13, N''Maya'', N''Sales'', N''user13@example.com''),
(14, N''Nanda'', N''Finance'', N''user14@example.com''),
(15, N''Oki'', N''HR'', N''user15@example.com'');

-- Applications: 5 baris
INSERT INTO dbo.Applications VALUES
(1, N''Payment Gateway'', N''payment.service''),
(2, N''Customer Portal'', N''portal.service''),
(3, N''Inventory System'', N''inventory.service''),
(4, N''HR Portal'', N''hr.service''),
(5, N''Reporting Dashboard'', N''reporting.service'');

-- Transactions: 40 baris
INSERT INTO dbo.Transactions VALUES
(1, N''REF-0001'', 1, 1, 42500.0, N''SUCCESS'', N''2026-11-01T11:00:00'', NULL),
(2, N''REF-0002'', 2, 2, 60000.0, N''FAILED'', N''2026-11-01T14:00:00'', N''PAYMENT_DECLINED''),
(3, N''REF-0003'', 3, 3, 77500.0, N''PENDING'', N''2026-11-01T17:00:00'', NULL),
(4, N''REF-0004'', 4, 4, 95000.0, N''SUCCESS'', N''2026-11-01T20:00:00'', NULL),
(5, N''REF-0005'', 5, 1, 112500.0, N''SUCCESS'', N''2026-11-01T23:00:00'', NULL),
(6, N''REF-0006'', 6, 2, 130000.0, N''SUCCESS'', N''2026-11-02T02:00:00'', NULL),
(7, N''REF-0007'', 7, 3, 147500.0, N''FAILED'', N''2026-11-02T05:00:00'', N''PAYMENT_DECLINED''),
(8, N''REF-0008'', 8, 4, 165000.0, N''PENDING'', N''2026-11-02T08:00:00'', NULL),
(9, N''REF-0009'', 9, 1, 25000.0, N''SUCCESS'', N''2026-11-02T11:00:00'', NULL),
(10, N''REF-0010'', 10, 2, 42500.0, N''SUCCESS'', N''2026-11-02T14:00:00'', NULL),
(11, N''REF-0011'', 11, 3, 60000.0, N''SUCCESS'', N''2026-11-02T17:00:00'', NULL),
(12, N''REF-0012'', 12, 4, 77500.0, N''FAILED'', N''2026-11-02T20:00:00'', N''PAYMENT_DECLINED''),
(13, N''REF-0013'', 1, 1, 95000.0, N''PENDING'', N''2026-11-02T23:00:00'', NULL),
(14, N''REF-0014'', 2, 2, 112500.0, N''SUCCESS'', N''2026-11-03T02:00:00'', NULL),
(15, N''REF-0015'', 3, 3, 130000.0, N''SUCCESS'', N''2026-11-03T05:00:00'', NULL),
(16, N''REF-0016'', 4, 4, 147500.0, N''SUCCESS'', N''2026-11-03T08:00:00'', NULL),
(17, N''REF-0017'', 5, 1, 165000.0, N''FAILED'', N''2026-11-04T10:00:00'', N''DB_TIMEOUT''),
(18, N''REF-0018'', 6, 1, 25000.0, N''FAILED'', N''2026-11-04T10:01:00'', N''DB_TIMEOUT''),
(19, N''REF-0019'', 7, 1, 42500.0, N''FAILED'', N''2026-11-04T10:02:00'', N''DB_TIMEOUT''),
(20, N''REF-0020'', 8, 4, 60000.0, N''SUCCESS'', N''2026-11-03T20:00:00'', NULL),
(21, N''REF-0021'', 9, 1, 77500.0, N''SUCCESS'', N''2026-11-03T23:00:00'', NULL),
(22, N''REF-0022'', 10, 2, 95000.0, N''FAILED'', N''2026-11-04T02:00:00'', N''PAYMENT_DECLINED''),
(23, N''REF-0023'', 11, 3, 112500.0, N''PENDING'', N''2026-11-04T05:00:00'', NULL),
(24, N''REF-0024'', 12, 4, 130000.0, N''SUCCESS'', N''2026-11-04T08:00:00'', NULL),
(25, N''REF-0025'', 1, 1, 147500.0, N''SUCCESS'', N''2026-11-04T11:00:00'', NULL),
(26, N''REF-0026'', 2, 2, 165000.0, N''SUCCESS'', N''2026-11-04T14:00:00'', NULL),
(27, N''REF-0027'', 3, 3, 25000.0, N''FAILED'', N''2026-11-04T17:00:00'', N''PAYMENT_DECLINED''),
(28, N''REF-0028'', 4, 4, 42500.0, N''PENDING'', N''2026-11-04T20:00:00'', NULL),
(29, N''REF-0029'', 5, 1, 60000.0, N''SUCCESS'', N''2026-11-04T23:00:00'', NULL),
(30, N''REF-0030'', 6, 2, 77500.0, N''SUCCESS'', N''2026-11-05T02:00:00'', NULL),
(31, N''REF-0030'', 7, 3, 95000.0, N''SUCCESS'', N''2026-11-05T05:00:00'', NULL),
(32, N''REF-0032'', 8, 4, 112500.0, N''FAILED'', N''2026-11-05T08:00:00'', N''PAYMENT_DECLINED''),
(33, N''REF-0033'', 9, 1, 130000.0, N''PENDING'', N''2026-11-05T11:00:00'', NULL),
(34, N''REF-0034'', 10, 2, 147500.0, N''SUCCESS'', N''2026-11-05T14:00:00'', NULL),
(35, N''REF-0035'', 11, 3, 165000.0, N''SUCCESS'', N''2026-11-05T17:00:00'', NULL),
(36, N''REF-0036'', 12, 4, 25000.0, N''SUCCESS'', N''2026-11-05T20:00:00'', NULL),
(37, N''REF-0037'', 1, 1, 42500.0, N''FAILED'', N''2026-11-05T23:00:00'', N''PAYMENT_DECLINED''),
(38, N''REF-0038'', 2, 2, 60000.0, N''PENDING'', N''2026-11-06T02:00:00'', NULL),
(39, N''REF-0039'', 3, 3, 77500.0, N''SUCCESS'', N''2026-11-06T05:00:00'', NULL),
(40, N''REF-0040'', 4, 4, 95000.0, N''SUCCESS'', N''2026-11-06T08:00:00'', NULL);

-- Tickets: 25 baris
INSERT INTO dbo.Tickets VALUES
(1, 5, 1, 17, N''INCIDENT'', N''P1'', N''IN_PROGRESS'', N''Multiple users report payment timeout'', N''2026-11-04T10:03:00'', N''2026-11-04T14:03:00'', NULL),
(2, 2, 2, 2, N''INCIDENT'', N''P2'', N''IN_PROGRESS'', N''User reports transaction failure'', N''2026-11-01T16:00:00'', N''2026-11-02T00:00:00'', NULL),
(3, 3, 3, NULL, N''SERVICE_REQUEST'', N''P3'', N''RESOLVED'', N''Request application access'', N''2026-11-01T20:00:00'', N''2026-11-02T20:00:00'', N''2026-11-02T19:00:00''),
(4, 4, 4, NULL, N''PROBLEM'', N''P4'', N''CLOSED'', N''Investigate recurring application errors'', N''2026-11-02T00:00:00'', N''2026-11-04T00:00:00'', N''2026-11-04T02:00:00''),
(5, 5, 1, 5, N''INCIDENT'', N''P1'', N''RESOLVED'', N''User reports transaction failure'', N''2026-11-02T04:00:00'', N''2026-11-02T08:00:00'', N''2026-11-02T07:00:00''),
(6, 6, 2, 6, N''INCIDENT'', N''P2'', N''OPEN'', N''User reports transaction failure'', N''2026-11-02T08:00:00'', N''2026-11-02T16:00:00'', NULL),
(7, 7, 3, 7, N''INCIDENT'', N''P3'', N''IN_PROGRESS'', N''User reports transaction failure'', N''2026-11-02T12:00:00'', N''2026-11-03T12:00:00'', NULL),
(8, 8, 3, NULL, N''SERVICE_REQUEST'', N''P4'', N''RESOLVED'', N''Request application access'', N''2026-11-02T16:00:00'', N''2026-11-04T16:00:00'', N''2026-11-04T18:00:00''),
(9, 9, 4, NULL, N''PROBLEM'', N''P1'', N''CLOSED'', N''Investigate recurring application errors'', N''2026-11-02T20:00:00'', N''2026-11-03T00:00:00'', N''2026-11-02T23:00:00''),
(10, 10, 2, 10, N''INCIDENT'', N''P2'', N''RESOLVED'', N''User reports transaction failure'', N''2026-11-03T00:00:00'', N''2026-11-03T08:00:00'', N''2026-11-03T10:00:00''),
(11, 11, 3, 11, N''INCIDENT'', N''P3'', N''OPEN'', N''User reports transaction failure'', N''2026-11-03T04:00:00'', N''2026-11-04T04:00:00'', NULL),
(12, 12, 4, 12, N''INCIDENT'', N''P4'', N''IN_PROGRESS'', N''User reports transaction failure'', N''2026-11-03T08:00:00'', N''2026-11-05T08:00:00'', NULL),
(13, 1, 3, NULL, N''SERVICE_REQUEST'', N''P1'', N''RESOLVED'', N''Request application access'', N''2026-11-03T12:00:00'', N''2026-11-03T16:00:00'', N''2026-11-03T15:00:00''),
(14, 2, 4, NULL, N''PROBLEM'', N''P2'', N''CLOSED'', N''Investigate recurring application errors'', N''2026-11-03T16:00:00'', N''2026-11-04T00:00:00'', N''2026-11-04T02:00:00''),
(15, 3, 3, 15, N''INCIDENT'', N''P3'', N''RESOLVED'', N''User reports transaction failure'', N''2026-11-03T20:00:00'', N''2026-11-04T20:00:00'', N''2026-11-04T19:00:00''),
(16, 4, 4, 16, N''INCIDENT'', N''P4'', N''OPEN'', N''User reports transaction failure'', N''2026-11-04T00:00:00'', N''2026-11-06T00:00:00'', NULL),
(17, 5, 1, 17, N''INCIDENT'', N''P1'', N''IN_PROGRESS'', N''User reports transaction failure'', N''2026-11-04T04:00:00'', N''2026-11-04T08:00:00'', NULL),
(18, 6, 3, NULL, N''SERVICE_REQUEST'', N''P2'', N''RESOLVED'', N''Request application access'', N''2026-11-04T08:00:00'', N''2026-11-04T16:00:00'', N''2026-11-04T18:00:00''),
(19, 7, 4, NULL, N''PROBLEM'', N''P3'', N''CLOSED'', N''Investigate recurring application errors'', N''2026-11-04T12:00:00'', N''2026-11-05T12:00:00'', N''2026-11-05T11:00:00''),
(20, 8, 4, 20, N''INCIDENT'', N''P4'', N''RESOLVED'', N''User reports transaction failure'', N''2026-11-04T16:00:00'', N''2026-11-06T16:00:00'', N''2026-11-06T18:00:00''),
(21, 9, 1, 21, N''INCIDENT'', N''P1'', N''OPEN'', N''User reports transaction failure'', N''2026-11-04T20:00:00'', N''2026-11-05T00:00:00'', NULL),
(22, 10, 2, 22, N''INCIDENT'', N''P2'', N''IN_PROGRESS'', N''User reports transaction failure'', N''2026-11-05T00:00:00'', N''2026-11-05T08:00:00'', NULL),
(23, 11, 3, NULL, N''SERVICE_REQUEST'', N''P3'', N''RESOLVED'', N''Request application access'', N''2026-11-05T04:00:00'', N''2026-11-06T04:00:00'', N''2026-11-06T03:00:00''),
(24, 12, 4, NULL, N''PROBLEM'', N''P4'', N''CLOSED'', N''Investigate recurring application errors'', N''2026-11-05T08:00:00'', N''2026-11-07T08:00:00'', N''2026-11-07T10:00:00''),
(25, 1, 1, 25, N''INCIDENT'', N''P1'', N''RESOLVED'', N''User reports transaction failure'', N''2026-11-05T12:00:00'', N''2026-11-05T16:00:00'', N''2026-11-05T15:00:00'');

-- ApplicationLogs: 15 baris
INSERT INTO dbo.ApplicationLogs VALUES
(1, 1, 17, N''ERROR'', N''2026-11-04T10:00:00'', N''Database request timed out after 30 seconds''),
(2, 1, 18, N''ERROR'', N''2026-11-04T10:01:00'', N''Database request timed out after 30 seconds''),
(3, 1, 19, N''ERROR'', N''2026-11-04T10:02:00'', N''Database request timed out after 30 seconds''),
(4, 4, 8, N''WARN'', N''2026-11-02T08:00:00'', N''Awaiting provider response''),
(5, 2, 10, N''INFO'', N''2026-11-02T14:00:00'', N''Transaction processed successfully''),
(6, 4, 12, N''ERROR'', N''2026-11-02T20:00:00'', N''Transaction rejected by provider''),
(7, 2, 14, N''INFO'', N''2026-11-03T02:00:00'', N''Transaction processed successfully''),
(8, 4, 16, N''INFO'', N''2026-11-03T08:00:00'', N''Transaction processed successfully''),
(9, 1, 18, N''ERROR'', N''2026-11-04T10:01:00'', N''Transaction rejected by provider''),
(10, 4, 20, N''INFO'', N''2026-11-03T20:00:00'', N''Transaction processed successfully''),
(11, 2, 22, N''ERROR'', N''2026-11-04T02:00:00'', N''Transaction rejected by provider''),
(12, 4, 24, N''INFO'', N''2026-11-04T08:00:00'', N''Transaction processed successfully''),
(13, 2, 26, N''INFO'', N''2026-11-04T14:00:00'', N''Transaction processed successfully''),
(14, 4, 28, N''WARN'', N''2026-11-04T20:00:00'', N''Awaiting provider response''),
(15, 5, NULL, N''WARN'', N''2026-11-05T07:00:00'', N''Scheduled reporting task delayed'');

COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;';
    PRINT N'Database latihan berhasil diisi.';
END
ELSE IF OBJECT_ID(N'dbo.Users', N'U') IS NOT NULL
AND OBJECT_ID(N'dbo.Applications', N'U') IS NOT NULL
AND OBJECT_ID(N'dbo.Transactions', N'U') IS NOT NULL
AND OBJECT_ID(N'dbo.Tickets', N'U') IS NOT NULL
AND OBJECT_ID(N'dbo.ApplicationLogs', N'U') IS NOT NULL
BEGIN
    PRINT N'Tabel latihan sudah ada. Data dipertahankan, tidak diisi ulang.';
END
ELSE
BEGIN
    ;THROW 50001, N'Hanya sebagian tabel ditemukan. Tidak ada data yang diubah.', 1;
END;
GO
-- Verifikasi: lima tabel dan TotalRows = 100.
SELECT N'Users' AS TableName, COUNT(*) AS JumlahBaris FROM dbo.Users
UNION ALL SELECT N'Applications', COUNT(*) FROM dbo.Applications
UNION ALL SELECT N'Transactions', COUNT(*) FROM dbo.Transactions
UNION ALL SELECT N'Tickets', COUNT(*) FROM dbo.Tickets
UNION ALL SELECT N'ApplicationLogs', COUNT(*) FROM dbo.ApplicationLogs;
SELECT (SELECT COUNT(*) FROM dbo.Users)
     + (SELECT COUNT(*) FROM dbo.Applications)
     + (SELECT COUNT(*) FROM dbo.Transactions)
     + (SELECT COUNT(*) FROM dbo.Tickets)
     + (SELECT COUNT(*) FROM dbo.ApplicationLogs) AS TotalRows;
GO
/*
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
*/

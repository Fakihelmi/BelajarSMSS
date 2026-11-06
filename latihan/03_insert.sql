USE SupportInterviewLab100;
GO
-- Jalankan seluruh batch berikut. Data ditampilkan sebelum dibatalkan.
-- Pilih ID latihan yang tidak bentrok dengan pengguna tambahan dari sesi belajar.
SET XACT_ABORT ON;
BEGIN TRY
    BEGIN TRANSACTION;
    IF EXISTS (SELECT 1 FROM dbo.Users WHERE UserID = 1001)
        THROW 50002, 'UserID 1001 sudah ada. Gunakan ID latihan lain.', 1;

    INSERT INTO dbo.Users (UserID, FullName, Department, Email)
    VALUES (1001, 'Pengguna Latihan', 'IT', 'practice@example.com');

    SELECT * FROM dbo.Users WHERE UserID = 1001;
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO
-- Setelah ROLLBACK, hasil ini kosong jika ID 1001 awalnya belum ada.
SELECT * FROM dbo.Users WHERE UserID = 1001;

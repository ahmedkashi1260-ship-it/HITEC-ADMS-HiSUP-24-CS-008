USE HiSUP_DB;
GO

-- Encrypt procedure
CREATE OR ALTER PROCEDURE UpdateStudentSensitiveInfo
    @StudentID INT,
    @CNIC NVARCHAR(20),
    @BankAccount NVARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        OPEN SYMMETRIC KEY HiSUP_SymKey
        DECRYPTION BY CERTIFICATE HiSUP_Cert;

        UPDATE Students
        SET 
            CNIC = CONVERT(NVARCHAR(256), 
                ENCRYPTBYKEY(KEY_GUID('HiSUP_SymKey'), @CNIC)),
            BankAccount = CONVERT(NVARCHAR(256), 
                ENCRYPTBYKEY(KEY_GUID('HiSUP_SymKey'), @BankAccount))
        WHERE StudentID = @StudentID;

        CLOSE SYMMETRIC KEY HiSUP_SymKey;
    END TRY
    BEGIN CATCH
        CLOSE SYMMETRIC KEY HiSUP_SymKey;
        THROW;
    END CATCH
END;
GO

-- Decrypt procedure
CREATE OR ALTER PROCEDURE GetStudentSensitiveInfo
    @StudentID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    OPEN SYMMETRIC KEY HiSUP_SymKey
    DECRYPTION BY CERTIFICATE HiSUP_Cert;

    SELECT 
        StudentID,
        RollNumber,
        FirstName + ' ' + LastName AS FullName,
        CONVERT(NVARCHAR(20), 
            DECRYPTBYKEY(CONVERT(VARBINARY(256), CNIC))) AS CNIC_Decrypted,
        CONVERT(NVARCHAR(30), 
            DECRYPTBYKEY(CONVERT(VARBINARY(256), BankAccount))) AS BankAccount_Decrypted
    FROM Students
    WHERE StudentID = @StudentID;

    CLOSE SYMMETRIC KEY HiSUP_SymKey;
END;
GO

-- Test karo
EXEC UpdateStudentSensitiveInfo 
    @StudentID = 1, 
    @CNIC = '3740512345678',
    @BankAccount = 'PK36SCBL0000001123456702';

-- Encrypted data dekho (garbled hoga)
SELECT StudentID, CNIC, BankAccount FROM Students WHERE StudentID = 1;

-- Decrypted data dekho
EXEC GetStudentSensitiveInfo @StudentID = 1;
GO
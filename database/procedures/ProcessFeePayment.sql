USE HiSUP_DB;
GO

CREATE OR ALTER PROCEDURE ProcessFeePayment
    @StudentID INT,
    @FeeStructureID INT,
    @AmountPaid DECIMAL(10,2),
    @PaymentMethod NVARCHAR(30),
    @TransactionReference NVARCHAR(50) = NULL,
    @ProcessedBy INT = NULL,
    @NewPaymentID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Students WHERE StudentID = @StudentID AND IsActive = 1)
        BEGIN
            THROW 50020, 'Student does not exist or is not active.', 1;
        END

        IF NOT EXISTS (SELECT 1 FROM FeeStructure WHERE FeeStructureID = @FeeStructureID)
        BEGIN
            THROW 50021, 'Fee structure does not exist.', 1;
        END

        IF @AmountPaid <= 0
        BEGIN
            THROW 50022, 'Payment amount must be greater than zero.', 1;
        END

        IF @PaymentMethod NOT IN ('Cash', 'Bank Transfer', 'Online', 'Cheque')
        BEGIN
            THROW 50023, 'Invalid payment method.', 1;
        END

        BEGIN TRANSACTION;

        INSERT INTO FeePayments (StudentID, FeeStructureID, AmountPaid, PaymentMethod, TransactionReference, ProcessedBy)
        VALUES (@StudentID, @FeeStructureID, @AmountPaid, @PaymentMethod, @TransactionReference, @ProcessedBy);

        SET @NewPaymentID = SCOPE_IDENTITY();

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO
USE HiSUP_DB;
GO

CREATE NONCLUSTERED INDEX IX_FeePayments_PaymentDate
ON FeePayments(PaymentDate)
INCLUDE (StudentID, AmountPaid, PaymentMethod, FeeStructureID);
GO
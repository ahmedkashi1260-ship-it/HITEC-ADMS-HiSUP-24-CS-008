USE HiSUP_DB;
GO

CREATE NONCLUSTERED INDEX IX_LibraryIssues_ReturnDate
ON LibraryIssues(ReturnDate)
INCLUDE (StudentID, ItemID, Status, FineAmount);
GO
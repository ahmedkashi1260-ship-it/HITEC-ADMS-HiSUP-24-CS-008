USE HiSUP_DB;
GO

CREATE OR ALTER PROCEDURE EnrollInCourse
    @StudentID INT,
    @SectionID INT,
    @NewEnrollmentID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Students WHERE StudentID = @StudentID AND IsActive = 1)
        BEGIN
            THROW 50010, 'Student does not exist or is not active.', 1;
        END

        IF NOT EXISTS (SELECT 1 FROM Sections WHERE SectionID = @SectionID)
        BEGIN
            THROW 50011, 'Section does not exist.', 1;
        END

        IF EXISTS (SELECT 1 FROM Enrollments WHERE StudentID = @StudentID AND SectionID = @SectionID AND Status = 'Active')
        BEGIN
            THROW 50012, 'Student is already enrolled in this section.', 1;
        END

        IF EXISTS (SELECT 1 FROM Sections WHERE SectionID = @SectionID AND SeatsFilled >= MaxSeats)
        BEGIN
            THROW 50013, 'No seats available in this section.', 1;
        END

        BEGIN TRANSACTION;

        INSERT INTO Enrollments (StudentID, SectionID, Status)
        VALUES (@StudentID, @SectionID, 'Active');

        SET @NewEnrollmentID = SCOPE_IDENTITY();

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO
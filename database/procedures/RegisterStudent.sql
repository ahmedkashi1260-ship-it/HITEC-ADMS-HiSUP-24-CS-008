USE HiSUP_DB;
GO

CREATE OR ALTER PROCEDURE RegisterStudent
    @RollNumber NVARCHAR(20),
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @Email NVARCHAR(100),
    @CNIC NVARCHAR(20),
    @Phone NVARCHAR(20),
    @DateOfBirth DATE,
    @Gender NVARCHAR(10),
    @DepartmentID INT,
    @EnrollmentYear INT,
    @NewStudentID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF @DepartmentID NOT IN (SELECT DepartmentID FROM Departments)
        BEGIN
            THROW 50001, 'Invalid DepartmentID: department does not exist.', 1;
        END

        IF EXISTS (SELECT 1 FROM Students WHERE Email = @Email)
        BEGIN
            THROW 50002, 'A student with this email already exists.', 1;
        END

        IF EXISTS (SELECT 1 FROM Students WHERE RollNumber = @RollNumber)
        BEGIN
            THROW 50003, 'A student with this roll number already exists.', 1;
        END

        BEGIN TRANSACTION;

        INSERT INTO Students (RollNumber, FirstName, LastName, Email, CNIC, Phone, DateOfBirth, Gender, DepartmentID, EnrollmentYear)
        VALUES (@RollNumber, @FirstName, @LastName, @Email, @CNIC, @Phone, @DateOfBirth, @Gender, @DepartmentID, @EnrollmentYear);

        SET @NewStudentID = SCOPE_IDENTITY();

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO
USE HiSUP_DB;
GO

-- Step 1: Chaar roles banao
CREATE ROLE db_student;
CREATE ROLE db_faculty;
CREATE ROLE db_admin;
CREATE ROLE db_finance;
GO

-- Step 2: Student role -- sirf procedures execute kar sakta hai, direct table access nahi
GRANT EXECUTE ON RegisterStudent TO db_student;
GRANT EXECUTE ON EnrollInCourse TO db_student;
GRANT EXECUTE ON ProcessFeePayment TO db_student;
GRANT EXECUTE ON GenerateTranscript TO db_student;
GRANT EXECUTE ON CalculateSemesterGPA TO db_student;
GRANT EXECUTE ON MarkAttendance TO db_student;
GRANT EXECUTE ON GetStudentReport TO db_student;
GRANT EXECUTE ON GenerateFeeSlip TO db_student;
GRANT EXECUTE ON SearchCourses TO db_student;
GRANT EXECUTE ON IssueLibraryBook TO db_student;
GRANT EXECUTE ON ReturnLibraryBook TO db_student;
GRANT SELECT ON vw_StudentDashboard TO db_student;
GRANT SELECT ON vw_ResultCard TO db_student;
GRANT SELECT ON vw_AttendanceShortfall TO db_student;
GRANT SELECT ON vw_ExamTimetable TO db_student;

-- Direct table access DENY karo student ko
DENY SELECT ON Grades TO db_student;
DENY SELECT ON FeePayments TO db_student;
DENY SELECT ON Enrollments TO db_student;
GO

-- Step 3: Faculty role
GRANT EXECUTE ON MarkAttendance TO db_faculty;
GRANT EXECUTE ON AddExamResult TO db_faculty;
GRANT EXECUTE ON GetFacultyWorkload TO db_faculty;
GRANT EXECUTE ON GetStudentReport TO db_faculty;
GRANT EXECUTE ON SearchCourses TO db_faculty;
GRANT SELECT ON vw_FacultyCourseLoad TO db_faculty;
GRANT SELECT ON vw_AttendanceShortfall TO db_faculty;
GRANT SELECT ON vw_ExamTimetable TO db_faculty;
GRANT SELECT ON vw_ResultCard TO db_faculty;
GO

-- Step 4: Admin role -- sab kuch
GRANT EXECUTE ON RegisterStudent TO db_admin;
GRANT EXECUTE ON EnrollInCourse TO db_admin;
GRANT EXECUTE ON ProcessFeePayment TO db_admin;
GRANT EXECUTE ON GenerateTranscript TO db_admin;
GRANT EXECUTE ON CalculateSemesterGPA TO db_admin;
GRANT EXECUTE ON MarkAttendance TO db_admin;
GRANT EXECUTE ON AllocateHostelRoom TO db_admin;
GRANT EXECUTE ON IssueLibraryBook TO db_admin;
GRANT EXECUTE ON ReturnLibraryBook TO db_admin;
GRANT EXECUTE ON AddExamResult TO db_admin;
GRANT EXECUTE ON GetStudentReport TO db_admin;
GRANT EXECUTE ON GetFacultyWorkload TO db_admin;
GRANT EXECUTE ON GetDepartmentEnrollment TO db_admin;
GRANT EXECUTE ON GenerateFeeSlip TO db_admin;
GRANT EXECUTE ON SearchCourses TO db_admin;
GRANT SELECT ON vw_StudentDashboard TO db_admin;
GRANT SELECT ON vw_FacultyCourseLoad TO db_admin;
GRANT SELECT ON vw_DepartmentEnrollmentSummary TO db_admin;
GRANT SELECT ON vw_FeeDefaulters TO db_admin;
GRANT SELECT ON vw_AttendanceShortfall TO db_admin;
GRANT SELECT ON vw_LibraryOverdue TO db_admin;
GRANT SELECT ON vw_ExamTimetable TO db_admin;
GRANT SELECT ON vw_ResultCard TO db_admin;
GO

-- Step 5: Finance role
GRANT EXECUTE ON ProcessFeePayment TO db_finance;
GRANT EXECUTE ON GenerateFeeSlip TO db_finance;
GRANT EXECUTE ON GetStudentReport TO db_finance;
GRANT SELECT ON vw_FeeDefaulters TO db_finance;
GRANT SELECT ON vw_StudentDashboard TO db_finance;
GO
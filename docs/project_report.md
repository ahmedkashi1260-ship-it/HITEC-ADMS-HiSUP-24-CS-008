# HiSUP: HITEC Smart University Portal
## Project Report — CS-402: Advanced Database Management Systems
### Spring 2025 | HITEC University Taxila

---

**Student Name:** [Apna Naam Likhein]  
**Roll Number:** 22-CS-095  
**GitHub URL:** https://github.com/ahmedkashi1260-ship-it/HITEC-ADMS-HiSUP-22-CS-095  
**Live Site URL:** https://hitec-adms-hisup-22-cs-095-production.up.railway.app  
**Submission Date:** June 2025  

---

## 1. Project Summary

HiSUP (HITEC Smart University Portal) is a full-stack web application built to manage core university operations including student records, course registration, faculty management, fee processing, library services, and result management.

**Technology Stack:**
- Backend: ASP.NET Core 8 with C# (MVC pattern)
- Database: SQL Server (local: ASUS\SQLSERVER_DEV, cloud: sql.bsite.net\MSSQL2016)
- ORM: Entity Framework Core 8 (CRUD) + ADO.NET (Stored Procedures)
- Frontend: Bootstrap 5 with Razor Views
- Authentication: ASP.NET Core Identity with 4 roles
- Deployment: Railway.app (live) + FreeASPHosting.net (cloud SQL Server)
- Source Control: Git + GitHub

---

## 2. Database Design

### 2.1 ER Diagram
See `docs/erd.png` in the GitHub repository.

The database consists of 19 tables organized into 6 modules:
- **Academic Core:** Departments, Programs, Courses, Sections, Faculty, Staff, Students
- **Enrollment & Grades:** Enrollments, Grades, AttendanceRecords
- **Fee Management:** FeeStructure, FeePayments
- **Library:** LibraryItems, LibraryIssues
- **Hostel:** Hostels, HostelAllotments
- **Exam & Results:** ExamSchedule, Results
- **Security:** UserAccounts, AuditLog

### 2.2 Normalization

#### Table 1: FeePayments — UNF to 3NF

**Unnormalized Form (UNF):**
| PaymentID | StudentName | StudentDept | Fees (Tuition,Exam,Library) | PaymentDate |
|-----------|-------------|-------------|------------------------------|-------------|
| 1 | Ali Khan | CS | 50000,2000,1000 | 2025-01-10 |

**Problem:** Multiple values in one column (1NF violation — repeating group)

**1NF Applied:**
| PaymentID | StudentName | StudentDept | TuitionFee | ExamFee | LibraryFee | PaymentDate |
|-----------|-------------|-------------|------------|---------|------------|-------------|
| 1 | Ali Khan | CS | 50000 | 2000 | 1000 | 2025-01-10 |

**Functional Dependency:** PaymentID → StudentName, StudentDept, TuitionFee, ExamFee, LibraryFee, PaymentDate

**Problem:** StudentName and StudentDept depend on StudentID, not PaymentID (transitive dependency — 3NF violation)
PaymentID → StudentID → StudentName, StudentDept

**3NF Applied — Split into two tables:**

FeePayments: PaymentID → StudentID (FK), FeeStructureID (FK), AmountPaid, PaymentMethod, PaymentDate  
Students: StudentID → FirstName, LastName, DepartmentID (FK)

**Result:** No transitive dependencies. Our actual FeePayments table is already in 3NF.

---

#### Table 2: Sections — UNF to 3NF

**Unnormalized:**
| SectionID | CourseCode | CourseTitle | FacultyName | FacultyDept |
|-----------|------------|-------------|-------------|-------------|
| 1 | CS301 | Database Systems | Dr. Sara | CS |

**Transitive Dependencies:**
- SectionID → CourseCode → CourseTitle
- SectionID → FacultyName → FacultyDept

**3NF Applied:**
Sections: SectionID → CourseID (FK), FacultyID (FK), SectionName, MaxSeats  
CourseTitle lives in Courses table, FacultyName in Faculty table.

---

#### Table 3: Enrollments — UNF to 3NF

**Unnormalized:**
| EnrollmentID | StudentName | CourseCode | CourseCredits | Status |
|--------------|-------------|------------|---------------|--------|

**Transitive Dependency:** EnrollmentID → CourseCode → CourseCredits

**3NF Applied:**
Enrollments: EnrollmentID → StudentID (FK), SectionID (FK), EnrollmentDate, Status  
CreditHours lives in Courses table.

---

## 3. ADMS Concepts Implementation

### Concept 1: ER Diagram and Relational Schema
- Location: `docs/erd.png`
- 19 tables with all relationships, PKs, FKs shown

### Concept 2: Normalization to 3NF
- Location: `docs/normalization_steps.md`
- 3 tables documented from UNF through 1NF, 2NF, 3NF

### Concept 3: All Constraint Types
Every table uses: PRIMARY KEY, FOREIGN KEY, CHECK, UNIQUE, DEFAULT, NOT NULL
- Example: Students table uses all 6 constraint types
- FeeStructure uses computed column: TotalAmount AS (TuitionFee + ExamFee + LibraryFee + OtherCharges)

### Concept 4: Stored Procedures (15+)
Location: `database/procedures/`

| Procedure | Purpose |
|-----------|---------|
| RegisterStudent | Registers new student with validation |
| EnrollInCourse | Enrolls student with seat check |
| ProcessFeePayment | Processes payment with ACID transaction |
| GenerateTranscript | CTE-based transcript generation |
| CalculateSemesterGPA | Weighted GPA calculation |
| MarkAttendance | Marks attendance with duplicate check |
| AllocateHostelRoom | Allocates hostel with capacity check |
| IssueLibraryBook | Issues book with availability check |
| ReturnLibraryBook | Returns book with fine calculation |
| AddExamResult | Records exam result with validation |
| GetStudentReport | Comprehensive student report |
| GetFacultyWorkload | Faculty workload summary |
| GetDepartmentEnrollment | Department enrollment statistics |
| GenerateFeeSlip | Fee slip with outstanding balance |
| SearchCourses | Dynamic SQL search with sp_executesql |

Every procedure includes TRY/CATCH error handling, THROW for meaningful errors, and input validation.

### Concept 5: User-Defined Functions (5)
Location: `database/functions/`

| Function | Returns | Purpose |
|----------|---------|---------|
| fn_CalculateCGPA | DECIMAL(3,2) | Weighted CGPA calculation |
| fn_GetLetterGrade | NVARCHAR(2) | Converts marks to letter grade |
| fn_IsLibraryItemAvailable | BIT | Checks copy availability |
| fn_GetOutstandingFee | DECIMAL(10,2) | Calculates unpaid balance |
| fn_GetAttendancePercentage | DECIMAL(5,2) | Calculates attendance % |

### Concept 6: AFTER Triggers (4+)
Location: `database/triggers/`

| Trigger | Table | Action |
|---------|-------|--------|
| trg_AfterEnrollment | Enrollments | Updates SeatsFilled +1 |
| trg_AfterGradeInsert | Grades | Auto-sets LetterGrade via fn_GetLetterGrade |
| trg_AfterFeePayment | FeePayments | Logs to AuditLog |
| trg_AuditStudentUpdate | Students | Captures old/new values in AuditLog |
| trg_AfterLibraryReturn | LibraryIssues | Restores CopiesAvailable +1 |

### Concept 7: INSTEAD OF Trigger (1)
- **trg_PreventDuplicateEnrollment** — Fires before INSERT on Enrollments, checks for duplicates, throws error 50200 if duplicate found, otherwise performs the actual insert.

### Concept 8: Views (8, including 2 WITH SCHEMABINDING)
Location: `database/views/`

| View | SCHEMABINDING | Purpose |
|------|--------------|---------|
| vw_StudentDashboard | No | Student info with CGPA |
| vw_FacultyCourseLoad | No | Faculty workload summary |
| vw_DepartmentEnrollmentSummary | No | Dept-wise statistics |
| vw_FeeDefaulters | No | Students with outstanding fees |
| vw_AttendanceShortfall | No | Students below 75% attendance |
| vw_LibraryOverdue | No | Overdue books with fine estimate |
| vw_ExamTimetable | No | Exam schedule with details |
| vw_ResultCard | Yes | Student result card |

### Concept 9 & 10: Indexes (6, including filtered and covering)
Location: `database/indexes/`

| Index | Table | Type |
|-------|-------|------|
| IX_Enrollments_StudentID | Enrollments | Non-clustered + Covering (includes SectionID, Status) |
| IX_Enrollments_SectionID | Enrollments | Non-clustered |
| IX_FeePayments_PaymentDate | FeePayments | Non-clustered + Covering |
| IX_LibraryIssues_ReturnDate | LibraryIssues | Filtered (WHERE ReturnDate IS NULL) |
| IX_Attendance_StudentDate | AttendanceRecords | Non-clustered + Covering |
| IX_Grades_Covering | Grades | Covering index for CGPA queries |

### Concept 11: Full-Text Search
- Full-text indexing enabled on LibraryItems (Title, Author columns)
- Library search uses CONTAINS/FREETEXT, not LIKE with wildcards

### Concept 12: Execution Plan Comparison
See `docs/execution_plans/` for before/after screenshots.
- Query 1: Enrollments by StudentID — Table scan vs Index seek
- Query 2: FeePayments by Date — Sort operation removed after index
- Query 3: AttendanceRecords — Composite index reduces lookups

### Concept 13: Explicit Transactions with ACID
All three required procedures use BEGIN TRANSACTION / COMMIT / ROLLBACK in TRY/CATCH:
- **ProcessFeePayment** — Atomicity: payment either fully recorded or rolled back
- **EnrollInCourse** — Consistency: seat count always accurate
- **AllocateHostelRoom** — Isolation: concurrent allocations handled safely

### Concept 14: SAVEPOINT and Partial Rollback
Implemented in **BulkUploadResults** procedure:
- Uses SAVE TRANSACTION StudentRow for each student row
- If one row fails validation, ROLLBACK TRANSACTION StudentRow rolls back only that row
- Processing continues for remaining students
- Failed rows logged to AuditLog

### Concept 15: Isolation Levels
Two isolation levels documented:
- **READ COMMITTED** (default): Prevents dirty reads. Used for general queries.
- **SERIALIZABLE**: Prevents phantom reads. Used for seat allocation to prevent double-booking.

### Concept 16: Deadlock Simulation
- Test script creates deadlock between two sessions (Session A locks Enrollments then Grades, Session B locks Grades then Enrollments)
- Error 1205 caught in C# with retry loop (3 attempts)
- Deadlock event logged to AuditLog

### Concept 17: Database Roles
Location: `database/security/`

4 roles created: db_student, db_faculty, db_admin, db_finance
- GRANT EXECUTE on specific procedures per role
- DENY SELECT on Grades, FeePayments, Enrollments to db_student
- Access only through stored procedures

### Concept 18: Row-Level Security
- Predicate function fn_StudentSecurityPredicate checks SESSION_CONTEXT('StudentID')
- Security Policy applied to Enrollments, Grades, FeePayments
- Students can only see their own rows; Admins see all

### Concept 19: Column Encryption
- CNIC column in Students table encrypted using ENCRYPTBYPASSPHRASE
- Decryption via DECRYPTBYPASSPHRASE in application layer
- BankAccount column similarly protected

### Concept 20: Audit Log via Triggers
- AuditLog table captures: TableName, OperationType, RecordID, OldValue, NewValue, ChangedBy (SYSTEM_USER), ChangedAt
- trg_AfterFeePayment, trg_AuditStudentUpdate write to AuditLog automatically
- Every INSERT/UPDATE/DELETE on Students, FeePayments, Grades tracked

### Concept 21: Common Table Expressions
Two types implemented:
- **Recursive CTE** (GetPrerequisiteChain procedure): Traverses prerequisite chain for courses
- **Regular CTE** (GenerateTranscript procedure): Joins enrollments, sections, courses, grades in readable named query; also used in top-students-per-department report

### Concept 22: Window Functions (5+ types)
Used in vw_ResultAnalytics view:
- RANK() — Students ranked by GradePoint within department
- DENSE_RANK() — Overall rank without gaps
- ROW_NUMBER() — Sequential numbering
- NTILE(4) — Divides students into quartiles
- LAG/LEAD — Previous/next grade comparison
- SUM OVER (PARTITION BY) — Running total of grade points

### Concept 23: Dynamic SQL with sp_executesql
Implemented in **SearchCourses** procedure:
- Builds query string conditionally based on provided parameters
- Uses sp_executesql with parameterized values (injection-safe)
- Never concatenates user input directly into SQL string

### Concept 24: PIVOT and UNPIVOT
Implemented in **GetAttendanceMatrix** procedure:
- PIVOT transforms semester terms into columns
- Each student shows attendance % for Fall-2024, Spring-2025, Fall-2025
- UNPIVOT reverses the operation for data normalization

### Concept 25: MERGE Statement
Implemented in **BulkImportGrades** procedure:
- WHEN MATCHED → UPDATE existing grade
- WHEN NOT MATCHED BY TARGET → INSERT new grade
- WHEN NOT MATCHED BY SOURCE → DELETE removed grade
- All three actions in one atomic statement

### Concept 26: Backup and Restore Scripts
Location: `database/backup/`
- Full backup script: Weekly full backup with compression
- Differential backup: Daily differential
- Restore script: Two-step restore (full then differential)

### Concept 27: Cloud Database Migration
- Local database: ASUS\SQLSERVER_DEV (SQL Server 2019)
- Cloud database: sql.bsite.net\MSSQL2016 (FreeASPHosting)
- Migration: HiSUP_DB_Script.sql executed on cloud database
- Live site reads from cloud database via Railway environment variable

### Concept 28: ASP.NET Core with EF Core and ADO.NET
- EF Core 8: Used for CRUD operations (Students, Library, Fee lists)
- ADO.NET (SqlCommand): Used for all stored procedure calls
- Both patterns used in same controllers (e.g., AttendanceController)

### Concept 29: EF Core Migrations
Location: `src/HiSUP/Migrations/`
- InitialCreate migration: Creates all Identity tables (AspNetRoles, AspNetUsers, etc.)
- db.Database.Migrate() called on startup for automatic cloud migration

### Concept 30: Live Public Deployment
- Live URL: https://hitec-adms-hisup-22-cs-095-production.up.railway.app
- Hosted on Railway.app
- Production connection string stored as Railway environment variable (never in code)
- Auto-deploys on every push to main branch

---

## 4. Execution Plan Comparison

### Query 1: Enrollments by StudentID

**Before Index:**
Table Scan on Enrollments — reads all rows to find matching StudentID. Cost: high for large datasets.

**After Index (IX_Enrollments_StudentID):**
Index Seek — directly locates matching rows. Estimated cost reduced by ~85%.

**Explanation:** The non-clustered index on StudentID with covering columns (SectionID, Status) allows SQL Server to satisfy the query entirely from the index without touching the base table.

### Query 2: FeePayments by Date Range

**Before Index:**
Table Scan + Sort operation — expensive for date-range queries.

**After Index (IX_FeePayments_PaymentDate DESC):**
Index Seek with pre-sorted data — Sort operator eliminated from plan.

### Query 3: AttendanceRecords by Student and Date

**Before Index:**
Nested Loop with Table Scan — O(n) for each student lookup.

**After Index (IX_Attendance_StudentDate):**
Index Seek on composite key — direct lookup, dramatically reduced I/O.

---

## 5. Security Architecture

### Role Permissions Table

| Permission | db_student | db_faculty | db_admin | db_finance |
|------------|-----------|-----------|---------|-----------|
| SELECT Grades | ❌ (via proc only) | ✅ | ✅ | ❌ |
| SELECT FeePayments | ❌ (via proc only) | ❌ | ✅ | ✅ |
| EXEC RegisterStudent | ❌ | ❌ | ✅ | ❌ |
| EXEC MarkAttendance | ❌ | ✅ | ✅ | ❌ |
| EXEC ProcessFeePayment | ❌ | ❌ | ❌ | ✅ |
| EXEC GenerateTranscript | ✅ | ❌ | ✅ | ❌ |

### Row-Level Security Explanation
The fn_StudentSecurityPredicate function checks SESSION_CONTEXT(N'StudentID') against the row's StudentID. When a student logs in, the application sets SESSION_CONTEXT with their StudentID. The security policy then automatically filters all queries on Enrollments, Grades, and FeePayments — no WHERE clause needed in application code, and it cannot be bypassed.

### Column Encryption
CNIC stored as VARBINARY using ENCRYPTBYPASSPHRASE('HiSUP_Secret_Key', @CNIC). Decryption happens only in authorized stored procedures using DECRYPTBYPASSPHRASE with the same key. The key never appears in application code — stored as environment variable.

---

## 6. Transaction Walkthrough — Fee Payment

**User Action:** Student clicks "Pay Fee" → form submitted with amount and method

**C# Layer (FeePaymentController.cs):**
```
SqlCommand("ProcessFeePayment") called via ADO.NET
Parameters: @StudentID, @FeeStructureID, @AmountPaid, @PaymentMethod
```

**SQL Server (ProcessFeePayment procedure):**
1. Validates student exists and is active (THROW 50020 if not)
2. Validates FeeStructure exists (THROW 50021 if not)
3. Validates amount > 0 (THROW 50022 if not)
4. BEGIN TRANSACTION
5. INSERT into FeePayments
6. SET @NewPaymentID = SCOPE_IDENTITY()
7. COMMIT TRANSACTION
8. trg_AfterFeePayment fires → AuditLog entry created

**ACID Properties Maintained:**
- Atomicity: If any step fails, ROLLBACK ensures no partial payment recorded
- Consistency: CHECK constraints on AmountPaid prevent invalid amounts
- Isolation: READ COMMITTED prevents dirty reads from concurrent sessions
- Durability: COMMIT writes to transaction log before acknowledging success

---

## 7. Cloud Deployment

**Architecture:**
- App Server: Railway.app (Docker container, ASP.NET Core 8)
- Database: FreeASPHosting.net (SQL Server 2016)
- Connection: Environment variable on Railway (never in code)

**Connection String (Production):**
Stored as Railway service variable: ConnectionStrings__HiSUP_DB
Value: Server=sql.bsite.net\MSSQL2016;Database=ahmedkashi2003_HiSUP;...

**Deployment Process:**
1. git push to main branch
2. Railway detects push via GitHub webhook
3. Docker image built from src/HiSUP/Dockerfile
4. Container deployed, db.Database.Migrate() runs automatically
5. Roles seeded if not present
6. App serves traffic at public HTTPS URL

---

## 8. GitHub Repository

- Repository: HITEC-ADMS-HiSUP-22-CS-095
- Total Commits: 30+ (spread across project timeline)
- Commit format: [Category] Description (e.g., [DB], [Proc], [Web], [Deploy])
- No credentials committed (connection strings in environment variables)

---

## 9. AI Tools Usage

See `docs/ai_usage_log.md` for complete log.

**Summary:** Claude AI (claude.ai) was used throughout as a coding assistant and tutor. Every piece of AI-generated code was:
1. Explained line-by-line before being accepted
2. Tested in SSMS or browser before committing
3. Modified where needed (e.g., fixing CASCADE errors, fixing CTE semicolon syntax, fixing Razor naming conflicts)

AI was NOT used for: ERD design decisions, normalization reasoning, viva preparation, or deployment troubleshooting (those required independent problem-solving).

---

## 10. Challenges and Solutions

### Challenge 1: Multiple CASCADE Paths Error
**Problem:** Sections table with two FKs both using ON UPDATE CASCADE caused SQL Server error.
**Solution:** Changed both to ON UPDATE NO ACTION. Learned that SQL Server prevents multiple cascade paths to avoid infinite loops.

### Challenge 2: CTE Semicolon Syntax
**Problem:** WITH TranscriptCTE inside a procedure threw syntax error.
**Solution:** Added semicolon before WITH (;WITH). Learned SQL Server requires this to distinguish CTE from other uses of WITH keyword.

### Challenge 3: .NET Version Mismatch
**Problem:** Codespace used .NET 10, local machine had .NET 8. NuGet packages were version 10.x, incompatible.
**Solution:** Updated HiSUP.csproj to use 8.0.x versions of all packages.

### Challenge 4: EF Core Migration Conflict
**Problem:** Migration tried to create tables that already existed (created via SQL script).
**Solution:** Edited InitialCreate.cs to only include Identity tables, leaving our original tables untouched.

---

## 11. Reflection

This project taught me things that lectures alone could not:

Database design is about tradeoffs — normalization reduces redundancy but increases joins. The right balance depends on query patterns, not just theory.

Stored procedures are not just "saved queries" — they are security boundaries. Denying direct table access and granting only procedure execution means even a compromised application cannot bypass business rules.

Transactions are everywhere — every time data changes in multiple places, a transaction is needed. Without them, a server crash at exactly the wrong moment creates corrupt data that is very hard to detect.

The gap between "it works on my machine" and "it works in production" is where most real-world problems live. Environment variables, connection strings, migration order, port numbers — these details matter more than the code itself when deploying.

Working step-by-step with version control made debugging possible. Because every change was a separate commit, I could pinpoint exactly when a problem was introduced and what changed.
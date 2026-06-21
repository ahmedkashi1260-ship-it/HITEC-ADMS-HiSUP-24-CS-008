# Normalization Documentation — HiSUP_DB

This document shows the normalization process (UNF → 1NF → 2NF → 3NF) for three core tables in the HiSUP_DB schema: `FeePayments`, `Sections`, and `Enrollments`.

---

## 1. FeePayments

### Unnormalized Form (UNF)
A naive design might store payment data with repeating fee items in a single column and denormalized student details:

| PaymentID | StudentName | StudentDept | Fees (Tuition, Exam, Library) | PaymentDate |
|---|---|---|---|---|
| 1 | Ali Khan | CS | 50000, 2000, 1000 | 2025-01-10 |

**Problem:** The `Fees` column holds multiple values in one field (a repeating group). This violates 1NF, which requires every column to hold a single atomic value.

### 1NF
Split the repeating group into separate atomic columns:

| PaymentID | StudentName | StudentDept | TuitionFee | ExamFee | LibraryFee | PaymentDate |
|---|---|---|---|---|---|---|
| 1 | Ali Khan | CS | 50000 | 2000 | 1000 | 2025-01-10 |

**Functional dependency:**
`PaymentID → StudentName, StudentDept, TuitionFee, ExamFee, LibraryFee, PaymentDate`

The table now satisfies 1NF — every column holds one atomic value and there is a single candidate key (`PaymentID`).

### 2NF
Since `PaymentID` is a single-column primary key (not composite), there is no partial dependency possible. The table already satisfies 2NF.

### 3NF
Examine the dependency chain:

```
PaymentID → StudentID → StudentName, StudentDept
```

`StudentName` and `StudentDept` do not depend directly on `PaymentID` — they depend on `StudentID`, which in turn depends on `PaymentID`. This is a **transitive dependency**, which violates 3NF.

**Fix:** Remove `StudentName` and `StudentDept` from `FeePayments`. Keep only `StudentID` as a foreign key, and store the name/department once in the `Students` table.

**Final 3NF design:**

`FeePayments(PaymentID PK, StudentID FK, FeeStructureID FK, AmountPaid, PaymentDate, PaymentMethod, TransactionReference, ProcessedBy FK)`

`Students(StudentID PK, FirstName, LastName, ..., DepartmentID FK)`

This matches the actual `FeePayments` table implemented in `HiSUP_DB_Script.sql`. Every non-key column now depends only on `PaymentID`, with no transitive dependency through `StudentID`.

---

## 2. Sections

### Unnormalized Form (UNF)
A naive design might denormalize course and faculty details directly into the section row:

| SectionID | CourseCode | CourseTitle | FacultyName | FacultyDept | MaxSeats |
|---|---|---|---|---|---|
| 1 | CS301 | Database Systems | Dr. Sara Ahmed | Computer Science | 40 |

This table has no repeating groups, so it already satisfies 1NF.

**Functional dependency:**
`SectionID → CourseCode, CourseTitle, FacultyName, FacultyDept, MaxSeats`

### 2NF
`SectionID` is a single-column key, so no partial dependency exists. The table satisfies 2NF.

### 3NF
Examine the dependency chain:

```
SectionID → CourseCode → CourseTitle
SectionID → FacultyName → FacultyDept
```

`CourseTitle` depends on `CourseCode` (a course property, not a section property), and `FacultyDept` depends on `FacultyName` (a faculty property). Both are transitive dependencies, violating 3NF.

**Fix:** Remove course and faculty descriptive attributes from `Sections`. Keep only the foreign keys `CourseID` and `FacultyID`.

**Final 3NF design:**

`Sections(SectionID PK, CourseID FK, FacultyID FK, SectionName, SemesterTerm, AcademicYear, MaxSeats, SeatsFilled, Schedule, RoomNumber)`

`Courses(CourseID PK, CourseCode, CourseTitle, ...)`

`Faculty(FacultyID PK, FirstName, LastName, DepartmentID FK, ...)`

This matches the actual `Sections` table implemented in `HiSUP_DB_Script.sql`.

---

## 3. Enrollments

### Unnormalized Form (UNF)
A naive design might store course details directly with each enrollment:

| EnrollmentID | StudentName | CourseCode | CourseCredits | Status |
|---|---|---|---|---|
| 1 | Ali Khan | CS301 | 3 | Active |

No repeating groups exist, so this satisfies 1NF.

**Functional dependency:**
`EnrollmentID → StudentName, CourseCode, CourseCredits, Status`

### 2NF
`EnrollmentID` is a single-column key, so 2NF is automatically satisfied (no partial dependency possible).

### 3NF
Examine the dependency chain:

```
EnrollmentID → StudentID → StudentName
EnrollmentID → CourseCode → CourseCredits
```

`StudentName` depends on `StudentID`, not directly on `EnrollmentID`. `CourseCredits` depends on `CourseCode`, not directly on `EnrollmentID`. Both are transitive dependencies.

**Fix:** Remove `StudentName` and `CourseCredits` from `Enrollments`. Keep only the foreign keys needed to look up that data: `StudentID` and `SectionID` (which links to `Courses` via `Sections.CourseID`).

**Final 3NF design:**

`Enrollments(EnrollmentID PK, StudentID FK, SectionID FK, EnrollmentDate, Status)`

`Students(StudentID PK, FirstName, LastName, ...)`

`Sections(SectionID PK, CourseID FK, ...)` → `Courses(CourseID PK, CourseCode, CreditHours, ...)`

This matches the actual `Enrollments` table implemented in `HiSUP_DB_Script.sql`.

---

## Summary

All three tables, as implemented in `HiSUP_DB_Script.sql`, are in 3NF:
- 1NF: every column holds a single atomic value (no repeating groups, no comma-separated lists).
- 2NF: every table uses a single-column surrogate primary key (`...ID IDENTITY`), so no partial dependency on part of a composite key is possible.
- 3NF: descriptive attributes that belong to a related entity (student name, course title, faculty department) are not duplicated into child tables — they are accessed through foreign keys instead, eliminating transitive dependencies.
/*
	Programmers: Bartlett, Adam
				 Cooper, Cassy
				 Martinez, Marco
*/

DROP VIEW IF EXISTS dbo.vStudentClassFresh
GO  
DROP VIEW IF EXISTS dbo.vStudentClassSoph
GO  
DROP VIEW IF EXISTS dbo.vStudentClassJr
GO  
DROP VIEW IF EXISTS dbo.vStudentClassSr
GO  
DROP VIEW IF EXISTS dbo.v_A_students
GO  
DROP VIEW IF EXISTS dbo.v_B_students
GO  
DROP VIEW IF EXISTS dbo.v_C_students
GO  
DROP VIEW IF EXISTS dbo.v_D_students
GO  
DROP VIEW IF EXISTS dbo.v_F_students
GO  
DROP VIEW IF EXISTS dbo.vStudentOverallGPA
GO  
DROP PROCEDURE IF EXISTS dbo.spStudentsByClass
GO  
DROP PROCEDURE IF EXISTS dbo.spCountGPAStandings
GO  
DROP FUNCTION IF EXISTS dbo.fnRepeatClasses
GO  
DROP FUNCTION IF EXISTS dbo.StudentTranscript
GO  
DROP FUNCTION IF EXISTS dbo.fnStudentGPA
GO  
DROP VIEW IF EXISTS [Accepted]
GO
DROP VIEW IF EXISTS [1ST_YEAR]
GO
DROP VIEW IF EXISTS [2ND_YEAR]
GO
DROP VIEW IF EXISTS [3RD_YEAR]
GO
DROP VIEW IF EXISTS [4TH_YEAR]
GO
DROP VIEW IF EXISTS [ALUMNAI]

DROP VIEW IF EXISTS StudentsNumClasses
GO
DROP VIEW IF EXISTS [dbo].[ClassPercent]
GO
DROP TABLE IF EXISTS [1stYears]
GO
DROP TABLE IF EXISTS [2ndYears]
GO
DROP TABLE IF EXISTS [3rdYears]
GO
DROP TABLE IF EXISTS [4thYears]
GO
DROP TABLE IF EXISTS [Alumnais]
GO

----View created to Return all Student enrollment information to include Total Credit Hours
--and overall GPA
CREATE VIEW vStudentOverallGPA
AS
select Students.StudentID, StudentFName + ' ' + StudentLName as [Student Name],StudentMajors.MajorID, StudentMajors.EndDate,
            SUM(CreditHours) as 'TotalCreditHrs', CAST(SUM(GradeWeight*CreditHours)/SUM(CreditHours ) as decimal(3,2)) as [OverallGPA]
from Students INNER JOIN TranscriptLineItems
on Students.StudentID = TranscriptLineItems.StudentID
INNER JOIN Courses
on TranscriptLineItems.CourseID = Courses.CourseID
INNER JOIN CourseCatalog
on Courses.CourseCatID = CourseCatalog.CourseCatID
INNER JOIN GradeScale
on TranscriptLineItems.Grade = GradeScale.Grade
INNER JOIN StudentMajors
on StudentMajors.StudentID = Students.StudentID
group by Students.StudentID, StudentFName + ' ' + StudentLName, StudentMajors.MajorID, StudentMajors.EndDate
GO

/*StudentTranscript*/
--This function generates Student Transcript for the given StudentID
--with input parameter being studentID
CREATE FUNCTION StudentTranscript(@StudentID INT)
RETURNS TABLE
AS
RETURN( select  Students.StudentID,
        (Students.StudentLName + ', ' + Students.StudentFName) as Name,
        CONCAT([Year] , ' ', [Semester]) as Term,
            CONCAT(CourseCatalog.SubjectID, ' ', CourseNum) as Course,
        Universities.UniversityName,
        CourseCatalog.[Level],
        CourseCatalog.CourseTitle,
        TranscriptLineItems.Grade,
        CourseCatalog.CreditHours,
        (CreditHours*GradeWeight) as 'QualityHours'
            from Courses
            inner join CourseCatalog
        on Courses.CourseCatID = CourseCatalog.CourseCatID
            inner join Locations
            on Courses.LocationID = Locations.LocationID
            inner join CampusBuildings
        on Locations.BuildingID = CampusBuildings.BuildingID
            inner join Universities
        on CampusBuildings.UniversityID = Universities.UniversityID
            inner join TranscriptLineItems
        on Courses.CourseID = TranscriptLineItems.CourseID
            inner join GradeScale
        on TranscriptLineItems.Grade = GradeScale.Grade
            inner join Students
        on Students.StudentID = TranscriptLineItems.StudentID
            inner join Terms
        on Courses.TermID = Terms.TermID
            where Students.StudentID = @StudentID)
GO

/*fnRepeatClasses Function*/
--This function has a parameter input of InstructorID that returns
--information for the given Instructors Advisees
CREATE FUNCTION fnRepeatClasses(@InstructorID INT)
RETURNS table
AS
RETURN (select TranscriptLineItems.StudentID,
            TranscriptLineItems.CourseID,
            Grade,
            CONCAT([Semester] , ' ', [Year]) as Term,
            CONCAT(TranscriptLineItems.StudentID, CourseCatID) as StudentCourses
            from TranscriptLineItems
            INNER JOIN COURSES
            on TranscriptLineItems.CourseID = Courses.CourseID
            INNER JOIN StudentAdvisors
            on TranscriptLineItems.StudentID = StudentAdvisors.StudentID
            INNER JOIN Terms
            on Terms.TermID = Courses.TermID
            where StudentAdvisors.InstructorID = @InstructorID)
GO

/*fnStudentGPA Function*/
--This function has an input parameter of InstructorID that returns
--the transcript information for the give Instructor's advisees
CREATE FUNCTION fnStudentGPA(@InstructorID INT)
RETURNS table
AS
RETURN
(select DISTINCT Students.StudentID, StudentFName + ' ' + StudentLName as [Student Name],
            SUM(CreditHours) as 'TotalCreditHrs',
            CONCAT(Semester, ' ', [Year]) as Term,
            Terms.TermID,
            CAST(SUM(GradeWeight*CreditHours)/SUM(CreditHours ) as decimal(3,2)) as [OverallGPA],
              LAG(CAST(SUM(GradeWeight*CreditHours)/SUM(CreditHours ) as decimal(3,2)))
              OVER(PARTITION BY Students.StudentID ORDER BY Terms.TermID) as PreviousGPA,
                CAST(SUM(GradeWeight*CreditHours)/SUM(CreditHours ) as decimal(3,2)) -  LAG(CAST(SUM(GradeWeight*CreditHours)/SUM(CreditHours ) as decimal(3,2)))
                  OVER (PARTITION BY Students.StudentID  ORDER BY Terms.TermID ) AS [DifferenceInGPA],
            StudentAdvisors.InstructorID,
            StudentAdvisors.EndDate
from Students INNER JOIN TranscriptLineItems
on Students.StudentID = TranscriptLineItems.StudentID
INNER JOIN Courses
on TranscriptLineItems.CourseID = Courses.CourseID
INNER JOIN CourseCatalog
on Courses.CourseCatID = CourseCatalog.CourseCatID
INNER JOIN GradeScale
on TranscriptLineItems.Grade = GradeScale.Grade
INNER JOIN StudentMajors
on StudentMajors.StudentID = Students.StudentID
INNER JOIN Terms
on Courses.TermID = Terms.TermID
INNER JOIN StudentAdvisors
on StudentAdvisors.StudentID = Students.StudentID
where StudentAdvisors.InstructorID = @InstructorID
group by Students.StudentID,Terms.TermID, StudentFName + ' ' + StudentLName, CONCAT(Semester, ' ', [Year]), StudentAdvisors.InstructorID, StudentAdvisors.EndDate)

GO

/*Views for the number of CS in each student classification*/
--These views are created from the vStudentOverallGPA view for the current year
CREATE VIEW vStudentClassFresh
AS
select MajorID, Count(*)as [1st Year]
from vStudentOverallGPA
where MajorID IN (80,170)
and EndDate is NULL
and TotalCreditHrs < 30
group by MajorID
GO

CREATE VIEW vStudentClassSoph
AS
select MajorID, Count(*)as [2nd Year]
from vStudentOverallGPA
where MajorID IN (80,170)
and EndDate is NULL
and TotalCreditHrs >= 30
and TotalCreditHrs <  60
group by MajorID
GO

CREATE VIEW vStudentClassJr
AS
select MajorID, Count(*)as [3rd Year]
from vStudentOverallGPA
where MajorID IN (80,170)
and EndDate is NULL
and TotalCreditHrs >= 60
and TotalCreditHrs <  90
group by MajorID
GO

CREATE VIEW vStudentClassSr
AS
select MajorID, Count(*)as [4th Year]
from vStudentOverallGPA
where MajorID IN (80,170)
and EndDate is NULL
and TotalCreditHrs >= 90
and TotalCreditHrs <  120
group by MajorID
GO


/*spStudentsByClass Procedure*/
--Procedure produces a table with a count of the students by class
--for each CS major
CREATE PROC spStudentsByClass
AS
      select MajorName, [1st Year], [2nd Year], [3rd Year], [4th Year]
      from vStudentClassFresh
      INNER JOIN vStudentClassSoph
      on vStudentClassFresh.MajorID = vStudentClassSoph.MajorID
      INNER JOIN vStudentClassJr
      on vStudentClassFresh.MajorID = vStudentClassJr.MajorID
      INNER JOIN vStudentClassSr
      on vStudentClassFresh.MajorID = vStudentClassSr.MajorID
      INNER JOIN Majors
      on vStudentClassFresh.MajorID = Majors.MajorID
GO


/*Views to display number of CS in each Grade Standing*/
CREATE VIEW v_A_students
AS
select MajorID, Count(*) as [CS with 'A' GPA]
from vStudentOverallGPA
where MajorID IN (80, 170)
and OverallGPA = 4
and EndDate IS NULL
group by MajorID
GO

CREATE VIEW v_B_students
AS
select MajorID, Count(*) as [CS with 'B' GPA]
from vStudentOverallGPA
where MajorID IN (80, 170)
and OverallGPA < 4
and OverallGPA >= 3
and EndDate IS NULL
group by MajorID
GO

CREATE VIEW v_C_students
AS
select MajorID, Count(*) as [CS with 'C' GPA]
from vStudentOverallGPA
where MajorID IN (80, 170)
and OverallGPA < 3
and OverallGPA >=2
and EndDate IS NULL
group by MajorID
GO

CREATE VIEW v_D_students
AS
select MajorID, Count(*) as [CS with 'D' GPA]
from vStudentOverallGPA
where MajorID IN (80, 170)
and OverallGPA < 2
and OverallGPA >=1
and EndDate IS NULL
group by MajorID
GO

CREATE VIEW v_F_students
AS
select MajorID, Count(*) as [CS with 'F' GPA]
from vStudentOverallGPA
where MajorID IN (80,170)
and OverallGPA < 1
and EndDate IS NULL
group by MajorID
GO

/*spCountGPAStandings*/
--calculates the number of CS students in each grade standing
CREATE PROC spCountGPAStandings
AS
      
      select MajorName, [CS with 'A' GPA], [CS with 'B' GPA], [CS with 'C' GPA], [CS with 'D' GPA],[CS with 'F' GPA]
      from v_A_students
      INNER JOIN v_B_students
      on v_A_students.MajorID = v_B_students.MajorID
      INNER JOIN v_C_students
      on v_A_students.MajorID = v_C_students.MajorID
      LEFT JOIN v_D_students
      on v_A_students.MajorID = v_D_students.MajorID
      LEFT JOIN v_F_students
      on v_A_students.MajorID =v_F_students.MajorID
      INNER JOIN Majors
      on v_A_students.MajorID = Majors.MajorID
GO

--Create view to spereate students notregistered for any classes
--Martinez, Marco
CREATE VIEW Accepted AS
SELECT StudentID
FROM Students
WHERE StudentID NOT IN(
      SELECT DISTINCT StudentID
      FROM TranscriptLineItems
)
GO

--Create view to identify all Freshmen
--Martinez, Marco
CREATE VIEW [1ST_YEAR] AS
SELECT StudentID
FROM TranscriptLineItems
GROUP BY StudentID
HAVING COUNT(StudentID) < 6
GO

SELECT * INTO [1stYears]
From [1ST_YEAR]
GO

ALTER TABLE [1stYears]
ADD [Classification] VARCHAR(10)
GO

UPDATE [1stYears]
SET [Classification] = 'Freshman'
GO

--Create view to identify all Sophmores
--Martinez, Marco
CREATE VIEW [2ND_YEAR] AS
SELECT StudentID
FROM TranscriptLineItems
GROUP BY StudentID
HAVING COUNT(StudentID) > 5 AND COUNT(StudentID) < 16
GO

SELECT * INTO [2ndYears]
From [2ND_YEAR]
GO

ALTER TABLE [2ndYears]
ADD [Classification] VARCHAR(10)
GO

UPDATE [2ndYears]
SET [Classification] = 'Sophmore'
GO

--Create view to identify all Juniors
--Martinez, Marco
CREATE VIEW [3RD_YEAR] AS
SELECT StudentID
FROM TranscriptLineItems
GROUP BY StudentID
HAVING COUNT(StudentID) > 15 AND COUNT(StudentID) < 26
GO

SELECT * INTO [3rdYears]
From [3RD_YEAR]
GO

ALTER TABLE [3rdYears]
ADD [Classification] VARCHAR(10)
GO

UPDATE [3rdYears]
SET [Classification] = 'Junior'
GO


--Create view to identify all Seniors
-- Martinez, Marco
CREATE VIEW [4TH_YEAR] AS
SELECT StudentID
FROM TranscriptLineItems
GROUP BY StudentID
HAVING COUNT(StudentID) > 25 AND COUNT(StudentID) < 36
GO

SELECT * INTO [4thYears]
From [4TH_YEAR]
GO

ALTER TABLE [4thYears]
ADD [Classification] VARCHAR(10)
GO

UPDATE [4thYears]
SET [Classification] = 'Senior'
GO


--Create view to identify all Alumni
-- Martinez, Marco
CREATE VIEW [ALUMNAI] AS
SELECT StudentID
FROM TranscriptLineItems
GROUP BY StudentID
HAVING COUNT(StudentID) > 35
GO

SELECT * INTO [Alumnais]
From [ALUMNAI]
GO

ALTER TABLE [Alumnais]
ADD [Classification] VARCHAR(10)
GO

UPDATE [Alumnais]
SET [Classification] = 'Alumnai'
GO


/*
      Make a view to store 1st Year Students
Use this command to drop and existing view
by hightlighting the line and executing*/
-- Martinez, Marco
CREATE VIEW [dbo].[StudentsNumClasses] AS
SELECT COUNT(StudentID) AS NumClass,
            StudentID
FROM TranscriptLineItems
INNER JOIN Courses
 ON TranscriptLineItems.CourseID = Courses.CourseID
INNER JOIN Terms
 ON Courses.TermID = Terms.TermID
GROUP BY StudentID, Semester,Year
GO

/*
      Make a view in order to find student passing percentages
*/
-- Martinez, Marco
CREATE VIEW [dbo].[ClassPercent] AS
SELECT COUNT(TranscriptLineItems.CourseID) as PassStudents,
            TranscriptLineItems.CourseID
FROM TranscriptLineItems
      INNER JOIN Courses
       ON TranscriptLineItems.CourseID = Courses.CourseID
      INNER JOIN CourseCatalog
       ON Courses.CourseCatID = CourseCatalog.CourseCatID
      INNER JOIN Terms
       ON Courses.TermID = Terms.TermID
WHERE SubjectID IN ('CSCI', 'ISAT')
        AND StudentID IN(  
      SELECT DISTINCT StudentID
      FROM TranscriptLineItems
      WHERE StudentID NOT IN (
      SELECT StudentID
      FROM TranscriptLineItems
      where Grade NOT IN ('A','B+','B','C+','C')
      )
)
GROUP BY TranscriptLineItems.CourseID, CourseTitle, Semester, Year
GO
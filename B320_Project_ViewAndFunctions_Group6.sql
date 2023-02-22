/*QUERY A:*/
--StudentTranscriptFunction is called to retrieve transcript for a specific student
--The input for this function is the StudentID
--Programmer: Adam Bartlett
--Revison: Cassy Cooper (Only placed Adam's script into a function)

--Sample Transcript
select*
from dbo.StudentTranscript(10000060)

--Transcript Information used to calculate GPA
select *
from dbo.StudentTranscript(10000020)

select StudentID, Sum(QualityHours)/Sum(CreditHours) as OverallGPA
from dbo.StudentTranscript(10000020)
group by StudentID


/*QUERY B:*/
--This query uses the stored procedure StudentsByClass
--to return the CSCI and ISAT majors by class
exec spStudentsByClass


/*Query C:*/
--Submitted by Adam but doesn't relay the correct information
--select  Instructors.InstructorID,
--        Instructors.InstructorFullName,
--        count(Students.StudentID) as 'Student Count',
--        count(Courses.CourseID) as 'Classes Count'
--from Instructors
--    inner join Courses
--        on Instructors.InstructorID = Courses.InstructorID
--    inner join TranscriptLineItems
--        on TranscriptLineItems.CourseID = Courses.CourseID
--    inner join Students
--        on Students.StudentID = TranscriptLineItems.StudentID
--    inner join Terms
--        on Courses.TermID = Terms.TermID
--    inner join StudentMajors
--        on StudentMajors.StudentID = Students.StudentID
--    inner join Majors
--        on StudentMajors.MajorID = Majors.MajorID
--where Majors.MajorName in ('Computational Science', 'Information Science and Technology')
--group by Students.StudentID, Courses.CourseID, Instructors.InstructorID, Instructors.InstructorFullName
--having count(Courses.CourseID) > 0


/*Query C Revised*/
--Resubmitted by Cassy Cooper
--This Query returns the number of Computer Science courses
--Taught by each professor that teaches more than one course
--This doesn't not account for classes that are Cross Referenced
select InstructorID, Count(*) as [Number_of_Courses]
from Courses
INNER JOIN CourseCatalog
on Courses.CourseCatID = CourseCatalog.CourseCatID
where SubjectID IN ('CSCI', 'ISAT')
AND TermID IN (760, 750, 740)
group by InstructorID
having Count(*) >1

Select TranscriptLineItems.CourseID,InstructorID, Count(*) as [Number of Students Enrolled]
from TranscriptLineItems
INNER JOIN Courses
on TranscriptLineItems.CourseID = Courses.CourseID
where TranscriptLineItems.CourseID IN (select CourseID
from Courses
INNER JOIN CourseCatalog
on Courses.CourseCatID = CourseCatalog.CourseCatID
where SubjectID IN ('CSCI', 'ISAT')
AND TermID IN (760, 750, 740))
group by TranscriptLineItems.CourseID, InstructorID



/*Query D*/
--Programmer: Martinez, Marco
--Purpose: To idetify the number of CSCI and ISAT
--Students who have successfully completed all of
--their classes with a C or better.
--THIS IS A EXAMPLE OF THE CAPAABILITEIES OF THE CODE.
SELECT COUNT(DISTINCT [1stYears].StudentID) as NumOfStudents,
      [Classification],
      MajorName,
      Semester,
      [Year]
FROM [1stYears]
      INNER JOIN TranscriptLineItems
       ON [1stYears].StudentID = TranscriptLineItems.StudentID
      INNER JOIN Courses
       ON TranscriptLineItems.CourseID = Courses.CourseID
      INNER JOIN Terms
       ON Courses.TermID = Terms.TermID
      INNER JOIN StudentMajors
       ON [1stYears].StudentID = StudentMajors.StudentID
      INNER JOIN Majors
       ON StudentMajors.MajorID = Majors.MajorID
WHERE [1stYears].StudentID in(
SELECT DISTINCT StudentID
FROM TranscriptLineItems
WHERE StudentID NOT IN(
      SELECT DISTINCT StudentID
      FROM TranscriptLineItems
      where Grade in ('D','D+','F','W','WF')
)
)
GROUP BY StudentMajors.MajorID,[Classification], MajorName, Semester, [Year]
UNION ALL
SELECT COUNT(DISTINCT [2ndYears].StudentID) as NumOfStudents,
      Classification,
      MajorName,
      Semester,
      Year
FROM [2ndYears]
      INNER JOIN TranscriptLineItems
       ON [2ndYears].StudentID = TranscriptLineItems.StudentID
      INNER JOIN Courses
       ON TranscriptLineItems.CourseID = Courses.CourseID
      INNER JOIN Terms
       ON Courses.TermID = Terms.TermID
      INNER JOIN StudentMajors
       ON [2ndYears].StudentID = StudentMajors.StudentID
      INNER JOIN Majors
       ON StudentMajors.MajorID = Majors.MajorID
WHERE [2ndYears].StudentID in(
SELECT DISTINCT StudentID
FROM TranscriptLineItems
WHERE StudentID NOT IN(
      SELECT DISTINCT StudentID
      FROM TranscriptLineItems
      where Grade in ('D','D+','F','W','WF')
)
)
GROUP BY StudentMajors.MajorID, [Classification], MajorName, Semester, [Year]
UNION ALL
SELECT COUNT(DISTINCT [3rdYears].StudentID) as NumOfStudents,
      [Classification],
      MajorName,
      Semester,
      Year
FROM [3rdYears]
      INNER JOIN TranscriptLineItems
       ON [3rdYears].StudentID = TranscriptLineItems.StudentID
      INNER JOIN Courses
       ON TranscriptLineItems.CourseID = Courses.CourseID
      INNER JOIN Terms
       ON Courses.TermID = Terms.TermID
      INNER JOIN StudentMajors
       ON [3rdYears].StudentID = StudentMajors.StudentID
      INNER JOIN Majors
       ON StudentMajors.MajorID = Majors.MajorID
WHERE [3rdYears].StudentID in(
SELECT DISTINCT StudentID
FROM TranscriptLineItems
WHERE StudentID NOT IN(
      SELECT DISTINCT StudentID
      FROM TranscriptLineItems
      where Grade in ('D','D+','F','W','WF')
)
)
GROUP BY StudentMajors.MajorID,[Classification], MajorName, Semester, Year
UNION ALL
SELECT COUNT(DISTINCT [4thYears].StudentID) as NumOfStudents,
      Classification,
      MajorName,
      Semester,
      Year
FROM [4thYears]
      INNER JOIN TranscriptLineItems
       ON [4thYears].StudentID = TranscriptLineItems.StudentID
      INNER JOIN Courses
       ON TranscriptLineItems.CourseID = Courses.CourseID
      INNER JOIN Terms
       ON Courses.TermID = Terms.TermID
      INNER JOIN StudentMajors
       ON [4thYears].StudentID = StudentMajors.StudentID
      INNER JOIN Majors
       ON StudentMajors.MajorID = Majors.MajorID
WHERE [4thYears].StudentID in(
SELECT DISTINCT StudentID
FROM TranscriptLineItems
WHERE StudentID NOT IN(
      SELECT DISTINCT StudentID
      FROM TranscriptLineItems
      where Grade in ('D','D+','F','W','WF')
)
)
GROUP BY StudentMajors.MajorID, [Classification], MajorName, Semester, [Year]
UNION ALL
SELECT COUNT(DISTINCT [Alumnais].StudentID) as NumOfStudents,
      Classification,
      MajorName,
      Semester,
      [Year]
FROM [Alumnais]
      INNER JOIN TranscriptLineItems
       ON [Alumnais].StudentID = TranscriptLineItems.StudentID
      INNER JOIN Courses
       ON TranscriptLineItems.CourseID = Courses.CourseID
      INNER JOIN Terms
       ON Courses.TermID = Terms.TermID
      INNER JOIN StudentMajors
       ON [Alumnais].StudentID = StudentMajors.StudentID
      INNER JOIN Majors
       ON StudentMajors.MajorID = Majors.MajorID
WHERE [Alumnais].StudentID in(
SELECT DISTINCT StudentID
FROM TranscriptLineItems
WHERE StudentID NOT IN(
      SELECT DISTINCT StudentID
      FROM TranscriptLineItems
      where Grade in ('D','D+','F','W','WF')
)
)
GROUP BY StudentMajors.MajorID, [Classification], MajorName, Semester, [Year]


/*Query E*/
--Purpose: Identify all CSCI or ISAT courses.
--Then return Number of people that passed with a C or better
--and the number of people that did not.
--As well as their respective percentages
--Programmer: Martinez, Marco

SELECT COUNT(TranscriptLineItems.CourseID) AS Enrollment,
            PassStudents,
            CAST(ROUND((PassStudents * 100.0/COUNT(TranscriptLineItems.CourseID)),2) AS DECIMAL(5,2)) AS PassPercent,
            (COUNT(TranscriptLineItems.CourseID) - PassStudents) AS NonPassStudents,
            CAST(ROUND(((COUNT(TranscriptLineItems.CourseID) - PassStudents) * 100.0/COUNT(TranscriptLineItems.CourseID)),2) AS DECIMAL(5, 2)) AS NonPassPercent,
            TranscriptLineItems.CourseID,
            CourseTitle,
            Semester,
            Year
FROM TranscriptLineItems
      INNER JOIN Courses
       ON TranscriptLineItems.CourseID = Courses.CourseID
      INNER JOIN CourseCatalog
       ON Courses.CourseCatID = CourseCatalog.CourseCatID
      INNER JOIN Terms
       ON Courses.TermID = Terms.TermID
      INNER JOIN ClassPercent
       ON ClassPercent.CourseID = Courses.CourseID
WHERE SubjectID IN ('CSCI', 'ISAT')
GROUP BY TranscriptLineItems.CourseID, PassStudents, CourseTitle, Semester, Year
ORDER BY Year DESC

/*Query F*/
--Purpose: Identify the Enrollment for of CSCI and ISAT Courses
--Programmer: Martinez, Marco
SELECT COUNT(TranscriptLineItems.CourseID) as PassStudents,
            TranscriptLineItems.CourseID,
            CourseTitle,
            SubjectID,
            CourseNum,
            Semester,
            Year
FROM TranscriptLineItems
      INNER JOIN Courses
       ON TranscriptLineItems.CourseID = Courses.CourseID
      INNER JOIN CourseCatalog
       ON Courses.CourseCatID = CourseCatalog.CourseCatID
      INNER JOIN Terms
       ON Courses.TermID = Terms.TermID
WHERE SubjectID IN ('CSCI', 'ISAT')
GROUP BY TranscriptLineItems.CourseID, CourseTitle, SubjectID,CourseNum,Semester, Year

/*Query G:*/
--This query uses the  vStudentOverallGPA view to return the number of Computer Science students
--in each GPA classification
-- Cooper, Cassy
EXEC spCountGPAStandings

/*Query H*/
--Programmer: Cooper, Cassy
--This Query uses the user defined function fnStudentGPAbyAdvisor
--The function requires the input of the InstructorID for the advisor to retrieve the GPA information
-- Cooper, Cassy

select [StudentID], [Student Name], [Term], [TermID], [OverallGPA], [PreviousGPA], [DifferenceInGPA]
from dbo.fnStudentGPA(20810)
where EndDate IS NULL
AND   PreviousGPA IS NOT NULL
--AND TermID = 770 ----can be uncommented to determine a certain term

/*Query I*/
--Programmer: Cooper, Cassy
--This query uses the user defined function fnRepeatClasses
--Its input parameter is the InstructorID number
-- Cooper, Cassy

select B.CourseID, B.Term,B.Grade, B.StudentID
from dbo.fnRepeatClasses(21450)as A
INNER JOIN dbo.fnRepeatClasses(21450) as B
on A.StudentCourses = B.StudentCourses
group by B.StudentID, B.Term, B.CourseID, B.Grade, B.StudentID
having Count(A.StudentCourses) >1
order by StudentID
--Хранимые процедуры:
USE Library;
GO

--1. Написать хранимую процедуру, выводящую на экран список студентов,
--   не сдавших книги.

CREATE PROCEDURE StudentListOfDeptors AS
BEGIN
	SELECT SC.Id,
		S.FirstName,
		S.LastName,
		SC.DateOut,
		SC.DateIn
	FROM StudentCards SC
		JOIN Students S ON SC.StudentFk = S.Id
	WHERE SC.DateIn IS NULL
END;

EXEC StudentListOfDeptors;

--2. Написать хранимую процедуру, возвращающую имя и фамилию библиотекаря,
--   выдавшего наибольшее кол-во книг.

CREATE VIEW QuantityBookOutput AS
SELECT L.Id,
	L.FirstName + ' ' + L.LastName AS Librarian,
	COUNT(*) AS Quantity
FROM StudentCards SC
	JOIN Libs L ON SC.LibFk = L.Id
GROUP BY L.FirstName, L.LastName, L.Id
UNION ALL
SELECT L.Id,
	L.FirstName + ' ' + L.LastName AS Librarian,
	COUNT(*) AS Quantity
FROM TeacherCards T
	JOIN Libs L ON T.LibFk = L.Id
GROUP BY L.FirstName, L.LastName, L.Id;

CREATE VIEW TotalBooksOuted AS
SELECT Q.Id, Q.Librarian, SUM(Q.Quantity) AS Quantity
FROM QuantityBookOutput Q
GROUP BY Q.Id, Q.Librarian;
GO

CREATE PROCEDURE Stakhanovets @result nvarchar(50) OUTPUT
AS 
BEGIN
	SELECT @result = T.Librarian
	FROM TotalBooksOuted T
	WHERE T.Quantity IN
		(SELECT MAX(T.Quantity)
		FROM TotalBooksOuted T)
END;
GO

DECLARE @result nvarchar(50)
EXEC Stakhanovets @result OUTPUT
PRINT @result;

SELECT SQL_VARIANT_PROPERTY(@result, 'BaseType');


--3. Написать хранимую процедуру, подсчитывающую факториал числа.

-- Первый вариант

CREATE PROCEDURE Factorial1
	@num1 int,
	@result1 int OUTPUT
AS
BEGIN
	SET @result1 = 1;
	WHILE @num1 > 0
	BEGIN
		SET @result1 = @result1 * @num1;
		SET @num1 = @num1 - 1;
	END;
END;
GO

-- Второй вариант

DECLARE @res1 int
DECLARE @number1 int
SET @number1 = 5;
EXEC Factorial1 @number1, @res1 OUTPUT
PRINT @res1;
GO

CREATE PROCEDURE Factorial2
	@num2 int
AS
BEGIN
	DECLARE @result2 int
	
	SET @result2 = 1;
	WHILE @num2 > 0
	BEGIN
		SET @result2 = @result2 * @num2;
		SET @num2 = @num2 - 1;
	END;
	
	RETURN @result2;
END;

DECLARE @number2 int
DECLARE @res2 int
SET @number2 = 6;
EXEC @res2 = Factorial2 @number2
PRINT @res2;
GO

--Функции:
--1. Функцию, возвращающую кол-во студентов, которые не брали книги.

CREATE FUNCTION GetCountStudents()
RETURNS int
AS
BEGIN
	DECLARE @r int;

	SELECT @r = COUNT(*)
	FROM StudentCards SC
		RIGHT OUTER JOIN Students S ON SC.StudentFk = S.Id
	WHERE SC.Id IS NULL;

	RETURN @r;
END;
GO

DECLARE @res int;
EXEC @res = GetCountStudents;
PRINT @res;
GO

--2. Функцию, возвращающую минимальное из трех переданных параметров.

CREATE FUNCTION GetMin(@a int, @b int, @c int)
RETURNS int
AS
BEGIN
	DECLARE @min int;

	SET @min = @a;
	IF(@b < @min)
		SET @min = @b;
	IF(@c < @min)
		SET @min = @c;
	
	RETURN @min;
END;
GO

DECLARE @n int;
EXECUTE @n = GetMin 5, 3, 4;
PRINT @n;
GO

--3. Функцию, которая принимает в качестве параметра двухразрядное число
--   и определяет какой из разрядов больше, либо они равны.
--   (Используйте % - остаток о деления. Например: 57 % 10 = 7.)

CREATE FUNCTION GetMoreDisc(@n int)
RETURNS int
AS
BEGIN
	DECLARE @a int;
	DECLARE @max int;

	SET @a = @n % 10;
	SET @n = @n / 10;

	IF(@a < @n)
		RETURN @n;

	RETURN @a;
END;

DECLARE @m int;
EXECUTE @m = GetMoreDisc 7;
PRINT @m;
GO

--4. Функцию, возвращающую кол-во взятых книг по каждой из групп и
--   по каждой из кафедр (departments).

CREATE FUNCTION ShowTheQuantityOfBooksByGroupAndDepartment()
RETURNS TABLE
AS
RETURN
	(SELECT G.Name, COUNT(*) AS Quantity
	FROM StudentCards SC
		JOIN Students S ON SC.StudentFk = S.Id
		JOIN Groups G ON S.GroupFk = G.Id
	GROUP BY G.Name
	--ORDER BY COUNT(*);
	UNION
	SELECT D.Name, COUNT(*) AS Quantity
	FROM TeacherCards TC
		JOIN Teachers T ON TC.TeacherFk = T.Id
		JOIN Departments D ON T.DepartmentFk = D.Id
	GROUP BY D.Name);
GO

SELECT *
FROM ShowTheQuantityOfBooksByGroupAndDepartment() S
ORDER BY S.Quantity DESC;
GO

--5. Функцию, возвращающую список книг, отвечающих набору критериев
--   (например, имя автора, фамилия автора, тематика, категория),
--   и отсортированный по номеру поля, указанному в 5-м параметре,
--   в направлении, указанном в 6-м параметре.

CREATE FUNCTION BookList(
	@nameAut nvarchar(50),
	@lastNameAut nvarchar(50),
	@themes nvarchar(50),
	@category nvarchar(50),
	@numField nvarchar(50),
	@sort int)
RETURNS TABLE
AS
RETURN
	(SELECT TOP 10 B.Id, B.Name AS Author,
		B.Pages, B.YearPress,
		T.Name AS Themes, C.Name AS Category,
		A.FirstName, A.LastName,
		P.Name AS Press, B.Comment, B.Quantity
	FROM Books B
		JOIN Authors A ON B.AuthorFk = A.Id
		JOIN Themes T ON B.ThemeFk = T.Id
		JOIN Categories C ON B.CategoryFk = C.Id
		JOIN Presses P ON B.PressFk = P.Id
	WHERE A.FirstName = @nameAut AND A.LastName = @lastNameAut
		AND T.Name = @themes AND C.Name	= @category
	ORDER BY
		CASE 
			WHEN @sort = 0 THEN @numField + 0
			WHEN @sort != 0 THEN @numField + 0 END ASC);
GO

SELECT *
FROM BookList(
	'Алексей',
	'Архангельский',
	'Программирование',
	'C++ Builder', 3, 1);
GO

--6. Функцию, которая возвращает список библиотекарей и кол-во выданных
--   каждым из них книг.

CREATE FUNCTION GetTheListLibs()
RETURNS TABLE
AS
RETURN
	(SELECT V.Id, V.FirstName, V.LastName, SUM(V.Quantity) AS SumOut
	FROM (SELECT L.Id, L.FirstName, L.LastName, COUNT(*) AS Quantity
		FROM StudentCards SC
			JOIN Libs L ON SC.LibFk = L.Id
		GROUP BY L.Id, L.FirstName, L.LastName
		UNION ALL
		SELECT L.Id, L.FirstName, L.LastName, COUNT(*) AS Quantity
		FROM TeacherCards TC
			JOIN Libs L ON TC.LibFk = L.Id
		GROUP BY L.Id, L.FirstName, L.LastName) V
	GROUP BY V.Id, V.FirstName, V.LastName);
GO

SELECT *
FROM GetTheListLibs();
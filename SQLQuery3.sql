USE Library
GO

-- 1. Вывести информацию о книге с наибольшим количеством страниц.

SELECT *
FROM Books B
WHERE Pages IN
	(SELECT MAX(B.Pages)
	FROM Books B);
GO

SELECT B.Id,
	B.Name,
	B.Pages,
	B.YearPress,
	T.Name,
	C.Name,
	A.FirstName + ' ' + A.LastName AS Author,
	P.Name,
	B.Comment,
	B.Quantity
FROM Books B
	JOIN Themes T ON B.ThemeFk = T.Id
	JOIN Authors A ON B.AuthorFk = A.Id
	JOIN Categories C ON B.CategoryFk = C.Id
	JOIN Presses P ON B.PressFk = P.Id
WHERE B.Pages =
	(SELECT MAX(B.Pages)
	FROM Books B);
GO

-- 2. Вывести информацию о книге по программированию с наибольшим количеством страниц.

SELECT B.Id,
	B.Name,
	B.Pages,
	B.YearPress,
	T.Name,
	C.Name,
	A.FirstName + ' ' + A.LastName AS Author,
	P.Name,
	B.Comment,
	B.Quantity
FROM Books B
	JOIN Themes T ON B.ThemeFk = T.Id
	JOIN Authors A ON B.AuthorFk = A.Id
	JOIN Categories C ON B.CategoryFk = C.Id
	JOIN Presses P ON B.PressFk = P.Id
WHERE B.Pages = (
	SELECT MAX(B.Pages)
	FROM Books B
		JOIN Themes T ON T.Id = B.ThemeFk
	WHERE T.Id = (
		SELECT T.Id
		FROM Themes T
		WHERE T.Name = 'Программирование'));
GO

-- 3. Вывести статистику посещений библиотеки по каждой группе студентов.

SELECT G.Name, COUNT(SC.BookFk) AS LibrarySatistics
FROM StudentCards SC
	JOIN Students S ON SC.StudentFk = S.Id
	JOIN Groups G ON S.GroupFk = G.Id
GROUP BY G.Name;
GO

-- 4. Вывести количество книг, взятых в библиотеке программистами по тематикам
--  «Программирование» и «Базы данных», и сумму страниц в этих книгах.

SELECT T.Name, COUNT(*) AS Quantity, SUM(B.Pages) AS SumPages
FROM StudentCards SC
	JOIN Books B ON SC.BookFk = B.Id
	JOIN Themes T ON B.ThemeFk = T.Id
GROUP BY T.Name
HAVING T.Name IN ('Программирование', 'Базы данных');

--5. Допустим, что студент имеет право держать книгу у себя дома только 1 месяц,
--    а за каждую неделю сверх того он обязан «выставить» уважаемому библиотекарю Сергею Максименко
--    полбутылки (емкость бутылки 0.5 л) светлого пива. Необходимо вывести сколько литров
--    должен каждый студент, а также суммарное количество литров пива. Итоговая сумма должна
--    округляться в большую сторону, то есть суммарное число литров должно быть целым.
--    Используйте функции DATEDIFF и CAST.

CREATE VIEW Debts
AS
SELECT S.LastName AS Student,
	DATEDIFF(DAY, SC.DateOut, ISNULL(SC.DateIn, '2002-01-01')) / 30 * 0.5 as Result
FROM StudentCards SC
	JOIN Students S ON SC.StudentFk = S.Id
	JOIN Libs L ON SC.LibFk = L.Id
WHERE L.LastName = 'Максименко'
	AND DATEDIFF(DAY, SC.DateOut, ISNULL(SC.DateIn, '2002-01-01')) > 30;
GO

SELECT D.Student, D.Result
FROM Debts D
UNION
	SELECT 'Итого', CAST(SUM(Result) AS decimal)
	FROM Debts
	ORDER BY Result;
GO

-- 6. Если считать общее количество книг в библиотеке за 100%, то необходимо подсчитать
--    сколько книг (в процентном отношении) брал каждый факультет.

SELECT F.Name AS Faculties,
	CAST(COUNT(F.NAME) * 100 / (SELECT SUM(B.Quantity) FROM Books B) AS money) AS 'Result, %' 
FROM StudentCards SC
	JOIN Students S ON SC.StudentFk = S.Id
	JOIN Groups G ON S.GroupFk = G.Id
	JOIN Faculties F ON G.FacultyFk = F.Id
	JOIN Books B ON SC.BookFk = B.Id
GROUP BY F.Name;

-- 7. Вывести самого популярного автора(ов) среди студентов.

CREATE VIEW MostPopAut
AS
SELECT A.LastName, A.FirstName, COUNT(*) AS Popularity
FROM StudentCards SC
	JOIN Books B ON SC.BookFk = B.Id
	JOIN Students S ON SC.StudentFk = S.Id
	JOIN Authors A ON B.AuthorFk = A.Id
GROUP BY A.LastName, A.FirstName;

SELECT MP.FirstName + ' ' + MP.LastName AS Authors, MP.Popularity
FROM MostPopAut MP
WHERE MP.Popularity IN 
	(SELECT MAX(MP.Popularity)
	FROM MostPopAut MP)

-- 8. Вывести самого популярного автора(ов) среди преподавателей и количество книг
--    этого автора, взятых в библиотеке.

SELECT *
FROM TeacherCards

CREATE VIEW MostPopTBooks
AS
SELECT A.FirstName + ' ' + A.LastName AS Author, COUNT(A.Id) AS Popularity
FROM TeacherCards TC
	JOIN Books B ON TC.BookFk = B.Id
	JOIN Authors A ON B.AuthorFk = A.Id
GROUP BY A.LastName, A.FirstName;

SELECT *
FROM MostPopTBooks M
WHERE M.Popularity IN
	(SELECT MAX(M.Popularity)
	FROM MostPopTBooks M)

-- 9. Вывести самого популярную(ые) тематику(и) среди студентов и преподавателей.

SELECT *
FROM Themes

CREATE VIEW PopularThemes
AS
SELECT T.Name, COUNT(T.Id) AS Popularity
FROM Books B
	JOIN StudentCards SC ON B.Id = SC.BookFk
	JOIN TeacherCards TC ON B.Id = TC.BookFk
	JOIN Themes T ON B.ThemeFk = T.Id
GROUP BY T.Name;
GO

SELECT *
FROM PopularThemes P
WHERE P.Popularity IN
	(SELECT MAX(P.Popularity)
	FROM PopularThemes P);
GO

--10. «Заставить» сдать книги тех студентов, которые не сдавали книги более года,
--    т.е. в таблице «Карточка студентов» (StudentCards) заполнить поле «Дата возврата»
--    (DateIn) текущей датой.

SELECT *
FROM StudentCards SC
WHERE SC.DateIn IS NOT NULL

UPDATE StudentCards
SET DateIn = GETDATE()
WHERE DateIn IS NULL
	OR DATEDIFF(MONTH, DateIn, CONVERT(date, GETDATE())) > 12;

--11.	Удалить из таблицы «Карточка студентов» студентов, которые уже вернули книги.

DELETE FROM StudentCards
WHERE DateIn IS NOT NULL;
GO

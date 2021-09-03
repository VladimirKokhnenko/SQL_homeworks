USE Books
GO

SELECT *
FROM Books;


-- 1. Вытащить название учебников, которые издавались не издательством 'BHV',
--    и тираж которых >= 3000 экземпляров.

SELECT Name
FROM Books
WHERE Izd NOT IN ('BHV') AND (Pressrun >= 3000);


-- 2. Вытащить книги, со дня издания которых прошло не более года.
--    Задать конкретную дату можно с помощью функции DATEFROMPARTS().

SELECT *
FROM Books
WHERE ([Date] > DATEFROMPARTS(2003, 1, 1));


-- 3. Вытащить книги, о дате издания которых ничего не известно.

SELECT *
FROM Books
WHERE [Date] IS NULL;


-- 4. Вытащить все книги-новинки, цена которых ниже 30 грн.

SELECT *
FROM Books
WHERE Price < 30
ORDER BY Price;


-- 5. Вытащить книги, в названиях которых есть слово Microsoft, но нет слова Windows.

SELECT *
FROM Books
WHERE Name LIKE '%Microsoft%' AND Name NOT LIKE ('%Windows%');


-- 6. Вытащить книги, у которых цена одной страницы < 10 копеек.

SELECT *
FROM Books
WHERE Pages > 0 AND Price / Pages < 10
ORDER BY Pages;


-- 7. Вытащить книги, в названиях которых присутствует как минимум одна цифра.

SELECT *
FROM Books
WHERE Name LIKE '%[0-9]%';


-- 8. Вытащить книги, в названиях которых присутствует не менее трех цифр.

SELECT *
FROM Books
WHERE Name LIKE '%[0-9]%[0-9]%[0-9]%';


-- 9. Вытащить книги, в названиях которых присутствует ровно пять цифр.

SELECT *
FROM Books
WHERE Name LIKE '%[0-9]%[0-9]%[0-9]%[0-9]%[0-9]%'
AND Name NOT LIKE '%[0-9]%[0-9]%[0-9]%[0-9]%[0-9]%[0-9]%';


-- 10.	Удалить книги, в коде которых присутствует цифры 6 или 7.

DELETE
FROM Books
WHERE Name LIKE '%[67]%';

SELECT *
FROM Books
WHERE Name LIKE '%[67]%';

-- 11.	Проставить текущую дату для тех книг, у которых дата издания отсутствует.
--    Tекущую дату можно получить с помощью функции GETDATE().

UPDATE Books
SET [Date] = CONVERT (date, GETDATE())
WHERE [Date] is null;


INSERT INTO Books (Id) 
VALUES (768);

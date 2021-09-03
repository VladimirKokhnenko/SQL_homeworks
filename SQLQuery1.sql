USE Books
GO

SELECT *
FROM Books;


-- 1. �������� �������� ���������, ������� ���������� �� ������������� 'BHV',
--    � ����� ������� >= 3000 �����������.

SELECT Name
FROM Books
WHERE Izd NOT IN ('BHV') AND (Pressrun >= 3000);


-- 2. �������� �����, �� ��� ������� ������� ������ �� ����� ����.
--    ������ ���������� ���� ����� � ������� ������� DATEFROMPARTS().

SELECT *
FROM Books
WHERE ([Date] > DATEFROMPARTS(2003, 1, 1));


-- 3. �������� �����, � ���� ������� ������� ������ �� ��������.

SELECT *
FROM Books
WHERE [Date] IS NULL;


-- 4. �������� ��� �����-�������, ���� ������� ���� 30 ���.

SELECT *
FROM Books
WHERE Price < 30
ORDER BY Price;


-- 5. �������� �����, � ��������� ������� ���� ����� Microsoft, �� ��� ����� Windows.

SELECT *
FROM Books
WHERE Name LIKE '%Microsoft%' AND Name NOT LIKE ('%Windows%');


-- 6. �������� �����, � ������� ���� ����� �������� < 10 ������.

SELECT *
FROM Books
WHERE Pages > 0 AND Price / Pages < 10
ORDER BY Pages;


-- 7. �������� �����, � ��������� ������� ������������ ��� ������� ���� �����.

SELECT *
FROM Books
WHERE Name LIKE '%[0-9]%';


-- 8. �������� �����, � ��������� ������� ������������ �� ����� ���� ����.

SELECT *
FROM Books
WHERE Name LIKE '%[0-9]%[0-9]%[0-9]%';


-- 9. �������� �����, � ��������� ������� ������������ ����� ���� ����.

SELECT *
FROM Books
WHERE Name LIKE '%[0-9]%[0-9]%[0-9]%[0-9]%[0-9]%'
AND Name NOT LIKE '%[0-9]%[0-9]%[0-9]%[0-9]%[0-9]%[0-9]%';


-- 10.	������� �����, � ���� ������� ������������ ����� 6 ��� 7.

DELETE
FROM Books
WHERE Name LIKE '%[67]%';

SELECT *
FROM Books
WHERE Name LIKE '%[67]%';

-- 11.	���������� ������� ���� ��� ��� ����, � ������� ���� ������� �����������.
--    T������ ���� ����� �������� � ������� ������� GETDATE().

UPDATE Books
SET [Date] = CONVERT (date, GETDATE())
WHERE [Date] is null;


INSERT INTO Books (Id) 
VALUES (768);

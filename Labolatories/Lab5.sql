--Przykład 1
use joindb
select buyer_name, sales.buyer_id, qty
from buyers, sales
where buyers.buyer_id = sales.buyer_id

--Przykład 2
use joindb
select buyer_name, s.buyer_id, qty
from buyers as b inner join sales as s
on b.buyer_id = s.buyer_id

use joindb
select b.buyer_name as [b.buyer_name],
b.buyer_id as [b.buyer_id],
s.buyer_id as [s.buyer_id],
qty as [s.qty]
from buyers as b, sales as s
where s.buyer_id = b.buyer_id
    and
    b.buyer_name like 'Adam Barr'

use Northwind
select productname, companyname
from Products, suppliers
where products.supplierid = suppliers.supplierid

select productname, companyname
from products inner join suppliers
on products.supplierid = suppliers.supplierid

select * from Orders

select CompanyName, OrderDate 
from Customers inner join Orders
on Customers.CustomerID = Orders.CustomerID
where OrderDate > '01/03/1998'


--Cwiczenia
/*
Wybierz nazwy i ceny produktów (baza northwind) o cenie
jednostkowej pomiędzy 20.00 a 30.00, dla każdego produktu podaj
dane adresowe dostawcy*/

select productname, unitprice, address
from Products inner join Suppliers
on Products.SupplierID = Suppliers. SupplierID
where UnitPrice between 20.00 and 30.00

/*
Wybierz nazwy produktów oraz inf. o stanie magazynu dla
produktów dostarczanych przez firmę ‘Tokyo Traders’*/

select ProductName, UnitsInStock 
from Products, Suppliers
where Suppliers.CompanyName like 'Tokyo Traders'
	and Suppliers.SupplierID = Products.SupplierID

select productname, unitsinstock
from products
inner join Suppliers
on Suppliers.SupplierID=Products.SupplierID
where companyname = 'Tokyo Traders'

/*
Czy są jacyś klienci którzy nie złożyli żadnego zamówienia w 1997
roku, jeśli tak to pokaż ich dane adresowe*/
use Northwind
select CompanyName, OrderID, OrderDate
from Customers inner join Orders
on Customers.CustomerID=Orders.CustomerID
where CompanyName like 'Around the Horn'

select distinct CompanyName, Address
from Orders, Customers
where year(OrderDate) = 1997
	and Orders.CustomerID != Customers.CustomerID

select distinct companyname,address
from customers
left outer join orders
on Customers.CustomerID=Orders.CustomerID
where orders.customerid NOT IN (select customerid from orders where year(orderdate)=1997)

select companyname,address
from Customers left join Orders
on Customers.CustomerID = Orders.CustomerID and year(OrderDate) = 1997
where Orders.OrderID is null


/*
Wybierz nazwy i numery telefonów dostawców, dostarczających
produkty, których aktualnie nie ma w magazynie */
use Northwind
select CompanyName, Phone
from Suppliers right outer join products
on Suppliers.SupplierID = Products.SupplierID
where UnitsInStock in (null, 0)

--Napisz polecenie, które wyświetla listę dzieci będących członkami biblioteki (baza library).
--Interesuje nas imię, nazwisko i data urodzenia dziecka.

use library
select firstname,lastname, birth_date 
from juvenile inner join member
on member.member_no = juvenile.member_no


/*Napisz polecenie, które podaje tytuły aktualnie wypożyczonych
książek*/

select distinct title
from loan inner join title
on loan.title_no = title.title_no

/*Podaj informacje o karach zapłaconych za przetrzymywanie książki
o tytule ‘Tao Teh King’. Interesuje nas data oddania książki, ile dni
była przetrzymywana i jaką zapłacono karę*/

select in_date,due_date, datediff(dd,due_date,in_date) as dni, fine_assessed
from loanhist inner join title
on loanhist.title_no = title.title_no
where title like 'Tao Teh King'
	and datediff(dd,due_date,in_date) > 0


/*Napisz polecenie które podaje listę książek (mumery ISBN)
zarezerwowanych przez osobę o nazwisku: Stephen A. Graff
*/
use library
select isbn
from member inner join reservation
on member.member_no = reservation.member_no
where firstname + middleinitial + lastname like 'Stephen%A%Graff'

USE northwind
SELECT suppliers.companyname, shippers.companyname
FROM suppliers
CROSS JOIN shippers
GO
select * from Suppliers
select * from Shippers

USE northwind
SELECT orderdate, productname
FROM orders AS O
INNER JOIN [order details] AS OD
ON O.orderid = OD.orderid
INNER JOIN products AS P
ON OD.productid = P.productid
WHERE orderdate = '7/8/96'
GO

/*Wybierz nazwy i ceny produktów (baza northwind) o cenie
jednostkowej pomiędzy 20.00 a 30.00, dla każdego produktu podaj
dane adresowe dostawcy, interesują nas tylko produkty z kategorii
‘Meat/Poultry’*/

select ProductName, UnitPrice, Address
from Categories
inner join Products
on Products.CategoryID = Categories.CategoryID
inner join Suppliers
on Products.SupplierID = Suppliers.SupplierID
where CategoryName = 'Meat/Poultry'
and UnitPrice between 20.00 and 30.00


/*Wybierz nazwy i ceny produktów z kategorii ‘Confections’ dla
każdego produktu podaj nazwę dostawcy.*/

select ProductName, UnitPrice, CompanyName
from Categories
inner join Products
on Products.CategoryID = Categories.CategoryID
inner join Suppliers
on Suppliers.SupplierID = Products.SupplierID
where CategoryName like 'Confections'

/*Wybierz nazwy i numery telefonów klientów , którym w 1997 roku
przesyłki dostarczała firma ‘United Package’*/


select Customers.CompanyName, Customers.Phone 
from Customers
inner join Orders
on Orders.CustomerID = Customers.CustomerID
inner join Shippers
on Shippers.ShipperID = Orders.ShipVia
where Shippers.CompanyName like 'United Package'
and year(ShippedDate) = 1997

/*Wybierz nazwy i numery telefonów klientów, którzy kupowali
produkty z kategorii ‘Confections’*/

select distinct Customers.CompanyName, Customers.Phone
from Customers
inner join Orders
on Orders.CustomerID = Customers.CustomerID
inner join [Order Details]
on Orders.OrderID = [Order Details].OrderID
inner join Products
on [Order Details].ProductID = Products.ProductID
inner join Categories
on Products.CategoryID = Categories.CategoryID
where CategoryName like 'Confections'

/*Napisz polecenie, które wyświetla listę dzieci będących członkami
biblioteki (baza library). Interesuje nas imię, nazwisko, data
urodzenia dziecka i adres zamieszkania dziecka.*/

use library
select firstname,lastname,birth_date,street+' '+city+' '+state as [adres zamieszkania]
from member
inner join juvenile
on member.member_no=juvenile.member_no
inner join adult
on adult.member_no=juvenile.adult_member_no


/*Napisz polecenie, które wyświetla listę dzieci będących członkami
biblioteki (baza library). Interesuje nas imię, nazwisko, data
urodzenia dziecka, adres zamieszkania dziecka oraz imię i nazwisko
rodzica.*/ 

SELECT m.firstname,m.lastname,j.birth_date,a.street+' '+a.city+ ' '+a.state AS [adres zamieszkania], ma.firstname, ma.lastname
FROM member AS m
INNER JOIN juvenile j
ON j.member_no=m.member_no
INNER JOIN adult a 
ON a.member_no=j.adult_member_no
INNER JOIN member ma
ON ma.member_no=a.member_no

/*Napisz polecenie, które wyświetla pracowników oraz ich
podwładnych (baza northwind)*/


SELECT a.buyer_id AS buyer1, a.prod_id, b.buyer_id AS buyer2
FROM sales AS a
JOIN sales AS b
ON a.prod_id = b.prod_id
WHERE a.buyer_id < b.buyer_id

USE northwind
SELECT a.employeeid, a.lastname AS name, a.title AS title,
       b.employeeid, b.lastname AS name, b.title AS title
FROM employees AS a
INNER JOIN employees AS b
ON a.title = b.title
WHERE a.employeeid < b.employeeid


select A.FirstName+ ' '+A.LastName as Pracownik, B.FirstName+ ' '+B.LastName as Podwladny
from Employees A
inner join Employees B
    on A.EmployeeID = B.ReportsTo
group by A.FirstName+ ' '+A.LastName, B.FirstName+ ' '+B.LastName

/*Napisz polecenie, które wyświetla pracowników, którzy nie mają
podwładnych (baza northwind)*/

select EmployeeID
from Employees 
where EmployeeID not in(select a.employeeid
						from Employees as a
						inner join Employees as b 
						on a.EmployeeID = b.ReportsTo)

/*Napisz polecenie, które wyświetla adresy członków biblioteki, którzy
mają dzieci urodzone przed 1 stycznia 1996*/
use library
select distinct adult.member_no, street, city, state
from juvenile  
inner join adult 
on juvenile.member_no = adult.member_no
where birth_date < '01/01/1996'
order by adult.member_no

/*Napisz polecenie, które wyświetla adresy członków biblioteki, którzy
mają dzieci urodzone przed 1 stycznia 1996. Interesują nas tylko
adresy takich członków biblioteki, którzy aktualnie nie przetrzymują
książek.*/

use library
select distinct adult.member_no, street
from juvenile
inner join adult
on juvenile.adult_member_no = adult.member_no
inner join loan
on loan.member_no = adult.member_no
inner join juvenile as b
on loan.member_no = b.member_no
where b.birth_date < '01/01/1996'
order by adult.member_no

SELECT distinct m.firstname+' '+m.lastname, a.street, a.city, a. state
FROM adult AS a
INNER JOIN member m
ON a.member_no=m.member_no
INNER JOIN juvenile j
ON a.member_no=j.adult_member_no AND year(birth_date)<1996
LEFT JOIN loan l
ON a.member_no=l.member_no
GROUP BY m.firstname+' '+m.lastname, a.street, a.city, a. state
HAVING COUNT(l.isbn)=0


/*Napisz polecenie które zwraca imię i nazwisko (jako pojedynczą
kolumnę – name), oraz informacje o adresie: ulica, miasto, stan kod
(jako pojedynczą kolumnę – address) dla wszystkich dorosłych
członków biblioteki*/

select (firstname +' '+ lastname) as name, (street +' '+ city +' '+ state +' '+ zip) as adress
from adult
inner join member
on member.member_no = adult.member_no


/*Napisz polecenie, które zwraca: isbn, copy_no, on_loan, title,
translation, cover, dla książek o isbn 1, 500 i 1000. Wynik posortuj
wg ISBN*/

select item.isbn, copy_no, on_loan, title, translation, cover   
from item
left outer join copy
on copy.title_no = item.title_no
inner join title
on title.title_no = copy.title_no
where item.isbn in(1,500,1000)
order by item.isbn

/*Napisz polecenie które zwraca o użytkownikach biblioteki o nr 250,
342, i 1675 (dla każdego użytkownika: nr, imię i nazwisko członka
biblioteki), oraz informację o zarezerwowanych książkach (isbn,
data)*/

select member.member_no, firstname, lastname, isbn, log_date
from member
left outer join reservation
on member.member_no = reservation.member_no
where member.member_no in (250,342,1675)


UNION
select member.member_no, firstname, lastname, isbn, log_date
from member
inner join reservation
on member.member_no = reservation.member_no
where member.member_no not in (250,342,1675)



/*Podaj listę członków biblioteki mieszkających w Arizonie (AZ) mają
więcej niż dwoje dzieci zapisanych do biblioteki*/

SELECT member.member_no,firstname,lastname
FROM member
INNER JOIN adult
ON member.member_no=adult.member_no AND state='AZ'
LEFT JOIN juvenile
ON member.member_no=juvenile.adult_member_no
GROUP BY member.member_no,firstname,lastname
HAVING COUNT(juvenile.adult_member_no)>2

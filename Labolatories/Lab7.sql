use Northwind

/*1.Wybierz nazwy i numery telefonów klientów ,
którym w 1997 roku przesyłki dostarczała firma United Package.
 */

select CompanyName, Phone
from Customers
where CustomerID in (select CustomerID from Orders
                        where year(OrderDate) = 1997 and ShipVia in
                        (select ShipperID from Shippers
                        where Shippers.CompanyName = 'United Package'))


select distinct Customers.CompanyName, Customers.Phone
from Customers
inner join Orders O on Customers.CustomerID = O.CustomerID
inner join Shippers S on S.ShipperID = O.ShipVia
where S.CompanyName = 'United Package' and year(OrderDate) = 1997



/*2.Wybierz nazwy i numery telefonów klientów ,
którym w 1997 roku przesyłek nie dostarczała firma United Package.*/

select CompanyName, Phone
from Customers
where CustomerID not in (select CustomerID from Orders
                        where year(OrderDate) = 1997 and ShipVia in
                        (select ShipperID from Shippers
                        where Shippers.CompanyName = 'United Package'))

--????
select distinct C.CompanyName, C.Phone
from Customers
inner join Orders O on Customers.CustomerID = O.CustomerID
inner join Shippers S
    on S.ShipperID = O.ShipVia and year(ShippedDate) = 1997 and S.CompanyName = 'United Package'
right join Customers C on C.CustomerID = Customers.CustomerID
where Customers.CustomerID is null

/*Wybierz nazwy i numery telefonów klientów,
którzy kupowali produkty z kategorii Confections..*/

select CompanyName, Phone
from Customers
where CustomerID in (select CustomerID from Orders
    where OrderID in (select OrderID from [Order Details]
        where ProductID in (select ProductID from Products
            where CategoryID in (select CategoryID from Categories
                where CategoryName = 'Confections'))))

select distinct CompanyName, Phone
from Customers
inner join Orders O on Customers.CustomerID = O.CustomerID
inner join [Order Details] [O D] on O.OrderID = [O D].OrderID
inner join Products P on P.ProductID = [O D].ProductID
inner join Categories C on C.CategoryID = P.CategoryID
where CategoryName = 'Confections'

/*2.Wybierz nazwy i numery telefonów klientów,
którzy nie kupowali produktów z kategorii Confections..*/

select CompanyName, Phone
from Customers
where CustomerID not in (select CustomerID from Orders
    where OrderID in (select OrderID from [Order Details]
        where ProductID in (select ProductID from Products
            where CategoryID in (select CategoryID from Categories
                where CategoryName = 'Confections'))))

select distinct C2.CompanyName, C2.Phone
from Customers
inner join Orders O on Customers.CustomerID = O.CustomerID
inner join [Order Details] [O D] on O.OrderID = [O D].OrderID
inner join Products P on P.ProductID = [O D].ProductID
inner join Categories C on C.CategoryID = P.CategoryID and CategoryName = 'Confections'
right outer join Customers C2 on C2.CustomerID = Customers.CustomerID
where Customers.CustomerID is null


/*1. Dla każdego produktu podaj maksymalną liczbę zamówionych jednostek*/

select ProductID,
       (select max(Quantity) from [Order Details]
       where Products.ProductID = [Order Details].ProductID) as maksymalne_zamowienie
from Products

select Products.ProductID, max(Quantity) as maksymalne_zamowienie
from Products
inner join [Order Details] [O D] on Products.ProductID = [O D].ProductID
group by Products.ProductID
order by Products.ProductID

/*2.Podaj wszystkie produkty których cena jest mniejsza niż średnia cena produktu
*/

select ProductID, UnitPrice
from Products
where UnitPrice < (select AVG(UnitPrice) from Products)


/*3.Podaj wszystkie produkty
których cena jest mniejsza niż średnia cena produktu danej kategorii*/

select ProductID, UnitPrice
from Products P1
where UnitPrice < (select AVG(UnitPrice) from Products P2
    where P1.CategoryID = P2.CategoryID)
order by ProductID

/*1.Dla każdego produktu podaj jego nazwę, cenę,
średnią cenę wszystkich produktów oraz różnicę między
ceną produktu a średnią ceną wszystkich produktów
   */
select P.ProductID, P.UnitPrice,
       (select AVG(UnitPrice) from Products) as srednia_cena,
       (P.UnitPrice - (select AVG(UnitPrice) from Products)) as roznica
from Products P

/*2.Dla każdego produktu podaj jego nazwę kategorii,
nazwę produktu, cenę, średnią cenę wszystkich produktów
danej kategorii oraz różnicę między ceną produktu a
średnią ceną wszystkich produktów danej kategorii*/

select (select CategoryName from Categories where P.CategoryID = Categories.CategoryID),
       UnitPrice,
       (select AVG(UnitPrice) from Products where P.CategoryID = Products.CategoryID),
       (UnitPrice - ((select AVG(UnitPrice) from Products where P.CategoryID = Products.CategoryID)))
from Products P


/*1.Podaj łączną wartość zamówienia o numerze 1025 (uwzględnij cenę za przesyłkę)
*/

select round((Freight + (select sum(UnitPrice*Quantity*(1-Discount)) from [Order Details] [O D]
    where O.OrderID = [O D].OrderID)),2)
from Orders O
where OrderID = 10250

select round((Orders.Freight + (select sum(UnitPrice*Quantity*(1-Discount)))),2)
from Orders
inner join [Order Details] [O D] on Orders.OrderID = [O D].OrderID
where Orders.OrderID = 10250
group by Freight

/*2.Podaj łączną wartość zamówień każdego zamówienia (uwzględnij cenę za przesyłkę)
*/
select OrderID, round((Freight + (select sum(UnitPrice*Quantity*(1-Discount)) from [Order Details] [O D]
    where O.OrderID = [O D].OrderID)),2)
from Orders O


select Orders.OrderID, round((Orders.Freight + (select sum(UnitPrice*Quantity*(1-Discount)))),2)
from Orders
inner join [Order Details] [O D] on Orders.OrderID = [O D].OrderID
group by Orders.OrderID, Freight

/*3.Czy są jacyś klienci którzy nie złożyli żadnego zamówienia w 1997 roku,
  jeśli tak to pokaż ich dane adresowe
*/

select Address,City
from Customers
where Customers.CustomerID not in (select CustomerID from Orders
    where year(OrderDate) = 1997 )

select C.Address,C.City
from Customers
inner join Orders O on Customers.CustomerID = O.CustomerID and year(OrderDate) = 1997
right join Customers C on C.CustomerID = Customers.CustomerID
where Customers.CustomerID is null

/*4.Podaj produkty kupowane przez więcej niż jednego klienta*/

select P.ProductName
from Products as p
inner join [Order Details] od on od.ProductID = p.ProductID
inner join Orders O on od.OrderID = O.OrderID
inner join Customers C on C.CustomerID = O.CustomerID
group by p.ProductName,C.CustomerID
having count(*) >1

???
select ProductName
from Products
group by ProductName
having sum(
       (select distinct CustomerID from Customers where CustomerID in
                    (select CustomerID from Orders where OrderID in
                    (select OrderID from [Order Details] where [Order Details].ProductID = Products.ProductID )))) > 1

/*Dla każdego pracownika (imię i nazwisko) podaj łączną wartość zamówień
  obsłużonych przez tego pracownika
(przy obliczaniu wartości zamówień uwzględnij cenę za przesyłkę_
*/
select FirstName + '' + LastName, round(((select sum(Freight) from Orders where Employees.EmployeeID = Orders.EmployeeID) +
                                       (select sum(Quantity*UnitPrice *(1- Discount)) from [Order Details] where OrderID
                                        in(select OrderID from Orders where Employees.EmployeeID = Orders.EmployeeID))),2)
from Employees


select E.FirstName + ' ' + E.LastName AS 'name', round((
 select SUM(OD.UnitPrice*od.quantity*(1-od.Discount))
 from Orders AS O
 inner join [Order Details] as OD ON O.OrderID = OD.OrderID
 where E.EmployeeID = O.EmployeeID) +
 (select sum(O.Freight)
 from Orders as o
 where o.EmployeeID = e.EmployeeID),2)
from Employees AS E

/*2.Który z pracowników obsłużył najaktywniejszy
(obsłużył zamówienia o największej wartości) w 1997r,
podaj imię i nazwisko takiego pracownika
*/

select top 1 FirstName + '' + LastName, round(((select sum(Freight) from Orders where year(ShippedDate) = 1997 and Employees.EmployeeID = Orders.EmployeeID) +
                                       (select sum(Quantity*UnitPrice *(1- Discount)) from [Order Details] where OrderID
                                        in(select OrderID from Orders where year(ShippedDate) = 1997 and Employees.EmployeeID = Orders.EmployeeID))),2)
from Employees
order by 2 desc


select top 1 E.FirstName + ' ' + e.LastName as 'pracownik', round(
 (select SUM(OD.UnitPrice*od.quantity*(1-od.Discount))
 from Orders AS O
 inner join [Order Details] as OD ON O.OrderID = OD.OrderID
 where E.EmployeeID = O.EmployeeID AND year(O.ShippedDate) = 1997)
 + (select sum(Freight) from Orders
    inner join Employees E2 on E2.EmployeeID = Orders.EmployeeID
    where E2.EmployeeID = E.EmployeeID and year(ShippedDate) = 1997),2 ) AS 'wartosc'
from Employees as E
order by wartosc desc


/*3.Ogranicz wynik z pkt1 tylko do pracownikówa)
  którzy mają podwładnych
*/

--A maja podwładnych
select FirstName + '' + LastName, round(((select sum(Freight) from Orders where Employees.EmployeeID = Orders.EmployeeID) +
                                       (select sum(Quantity*UnitPrice *(1- Discount)) from [Order Details] where OrderID
                                        in(select OrderID from Orders where Employees.EmployeeID = Orders.EmployeeID))),2)
from Employees
where EmployeeID in(select a.employeeid
						from Employees as a
						inner join Employees as b
						on a.EmployeeID = b.ReportsTo)

select distinct E.FirstName + ' ' + E.LastName AS 'name', round((
 select SUM(OD.UnitPrice*od.quantity*(1-od.Discount))
 from Orders AS O
 inner join [Order Details] as OD ON O.OrderID = OD.OrderID
 where E.EmployeeID = O.EmployeeID) +
 (select sum(O.Freight)
 from Orders as o
 where o.EmployeeID = e.EmployeeID),2)
from Employees AS E
left join Employees E2 on E.EmployeeID = E2.ReportsTo
where E2.EmployeeID is not null




--B nie maja podwładnych
select FirstName + '' + LastName, round(((select sum(Freight) from Orders where Employees.EmployeeID = Orders.EmployeeID) +
                                       (select sum(Quantity*UnitPrice *(1- Discount)) from [Order Details] where OrderID
                                        in(select OrderID from Orders where Employees.EmployeeID = Orders.EmployeeID))),2)
from Employees
where EmployeeID not in(select a.employeeid
						from Employees as a
						inner join Employees as b
						on a.EmployeeID = b.ReportsTo)


select E.FirstName + ' ' + E.LastName AS 'name', round((
 select SUM(OD.UnitPrice*od.quantity*(1-od.Discount))
 from Orders AS O
 inner join [Order Details] as OD ON O.OrderID = OD.OrderID
 where E.EmployeeID = O.EmployeeID) +
 (select sum(O.Freight)
 from Orders as o
 where o.EmployeeID = e.EmployeeID),2)
from Employees AS E
left join Employees E2 on E.EmployeeID = E2.ReportsTo
where E2.EmployeeID is null



/*4.Zmodyfikuj rozwiązania z pkt3 tak aby dla pracowników
  pokazać jeszcze datę ostatnio obsłużonego zamówienia */

--A maja podwładnych
select FirstName + '' + LastName, round(((select sum(Freight) from Orders where Employees.EmployeeID = Orders.EmployeeID) +
                                       (select sum(Quantity*UnitPrice *(1- Discount)) from [Order Details] where OrderID
                                        in(select OrderID from Orders where Employees.EmployeeID = Orders.EmployeeID))),2),
       (select top 1 ShippedDate from Orders where Employees.EmployeeID = Orders.EmployeeID order by ShippedDate desc)
from Employees
where EmployeeID in(select a.employeeid
						from Employees as a
						inner join Employees as b
						on a.EmployeeID = b.ReportsTo)


select distinct E.FirstName + ' ' + E.LastName AS 'name',
round((select SUM(OD.UnitPrice*od.quantity*(1-od.Discount)) from Orders AS O inner join [Order Details] as OD ON O.OrderID = OD.OrderID where E.EmployeeID = O.EmployeeID) +
(select sum(O.Freight) from Orders as o where o.EmployeeID = E.EmployeeID),2),
(select top 1 ShippedDate from Orders where E.EmployeeID = Orders.EmployeeID order by ShippedDate desc)
from Employees AS E
left join Employees E2 on E.EmployeeID = E2.ReportsTo
where E2.EmployeeID is not null

--B nie maja podwładnych
select FirstName + '' + LastName, round(((select sum(Freight) from Orders where Employees.EmployeeID = Orders.EmployeeID) +
                                       (select sum(Quantity*UnitPrice *(1- Discount)) from [Order Details] where OrderID
                                        in(select OrderID from Orders where Employees.EmployeeID = Orders.EmployeeID))),2),
       (select top 1 ShippedDate from Orders where Employees.EmployeeID = Orders.EmployeeID order by ShippedDate desc)
from Employees
where EmployeeID not in(select a.employeeid
						from Employees as a
						inner join Employees as b
						on a.EmployeeID = b.ReportsTo)


select distinct E.FirstName + ' ' + E.LastName AS 'name',
round((select SUM(OD.UnitPrice*od.quantity*(1-od.Discount)) from Orders AS O inner join [Order Details] as OD ON O.OrderID = OD.OrderID where E.EmployeeID = O.EmployeeID) +
(select sum(O.Freight) from Orders as o where o.EmployeeID = E.EmployeeID),2),
(select top 1 ShippedDate from Orders where E.EmployeeID = Orders.EmployeeID order by ShippedDate desc)
from Employees AS E
left join Employees E2 on E.EmployeeID = E2.ReportsTo
where E2.EmployeeID is null





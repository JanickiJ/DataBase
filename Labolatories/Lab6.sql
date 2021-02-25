/*Dla każdego zamówienia podaj łączną liczbę zamówionych
jednostek towaru oraz nazwę klienta.
*/

select OD.OrderID, sum(Quantity) as quantity_sum, C.CompanyName
from [Order Details] OD
inner join Orders O on OD.OrderID = O.OrderID
inner join Customers C on O.CustomerID = C.CustomerID
group by OD.OrderID, C.CompanyName
order by OD.OrderID

/*Zmodyfikuj poprzedni przykład, aby pokazać tylko takie zamówienia,
dla których łączna liczbę zamówionych jednostek jest większa niż
250*/

select OD.OrderID, sum(Quantity) as quantity_sum, C.CompanyName
from [Order Details] OD
inner join Orders O on OD.OrderID = O.OrderID
inner join Customers C on O.CustomerID = C.CustomerID
group by OD.OrderID, C.CompanyName
having sum(Quantity) > 250
order by OD.OrderID

/*Dla każdego zamówienia podaj łączną wartość tego zamówienia oraz
nazwę klienta.
*/

select C.CompanyName, round(sum((UnitPrice - Discount) * Quantity),2) as suma_zamowien
from Orders
inner join [Order Details] [O D] on Orders.OrderID = [O D].OrderID
inner join Customers C on C.CustomerID = Orders.CustomerID
group by CompanyName

/*Zmodyfikuj poprzedni przykład, aby pokazać tylko takie zamówienia,
dla których łączna liczba jednostek jest większa niż 250.
*/

select C.CompanyName, round(sum((UnitPrice - Discount) * Quantity),2) as suma_zamowien
from Orders
inner join [Order Details] [O D] on Orders.OrderID = [O D].OrderID
inner join Customers C on C.CustomerID = Orders.CustomerID
group by CompanyName,[O D].OrderID
having sum(Quantity) > 250

/*Zmodyfikuj poprzedni przykład tak żeby dodać jeszcze imię i
nazwisko pracownika obsługującego zamówienie*/

select C.CompanyName, round(sum((UnitPrice - Discount) * Quantity),2) as suma_zamowien, (E.FirstName + ' ' + E.LastName) as pracownik
from Orders
inner join [Order Details] [O D] on Orders.OrderID = [O D].OrderID
inner join Customers C on C.CustomerID = Orders.CustomerID
inner join Employees E on Orders.EmployeeID = E.EmployeeID
group by CompanyName, [O D].OrderID, E.FirstName, E.LastName
having sum(Quantity) > 250

/*Dla każdej kategorii produktu (nazwa), podaj łączną liczbę
zamówionych przez klientów jednostek towarów z tek kategorii.
*/

select CategoryName, sum(Quantity) as suma_towarow
from Orders O
inner join [Order Details] OD
    on O.OrderID = OD.OrderID
inner join Products P
    on OD.ProductID = P.ProductID
right outer join Categories C
    on P.CategoryID = C.CategoryID
group by CategoryName

/*Dla każdej kategorii produktu (nazwa), podaj łączną wartość
zamówionych przez klientów jednostek towarów z tek kategorii.
*/

select CategoryName, round(sum((P.UnitPrice - Discount)*Quantity),2) as suma_towarow
from Orders O
inner join [Order Details] OD
    on O.OrderID = OD.OrderID
inner join Products P
    on OD.ProductID = P.ProductID
right outer join Categories C
    on P.CategoryID = C.CategoryID
group by CategoryName

/*Posortuj wyniki w zapytaniu z poprzedniego punktu wg:
a) łącznej wartości zamówień
b) łącznej liczby zamówionych przez klientów jednostek towarów.
*/

select CategoryName, round(sum((P.UnitPrice - Discount)*Quantity),2) as suma_towarow
from Orders O
inner join [Order Details] OD
    on O.OrderID = OD.OrderID
inner join Products P
    on OD.ProductID = P.ProductID
right outer join Categories C
    on P.CategoryID = C.CategoryID
group by CategoryName
order by suma_towarow, sum(Quantity)

/*Dla każdego zamówienia podaj jego wartość uwzględniając opłatę za
przesyłkę*/

select O.OrderID, round(sum((UnitPrice - Discount)* Quantity) + O.Freight,2) as cena_calkowita
from Orders O
inner join [Order Details] [O D] on O.OrderID = [O D].OrderID
group by O.OrderID, Freight

/*Dla każdego przewoźnika (nazwa) podaj liczbę zamówień które
przewieźli w 1997r
*/
select S.CompanyName, count(*)
from Shippers S
left outer join Orders O on S.ShipperID = O.ShipVia
where year(ShippedDate) = 1997
group by CompanyName



/*Który z przewoźników był najaktywniejszy (przewiózł największą
liczbę zamówień) w 1997r, podaj nazwę tego przewoźnika
*/
select top 1 S.CompanyName, count(*) as liczba_zamowien
from Shippers S
left outer join Orders O on S.ShipperID = O.ShipVia
where year(ShippedDate) = 1997
group by CompanyName
order by liczba_zamowien desc

/*Dla każdego pracownika (imię i nazwisko) podaj łączną wartość
zamówień obsłużonych przez tego pracownika
*/
select FirstName, LastName, count(*) as liczba_zamowien
from Employees E
left outer join Orders O on E.EmployeeID = O.EmployeeID
group by E.EmployeeID, FirstName, LastName

/*Który z pracowników obsłużył największą liczbę zamówień w 1997r,
podaj imię i nazwisko takiego pracownika
*/
select top 1 FirstName, LastName, count(*) as liczba_zamowien
from Employees E
left outer join Orders O on E.EmployeeID = O.EmployeeID
group by E.EmployeeID, FirstName, LastName
order by liczba_zamowien desc

/*Który z pracowników obsłużył najaktywniejszy (obsłużył zamówienia
o największej wartości) w 1997r, podaj imię i nazwisko takiego
pracownika
*/
select top 1 FirstName, LastName, count(*) as liczba_zamowien
from Employees E
left outer join Orders O on E.EmployeeID = O.EmployeeID
where year(OrderDate) = 1997
group by E.EmployeeID, FirstName, LastName
order by liczba_zamowien desc

/*
Dla każdego pracownika (imię i nazwisko) podaj łączną wartość
zamówień obsłużonych przez tego pracownika
l Ogranicz wynik tylko do pracowników
a) którzy mają podwładnych
b) którzy nie mają podwładnych
*/

select A.FirstName, A.LastName, count(*) as liczba_zamowien
from Orders O
right outer join Employees A
    on A.EmployeeID = O.EmployeeID and year(OrderDate) = 1997
inner join Employees B
    on A.EmployeeID = B.ReportsTo
group by A.EmployeeID, A.FirstName, A.LastName
order by liczba_zamowien desc

select A.FirstName, A.LastName, count(*) as liczba_zamowien
from Orders O
right outer join Employees A
    on A.EmployeeID = O.EmployeeID and year(OrderDate) = 1997
    where A.EmployeeID  not in(select a.employeeid
						from Employees as a
						inner join Employees as b
						on a.EmployeeID = b.ReportsTo)

group by A.EmployeeID, A.FirstName, A.LastName
order by liczba_zamowien desc
/*Napisz polecenie, które oblicza wartość sprzedaży dla każdego
zamówienia w tablicy order details i zwraca wynik posortowany
w malejącej kolejności (wg wartości sprzedaży).*/

select OrderID, round(sum(UnitPrice*Quantity*(1-Discount)),2) as total_price
from [Order Details]
group by OrderID
order by total_price desc

/*-- Zmodyfikuj zapytanie z poprzedniego punktu, tak aby zwraca�o
--pierwszych 10 wierszy
--cena*/

select top 10 with ties OrderID, round(sum(UnitPrice*Quantity*(1-Discount)),2) as total_price
from [Order Details]
group by OrderID
order by total_price desc

/*
Podaj liczbę zamówionych jednostek produktów dla
produktów, dla których productid < 3*/

select productid, sum(quantity)
from [Order Details]
where ProductID < 3 
group by ProductID

/*
Zmodyfikuj zapytanie z poprzedniego punktu, tak aby podawało
liczbę zamówionych jednostek produktu dla wszystkich
produktów
*/

select productid, sum(quantity)
from [Order Details]
group by ProductID
order by productid
/*
Podaj nr zamówienia oraz wartość zamówienia, dla zamówień,
dla których łączna liczba zamawianych jednostek produktów
jest > 250 */

select OrderID, round(sum(UnitPrice*Quantity*(1-Discount)),2) as total_price
from [Order Details]
group by OrderID
having sum(quantity) > 250 


select productid, orderid, quantity
from [Order Details]
group by ProductID
with rollup

use Northwind
SELECT ProductID, OrderID, Quantity
FROM [Order Details]
group by ProductID, OrderID, Quantity
with rollup

select orderid, productid, sum(Quantity)
from [Order Details]
where OrderID > 11070
group by orderid, productid
with cube
order by OrderID, ProductID

/*
Dla każdego pracownika podaj liczbę obsługiwanych przez
niego zamówień*/

select EmployeeID, count(*)
from Orders
group by EmployeeID

/*
Dla każdego spedytora/przewoźnika podaj wartość "opłata za
przesyłkę" przewożonych przez niego zamówień*/

SELECT shipvia,orderid,SUM(freight) AS [opłata za przesyłke]
FROM orders
GROUP BY shipvia,orderid
WITH ROLLUP

/*
Dla każdego spedytora/przewoźnika podaj wartość "opłata za
przesyłkę" przewożonych przez niego zamówień w latach o
1996 do 1997*/

select ShipVia, sum(Freight) as opłata_za_przesyłke
from Orders
where year(shippeddate) between 1996 and 1997
group by shipvia



select ShipVia, orderid, sum(Freight) as opłata_za_przeyłke
from Orders
where year(shippeddate) between 1996 and 1997
group by shipvia,OrderID
order by ShipVia, OrderID

/*
Dla każdego pracownika podaj liczbę obsługiwanych przez
niego zamówień z podziałem na lata i miesiące
*/

select EmployeeID,year(OrderDate) as rok, month(OrderDate) as miesiac, count(*) as liczba_zamówień
from Orders
group by EmployeeID, year(OrderDate), month(OrderDate), year(OrderDate), month(OrderDate)
with rollup


/*
Dla każdej kategorii podaj maksymalną i minimalną cenę
produktu w tej kategorii
*/

select Categoryid ,max(UnitPrice) as max_cena, min(UnitPrice) as min_cena
from Products
group by CategoryID
with rollup
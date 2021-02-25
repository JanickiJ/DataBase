select top 10 * from Products

select top 5 with ties *
from [order details]
order by quantity desc

select *
from Employees

select count(*)
from Products
where UnitPrice between 10.00 and 20.00

select max(UnitPrice)
from Products
where UnitPrice < 20.00

select * from Products

select max(UnitPrice), min(UnitPrice), avg(UnitPrice)
from Products
where QuantityPerUnit like '%bottle%'

select * from Products
where UnitPrice> (select avg(UnitPrice) from Products)

select sum((UnitPrice - Discount)*Quantity) from [Order Details]
where OrderID = 10250

select productid, sum(quantity) as total_q  
from orderhist
group by productid

select * from orderhist

select productid, sum(Quantity)
from [Order Details]
group by ProductID
order by ProductID

select Orderid, max(UnitPrice), min(UnitPrice)
from [Order Details]
group by OrderID
order by OrderID

select count(*)
from [orders]
where year(ShippedDate) = 1997
group by ShipVia


select * from Orders

select ProductID, sum(quantity) as total_quantity
from [Order Details]
group by ProductID
having sum(Quantity) > 1200

select* from [order details]

select OrderID
from [Order Details]
group by OrderID
having count(*) > 5

select CustomerID
from Orders
where year(ShippedDate) = 1998
group by CustomerID
having count(*) > 8

select productid, orderid, sum(quantity) as total_quantity
from orderhist
group by  productid, orderid
with rollup
order by productid, orderid

SELECT orderid, productid, SUM(quantity) AS total_quantity
FROM [Order Details]
WHERE orderid < 10250
GROUP BY orderid, productid
with cube
ORDER BY orderid, productid

select productid,orderid,quantity 
from orderhist
order by productid, orderid


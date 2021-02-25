select CompanyName, Address from Customers
select LastName,HomePhone from Employees
select ProductName, UnitPrice from Products
select CategoryName,Description from Categories
select CompanyName,HomePage from Suppliers


select CompanyName, Address from Customers where City = 'London'
select CompanyName, Address from Customers where Country = 'France' or Country = 'Spain'
select ProductName, UnitPrice from Products where UnitPrice Between 20.00 and 30.00
select ProductName, UnitPrice from Products where CategoryID=(select CategoryID from Categories where CategoryName='meat/poultry')
select CategoryID from Categories where CategoryName = 'meat/poultry'
select ProductName, UnitPrice from Products where CategoryID ='6'
select SupplierID from Suppliers where CompanyName ='Tokyo Traders'
select ProductName, UnitsInStock from Products where SupplierID = 4 
select ProductName from Products where UnitsInStock = 0


select * from Products where QuantityPerUnit like '%bottles%' 
select Title from Employees where LastName like '[B-L]%'
select Title from Employees where LastName like '[BL]%'
select CategoryName from Categories where CategoryName like '%,%'
select * from Categories where CategoryName like '%Store%'

select * from Products where UnitPrice not between 10.00 and 20.00
select * from Products where UnitPrice < 10.00 and UnitPrice >20.00
select ProductName, UnitPrice from Products where UnitPrice between 20.00 and 30.00
select ProductName, UnitPrice from Products where UnitPrice > 20.00 and UnitPrice < 30

select CompanyName, Country from Customers where Country = 'Japan' or Country = 'Italy'
select CompanyName, Country from Customers where Country in ('Japan', 'Italy')
select OrderID, OrderDate, CustomerID from Orders where (ShippedDate is Null or ShippedDate > '1997-10-04') and ShipCountry = 'Argentina'

select CompanyName, Country from Customers order by Country, CompanyName
select CategoryID ,ProductName, UnitPrice from Products order by CategoryID, UnitPrice Desc
select CompanyName, Country from Customers where Country in ('Italy','Japan') order by Country, CompanyName

select distinct country from suppliers order by country
select firstname as First, lastname as Last, employeeID as 'Employeee ID:' from employees
select firstname, lastname, 'Identification number:', employeeid from employees
select orderid, unitprice *1.05 as newunitprice from [Order details]
select firstname + ' ' + lastname as imie_nazwisko from employees

select * from Categories where Description like '%[%]%'
select * from Categories where Description like '%\%%' ESCAPE '\'

select FirstName + ' ' + Lastname as ImieNazwisko,
		'Nr pracownika: ' + CONVERT(varchar(10), EmployeeID)
from Employees
order by 2 

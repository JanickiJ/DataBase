--TABLES, INDEXES, TRIGGERS
create table Categories
(
    CategoryID   int identity,
    CategoryName varchar(30),
    Description  varchar(200) default NULL,
    constraint CategoriesPK
        primary key (CategoryID),
    constraint CategoriesUnique
        unique (CategoryName)
)
go

create index IDXCategories_CategoryName
    on Categories (CategoryName)
go

create table Customers
(
    CustomerID int identity,
    IsCompany  bit default 0 not null,
    Name       varchar(50),
    Email      varchar(30),
    constraint CustomersPK
        primary key (CustomerID),
    constraint CustomersCheck
        check ([Email] like '%@%')
)
go

create table Discounts
(
    DiscountID        int identity,
    [Percent]         decimal(2, 2) not null,
    SingleUse         bit           not null,
    IsForCompanies    bit default 0 not null,
    MinimumPrevOrders int default 0 not null,
    MinimumPrevCost   int default 0 not null,
    Description       varchar(200),
    Weeks             int default 0,
    constraint DiscountsPK
        primary key (DiscountID),
    constraint DiscountCheck
        check ([MinimumPrevCost] >= 0 AND [MinimumPrevOrders] >= 0 AND [Weeks] >= 0 AND [Percent] >= 0)
)
go

create table CustomerDiscounts
(
    CustomerDiscountsID int identity,
    CustomerID          int not null,
    DiscountID          int not null,
    StartDate           date,
    IsAvailable         bit,
    constraint CustomerDiscounts_pk
        primary key nonclustered (CustomerDiscountsID),
    constraint CustomerDiscounts_Customer
        foreign key (CustomerID) references Customers,
    constraint CustomerDiscounts_Discounts
        foreign key (DiscountID) references Discounts
)
go

create index IDXCustomerDiscounts_StartDate
    on CustomerDiscounts (StartDate)
go

create table Dishes
(
    DishID    int identity,
    DishName  varchar(30)   not null,
    UnitPrice decimal(8, 2) not null,
    isVegan   bit default 0 not null,
    constraint DishesPK
        primary key (DishID),
    constraint DishesCheck
        check ([UnitPrice] >= 0)
)
go

create index IDXDishes_DishName
    on Dishes (DishName)
go

create table Employess
(
    EmployeeID int identity,
    FirstName  varchar(30) not null,
    LastName   varchar(30) not null,
    Title      varchar(30) default NULL,
    Address    varchar(40) default NULL,
    City       varchar(30) default NULL,
    PostalCode varchar(30) default NULL,
    constraint EmployessPK
        primary key (EmployeeID),
    constraint EmployessCheck
        check ([PostalCode] like '%-%')
)
go

create index IDXEmployess_Name
    on Employess (FirstName, LastName)
go

create table Products
(
    ProductID   int identity,
    ProductName varchar(30) not null,
    CategoryID  int         not null,
    constraint ProductsPK
        primary key (ProductID),
    constraint ProductsUnique
        unique (ProductName),
    constraint Products_Categories
        foreign key (CategoryID) references Categories
)
go

create table DishDetails
(
    DishID    int not null,
    ProductID int not null,
    Quantity  int,
    constraint DishDetailsPK
        primary key (DishID, ProductID),
    constraint DishDetails_Dishes
        foreign key (DishID) references Dishes,
    constraint DishDetails_Products
        foreign key (ProductID) references Products
)
go

create index IDXProducts_CategoryID
    on Products (CategoryID)
go

create index IDXProducts_ProductName
    on Products (ProductName)
go

create table ReservationRequirements
(
    RequirementID     int identity,
    MinimumOrderCost  int default 0 not null,
    MinimumPrevOrders int default 0 not null,
    MinimumPrevCost   int default 0 not null,
    constraint ReservationRequirementsPK
        primary key (RequirementID),
    constraint ReservationRequirementsCheck
        check ([MinimumPrevOrders] >= 0 AND [MinimumPrevCost] >= 0 AND [MinimumOrderCost] >= 0)
)
go

create table Restaurants
(
    RestaurantID   int identity,
    RestaurantName varchar(40),
    Address        varchar(40),
    City           varchar(30),
    PostalCode     varchar(30),
    constraint RestaurantPK
        primary key (RestaurantID),
    constraint RestaurantCheck
        check ([PostalCode] like '%-%')
)
go

create table Magazine
(
    RestaurantID int not null,
    ProductID    int not null,
    UnitsInStock int,
    constraint MagazinePK
        primary key (RestaurantID, ProductID),
    constraint Magazine_Products
        foreign key (ProductID) references Products,
    constraint Magazine_Restaurants
        foreign key (RestaurantID) references Restaurants
)
go

create table Menu
(
    MenuID       int identity,
    StartDate    date,
    EndDate      date,
    RestaurantID int,
    Time         varchar default 'n' not null,
    constraint MenuPK
        primary key (MenuID),
    constraint Menu_Restaurant
        foreign key (RestaurantID) references Restaurants,
    constraint MenuCheck
        check ([StartDate] <= [EndDate]),
    constraint MenuTimeCheck
        check ([Time] = 'f' OR [Time] = 'n' OR [Time] = 'p')
)
go

create index IDXMenu_RestaurantID
    on Menu (RestaurantID)
go

create table MenuDetails
(
    MenuID int not null,
    DishID int not null,
    constraint MenuDetailsPK
        primary key (MenuID, DishID),
    constraint MenuDetails_Dishes
        foreign key (DishID) references Dishes,
    constraint MenuDetails_Menu
        foreign key (MenuID) references Menu
)
go

create table Orders
(
    OrderID         int identity,
    CustomerID      int                        not null,
    EmployeeID      int                        not null,
    RestaurantID    int                        not null,
    OrderDate       datetime default getdate() not null,
    RealizationDate datetime,
    Price           decimal(6, 2),
    FinePaid        decimal(6, 2),
    isOnline        bit                        not null,
    constraint OrdersPK
        primary key (OrderID),
    constraint Orders_Customers
        foreign key (CustomerID) references Customers,
    constraint Orders_Employess
        foreign key (EmployeeID) references Employess,
    constraint Orders_Restaurant
        foreign key (RestaurantID) references Restaurants,
    constraint OrdersCheck
        check ([Price] >= 0 AND [FinePaid] >= 0)
)
go

create table OrderDetails
(
    OrderID int not null,
    DishID  int not null,
    constraint OrderDetailsPK
        primary key (OrderID, DishID),
    constraint OrderDetails_Dishes
        foreign key (DishID) references Dishes,
    constraint OrderDetails_Order
        foreign key (OrderID) references Orders
)
go

create index IDXOrders_OrderDate
    on Orders (OrderDate)
go

create index IDXOrders_CustomerID
    on Orders (CustomerID)
go

create index IDXOrders_EmployeeID
    on Orders (EmployeeID)
go

create index IDXOrders_RestaurantID
    on Orders (RestaurantID)
go

create trigger UpdateCustomerDiscounts
    on Orders
    after update as
begin
    declare @PrevCost int, @PrevOrders int, @CustomerID int, @OrderID int
    set @CustomerID = (select CustomerID FROM inserted)
    set @OrderID = (select OrderID FROM inserted)
    set @PrevCost = (select sum(Price) from Orders where CustomerID = @CustomerID)
    set @PrevOrders = (select sum(OrderID) from Orders where CustomerID = @CustomerID)

    if update(Price)
        if (select IsCompany from Customers where CustomerID = @CustomerID) = 0
            --Discount 1
            if @PrevCost > (select MinimumPrevCost from Discounts where DiscountID = 1) and
               @PrevOrders > (select MinimumPrevOrders from Discounts where DiscountID = 1)
                insert into CustomerDiscounts values (@CustomerID, 1, GETDATE(), null)

            --Discount 2
            if @PrevCost > (select sum(MinimumPrevCost) from Discounts where DiscountID in (1, 2)) and
               @PrevOrders > (select sum(MinimumPrevOrders) from Discounts where DiscountID in (1, 2))
                insert into CustomerDiscounts values (@CustomerID, 2, GETDATE(), null)

            --Discount 3
            if @PrevCost > (select sum(MinimumPrevCost) from Discounts where DiscountID = 3)
                and not EXISTS(select * from CustomerDiscounts where @CustomerID = CustomerID and DiscountID = 3)
                insert into CustomerDiscounts values (@CustomerID, 3, GETDATE(), default)

            --Discount 4
            if @PrevCost > (select sum(MinimumPrevCost) from Discounts where DiscountID = 4)
                and not EXISTS(select * from CustomerDiscounts where @CustomerID = CustomerID and DiscountID = 4)
                insert into CustomerDiscounts values (@CustomerID, 4, GETDATE(), default)

        --For Companies
        if (select IsCompany from Customers where CustomerID = @CustomerID) = 1

            --Discount 5
            exec addDiscountForCompanies @OrderID = @OrderID, @CustomerID = @CustomerID, @DiscountID = 5

            --Discount 6
            exec addDiscountForCompanies @OrderID = @OrderID, @CustomerID = @CustomerID, @DiscountID = 6


end
go

create trigger UpdateMagazine
    on Orders
    after update as
begin
    declare @OrderID int, @RestaurantID int, @Quantity int, @Counter int, @ProductID int
    set @OrderID = (select OrderID FROM inserted)
    set @RestaurantID = (select RestaurantID FROM inserted)


    select ProductID as ProductID, sum(Quantity) as Quantity
    into #temporary
    from DishDetails
             inner join Dishes D on D.DishID = DishDetails.DishID
             inner join OrderDetails OD on D.DishID = OD.DishID
             inner join Orders O on O.OrderID = OD.OrderID
    where O.OrderID = @OrderID
    group by ProductID

    select @Counter = (-1) + count(*) from #temporary

    while @Counter >= 0
        begin
            set @ProductID =
                    (select ProductID from #temporary order by ProductID offset @Counter rows fetch next 1 rows only)
            set @Quantity =
                    (select Quantity from #temporary order by ProductID offset @Counter rows fetch next 1 rows only)
            update Magazine set UnitsInStock -= @Quantity where ProductID = @ProductID
            set @Counter -=1
        end


    If (OBJECT_ID('tempdb..#temporary') Is Not Null)
        drop table #temporary

end
go

create table Tables
(
    TableID      int identity,
    RestaurantID int           not null,
    IsAvailable  bit default 1 not null,
    constraint TablesPK
        primary key (TableID),
    constraint Tables_Restaurant
        foreign key (RestaurantID) references Restaurants
)
go

create table Reservations
(
    ReservationID int identity,
    RestaurantID  int           not null,
    TableID       int,
    StartDate     datetime      not null,
    EndDate       datetime      not null,
    CustomerID    int           not null,
    IsConfirmed   bit default 0 not null,
    RequirementID int           not null,
    OrderID       int,
    constraint ReservationsPK
        primary key (ReservationID),
    constraint Reservation_Tables
        foreign key (TableID) references Tables,
    constraint Reservations_Customers
        foreign key (CustomerID) references Customers,
    constraint Reservations_Orders
        foreign key (OrderID) references Orders,
    constraint Reservations_ReservationsRequirement
        foreign key (RequirementID) references ReservationRequirements,
    constraint Reservations_Restaurant
        foreign key (RestaurantID) references Restaurants,
    constraint ReservationsCheck
        check ([StartDate] <= [EndDate])
)
go

create index IDXReservations_Date
    on Reservations (StartDate, EndDate)
go

create index IDXReservations_OrderID
    on Reservations (OrderID)
go

create index IDXReservations_RequirementID
    on Reservations (RequirementID)
go

create index IDXReservations_CustomerID
    on Reservations (CustomerID)
go

create index IDXReservations_TableID
    on Reservations (TableID)
go

create index IDXReservations_RestaurantID
    on Reservations (RestaurantID)
go

create index IDXTables_RestaurantID
    on Tables (RestaurantID)
go

CREATE VIEW [dbo].[v_AllNeededProductsForMenus]
AS
SELECT DISTINCT DD.ProductID
from MenuDetails MD
         INNER JOIN DishDetails DD on MD.DishID = DD.DishID
go

create view [dbo].[v_CountOfDishesOrdered]
as
select DishID 'DishID', COUNT(OrderID) 'Counted occurrences'
from OrderDetails
group by DishID
go

create view [dbo].[v_CurrentReservations]
as
select *
from Reservations
where day(getdate()) = day(StartDate)
go


--VIEWS


CREATE VIEW [dbo].[v_NotAvailableProductsForMenus]
AS
SELECT MD.MenuID, DD.ProductID
from MenuDetails MD
         INNER JOIN DishDetails DD ON MD.DishID = DD.DishID
         INNER JOIN (select ProductID from Magazine where UnitsInStock = 0) NA ON DD.ProductID = NA.ProductID
group by MenuID, DD.ProductID
go

create view [dbo].[v_Orders]
as
select *
from Orders
go

create view [dbo].[v_veganDishes]
as
select DishName, UnitPrice
from Dishes
where isVegan = 1
go


--PROCEDURES


CREATE PROCEDURE [dbo].[addCategory] @CategoryName varchar(30),
                                     @Description varchar(200)=null
AS
BEGIN
    SET NOCOUNT ON

    BEGIN TRY
        BEGIN TRANSACTION
            IF @CategoryName IS NULL OR LEN(@CategoryName) < 3
                THROW 51000, '@CategoryName is null or too short',1
            INSERT INTO Categories
            values (@CategoryName, @Description)
        COMMIT TRANSACTION
    end try
    begin catch
        ROLLBACK TRANSACTION
        THROW
    end catch
end
go

CREATE PROCEDURE [dbo].[addCustomer] @Name varchar(50),
                                     @Email varchar(30),
                                     @IsCompany bit= FALSE
AS
BEGIN
    SET NOCOUNT ON

    BEGIN TRY
        BEGIN TRANSACTION
            IF @Email NOT LIKE '^([a-zA-Z0-9_\-\.]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,5})$'
                THROW 51000,'Provide real email address',1
            INSERT Customers
            values (@IsCompany, @Name, @Email)
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        THROW
    end catch
END
go

CREATE PROCEDURE [dbo].[addCustomerDiscount] @CustomerID int,
                                             @DiscountID int,
                                             @StartDate date
AS
BEGIN
    SET NOCOUNT ON

    BEGIN TRY
        BEGIN TRANSACTION
            IF (select CustomerID from Customers where CustomerID = @CustomerID) IS NULL
                THROW 51000,'Nie ma klienta o takim CustomerID',1
            IF (select DiscountID from Discounts where DiscountID = @DiscountID) IS NULL
                THROW 51000,'Nie ma znizki o takim DiscountID',1
            INSERT INTO CustomerDiscounts
            values (@CustomerID, @DiscountID, @StartDate,  default)
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        THROW
    end catch
END
go

CREATE PROCEDURE [dbo].[addDiscount] @Percent decimal(2, 2),
                                     @SingleUse bit,
                                     @IsForCompanies bit= FALSE,
                                     @MinimumPrevOrders int=0,
                                     @MinimumPrevCost int=0,
                                     @Description varchar(200)='',
                                     @Weeks int=0
AS
BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        BEGIN TRANSACTION
            IF @MinimumPrevOrders < 1
                THROW 51000,'Number of previous orders must be greater than 0',1
            IF @MinimumPrevCost < 1
                THROW 51000,'Number of previous orders cost must be greater than 0',1
            IF @Weeks < 1
                THROW 51000,'Number of weeks must be greater than 0',1
            INSERT INTO Discounts
            values (@Percent, @SingleUse, @IsForCompanies, @MinimumPrevOrders, @MinimumPrevCost, @Description, @Weeks)
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        THROW
    end catch
end
go

CREATE PROCEDURE addDiscountForCompanies(@CustomerID int, @DiscountID int)
AS
BEGIN
    declare @lastDiscount date, @duration int, @PrevCost int, @PrevOrders int
    set @lastDiscount = (select top 1 StartDate
                         from CustomerDiscounts
                                  inner join Discounts D2 on D2.DiscountID = CustomerDiscounts.DiscountID
                         where @CustomerID = CustomerDiscounts.CustomerID
                           and D2.DiscountID = @DiscountID
                         order by StartDate desc)

    set @duration = (select Weeks from Discounts where DiscountID = @DiscountID)

    if (@lastDiscount is null or (datediff(week, getdate(), @lastDiscount)) > @duration)
        set @PrevCost = (select sum(Price)
                         from Orders
                         where CustomerID = @CustomerID and RealizationDate > dateadd(week, @duration, getdate()))
    set @PrevOrders = (select count(OrderID)
                       from Orders
                       where CustomerID = @CustomerID
                         and RealizationDate > dateadd(week, @duration, getdate()))

    if @PrevCost > (select MinimumPrevCost from Discounts where DiscountID = @DiscountID)
        and @PrevOrders > (select MinimumPrevCost from Discounts where DiscountID = @DiscountID)
        insert into CustomerDiscounts values (@CustomerID, @DiscountID, GETDATE(), default)


    else
        if (datediff(week, getdate(), @lastDiscount) < @duration)
            set @PrevCost = (select sum(Price)
                             from Orders
                             where CustomerID = @CustomerID and (RealizationDate between @lastDiscount and getdate()))
    set @PrevOrders = (select count(OrderID)
                       from Orders
                       where CustomerID = @CustomerID
                         and (RealizationDate between @lastDiscount and getdate()))

    if @PrevCost > (select MinimumPrevCost from Discounts where DiscountID = @DiscountID)
        and @PrevOrders > (select MinimumPrevCost from Discounts where DiscountID = @DiscountID)
        insert into CustomerDiscounts
        values (@CustomerID, @DiscountID, dateadd(week, @duration, @lastDiscount), default)

end
go

CREATE PROCEDURE [dbo].[addDish] @DishName varchar(30), @UnitPrice decimal(8, 2), @IsVegan bit=0
AS
BEGIN
    SET NOCOUNT ON

    BEGIN TRY
        BEGIN TRANSACTION
            IF @DishName IS NULL OR LEN(@DishName) < 3
                THROW 51000,'@DishName is null or too short',1
            INSERT Dishes
            values (@DishName, @UnitPrice, @IsVegan)
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        THROW
    end catch
end
go

CREATE PROCEDURE [dbo].[addDishDetails] @DishID int, @ProductID int, @Quantity int
AS
BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        BEGIN TRANSACTION
            IF (select DishID from Dishes where DishID = @DishID) IS NULL
                THROW 51000,'There is no such dish',1
            IF (select ProductID from Products where ProductID = @ProductID) IS NULL
                THROW 51000,'There is no such product',1
            INSERT INTO DishDetails
            values (@DishID, @ProductID, @Quantity)
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        THROW
    end catch
end
go

CREATE PROCEDURE [dbo].[addEmployee] @FirstName varchar(30),
                                     @LastName varchar(30),
                                     @Title varchar(30)=null,
                                     @Address varchar(40)=null,
                                     @City varchar(30)=null,
                                     @PostalCode varchar(30)=null
AS
BEGIN
    SET NOCOUNT ON

    BEGIN TRY
        BEGIN TRANSACTION
            IF LEN(@FirstName) < 3
                THROW 51000,'@FirstName is too short',1
            IF LEN(@LastName) < 3
                THROW 51000,'@LastName is too short',1
            INSERT Employess
            values (@FirstName, @LastName, @Title, @Address, @City, @PostalCode)
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        THROW
    end catch
end
go

CREATE PROCEDURE [dbo].[addMenu] @StartDate date,
                                 @EndDate date,
                                 @RestaurantID int,
                                 @Time varchar(1)='n'
AS
BEGIN
    SET NOCOUNT ON

    BEGIN TRY
        BEGIN TRANSACTION
            IF @EndDate < getdate()
                THROW 51000,'You cant add menu into past',1
            IF (select RestaurantID from Restaurants where RestaurantID = @RestaurantID) IS NULL
                THROW 51000,'There is no such restaurant',1
            INSERT [Menu]
            values (@StartDate, @EndDate, @RestaurantID, @Time)
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        THROW
    end catch
end
go

CREATE PROCEDURE [dbo].[addMenuDetails] @MenuID int,
                                        @DishID int
AS
BEGIN
    SET NOCOUNT ON

    BEGIN TRY
        BEGIN TRANSACTION
            IF (SELECT MenuID from Menu where MenuID = @MenuID) IS NULL
                THROW 51000,'There is no such menu',1
            IF (SELECT DishID from Dishes where DishID = @DishID) IS NULL
                THROW 51000,'There is no such dish',1
            IF @DishID IN (select MD.DishID
                           from [dbo].showMenusInLastMonth() MLM
                                    inner join MenuDetails MD on MLM.MenuID = MD.MenuID)
                THROW 51000,'This dish was in menu during this month',1
            INSERT [MenuDetails]
            values (@MenuID, @DishID)
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        THROW
    end catch
end
go

CREATE PROCEDURE [dbo].[addOrder] @CustomerID int,
                                  @EmployeeID int,
                                  @RestaurantID int,
                                  @isOnline bit=0
AS
BEGIN
    SET NOCOUNT ON

    BEGIN TRY
        BEGIN TRANSACTION
            IF @CustomerID IS NOT NULL AND (SELECT CustomerID from Customers where CustomerID = @CustomerID) IS NULL
                THROW 51000,'There is no such customer',1
            IF (SELECT EmployeeID from Employess where EmployeeID = @EmployeeID) IS NULL
                THROW 51000,'There is no such employee',1
            IF (SELECT RestaurantID from Restaurants where RestaurantID = @RestaurantID) IS NULL
                THROW 51000,'There is no such restaurant',1
            INSERT INTO Orders(CustomerID, EmployeeID, RestaurantID, isOnline)
            values (@CustomerID, @EmployeeID, @RestaurantID, @isOnline)
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        THROW
    end catch
end
go

CREATE PROCEDURE [dbo].[addOrderDetails] @OrderID int,
                                         @DishID int
AS
BEGIN
    SET NOCOUNT ON

    BEGIN TRY
        BEGIN TRANSACTION
            IF (SELECT OrderID from Orders where OrderID = @OrderID) IS NULL
                THROW 51000,'There is no such order',1
            IF (SELECT DishID from Dishes where DishID = @DishID) IS NULL
                THROW 51000,'There is no such dish',1
            INSERT [OrderDetails]
            values (@OrderID, @DishID)
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        THROW
    end catch
end
go

CREATE PROCEDURE [dbo].[addProduct] @ProductName varchar(30),
                                    @CategoryID int
AS
BEGIN
    SET NOCOUNT ON

    BEGIN TRY
        BEGIN TRANSACTION
            IF LEN(@ProductName) < 3
                THROW 51000,'Provide valid name', 1
            IF (select CategoryID from Categories where CategoryID = @CategoryID) IS NULL
                THROW 51000,'There is no such category',1
            INSERT Products
            values (@ProductName, @CategoryID)
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        THROW
    end catch
end
go

CREATE PROCEDURE [dbo].[addProductToMagazine] @RestaurantID int,
                                              @ProductID int,
                                              @UnitsInStock int
AS
BEGIN
    SET NOCOUNT ON

    BEGIN TRY
        BEGIN TRANSACTION
            DECLARE @Quantity int

            IF (SELECT RestaurantID from Restaurants where RestaurantID = @RestaurantID) IS NULL
                THROW 51000,'There is no such restaurant',1
            IF (select ProductID from Products where ProductID = @ProductID) IS NULL
                THROW 51000,'There is no such product',1
            SET @Quantity =
                    (select UnitsInStock from Magazine where RestaurantID = @RestaurantID and ProductID = @ProductID)
            IF @Quantity IS NOT NULL
                IF @Quantity - @UnitsInStock < 0
                    THROW 51000, 'You are decreasing more Units than there are in magazine',1
                ELSE
                    UPDATE Magazine
                    SET UnitsInStock=@Quantity + @UnitsInStock
                    where RestaurantID = @RestaurantID
                      and ProductID = @ProductID
            ELSE
                IF @UnitsInStock < 0
                    THROW 51000, 'You can not decrease product that was not available before',1
                ELSE
                    UPDATE Magazine
                    SET UnitsInStock=@UnitsInStock
                    where RestaurantID = @RestaurantID
                      and ProductID = @ProductID
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        THROW
    end catch
end
go

CREATE PROCEDURE [dbo].[addReservation] @RestaurantID int,
                                        @TableID int,
                                        @StartDate datetime,
                                        @EndDate datetime,
                                        @CustomerID int,
                                        @OrderID int,
                                        @RequirementID int
AS
BEGIN
    SET NOCOUNT ON

    BEGIN TRY
        BEGIN TRANSACTION
            IF (select RestaurantID from Restaurants where RestaurantID = @RestaurantID) IS NULL
                THROW 51000,'There is no such restaurant',1
            IF (select TableID from Tables where TableID = @TableID) IS NULL
                THROW 51000,'There is no such table',1
            IF (select IsAvailable from Tables where TableID = @TableID and IsAvailable = 0) IS NOT NULL
                THROW 51000,'You have selected unavailable table',1
            IF (select CustomerID from Customers where CustomerID = @CustomerID) IS NULL
                THROW 51000, 'There is no such customer',1
            IF (select RequirementID from ReservationRequirements where RequirementID = @RequirementID) IS NULL
                THROW 51000, 'There is no requirement with such ID',1
            INSERT INTO Reservations
            VALUES (@RestaurantID, @TableID, @StartDate, @EndDate, @CustomerID, 0, @RequirementID, @OrderID)
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        THROW
    end catch
end
go

CREATE PROCEDURE [dbo].[addReservationRequirement] @MinimumOrderCost int=0,
                                                   @MinimumPrevOrders int=0,
                                                   @MinimumPrevCost int=0
AS
BEGIN
    SET NOCOUNT ON

    BEGIN TRY
        BEGIN TRANSACTION
            IF @MinimumPrevOrders < 0 or @MinimumPrevCost < 0 or @MinimumOrderCost < 0
                THROW 51000,'Provide positive numbers',1
            INSERT ReservationRequirements
            values (@MinimumOrderCost, @MinimumPrevOrders, @MinimumPrevCost)
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        THROW
    end catch
end
go

CREATE PROCEDURE [dbo].[addRestaurant] @RestaurantName varchar(40),
                                       @Address varchar(40),
                                       @City varchar(30),
                                       @PostalCode varchar(30)
AS
BEGIN
    SET NOCOUNT ON
    INSERT Restaurants
    values (@RestaurantName, @Address, @City, @PostalCode)
end
go

CREATE PROCEDURE [dbo].[addTable] @RestaurantID int,
                                  @IsAvailable bit=1
AS
BEGIN
    SET NOCOUNT ON

    BEGIN TRY
        BEGIN TRANSACTION
            IF (select RestaurantID from Restaurants where RestaurantID = @RestaurantID) IS NULL
                THROW 51000,'There is no such restaurant',1
            INSERT Tables
            values (@RestaurantID, @IsAvailable)
        COMMIT TRANSACTION
    END TRY
    begin catch
        ROLLBACK TRANSACTION
        THROW
    end catch
end
go

CREATE PROCEDURE [dbo].[changeTablesAvailability] @TableID int, @availability bit
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
            SET NOCOUNT ON

            IF (select TableID from Tables where TableID = @TableID) IS NULL
                THROW 51000,'There is no such table',1
            UPDATE Tables
            SET IsAvailable=@availability
            WHERE TableID = @TableID
        COMMIT TRANSACTION
    end try
    begin catch
        ROLLBACK TRANSACTION
        THROW
    end catch
end
go


--FUNCTIONS


CREATE FUNCTION [dbo].[checkIfNewMenuIsValid](@MenuID int)
    RETURNS BIT
AS
BEGIN
    DECLARE @numberOfDishes int,@numberOfCommonDishes int
    set @numberOfDishes = (select COUNT(*) from [dbo].getCurrentMenu())
    set @numberOfCommonDishes = (select COUNT(*)
                                 from [dbo].getCurrentMenu() M
                                          inner join [dbo].getMenuFromID(@MenuID) NM on NM.DishID = M.DishID)
    IF @numberOfCommonDishes / @numberOfDishes >= 1 / 2
        RETURN 0
    RETURN 1
end
go

CREATE FUNCTION [dbo].[checkOnlineOrderRequirements](@OrderID int)
    RETURNS bit
AS
BEGIN
    DECLARE @minPrevCost int,@minOrderCost int, @minPrevOrders int

    set @minPrevCost = (select max(MinimumPrevCost) from ReservationRequirements)
    set @minOrderCost = (select max(MinimumOrderCost) from ReservationRequirements)
    set @minPrevOrders = (select max(MinimumPrevOrders) from ReservationRequirements)

    IF ([dbo].computePrice(@OrderID) < @minOrderCost)
        RETURN 0
    IF (select COUNT(OrderID) from Orders where [dbo].computePrice(OrderID) >= @minPrevCost) < @minPrevOrders
        RETURN 0
    RETURN 1
end
go

CREATE FUNCTION [dbo].[checkReservationRequirements](@TableID int,
                                                     @StartDate datetime,
                                                     @EndDate datetime)
    returns bit
AS
BEGIN
    IF (SELECT ReservationID
        from Reservations
        where TableID = @TableID and @StartDate BETWEEN StartDate AND EndDate) IS NOT NULL
        RETURN 0
    IF (SELECT ReservationID
        from Reservations
        where TableID = @TableID and @EndDate BETWEEN StartDate AND EndDate) IS NOT NULL
        RETURN 0
    RETURN 1
end
go

CREATE PROCEDURE computeDiscountedPrice @OrderID int
AS
BEGIN
    DECLARE @CustomerID int, @IsCompany bit, @Percent decimal(8, 2), @StartDate date

    set @CustomerID = (select CustomerID from Orders where OrderID = @OrderID)
    set @IsCompany = (select IsCompany from Customers where CustomerID = @CustomerID)
    set @Percent = 0
    IF (@IsCompany = 0)
        --Discount 1
        IF EXISTS(select * from CustomerDiscounts where DiscountID = 1)
            set @Percent = (select [Percent] from Discounts where DiscountID = 1)
    --Discount 2
    IF EXISTS(select * from CustomerDiscounts where DiscountID = 2)
        set @Percent += (select [Percent] from Discounts where DiscountID = 2)
    --Discount 3
    IF EXISTS(select *
              from CustomerDiscounts
                       inner join Discounts D on CustomerDiscounts.DiscountID = D.DiscountID
              where CustomerID = @CustomerID
                and D.DiscountID = 3
                and IsAvailable = 1
                and datediff(week, getdate(), StartDate) < Weeks)
        set @Percent += (select [Percent] from Discounts where DiscountID = 2)
    update CustomerDiscounts set IsAvailable = 0 where CustomerID = @CustomerID and DiscountID = 3 and IsAvailable = 1
    --Discount 4
    IF EXISTS(select *
              from CustomerDiscounts
                       inner join Discounts D on CustomerDiscounts.DiscountID = D.DiscountID
              where CustomerID = @CustomerID
                and D.DiscountID = 4
                and IsAvailable = 1
                and datediff(week, getdate(), StartDate) < Weeks)
        set @Percent += (select [Percent] from Discounts where DiscountID = 4)
    update CustomerDiscounts set IsAvailable = 0 where CustomerID = @CustomerID and DiscountID = 4 and IsAvailable = 1

    IF (@IsCompany = 1)
        --Discount 5
        IF EXISTS(select *
                  from CustomerDiscounts
                           inner join Discounts D on CustomerDiscounts.DiscountID = D.DiscountID
                  where CustomerID = @CustomerID
                    and D.DiscountID = 5
                    and IsAvailable = 1
                    and datediff(week, getdate(), StartDate) < Weeks)
            set @StartDate = (select top 1 StartDate
                              from CustomerDiscounts
                                       inner join Discounts D on CustomerDiscounts.DiscountID = D.DiscountID
                              where CustomerID = @CustomerID
                                and D.DiscountID = 5
                                and IsAvailable = 1
                                and datediff(week, getdate(), StartDate) < Weeks
                              order by StartDate desc)

    set @Percent += [dbo].[countDiscountsInRowRec](@CustomerID, @StartDate, 1) *
                    (select [Percent] from Discounts where DiscountID = 6)


    --Discount 6
    IF EXISTS(select *
              from CustomerDiscounts
                       inner join Discounts D on CustomerDiscounts.DiscountID = D.DiscountID
              where CustomerID = @CustomerID
                and D.DiscountID = 6
                and IsAvailable = 1
                and datediff(week, getdate(), StartDate) < Weeks)
        set @Percent = (select [Percent] from Discounts where DiscountID = 6)

    update Orders set Price = ([dbo].[computePrice](@OrderID) * (1 - @Percent)) where OrderID = @OrderID


end
go

CREATE FUNCTION [dbo].[computePrice](@OrderID int)
    RETURNS decimal(8, 2)
AS
BEGIN
    RETURN (select SUM(UnitPrice)
            from Dishes
            where DishID in (select DishID from OrderDetails where OrderID = @OrderID))
END
go

CREATE OR ALTER PROCEDURE confirmReservation @ReservationID int
AS
BEGIN
    SET NOCOUNT ON
    DECLARE @bool1 bit,@bool2 bit, @OrderID int,@CustomerID int,@TableID int,@StartDate datetime,@EndDate datetime
    set @OrderID = (select OrderID from Reservations where ReservationID = @ReservationID)
    set @CustomerID = (select CustomerID from Reservations where ReservationID = @ReservationID)
    set @bool1 = [dbo].[checkOnlineOrderRequirements]( @CustomerID)
    set @TableID = (select TableID from Reservations where ReservationID = @ReservationID)
    set @StartDate = (select StartDate from Reservations where ReservationID = @ReservationID)
    set @EndDate = (select EndDate from Reservations where ReservationID = @ReservationID)
    set @bool2 = [dbo].[checkReservationRequirements](@TableID, @StartDate, @EndDate)
    IF @bool1 = 1 and @bool2 = 1
        UPDATE Reservations
        SET IsConfirmed=1
        WHERE ReservationID = @ReservationID
    ELSE
        EXEC deleteOrderFromDatabase @OrderID
    DELETE
    FROM Reservations
    where ReservationID = @ReservationID
end
go

CREATE FUNCTION [dbo].[countDiscountsInRowRec](@CustomerID int,
                                               @StartDate date,
                                               @Counter int)
    returns int
AS
BEGIN
    declare @newDate date
    IF NOT EXISTS(select StartDate
                  from CustomerDiscounts
                  where CustomerID = @CustomerID
                    and DiscountID = 5
                    and datediff(month, @StartDate, StartDate) between 0 and 1)
        return @Counter

    set @newDate = (select top 1 StartDate
                    from CustomerDiscounts
                    where CustomerID = 2
                      and DiscountID = 5
                      and (datediff(month, '2000-12-11', StartDate) < 1)
                    order by StartDate)

    return [dbo].[countDiscountsInRowRec](@CustomerID, @StartDate, @Counter + 1)

end
go

CREATE PROCEDURE [dbo].[deleteDishFromMenu] @MenuID int, @DishID int
AS
BEGIN
    DELETE
    FROM MenuDetails
    WHERE MenuID = @MenuID
      and DishID = @DishID
end
go

CREATE PROCEDURE [dbo].[deleteOrderFromDatabase] @OrderID int
AS
BEGIN
    DELETE
    FROM OrderDetails
    where OrderID = @OrderID

    DELETE
    FROM Orders
    where OrderID = @OrderID
end
go

create procedure [dbo].[fillOrderInformation] @OrderID int, @RealizationDate datetime=null, @FinePaid decimal(6, 2)=null
as
begin
    SET NOCOUNT ON

    BEGIN TRY
        BEGIN TRANSACTION
            IF (select OrderID from Orders where OrderID = @OrderID) IS NULL
                THROW 51000,'There is no such order',1
            IF @RealizationDate IS NOT NULL
                UPDATE Orders
                SET RealizationDate=@RealizationDate
                where OrderID = @OrderID
            IF @FinePaid IS NOT NULL
                UPDATE Orders
                SET FinePaid=@FinePaid
                where OrderID = @OrderID
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        THROW
    end catch
end
go

create function [dbo].[generateCustomerReportOrders](@CustomerID int)
    returns table
        as return
        select OrderID, RestaurantName, RealizationDate, Price
        from Orders
                 inner join Restaurants R2 on Orders.RestaurantID = R2.RestaurantID
        where Orders.CustomerID = @CustomerID
go

create function [dbo].[generateInvoiceFromOneMonth](@CustomerID int)
    returns table
        as return select O.OrderID, C.Name, O.RestaurantID, O.Price, O.isOnline, O.OrderDate
                  from Orders O
                           inner join Customers C on C.CustomerID = O.CustomerID
                  where O.CustomerID = @CustomerID
                    and C.IsCompany = 1
                    and datediff(month, O.OrderDate, getdate()) < 1
go

create function [dbo].[generateInvoiceOfOneOrder](@CustomerID int, @OrderID int)
    returns table
        as return select OrderID, C.Name, RestaurantID, Price, isOnline, OrderDate
                  from Orders
                           inner join Customers C on Orders.CustomerID = C.CustomerID
                  where Orders.CustomerID = @CustomerID
                    and Orders.OrderID = @OrderID
                    and C.IsCompany = 1
go

create function [dbo].[generateMonthReportClient](@CustomerID int)
    returns table
        as return select OrderID,
                         [dbo].computePrice(OrderID) as 'original price',
                         Price                       as 'price after discounts',
                         OrderDate
                  from Orders
                  where CustomerID = @CustomerID
                    and DATEDIFF(month, RealizationDate, getdate()) < 1
go

create function [dbo].[generateMonthReportDiscounts]()
    returns table
        as return select CustomerID, DiscountID, StartDate
                  from CustomerDiscounts
                  where datediff(month, StartDate, getdate()) < 1
                    and IsAvailable = 1
go

create function [dbo].[generateMonthReportMenus]()
    returns table
        as return select M.MenuID, M.StartDate, MD.DishID
                  from Menu M
                           inner join MenuDetails MD on M.MenuID = MD.MenuID
                  where datediff(month, StartDate, getdate()) < 1
go

create function [dbo].[generateMonthReportTables]()
    returns table
        as return select TableID, StartDate, CustomerID
                  from Reservations
                  where datediff(month, StartDate, getdate()) < 1
go

create function [dbo].[generateWeekReportClient](@CustomerID int)
    returns table
        as return select OrderID,
                         [dbo].computePrice(OrderID) as 'original price',
                         Price                       as 'price after discounts',
                         OrderDate
                  from Orders
                  where CustomerID = @CustomerID
                    and DATEDIFF(week, RealizationDate, getdate()) < 1
go

create function [dbo].[generateWeekReportDiscounts]()
    returns table
        as return select CustomerID, DiscountID, StartDate
                  from CustomerDiscounts
                  where datediff(week, StartDate, getdate()) < 1
                    and IsAvailable = 1
go

create function [dbo].[generateWeekReportMenus]()
    returns table
        as return select M.MenuID, M.StartDate, MD.DishID
                  from Menu M
                           inner join MenuDetails MD on M.MenuID = MD.MenuID
                  where datediff(week, StartDate, getdate()) < 1
go

create function [dbo].[generateWeekReportTables]()
    returns table
        as return select TableID, StartDate, CustomerID
                  from Reservations
                  where datediff(week, StartDate, getdate()) < 1
go

CREATE
    FUNCTION [dbo].[getCurrentMenu]()
    RETURNS TABLE
        AS
        RETURN SELECT MenuID, DishID
               from MenuDetails
               where MenuID = (select MenuID from Menu where Time = 'n')
go

CREATE FUNCTION [dbo].[getMenuFromID](@MenuID int)
    RETURNS TABLE
        AS RETURN SELECT *
                  from MenuDetails
                  where MenuID = @MenuID
go

CREATE FUNCTION [dbo].[showCurrentMenus](@RestaurantID int)
    RETURNS TABLE
        AS RETURN
        select MenuID
        from Menu
        where RestaurantID = @RestaurantID
          and getdate() BETWEEN StartDate and EndDate
go

CREATE FUNCTION [dbo].[showCurrentMenusWithIngredient](@RestaurantID int, @ProductID int)
    returns TABLE
        as RETURN
        select M.MenuID
        from [dbo].[showCurrentMenus](@RestaurantID) M
                 INNER JOIN MenuDetails MD on M.MenuID = MD.MenuID
                 INNER JOIN DishDetails DD on MD.DishID = DD.DishID
        where DD.ProductID = @ProductID
go

create function [dbo].[showCustomerDetails](@CustomerID int)
    returns table
        as return select *
                  from Customers
                  where CustomerID = @CustomerID
go

create function [dbo].[showCustomerReservations](@CustomerID int)
    returns table
        as return select *
                  from Reservations
                  where CustomerID = @CustomerID
                    and StartDate >= getdate()
go

create function [dbo].[showCustomersOrdersNumberDetails](@CustomerID int)
    returns table
        as return select count(*) 'number of orders', sum(Price) 'sum of price of orders'
                  from Orders
                  where CustomerID = @CustomerID
go

create function [dbo].[showCustomersOrdersNumberDetailsLastMonth](@CustomerID int)
    returns table
        as return select count(*) 'number of orders', sum(Price) 'sum of price of orders'
                  from Orders
                  where CustomerID = @CustomerID
                    and datediff(month, RealizationDate, getdate()) < 1
go

create function [dbo].[showCustomersOrdersNumberDetailsLastQuarter](@CustomerID int)
    returns table
        as return select count(*) 'number of orders', sum(Price) 'sum of price of orders'
                  from Orders
                  where CustomerID = @CustomerID
                    and datediff(month, RealizationDate, getdate()) < 3
go

CREATE FUNCTION [dbo].[showDishIngredients](@DishID int)
    RETURNS TABLE
        AS RETURN
        select ProductName
        from Products P
                 INNER JOIN DishDetails DD on P.ProductID = DD.ProductID
        where DD.DishID = @DishID
go

create function [dbo].[showFutureOrdersWithDish](@DishID int)
    returns table
        as return select O.OrderID
                  from Orders O
                           inner join OrderDetails OD on O.OrderID = OD.OrderID
                  where OD.DishID = @DishID
                    and RealizationDate is null
go

CREATE FUNCTION [dbo].[showMenusInLastMonth]()
    RETURNS TABLE
        AS RETURN
        select MenuID
        from Menu
        where StartDate <= getdate()
          and datediff(month, StartDate, getdate()) <= 30
go

CREATE FUNCTION [dbo].[showMenusWithDish](@DishID int)
    returns table
        as return
        select MenuID
        from MenuDetails
        where DishID = @DishID
go

CREATE FUNCTION [dbo].[showRestaurantTables](@RestaurantID int)
    RETURNS TABLE
        AS
        RETURN
        SELECT TableID, IsAvailable
        from Tables
        where RestaurantID = @RestaurantID
go
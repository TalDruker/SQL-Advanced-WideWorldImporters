-- Project: Advanced SQL Queries & Business Analytics (WideWorldImporters)
-- Description: Advanced analytical queries utilizing CTEs, window functions, and aggregations.

-- Q1: Calculate yearly income, linear projected yearly income, and YoY growth rate
with cte_Q1 
as
(
    select year(o.OrderDate) as 'Year',
    sum(il.ExtendedPrice - il.TaxAmount) as IncomePerYear,
    count(distinct month(o.OrderDate)) as Months,
    cast((sum(il.ExtendedPrice - il.TaxAmount) / count(distinct month(o.OrderDate)) * 12) as decimal(12,2)) as YearlyLinearIncome
    from Sales.Orders o
    left join Sales.Invoices i on o.OrderID = i.OrderID
    left join Sales.InvoiceLines il on i.InvoiceID = il.InvoiceID
    group by year(o.OrderDate)
),
cte_Q1A as(
    select Year, IncomePerYear, Months, YearlyLinearIncome,
    lag(YearlyLinearIncome) over (order by Year) as Prev_YearlyLinearIncome
    from cte_Q1
) 
select Year, IncomePerYear, Months, YearlyLinearIncome,
cast(((YearlyLinearIncome / Prev_YearlyLinearIncome) - 1) * 100 as decimal(12,2)) AS GrowthRate
from cte_Q1A;

--------------------------------------------------------------------------

-- Q2: Find the top 5 customers with the highest income per year and quarter using Dense_Rank
with cte_Q2 
as 
(
    select year(o.OrderDate) as 'Year', datepart(QUARTER, o.OrderDate) as QUARTER,
    c.CustomerName as CustomerName, sum(ol.Quantity * ol.UnitPrice) as IncomePerYear
    from Sales.Orders o 
    inner join Sales.Customers c on o.CustomerID = c.CustomerID
    inner join Sales.OrderLines ol on ol.OrderID = o.OrderID
    group by year(o.OrderDate), datepart(QUARTER, o.OrderDate), c.CustomerName
), 
cte_Q2a as(
    select Year, QUARTER, CustomerName, incomePerYear,
    dense_rank() over (partition by year, QUARTER order by incomePerYear desc) as DNR
    from cte_Q2
)
select Year, QUARTER as TheQuarter, CustomerName, IncomePerYear, DNR
from cte_Q2a
where DNR <= 5;

--------------------------------------------------------------------------

-- Q3: Retrieve the top 10 most profitable stock items based on extended price minus tax
select top 10 s.StockItemID, s.StockItemName, sum(i.ExtendedPrice - i.TaxAmount) as TotalProfit
from Warehouse.StockItems s 
inner join Sales.InvoiceLines i on s.StockItemID = i.StockItemID
group by s.StockItemID, s.StockItemName
order by 3 desc;

--------------------------------------------------------------------------

-- Q4: Rank stock items by nominal product price (Retail Price - Unit Price) using Row_Number and Dense_Rank
with cte_Q4 as (
    select 
        s.StockItemID, s.StockItemName, s.UnitPrice, s.RecommendedRetailPrice,
        sum(s.RecommendedRetailPrice - s.UnitPrice) as NominalProudctPrice
    from Warehouse.StockItems s
    where ValidTo > getDate()
    group by s.StockItemID, s.StockItemName, s.UnitPrice, s.RecommendedRetailPrice
)
select row_number() over (order by NominalProudctPrice desc) AS Rn,
StockItemID, StockItemName, UnitPrice, RecommendedRetailPrice,
NominalProudctPrice, dense_rank() over (order by NominalProudctPrice desc) as Dnr
from cte_Q4;

--------------------------------------------------------------------------

-- Q5: Concatenate supplier details with a comma-separated list of their supplied products using STRING_AGG
select cast(s.SupplierID as varchar(10)) + ' - ' + s.SupplierName as SupplierDetails,
string_agg(cast(si.StockItemID as varchar(10)) + ' ' + si.StockItemName, ' /, ') as ProductDetails
from Purchasing.Suppliers s 
inner join Warehouse.StockItems si on s.SupplierID = si.SupplierID
group by s.SupplierID, s.SupplierName
order by s.SupplierID;

--------------------------------------------------------------------------

-- Q6: Find the top 5 customers with the highest total extended price including geographical details
select top 5 c.CustomerID, ci.CityName, co.CountryName, co.Continent, co.Region,
sum(il.ExtendedPrice) as TotalExtendedPrice
from Sales.Invoices i 
inner join Sales.InvoiceLines il on i.InvoiceID = il.InvoiceID
inner join Sales.Customers c on c.CustomerID = i.CustomerID
inner join Application.Cities ci on ci.CityID = c.DeliveryCityID
inner join Application.StateProvinces sp on sp.StateProvinceID = ci.StateProvinceID
inner join Application.Countries co on co.CountryID = sp.CountryID
group by c.CustomerID, ci.CityName, co.CountryName, co.Continent, co.Region
order by sum(il.ExtendedPrice) desc;

--------------------------------------------------------------------------

-- Q7: Generate a monthly sales report with cumulative totals and yearly grand totals using UNION ALL
with monthlysales as (
    select 
        year(orderdate) as OrderYear,
        month(orderdate) as orderm,
        sum(extendedprice - taxamount) as MonthlyTotal
    from sales.invoices a
    left join sales.invoicelines b on a.invoiceid = b.invoiceid
    left join sales.orders c on a.orderid = c.orderid
    group by year(orderdate), month(orderdate)
),
cte_1 as (
    select 
        OrderYear, orderm, MonthlyTotal,
        sum(monthlytotal) over (partition by orderyear order by orderm) as CumulativeTotal
    from monthlysales
),
cte_yearlysales as (
    select 
        OrderYear, 
        sum(MonthlyTotal) as yearlytotal
    from monthlysales
    group by OrderYear
),
cte_final as (
    select 
        OrderYear, orderm, cast(orderm as varchar(10)) as OrderMonth, 
        MonthlyTotal, CumulativeTotal
    from cte_1
    union all
    select 
        OrderYear, 13, 'Grand Total', 
        yearlytotal, yearlytotal
    from cte_yearlysales
)
select OrderYear, OrderMonth, MonthlyTotal, CumulativeTotal 
from cte_final
order by OrderYear, orderm;

--------------------------------------------------------------------------

-- Q8: Pivot order counts by month across multiple years (2013-2016) using Conditional Aggregation (CASE)
select 
    month(o.OrderDate) as OrderMonth,
    count(case when year(o.OrderDate) = 2013 then o.OrderID end) as '2013',
    count(case when year(o.OrderDate) = 2014 then o.OrderID end) as '2014',
    count(case when year(o.OrderDate) = 2015 then o.OrderID end) as '2015',
    count(case when year(o.OrderDate) = 2016 then o.OrderID end) as '2016'
from Sales.Orders o
group by month(o.OrderDate)
order by 1;

--------------------------------------------------------------------------

-- Q9: Calculate days since last order and average days between orders to flag potential customer churn
with cte_Q9 as(
    select c.CustomerID, c.CustomerName, 
    o.OrderDate, lag(o.OrderDate) over (partition BY c.CustomerID order by o.OrderDate) as PreiviousSinceLastDate
    from Sales.Orders o  
    inner join Sales.Customers c on c.CustomerID = o.CustomerID
), 
cte_Q9A as(
    select CustomerID, CustomerName, OrderDate, PreiviousSinceLastDate, 
    datediff(day, max(OrderDate) over (partition by CustomerID), (select max(OrderDate) from Sales.Orders)) as DaysSinceLastOrder
    from cte_Q9
),
cte_Q9B as(
    select CustomerID, CustomerName, OrderDate, PreiviousSinceLastDate, DaysSinceLastOrder,
    avg(datediff(day, PreiviousSinceLastDate, OrderDate)) over (partition by CustomerID) as AvgDaysBetweenOrders
    from cte_Q9A
)
select CustomerID, CustomerName, OrderDate, PreiviousSinceLastDate, DaysSinceLastOrder, AvgDaysBetweenOrders,
case when DaysSinceLastOrder > AvgDaysBetweenOrders * 2 then 'Potential Churn' else 'Active' end as CustomerStatus
from cte_Q9B;

--------------------------------------------------------------------------

-- Q10: Calculate customer category distribution and percentage share across the customer base
with cte_Q10 as (
    select 
        cc.customercategoryname,
        count(distinct case 
            when c.customername like 'wingtip%' then 'wingtip toys'
            when c.customername like 'tailspin%' then 'tailspin toys'
            else c.customername
        end) as customercount
    from sales.customers c
    inner join sales.customercategories cc on c.customercategoryid = cc.customercategoryid
    group by cc.customercategoryname
)
select 
    customercategoryname,
    customercount,
    sum(customercount) over() as totalcustcount,
    format(customercount * 1.0 / sum(customercount) over(), 'P2') as distributionfactor
from cte_Q10
order by 1;
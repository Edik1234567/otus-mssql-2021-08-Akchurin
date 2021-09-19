/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, GROUP BY, HAVING".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Все товары, в названии которых есть "urgent" или название начинается с "Animal".
Вывести: ИД товара (StockItemID), наименование товара (StockItemName).
Таблицы: Warehouse.StockItems.
*/

TODO: напишите здесь свое решение

SELECT
     StockItemID
    ,StockItemName
FROM Warehouse.StockItems
WHERE 1=1
    AND StockItemName LIKE '%urgent%' OR StockItemName LIKE 'Animal%'


/*
2. Поставщиков (Suppliers), у которых не было сделано ни одного заказа (PurchaseOrders).
Сделать через JOIN, с подзапросом задание принято не будет.
Вывести: ИД поставщика (SupplierID), наименование поставщика (SupplierName).
Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders.
По каким колонкам делать JOIN подумайте самостоятельно.
*/

TODO: напишите здесь свое решение

SELECT
     sup.SupplierID
    ,sup.SupplierName
FROM Purchasing.Suppliers AS sup
LEFT JOIN Purchasing.PurchaseOrders AS pur
    ON sup.SupplierID = pur.SupplierID
WHERE 1=1
    AND pur.SupplierID IS NULL


/*
3. Заказы (Orders) с ценой товара (UnitPrice) более 100$ 
либо количеством единиц (Quantity) товара более 20 штук
и присутствующей датой комплектации всего заказа (PickingCompletedWhen).
Вывести:
* OrderID
* дату заказа (OrderDate) в формате ДД.ММ.ГГГГ
* название месяца, в котором был сделан заказ
* номер квартала, в котором был сделан заказ
* треть года, к которой относится дата заказа (каждая треть по 4 месяца)
* имя заказчика (Customer)
Добавьте вариант этого запроса с постраничной выборкой,
пропустив первую 1000 и отобразив следующие 100 записей.

Сортировка должна быть по номеру квартала, трети года, дате заказа (везде по возрастанию).

Таблицы: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/

TODO: напишите здесь свое решение

SELECT DISTINCT 
     o.OrderID, convert(nvarchar(10)
    ,o.OrderDate, 104) AS OrderDate
    ,datename(month, o.OrderDate) AS MonthOrderDate
    ,datename(quarter, o.OrderDate) AS QuarterOrderDate,
    case when datepart(month, o.OrderDate) between 1 and 4 then 1
    	when datepart(month, o.OrderDate) between 5 and 8 then 2
    	when datepart(month, o.OrderDate) between 9 and 12 then 3
    end AS ThirdOrderDate
	,c.CustomerName
FROM Sales.Orders o 
JOIN Sales.OrderLines AS ol 
    ON ol.OrderID = o.OrderID 
JOIN Sales.Customers AS c
    ON c.CustomerID = o.CustomerID
WHERE ol.UnitPrice > 100 or (ol.Quantity > 20 and ol.PickingCompletedWhen IS NOT NULL)
ORDER BY QuarterOrderDate, ThirdOrderDate, OrderDate, o.orderId OFFSET 1000 ROWS FETCH FIRST 100 ROWS ONLY

/*
4. Заказы поставщикам (Purchasing.Suppliers),
которые должны быть исполнены (ExpectedDeliveryDate) в январе 2013 года
с доставкой "Air Freight" или "Refrigerated Air Freight" (DeliveryMethodName)
и которые исполнены (IsOrderFinalized).
Вывести:
* способ доставки (DeliveryMethodName)
* дата доставки (ExpectedDeliveryDate)
* имя поставщика
* имя контактного лица принимавшего заказ (ContactPerson)

Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
*/

TODO: напишите здесь свое решение


SELECT
     del.DeliveryMethodName
    ,ord.ExpectedDeliveryDate
    ,sup.SupplierName
    ,peo.FullName
FROM Purchasing.Suppliers AS sup
INNER JOIN Purchasing.PurchaseOrders AS ord
on sup.SupplierID = ord.SupplierID
INNER JOIN Application.DeliveryMethods AS del
on ord.DeliveryMethodID = del.DeliveryMethodID
INNER JOIN Application.People AS peo
on ord.PurchaseOrderID = peo.PersonID
where 1 =1
AND ord.ExpectedDeliveryDate BETWEEN '2013-01-01' AND '2013-01-31'
AND (del.DeliveryMethodName LIKE '%Air Freight%' OR del.DeliveryMethodName LIKE '%Refrigerated Air Freight%')
AND ord.IsOrderFinalized = 1
/*
5. Десять последних продаж (по дате продажи) с именем клиента и именем сотрудника,
который оформил заказ (SalespersonPerson).
Сделать без подзапросов.
*/

TODO: напишите здесь свое решение

SELECT TOP 10 
     inv.OrderID
    ,cus.CustomerName
    ,peo.FullName
FROM Sales.Invoices AS inv
JOIN Sales.Customers AS cus
    ON cus.CustomerID = inv.CustomerID
JOIN Application.People AS peo
    ON peo.PersonID = inv.SalespersonPersonID
ORDER BY inv.InvoiceDate DESC


/*
6. Все ид и имена клиентов и их контактные телефоны,
которые покупали товар "Chocolate frogs 250g".
Имя товара смотреть в таблице Warehouse.StockItems.
*/

TODO: напишите здесь свое решение

SELECT
     c.CustomerID
	,c.CustomerName
	,c.PhoneNumber
FROM Sales.Customers AS c
JOIN Sales.Orders AS o
    ON o.CustomerID = c.CustomerID
JOIN Sales.OrderLines AS ol
    ON ol.OrderID = o.OrderID
JOIN Warehouse.StockItems AS si
    ON si.StockItemID = ol.StockItemID
WHERE si.StockItemName = 'Chocolate frogs 250g'

/*
7. Посчитать среднюю цену товара, общую сумму продажи по месяцам
Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Средняя цена за месяц по всем товарам
* Общая сумма продаж за месяц

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

TODO: напишите здесь свое решение

SELECT
     year(inv.InvoiceDate) AS InvoiceYear
	,month(inv.InvoiceDate) AS InvoiceMonth 
    ,avg(inl.UnitPrice) AS AvgPrice
    ,sum(inl.ExtendedPrice) AS SumInv
FROM Sales.Invoices AS inv
JOIN Sales.InvoiceLines AS inl 
    ON inl.InvoiceID = inv.InvoiceID
GROUP BY
     year(inv.InvoiceDate)
    ,month(inv.InvoiceDate)
ORDER BY InvoiceYear, InvoiceMonth
/*
8. Отобразить все месяцы, где общая сумма продаж превысила 10 000

Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Общая сумма продаж

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

TODO: напишите здесь свое решение

SELECT
     year(inv.InvoiceDate) AS InvoiceYear
    ,month(inv.InvoiceDate) AS InvoiceMonth
	,sum(inl.ExtendedPrice) AS SumInv
FROM Sales.Invoices AS inv
JOIN Sales.InvoiceLines AS inl
    ON inl.InvoiceID = inv.InvoiceID
GROUP BY year(inv.InvoiceDate), month(inv.InvoiceDate)
HAVING sum(inl.ExtendedPrice) > 10000
ORDER BY InvoiceYear, InvoiceMonth

/*
9. Вывести сумму продаж, дату первой продажи
и количество проданного по месяцам, по товарам,
продажи которых менее 50 ед в месяц.
Группировка должна быть по году,  месяцу, товару.

Вывести:
* Год продажи
* Месяц продажи
* Наименование товара
* Сумма продаж
* Дата первой продажи
* Количество проданного

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

TODO: напишите здесь свое решение

SELECT 
     year(inv.InvoiceDate) AS InvoiceYear
    ,month(inv.InvoiceDate) AS InvoiceMonth
	,si.StockItemName
    ,sum(inl.ExtendedPrice) AS SumInv
    ,min(inv.InvoiceDate) AS FirstInvoiceDate
    ,sum(inl.Quantity) AS Quantity
FROM Sales.Invoices AS inv
JOIN Sales.InvoiceLines AS inl
    ON inl.InvoiceID = inv.InvoiceID
JOIN Warehouse.StockItems AS si
    ON si.StockItemID = inl.StockItemID
GROUP BY year(inv.InvoiceDate), month(inv.InvoiceDate), si.StockItemName
HAVING sum(inl.Quantity) < 50
ORDER BY InvoiceYear, InvoiceMonth, si.StockItemName
-- ---------------------------------------------------------------------------
-- Опционально
-- ---------------------------------------------------------------------------
/*
Написать запросы 8-9 так, чтобы если в каком-то месяце не было продаж,
то этот месяц также отображался бы в результатах, но там были нули.
*/
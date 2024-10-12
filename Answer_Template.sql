--SQL Advance Case Study


--Q1--BEGIN 


	SELECT [STATE] , Customer_Name FROM DIM_CUSTOMER
	INNER JOIN FACT_TRANSACTIONS ON FACT_TRANSACTIONS.IDCustomer = DIM_CUSTOMER.IDCustomer
	INNER JOIN DIM_LOCATION ON DIM_LOCATION.IDLocation = FACT_TRANSACTIONS.IDLocation
	INNER JOIN DIM_DATE ON DIM_DATE.DATE = FACT_TRANSACTIONS.Date
	WHERE YEAR >= 2005
	






--Q1--END

--Q2--BEGIN


	SELECT top 1 [State],COUNT (Quantity)AS Total FROM DIM_LOCATION
	LEFT JOIN FACT_TRANSACTIONS ON FACT_TRANSACTIONS.IDLocation = DIM_LOCATION.IDLocation
	LEFT JOIN DIM_MODEL ON DIM_MODEL.IDModel = FACT_TRANSACTIONS.IDModel
	LEFT JOIN DIM_MANUFACTURER ON DIM_MANUFACTURER.IDManufacturer = DIM_MODEL.IDManufacturer
    WHERE Manufacturer_Name = 'Samsung' and Country = 'US'
	GROUP BY [State]
	










--Q2--END

--Q3--BEGIN   


SELECT count (Model_Name) as [transaction] ,Model_Name , zipcode , [state]  from DIM_MODEL
inner join FACT_TRANSACTIONS on FACT_TRANSACTIONS.IDModel = DIM_MODEL.IDModel
inner join DIM_LOCATION on DIM_LOCATION.IDLocation = FACT_TRANSACTIONS.IDLocation
group by Model_Name , zipcode , [state]
	










--Q3--END

--Q4--BEGIN


SELECT TOP 1 Manufacturer_Name , MODEL_NAME , UNIT_PRICE FROM DIM_MODEL
INNER JOIN DIM_MANUFACTURER ON DIM_MANUFACTURER.IDManufacturer = DIM_MODEL.IDManufacturer
ORDER BY Unit_price








--Q4--END

--Q5 


SELECT DISTINCT TOP 5 Manufacturer_Name , Model_Name ,sum (Quantity) as  Sale_Quantity, AVG (UNIT_PRICE) AS Average_Price FROM FACT_TRANSACTIONS
INNER JOIN DIM_MODEL ON DIM_MODEL.IDModel = FACT_TRANSACTIONS.IDModel
INNER JOIN DIM_MANUFACTURER ON DIM_MANUFACTURER.IDManufacturer = DIM_MODEL.IDManufacturer
GROUP BY Manufacturer_Name , Model_Name 
order by AVG (UNIT_PRICE) desc







--Q5--END

----Q6--BEGIN   

select customer_name , avg (totalprice) as average_amount from DIM_CUSTOMER c
inner join FACT_TRANSACTIONS f on f.IDCustomer = c.IDCustomer
inner join DIM_DATE d on d.[DATE] = f.[Date]
where [YEAR]= 2009 
group by Customer_Name 
having avg (totalprice) > 500
order by avg (totalprice) desc












--Q6--END
	
--Q7--BEGIN
	



SELECT MODEL_NAME 
FROM FACT_TRANSACTIONS
INNER JOIN DIM_MODEL ON FACT_TRANSACTIONS.IDMODEL = DIM_MODEL.IDMODEL
GROUP BY MODEL_NAME
HAVING SUM(QUANTITY) IN ( SELECT TOP 5 SUM(QUANTITY) 
                          FROM FACT_TRANSACTIONS 
                          WHERE YEAR(Date) = 2008  
                          GROUP BY IDMODEL 
                          ORDER BY SUM(QUANTITY) DESC) 
AND 
 SUM(QUANTITY) IN (SELECT TOP 5 SUM(QUANTITY) 
                   FROM FACT_TRANSACTIONS 
                   WHERE YEAR(Date) = 2009  
                   GROUP BY IDMODEL 
                   ORDER BY SUM(QUANTITY) DESC) 
AND 
 SUM(QUANTITY) IN (SELECT TOP 5 SUM(QUANTITY) 
                   FROM FACT_TRANSACTIONS 
                   WHERE YEAR(Date) = 2010  
                   GROUP BY IDMODEL 
                   ORDER BY SUM(QUANTITY) DESC)











--Q7--END	
--Q8--BEGIN   





SELECT Manufacturer_Name, SUM(Sales) AS sales, [YEAR] FROM ( 
    SELECT TOP 2 Manufacturer_Name, DENSE_RANK() OVER (ORDER BY SUM(quantity) DESC) AS Rank, SUM(quantity) AS Sales, [YEAR] FROM
    DIM_MANUFACTURER
    INNER JOIN DIM_MODEL ON DIM_MODEL.IDManufacturer = DIM_MANUFACTURER.IDManufacturer
    INNER JOIN FACT_TRANSACTIONS ON FACT_TRANSACTIONS.IDModel = DIM_MODEL.IDModel
    INNER JOIN DIM_DATE ON DIM_DATE.DATE = FACT_TRANSACTIONS.Date
    WHERE [YEAR] = 2009
    GROUP BY Manufacturer_Name, [YEAR]
    ORDER BY SUM(quantity) DESC
) T1 
WHERE Rank = 2
GROUP BY Manufacturer_Name, [YEAR]

UNION ALL

SELECT Manufacturer_Name, SUM(Sales) AS sales, [YEAR] FROM (
    SELECT TOP 2 Manufacturer_Name, DENSE_RANK() OVER (ORDER BY SUM(quantity) DESC) AS Rank, SUM(quantity) AS Sales, [YEAR] FROM
    DIM_MANUFACTURER
    INNER JOIN DIM_MODEL ON DIM_MODEL.IDManufacturer = DIM_MANUFACTURER.IDManufacturer
    INNER JOIN FACT_TRANSACTIONS ON FACT_TRANSACTIONS.IDModel = DIM_MODEL.IDModel
    INNER JOIN DIM_DATE ON DIM_DATE.DATE = FACT_TRANSACTIONS.Date
    WHERE [YEAR] = 2010
    GROUP BY Manufacturer_Name, [YEAR]
    ORDER BY Sales DESC
) T2
WHERE Rank = 2
GROUP BY Manufacturer_Name, [YEAR]






--Q8--END
--Q9--BEGIN   
	
SELECT DISTINCT Manufacturer_Name
FROM DIM_MANUFACTURER M
INNER JOIN DIM_MODEL MO ON MO.IDManufacturer = M.IDManufacturer
INNER JOIN FACT_TRANSACTIONS FT ON FT.IDModel = MO.IDModel
INNER JOIN DIM_DATE D ON D.DATE = FT.Date
WHERE D.YEAR = 2010
AND NOT EXISTS 
(SELECT *
FROM DIM_MANUFACTURER M2
INNER JOIN DIM_MODEL MO2 ON MO2.IDManufacturer = M2.IDManufacturer
INNER JOIN FACT_TRANSACTIONS FT2 ON FT2.IDModel = MO2.IDModel
INNER JOIN DIM_DATE D2 ON D2.DATE = FT2.Date
WHERE M.IDManufacturer = M2.IDManufacturer
AND D2.YEAR = 2009)


















--Q9--END

--Q10--BEGIN 
	


SELECT TOP 100 Customer_Name, Year, Average_Spend, Average_Quantity,
  ((Average_Spend - LAG(Average_Spend) OVER (PARTITION BY Customer_Name ORDER BY Year)) / LAG(Average_Spend) OVER (PARTITION BY Customer_Name ORDER BY Year)) * 100 AS Spend_Change_Percentage
FROM (
  SELECT Customer_Name, Year, AVG(TotalPrice) AS Average_Spend, AVG(Quantity) AS Average_Quantity,
    ROW_NUMBER() OVER (PARTITION BY Year ORDER BY AVG(TotalPrice) DESC) AS rank
  FROM Fact_Transactions F
  INNER JOIN Dim_Customer C ON F.IDCustomer = C.IDCustomer
  INNER JOIN Dim_Date D ON D.Date = F.Date
  GROUP BY Customer_Name, Year
) AS subquery
WHERE rank <= 100
ORDER BY Year, Average_Spend DESC;




















--Q10--END
	
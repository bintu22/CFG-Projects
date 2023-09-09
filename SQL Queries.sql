USE `e-commerce`;
/* stored function */
DELIMITER $$
CREATE FUNCTION calcCost(revenue DECIMAL, profit DECIMAL) RETURNS DECIMAL(65,2)
DETERMINISTIC
BEGIN
DECLARE Cost DECIMAL (65,2);
SET cost = revenue-profit;
RETURN cost;
END$$
DELIMITER ;

/*sales by furniture category*/
SELECT Category, SUM(revenue) AS Revenue, SUM(calcCost(revenue, profit)) AS Cost, SUM(profit) AS Profit, SUM(quantity) AS Quantity FROM `order_details`
LEFT JOIN `furniture_categories`
ON `order_details`.`Sub-Category` = `furniture_categories`.`Sub-Category`
GROUP BY category
HAVING revenue > 0
ORDER BY profit DESC;

/* sales by customer: Join orders and orderdetails with profit Group by Customer*/
SELECT CustomerName, SUM(revenue) AS Revenue, SUM(profit) AS Profit, SUM(quantity) AS Quantity FROM `order_details`
LEFT JOIN `orders`
ON `order_details`.`OrderID` = `orders`.`OrderID`
GROUP BY CustomerName
HAVING revenue > 0
ORDER BY profit DESC;

/*Query to create view to show Customers contact info, state, spend, etc and product categories*/
ALTER VIEW States_Spend AS  
SELECT ID AS Customer_ID, customer_id.CustomerName AS CustomerName, Email, State, SUM(Revenue) AS Revenue, SUM(Profit) AS Profit, SUM(Quantity) AS Quantity, Category
FROM customers
LEFT JOIN customer_id
ON customers.ID = customer_id.CustomerID
LEFT JOIN orders
ON customer_id.CustomerName = orders.CustomerName
LEFT JOIN order_details
ON orders.OrderID = order_details.OrderID
LEFT JOIN furniture_categories
ON  `order_details`.`Sub-Category` = `furniture_categories`.`Sub-Category`
GROUP BY Customer_ID, Category
HAVING revenue > 0
ORDER BY profit DESC;

/*Query States_Spend view*/
SELECT * FROM States_Spend;

/*Query that view for profit by state*/
SELECT State, SUM(Profit) FROM States_Spend
GROUP BY State
ORDER BY SUM(Profit) DESC;

/* Orders per category*/
SELECT `Category`, `Sub-Category`, (SELECT COUNT(*) FROM order_details WHERE `order_details`.`Sub-Category` = `furniture_categories`.`Sub-Category`) AS Total_Orders
FROM furniture_categories
GROUP BY `Category`, `Sub-Category`
ORDER BY Category ASC;


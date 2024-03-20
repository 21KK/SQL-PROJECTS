-- Initially I have created a database 'kirandb1' which will be used for this sales analysis project
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ---------------------------------- Feature Engineering Product Analysis -----------------------------------------
 -- 1. Add new column 'time of the day' to give insight of sales in the morning, noon and evening. This answers which part of the day has most sales
 USE kirandb1;
 select `Time` from sales;

SELECT Time, (CASE 
		WHEN Time BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
                    WHEN Time BETWEEN "12:00:00" AND "16:00:00" THEN "AFTERNOON"
                    ELSE "EVENING"
                    END) AS time_of_the_day
FROM sales;

ALTER TABLE sales ADD COLUMN time_of_the_day varchar(15);

UPDATE sales
SET time_of_the_day = (CASE 
			WHEN Time BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
                    WHEN Time BETWEEN "12:00:00" AND "16:00:00" THEN "AFTERNOON"
                    ELSE "EVENING"
                    END
);

SELECT * FROM sales;

-- 2. Add day name, which contains extracted days of the weeks.
SELECT 
	Sales_Date, dayname(Sales_Date)
FROM sales;

DESCRIBE sales;

ALTER TABLE sales ADD COLUMN day_name VARCHAR(15);
UPDATE sales 
SET day_name = dayname(Sales_Date);

-- 3. Add column month_name
SELECT 
	Sales_Date,
    monthname(Sales_Date)
FROM sales;

ALTER TABLE sales ADD COLUMN month_name VARCHAR(15);
UPDATE sales
SET month_name = monthname(Sales_Date);
SELECT * FROM sales;

-- -----------------------------------------------------------EDA- Exloratory data analysis -------------------------------------------------------

-- 1. Generic Questions: How many unique cities are there?
SELECT DISTINCT City FROM sales;

-- 2. In whihc city is at each branch?
SELECT DISTINCT count(Branch) FROM sales;
SELECT DISTINCT City, Branch FROM sales;

-- --------------------------------------------------------------- Product Questions -----------------------------------------------------------------
-- 3. How many unique product lines are there? 
SELECT count(DISTINCT(Product_line)) FROM sales;

-- 4. what is the most common payment method?
SELECT payment_method, count(payment_method) FROM sales
GROUP BY payment_method
ORDER BY count(payment_method) DESC;

-- 5. what is the most selling product line? -- >> electronic accessories
SELECT Quantity, Product_line
FROM sales
GROUP BY product_line
ORDER BY quantity DESC;

-- 6. What is the total revenue by month? Jan
SELECT distinct month_name, sum(total) FROM sales
GROUP BY month_name
ORDER BY sum(total) DESC;

-- 7. What month had the largest COGS ~ cost of goods sold? --> Jan
SELECT sum(cogs), month_name FROM sales
GROUP BY month_name
ORDER BY sum(cogs) DESC;

-- 8. Product with largest revenue? -->> Food and Beverages
SELECT product_line, sum(total) AS revenue FROM sales
GROUP BY product_line
ORDER BY revenue DESC;

-- 9. City with largest revenue? -->> Naypyitaw
SELECT city, sum(total) AS revenue FROM sales
GROUP BY city
ORDER BY revenue DESC
limit 1;

-- 10. Product with largest VAT? -->> Food and Beverages
SELECT product_line AS product, sum(vat) FROM sales
GROUP BY product
ORDER BY sum(vat) DESC;

-- -------- 11. Fetch each product and add a column to those products showing 'good', 'bad'. Good if its greater than avg sales.
SELECT product_line,
					CASE WHEN total > (SELECT avg(total) FROM sales) THEN 'GOOD'
                    ELSE 'BAD' END AS csat
FROM sales;
-- This above query works, now let's update the fact table
-- mysql is not allowing to use the same table to update ny referencing by itself. 
-- so alternative is to store the csat values in temp table and update fact table by referencing temp table

CREATE TEMPORARY TABLE REVIEW AS 
SELECT avg(total) AS csat FROM sales;
UPDATE sales
		SET csat = CASE WHEN total > (SELECT csat FROM review) THEN 'GOOD' 
								ELSE 'BAD' END;
-- Check if the column has been updated in fact table
SELECT * FROM sales;

-- 12. Which Branch sold more products than average product sold?
SELECT branch, product_line, sum(quantity) AS qty FROM sales
GROUP BY branch
HAVING sum(quantity) > (SELECT avg(quantity) FROM sales);

-- 13. What is the most common product line by gender?
SELECT product_line, gender, count(gender) AS gen_count FROM sales
GROUP BY gender, product_line
ORDER BY gen_count DESC;

-- 14. What is the average rating of each product line?
SELECT product_line, round(avg(rating),2) AS Avg_Rating FROM sales
GROUP BY product_line;

-- ----------------------- Sales exploration -------------------------------------
-- 15. Number of sales made in each time of the day per week per weekday?
SELECT day_name, time_of_the_day, count(total) FROM sales
GROUP BY day_name
ORDER BY count(total) DESC ;

-- 16. Which of the customer types brings most revenue?
SELECT customer_type, sum(total) FROM sales
GROUP BY customer_type
ORDER BY total DESC;

-- 17. Which city has the largest tax percent/ vat?
SELECT city, avg(vat) FROM sales
GROUP BY city
ORDER BY avg(vat);

-- 18. Which customer type pays the most in VAT?
SELECT customer_type, avg(vat) FROM sales
GROUP BY customer_type
ORDER BY avg(vat);

-- ----------------------- Exploring Customers -----------------------------------------
-- 19. How many unique customer types does the data have?
SELECT DISTINCT customer_type FROM sales;

-- 20. How many unique payment methods are there in data?
SELECT COUNT(DISTINCT(payment_method)) FROM sales;

-- 21. What is the most common customer type?
SELECT customer_type, count(*) FROM sales
GROUP BY customer_type
ORDER BY count(*) DESC
LIMIT 1;

-- 22. Which customer type buys the most?
SELECT customer_type, count(quantity) from sales
GROUP BY customer_type
ORDER BY count(quantity) DESC
LIMIT 1;

-- 23. What is the gender of most of the customers?
SELECT gender, count(gender)  FROM sales
GROUP BY gender
ORDER BY count(gender) DESC
LIMIT 1;

-- 24. What is the gender distribution per branch?
SELECT branch, gender, count(gender) FROM sales
GROUP BY gender, branch
ORDER BY branch, gender DESC;

-- 25. Which time of the day do customers give highest rating?
SELECT time_of_the_day, avg(rating) FROM sales
GROUP BY time_of_the_day
ORDER BY avg(rating) DESC
LIMIT 1;

-- 26. Which time of the day do customers give most rating per branch?
SELECT time_of_the_day, branch, count(rating) FROM sales
GROUP BY branch, time_of_the_day
ORDER BY branch, count(rating) DESC;

-- 27. Which day of the week has the best average ratings?
SELECT day_name, avg(rating) FROM sales
GROUP BY day_name
ORDER BY avg(rating) DESC
LIMIT 1;

-- 28. Which day of the week has the best average ratings per branch?
SELECT day_name, branch, avg(rating) FROM sales
WHERE branch = 'C'
GROUP BY day_name, branch
ORDER BY avg(rating) desc
limit 1;



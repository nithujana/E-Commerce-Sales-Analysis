CREATE DATABASE ecommerce_analysis;
SHOW DATABASES;

USE ecommerce_analysis;

SHOW TABLES;

SELECT *
FROM ecommerce_master;

#--Q1. Who are the top 10 customers generating the highest revenue?
SELECT customer_id, round(SUM(quantity * unit_price - discount_amount),2) AS total_revenue
FROM ecommerce_master
WHERE status = 'completed'
GROUP BY customer_id
ORDER BY total_revenue DESC
LIMIT 10;

#--Q2. How has revenue changed month by month throughout the year?
SELECT DATE_FORMAT(order_date, '%Y-%m') AS month, ROUND(SUM(quantity * unit_price - discount_amount),2) AS monthly_revenue
FROM ecommerce_master
WHERE status = 'completed'
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY month;

#--Q3. Which acquisition channel brings the highest revenue and most customers?
SELECT acquisition_channel, COUNT(DISTINCT customer_id) AS total_customers, ROUND(SUM(quantity * unit_price - discount_amount),2) AS total_revenue
from ecommerce_master
WHERE status = 'completed'
GROUP BY acquisition_channel
ORDER BY total_revenue DESC;

#--Q4. Which states generate the highest sales and revenue?
SELECT state, COUNT(DISTINCT order_id) AS total_orders, SUM(quantity) as total_quantity_sold, ROUND(SUM(quantity * unit_price - discount_amount),2) AS total_revenue
FROM ecommerce_master
WHERE status = 'completed'
GROUP BY state
ORDER BY total_revenue DESC;

#--Q5. Which products generate the highest profit?
SELECT product_id, product_name, ROUND(SUM((quantity * unit_price)-discount_amount-(quantity * unit_cost)),2) AS total_profit
FROM ecommerce_master
WHERE status = 'completed'
GROUP BY product_id, product_name
ORDER BY total_profit DESC 
LIMIT 10 ;

#--Q6. What percentage of total revenue comes from each product category?
SELECT category, 
	   ROUND(SUM(quantity * unit_price - discount_amount),2) AS category_revenue,
	   ROUND(SUM(quantity * unit_price - discount_amount) *100.0/ SUM(SUM(quantity * unit_price - discount_amount)) OVER(),2) AS revenue_percentage
FROM ecommerce_master
WHERE status = 'completed'
GROUP BY category
ORDER BY revenue_percentage DESC;

#--Q7. What is the lifetime value of each customer based on total purchases?
SELECT customer_id, 
       ROUND(SUM(quantity * unit_price - discount_amount), 2) AS customer_lifetime_value
FROM ecommerce_master
WHERE status = 'completed'
GROUP BY customer_id 
ORDER BY customer_lifetime_value DESC;

#--Q8. How many customers are repeat buyers and how much revenue do they contribute?
SELECT COUNT(*) AS repeat_customers,
       ROUND(SUM(customer_revenue), 2) AS repeat_customer_revenue
FROM ( SELECT customer_id,
	   COUNT(DISTINCT order_id) AS total_orders,
	   SUM(quantity * unit_price - discount_amount) AS customer_revenue
    FROM ecommerce_master
    WHERE status = 'completed'
    GROUP BY customer_id
    HAVING COUNT(DISTINCT order_id) > 1 
) AS repeat_buyers;

#--Q9. Which product generates the highest revenue within each category?

WITH product_revenue AS (
SELECT product_id, product_name, category, SUM(quantity * unit_price - discount_amount) AS total_revenue,
ROW_NUMBER() OVER (PARTITION BY category ORDER BY SUM(quantity * unit_price - discount_amount) DESC) AS product_rank
FROM ecommerce_master
WHERE status = 'completed'
GROUP BY category, product_id, product_name)

SELECT product_id, product_name,category, ROUND(total_revenue, 2) AS total_revenue
FROM product_revenue
WHERE product_rank =1
ORDER BY total_revenue DESC;

# OR

SELECT product_id, product_name, category, SUM(quantity * unit_price - discount_amount) AS total_revenue
FROM ecommerce_master
WHERE status ='completed'
GROUP BY category, product_id, product_name
HAVING SUM(quantity * unit_price - discount_amount) >= ALL (
    SELECT SUM(e2.quantity * e2.unit_price - e2.discount_amount)
    FROM ecommerce_master e2
    WHERE e2.status = 'completed' AND e2.category = ecommerce_master.category
    GROUP BY e2.product_id, e2.product_name)
    ORDER BY total_revenue DESC;



#--Q10. Do orders with shipping fees generate higher order values compared to free shipping orders?

SELECT
    CASE
        WHEN shipping_fee > 0 THEN 'Paid Shipping'
        ELSE 'Free Shipping' END AS shipping_type,
        COUNT(DISTINCT order_id) AS total_orders,
        ROUND(AVG(order_value), 2) AS average_order_value
FROM (
    SELECT order_id, shipping_fee, SUM(quantity * unit_price - discount_amount) AS order_value
    FROM ecommerce_master
    WHERE status = 'completed'
    GROUP BY order_id, shipping_fee
) AS order_summary
GROUP BY shipping_type
ORDER BY average_order_value DESC;

#--Q11. What is the cumulative revenue over time?
WITH monthly_revenue AS (
    SELECT DATE_FORMAT(order_date, '%Y-%m') AS month,
           SUM(quantity * unit_price - discount_amount) AS total_revenue
    FROM ecommerce_master
    WHERE status = 'completed'
    GROUP BY month)
SELECT month, ROUND(total_revenue, 2) AS monthly_revenue, round(SUM(total_revenue) OVER ( ORDER BY month ),2) AS cumulative_revenue
FROM monthly_revenue;

#--Q12. Rank all customers based on total revenue generated.
SELECT customer_id,
       ROUND(SUM(quantity * unit_price - discount_amount), 2) AS total_revenue,
       RANK() OVER ( ORDER BY SUM(quantity * unit_price - discount_amount) DESC ) AS revenue_rank
FROM ecommerce_master
WHERE status = 'completed'
GROUP BY customer_id
ORDER BY revenue_rank;
 
# OR

WITH customer_revenue AS (
SELECT customer_id, SUM(quantity * unit_price - discount_amount) AS total_revenue
FROM ecommerce_master
WHERE status = 'completed'
GROUP BY customer_id)

SELECT customer_id, 
	   ROUND(total_revenue, 2) AS total_revenue, 
       RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank
FROM customer_revenue
ORDER BY revenue_rank;


#--Q13. What is the month-over-month revenue growth rate?

WITH monthly_revenue AS (
    SELECT DATE_FORMAT(order_date, '%Y-%m') AS month,
          SUM(quantity * unit_price - discount_amount) AS total_revenue
    FROM ecommerce_master
    WHERE status = 'completed'
    GROUP BY DATE_FORMAT(order_date, '%Y-%m') ),
revenue_comparison AS (
    SELECT month, 
		   total_revenue,
           LAG(total_revenue) OVER (ORDER BY month) AS previous_month_revenue
    FROM monthly_revenue )
SELECT month,
       ROUND(total_revenue, 2) AS total_revenue,
       ROUND(previous_month_revenue, 2) AS previous_month_revenue,
       ROUND( (total_revenue - previous_month_revenue) * 100.0 / NULLIF(previous_month_revenue, 0), 2 ) AS mom_growth_percentage
FROM revenue_comparison
ORDER BY month;


#--Q14. Which products are frequently purchased together?
SELECT a.product_name AS product_1,
       b.product_name AS product_2,
       COUNT(DISTINCT a.order_id) AS times_purchased_together
FROM ecommerce_master a
JOIN ecommerce_master b
    ON a.order_id = b.order_id
    AND a.product_id < b.product_id
WHERE a.status = 'completed'
  AND b.status = 'completed'
GROUP BY a.product_id, a.product_name,
         b.product_id, b.product_name
ORDER BY times_purchased_together DESC
LIMIT 10;

#--Q15. Do discounted orders generate higher revenue than non-discounted orders?
SELECT
    CASE
        WHEN discount_amount > 0 THEN 'Discounted'
        ELSE 'Non-Discounted'
    END AS discount_type,
    ROUND(SUM(quantity * unit_price - discount_amount), 2) AS total_revenue
FROM ecommerce_master
WHERE status = 'completed'
GROUP BY discount_type
ORDER BY total_revenue DESC;

# OR
SELECT
    CASE
        WHEN total_discount > 0 THEN 'Discounted'
        ELSE 'Non-Discounted'
    END AS discount_type,
    COUNT(*) AS total_orders,
    ROUND(AVG(order_revenue), 2) AS average_order_revenue,
    ROUND(SUM(order_revenue), 2) AS total_revenue
FROM (
    SELECT
        order_id,
        SUM(quantity * unit_price - discount_amount) AS order_revenue,
        SUM(discount_amount) AS total_discount
    FROM ecommerce_master
    WHERE status = 'completed'
    GROUP BY order_id
) AS order_summary
GROUP BY discount_type
ORDER BY average_order_revenue DESC;

#add revenue and profit columns
ALTER TABLE ecommerce_master
ADD COLUMN revenue DECIMAL(12,2);

SET SQL_SAFE_UPDATES = 0;

UPDATE ecommerce_master
SET revenue = (quantity * unit_price) - discount_amount;

SET SQL_SAFE_UPDATES = 1;

ALTER TABLE ecommerce_master
ADD COLUMN profit DECIMAL(12,2);

SET SQL_SAFE_UPDATES = 0;

UPDATE ecommerce_master
SET profit = (quantity * unit_price)
             - discount_amount
             - (quantity * unit_cost);

SET SQL_SAFE_UPDATES = 1;

SELECT
    product_name,
    quantity,
    unit_price,
    unit_cost,
    discount_amount,
    revenue,
    profit
FROM ecommerce_master
LIMIT 10;
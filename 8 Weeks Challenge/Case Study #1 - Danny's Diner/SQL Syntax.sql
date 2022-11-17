
-- CASE STUDY #1: DANNY'S DINER

-- Author : Fifi Natalia

Schema SQL Query SQL Results
Edit on DB Fiddle

CREATE DATABASE dannys_dinner;
USE dannys_dinner;
CREATE SCHEMA dannys_diner;
SET search_path = dannys_diner;

CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');

-- 1. What is the total amount each customer spent at the restaurant?
  SELECT s.customer_id, sum(price) FROM menu m 
  JOIN sales s ON
       s.product_id = m.product_id
  GROUP BY customer_id;
  
-- 2. How many days has each customer visited the restaurant?
  SELECT customer_id,COUNT(DISTINCT(order_date)) AS day_visit FROM sales
  GROUP BY customer_id;
  
-- 3. What was the first item from the menu purchased by each customer?
  SELECT s.customer_id,m.product_name FROM sales s
  JOIN menu m ON
       s.product_id = m.product_id
  WHERE s.order_date LIKE '2021-01-01'
  GROUP BY customer_id;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
  SELECT (COUNT(s.product_id)) AS most_purchased, product_name FROM sales s 
       INNER JOIN menu m ON
       s.product_id = m.product_id
  GROUP BY s.product_id
  ORDER BY most_purchased DESC;

-- 5. Which item was the most popular for each customer?
  SELECT s.customer_id,(COUNT(s.product_id)) AS most_purchased, product_name FROM sales s 
       INNER JOIN menu m ON
       s.product_id = m.product_id
  GROUP BY s.customer_id
  ORDER BY s.customer_id;

-- 6. Which item was purchased first by the customer after they became a member?
-- checking join all data table
  SELECT *
  FROM sales s
  JOIN members mm ON
       s.customer_id = mm.customer_id
  JOIN menu m ON 
       s.product_id = m.product_id
  ORDER BY s.customer_id,s.order_date;

-- ans for no 6
  SELECT 
     s.customer_id, 
     m.product_name, 
     mm.join_date
  FROM sales s
  JOIN members mm ON 
     s.customer_id = mm.customer_id
  JOIN menu m ON 
     s.product_id = m.product_id
  WHERE s.order_date >= mm.join_date
  GROUP BY s.customer_id
  ORDER BY s.customer_id;

-- 7. Which item was purchased just before the customer became a member?
  SELECT 
     s.customer_id, 
     m.product_name, 
     mm.join_date
  FROM sales s
  JOIN members mm ON 
     s.customer_id = mm.customer_id
  JOIN menu m ON 
     s.product_id = m.product_id
  WHERE s.order_date < mm.join_date
  ORDER BY s.customer_id;

-- 8. What is the total items and amount spent for each member before they became a member?
  SELECT 
     s.customer_id, 
  COUNT(DISTINCT s.product_id) AS total_item, 
     SUM(m.price) AS total_sales
  FROM sales s
  JOIN members mm ON 
     s.customer_id = mm.customer_id
  JOIN menu m ON 
     s.product_id = m.product_id
  WHERE s.order_date < mm.join_date
  GROUP BY s.customer_id;

-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
  SELECT s.customer_id, m.product_name,
     SUM(CASE 
     WHEN product_name = "sushi" THEN price*20
     ELSE price*10
     END) AS point
  FROM sales s 
  JOIN menu m ON
     s.product_id = m.product_id
  GROUP BY s.customer_id
  ORDER BY s.customer_id;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
  SELECT s.customer_id, s.order_date,
     SUM(CASE 
     WHEN order_date <= DATE_ADD(join_date, INTERVAL 6 DAY) THEN price*20
     ELSE price*10
     END) AS point
  FROM sales s 
  JOIN members mm ON 
     s.customer_id = mm.customer_id
  JOIN menu m ON 
     s.product_id = m.product_id
  WHERE order_date >= join_date
  GROUP BY s.customer_id
  ORDER BY s.customer_id;

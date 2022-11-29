-- Case Study #2 Pizza Runner
-- Author : Fifi Natalia

CREATE SCHEMA pizza_runner;
SET search_path = pizza_runner;

DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  "runner_id" INTEGER,
  "registration_date" DATE
);
INSERT INTO runners
  ("runner_id", "registration_date")
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  "order_id" INTEGER,
  "customer_id" INTEGER,
  "pizza_id" INTEGER,
  "exclusions" VARCHAR(4),
  "extras" VARCHAR(4),
  "order_time" TIMESTAMP
);

INSERT INTO customer_orders
  ("order_id", "customer_id", "pizza_id", "exclusions", "extras", "order_time")
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  "order_id" INTEGER,
  "runner_id" INTEGER,
  "pickup_time" VARCHAR(19),
  "distance" VARCHAR(7),
  "duration" VARCHAR(10),
  "cancellation" VARCHAR(23)
);

INSERT INTO runner_orders
  ("order_id", "runner_id", "pickup_time", "distance", "duration", "cancellation")
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');


DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  "pizza_id" INTEGER,
  "pizza_name" TEXT
);
INSERT INTO pizza_names
  ("pizza_id", "pizza_name")
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  "pizza_id" INTEGER,
  "toppings" TEXT
);
INSERT INTO pizza_recipes
  ("pizza_id", "toppings")
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  "topping_id" INTEGER,
  "topping_name" TEXT
);
INSERT INTO pizza_toppings
  ("topping_id", "topping_name")
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');

SELECT * FROM customer_orders;
SELECT * FROM pizza_names;
SELECT * FROM pizza_recipes;
SELECT * FROM pizza_toppings;
SELECT * FROM runner_order;
SELECT * FROM runners;

-- A. A. Pizza Metrics
-- 1. How many pizzas were ordered?
SELECT COUNT(DISTINCT(order_id)) AS pizza_order FROM customer_orders;

-- 2. How many unique customer orders were made?
SELECT customer_id, COUNT(order_id) AS unique_orders FROM customer_orders
GROUP BY customer_id;

-- 3. How many successful orders were delivered by each runner?
SELECT COUNT(order_id) AS successful_orders
FROM runner_orders
WHERE distance != 0;

-- 4. How many of each type of pizza was delivered?
SELECT c.pizza_id, COUNT(c.pizza_id) AS delivered_pizza
FROM customer_orders c
JOIN runner_orders r ON c.order_id = r.order_id
WHERE distance != 0
GROUP BY c.pizza_id;

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?
SELECT c.customer_id, p.pizza_name, COUNT(p.pizza_name) AS orders
FROM customer_orders c
JOIN pizza_names p ON c.pizza_id= p.pizza_id
GROUP BY c.customer_id, p.pizza_name
ORDER BY c.customer_id;
 
-- 6. What was the maximum number of pizzas delivered in a single order?
WITH max_pizza AS (
SELECT c.order_id, COUNT(c.pizza_id) AS pizza_per_order
FROM customer_orders c
JOIN runner_orders r ON c.order_id = r.order_id
WHERE r.distance != 0
GROUP BY c.order_id)

SELECT MAX(pizza_per_order) AS pizza_count FROM max_pizza;

-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT c.customer_id,
	SUM(CASE 
		WHEN c.exclusions <> ' ' OR c.extras <> ' ' THEN 1
		ELSE 0
		END) AS with_changes,
	SUM(CASE 
		WHEN c.exclusions IS NULL OR c.extras IS NULL THEN 1 
		ELSE 0
		END) AS number_changes
FROM customer_orders c
JOIN runner_orders r ON c.order_id = r.order_id
WHERE r.distance != 0
GROUP BY c.customer_id
ORDER BY c.customer_id;

-- 8. How many pizzas were delivered that had both exclusions and extras?
SELECT c.order_id, 
	SUM(CASE
		WHEN exclusions IS NOT NULL AND extras IS NOT NULL THEN 1
		ELSE 0
		END) AS pizza_delivered
FROM customer_orders c
JOIN runner_orders r ON c.order_id = r.order_id
WHERE r.distance >= 1 
	AND exclusions <> ' ' 
	AND extras <> ' ' 
GROUP BY c.order_id, c.pizza_id;

-- 9. What was the total volume of pizzas ordered for each hour of the day?
SELECT HOUR(order_time) AS hours, COUNT(order_id) AS total_ordered
FROM customer_orders
GROUP BY HOUR(order_time)
ORDER BY HOUR(order_time);

-- 10. What was the volume of orders for each day of the week?
SELECT DAYNAME(order_time) AS days_name, COUNT(order_id) AS total_ordered
FROM customer_orders
GROUP BY DAYNAME(order_time);

-- B. Runner and Customer Experience
-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
SELECT runner_id,
	CASE
		WHEN registration_date BETWEEN '2021-01-01' AND '2021-01-07' THEN 'Week 1'
		WHEN registration_date BETWEEN '2021-01-08' AND '2021-01-14'THEN 'Week 2'
		ELSE 'Week 3'
		END AS runner_signups
FROM runners
GROUP BY registration_date, runner_id;

-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
WITH time_taken AS
(
SELECT r.runner_id, c.order_id, c.order_time, r.pickup_time, DATEDIFF(MINUTE, c.order_time, r.pickup_time) AS mins_taken_to_arrive_HQ
FROM customer_orders c
JOIN runner_orders r ON c.order_id = r.order_id
WHERE r.distance != 0
GROUP BY r.runner_id, c.order_id, c.order_time, r.pickup_time
)

SELECT runner_id, AVG(mins_taken_to_arrive_HQ) AS avg_mins_taken_to_arrive_HQ
FROM time_taken
WHERE mins_taken_to_arrive_HQ > 1
GROUP BY runner_id;

-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
WITH prepare_time AS
(
SELECT c.order_id, COUNT(c.order_id) AS no_pizza_ordered, c.order_time, r.pickup_time, DATEDIFF(MINUTE, c.order_time, r.pickup_time) AS time_taken_to_prepare
FROM customer_orders c
JOIN runner_orders r ON c.order_id = r.order_id
WHERE r.distance != 0
GROUP BY c.order_id, c.order_time, r.pickup_time
)

SELECT no_pizza_ordered, AVG(time_taken_to_prepare) AS avg_time_to_prepare
FROM prepare_time
WHERE time_taken_to_prepare > 1
GROUP BY no_pizza_ordered;

-- 4. What was the average distance travelled for each customer?
SELECT c.customer_id, AVG(r.distance) AS avg_distance
FROM customer_orders c
JOIN runner_orders r ON c.order_id = r.order_id
WHERE duration != 0
GROUP BY c.customer_id;

-- 5. What was the difference between the longest and shortest delivery times for all orders?
WITH time_taken AS
(
SELECT r.runner_id, c.order_id, c.order_time, r.pickup_time, DATEDIFF(MINUTE, c.order_time, r.pickup_time) AS delivery_time
FROM customer_orders c
JOIN runner_orders r ON c.order_id = r.order_id
WHERE r.distance != 0
GROUP BY r.runner_id, c.order_id, c.order_time, r.pickup_time
)

SELECT (MAX(delivery_time) - MIN(delivery_time)) AS diff_longest_shortest_delivery_time
FROM time_taken
WHERE delivery_time > 1;

-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
SELECT runner_id, c.order_id, COUNT(c.order_id) AS pizza_count, (distance * 1000) AS distance_meter, duration, ROUND((distance * 1000/duration),2) AS avg_speed
FROM runner_orders r
JOIN customer_orders c ON r.order_id = c.order_id
WHERE distance != 0
GROUP BY runner_id, c.order_id, distance, duration
ORDER BY runner_id, pizza_count, avg_speed;

-- 7. What is the successful delivery percentage for each runner?
WITH delivery AS
(
SELECT runner_id, COUNT(order_id) AS total_delivery,
	SUM(CASE
		WHEN distance != 0 THEN 1
		ELSE distance
		END) AS successful_delivery,
	SUM(CASE
		WHEN cancellation LIKE '%Cancel%' THEN 1 
		ELSE cancellation
		END) AS failed_delivery
FROM runner_orders
GROUP BY runner_id, order_id
)

SELECT runner_id, (SUM(successful_delivery)/SUM(total_delivery)*100) AS successful_delivery_perc
FROM delivery
GROUP BY runner_id;



-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

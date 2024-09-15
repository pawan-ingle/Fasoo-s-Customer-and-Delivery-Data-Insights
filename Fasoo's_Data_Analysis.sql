
--A. Roll Metrics 

--1. How Many Rolls Were Ordered

SELECT COUNT(roll_id) FROM customer_orders;


--2. How Many unique Customers were ordered?

SELECT COUNT(DISTINCT customer_id) FROM customer_orders;


--3. How Many Successful Orders were deliver by each driver?

SELECT driver_id, COUNT(DISTINCT order_id) as successful_orders
FROM driver_order
WHERE cancellation NOT IN ('Cancellation','Customer Cancellation')
GROUP BY driver_id;


--4. How many each type od roll was delivered?

SELECT roll_id, COUNT(roll_id) AS no_of_roll
FROM customer_orders 
WHERE order_id IN
(SELECT order_id FROM
(SELECT *, 
	CASE WHEN cancellation IN ('Cancellation','Customer Cancellation') THEN 'cancelled'
ELSE  'not cancelled' END AS  cancel_order_details
FROM driver_order)
WHERE cancel_order_details = 'not cancelled')
GROUP BY roll_id;



--5. How many veg and nonveg rolls were ordered by each customer?


SELECT r.*, rn.roll_name 
FROM
(SELECT customer_id, roll_id, COUNT(roll_id) as no_of_rolls
FROM customer_orders
GROUP BY customer_id, roll_id)
r INNER JOIN rolls rn 
ON r.roll_id = rn.roll_id;


--6. What was the maximum no. of rolls ordered by single customer?

SELECT * FROM
(
SELECT *, RANK() OVER(ORDER BY no_of_rolls DESC) rnk FROM
(
SELECT customer_id, COUNT(roll_id) no_of_rolls
FROM 
(
SELECT * FROM customer_orders 
WHERE customer_id IN(
	SELECT customer_id FROM
	(SELECT *, 
	CASE WHEN cancellation IN ('Cancellation','Customer Cancellation') THEN 'cancelled'
	ELSE  'not cancelled' END AS  cancel_order_details
	FROM driver_order)a
	WHERE cancel_order_details = 'not cancelled'))b
GROUP BY customer_id)c)d
WHERE rnk= 1;





-- 7. For each customer , how many delivered rolls has at least 1 change and how many had no change

WITH temp_customer_orders(order_id, customer_id, roll_id, not_include_items, extra_items_included, order_date)
AS (SELECT order_id, customer_id, roll_id, 
	CASE WHEN not_include_items IS NULL OR not_include_items = '' THEN '0' 
	ELSE not_include_items END AS new_not_include_items,
	CASE WHEN extra_items_included IS NULL OR extra_items_included  = '' OR extra_items_included = 'NaN' THEN '0'
	ELSE extra_items_included END AS new_extra_items_included,
	order_date 
	FROM customer_orders
)
,
temp_driver_order(order_id, driver_id, pickup_time, distance, duration, new_cancellation) AS
(
SELECT order_id, driver_id, pickup_time, distance, duration,
	CASE WHEN cancellation IN ('Cancellation','Customer Cancellation') THEN 0 ELSE 1 END AS new_cancellation
	FROM driver_order
)

SELECT customer_id,changes, COUNT(order_id) FROM
(SELECT *, CASE WHEN not_include_items = '0' and extra_items_included = '0' THEN 'no_change' ELSE 'change' END changes  
FROM temp_customer_orders WHERE order_id IN 
(
SELECT order_id FROM temp_driver_order
WHERE new_cancellation != 0)) x
GROUP BY customer_id,changes;





--8. How many rolls were delivered have both exclusions or extras

WITH temp_customer_orders(order_id, customer_id, roll_id, not_include_items, extra_items_included, order_date)
AS (SELECT order_id, customer_id, roll_id, 
	CASE WHEN not_include_items IS NULL OR not_include_items = '' THEN '0' 
	ELSE not_include_items END AS new_not_include_items,
	CASE WHEN extra_items_included IS NULL OR extra_items_included  = '' OR extra_items_included = 'NaN' THEN '0'
	ELSE extra_items_included END AS new_extra_items_included,
	order_date 
	FROM customer_orders
)
,
temp_driver_order(order_id, driver_id, pickup_time, distance, duration, new_cancellation) AS
(
SELECT order_id, driver_id, pickup_time, distance, duration,
	CASE WHEN cancellation IN ('Cancellation','Customer Cancellation') THEN 0 ELSE 1 END AS new_cancellation
	FROM driver_order
)

SELECT changes, COUNT(changes) FROM 
(SELECT *, CASE WHEN not_include_items != '0' and extra_items_included != '0' THEN 'both inc exc' ELSE 'either 1 inc or exc' END changes  
FROM temp_customer_orders WHERE order_id IN 
(
SELECT order_id FROM temp_driver_order
WHERE new_cancellation != 0))
GROUP BY changes;


--9. What was the total no. of rolls ore=dered for each hour of the day

SELECT hours, count(hours) FROM
(SELECT *, CONCAT(CAST (DATE_PART('hour', order_date)AS VARCHAR),'-',CAST(DATE_PART('hour', order_date)+1 AS VARCHAR))  AS hours
FROM customer_orders)a
GROUP BY hours;


--10. What was the no. of orders for each day of week?

SELECT day_of_week, COUNT(order_id) FROM
(
SELECT *, to_char(order_date, 'Day') AS day_of_week 
FROM customer_orders)
GROUP BY day_of_week;


-- DRIVER AND CUSTOMER EXPERIENCE

--1.  What was the average times it took for each driver to arrive at fasoos HQ to pickup the order;

SELECT driver_id, sum(diff_in_minutes)/COUNT(order_id) as avg_mins FROM
(
SELECT * FROM
(SELECT sub.*, 
       row_number() OVER (PARTITION BY sub.order_id ORDER BY sub.diff_in_minutes) AS rn 
FROM (
    SELECT c.order_id, c.customer_id, c.roll_id, c.not_include_items, c.extra_items_included, c.order_date,
           d.driver_id, d.pickup_time, d.distance, d.duration, d.cancellation,
           ROUND((EXTRACT(EPOCH FROM (d.pickup_time - c.order_date)) / 60), 0) AS diff_in_minutes
    FROM customer_orders c
    INNER JOIN driver_order d ON c.order_id = d.order_id
    WHERE d.pickup_time IS NOT NULL
) AS sub)b )c
GROUP BY driver_id;


-- 2. What was the average distance travelled for each customer

SELECT customer_id, sum(distance)/count(order_id) as avg_distance  FROM
(
SELECT * FROM
(SELECT c.order_id, c.customer_id, c.roll_id, c.not_include_items, c.extra_items_included, c.order_date,
           d.driver_id, d.pickup_time,
cast(trim(replace(d.distance,'km','')) as decimal(4,2)) distance, 
d.duration, d.cancellation
	FROM customer_orders c
INNER JOIN driver_order d on c.order_id = d.order_id
WHERE d.pickup_time is NOT NULL) X) Y
GROUP BY customer_id;


--3. What was the difference between the longest and shortest delivery times for all orders?

SELECT MAX(duration) - MIN(duration) AS difference FROM
(SELECT 
   CAST (CASE 
        WHEN duration LIKE '%min%' THEN LEFT(duration, POSITION('m' IN duration) - 1) 
        ELSE duration
    END AS integer) AS duration
FROM driver_order 
WHERE duration IS NOT NULL)x;



--4. What was the average speed for each delivery and do you notice any trend for this values

SELECT order_id, driver_id, ROUND((distance/duration),2) as speed FROM
(SELECT order_id, driver_id,
	CAST(trim(replace(distance,'km','')) as decimal(4,2)) distance, 
	CAST (CASE 
        WHEN duration LIKE '%min%' THEN LEFT(duration, POSITION('m' IN duration) - 1) 
        ELSE duration
    END AS integer) AS duration
	FROM driver_order WHERE distance IS NOT NULL)x;

-- speed = distance / time



--5. What is the successful delivery percentage for each driver

SELECT driver_id, ROUND((s*1.0/c)*100,2) as cancelled_percentage FROM
(SELECT driver_id, sum(cancel_percentage) as s, count(driver_id) as c FROM
(SELECT driver_id, 
	CASE WHEN LOWER(cancellation) LIKE '%cancel%' then 0 else 1 
	end as cancel_percentage FROM driver_order)x
	GROUP BY driver_id)y
	ORDER BY driver_id ;

-- successful delivery percentage = total orders successfully delivered / total orders taken


























































































































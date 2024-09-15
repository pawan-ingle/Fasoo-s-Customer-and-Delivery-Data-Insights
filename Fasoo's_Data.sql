-- Drop the driver table if it exists
DROP TABLE IF EXISTS driver;



-- Create the driver table with driver_id and reg_date columns
CREATE TABLE driver (
    driver_id integer,
    reg_date date
);



-- Insert data into the driver table
INSERT INTO driver(driver_id, reg_date) 
VALUES 
(1, '2024-01-01'),
(2, '2024-01-03'),
(3, '2024-01-08'),
(4, '2024-01-15');



-- Drop the ingredients table if it exists
DROP TABLE IF EXISTS ingredients;

-- Create the ingredients table with ingredients_id and ingredients_name columns
CREATE TABLE ingredients (
    ingredients_id integer,
    ingredients_name varchar(60)
);


-- Insert data into the ingredients table
INSERT INTO ingredients(ingredients_id, ingredients_name) 
VALUES 
(1, 'BBQ Chicken'),
(2, 'Chilli Sauce'),
(3, 'Chicken'),
(4, 'Cheese'),
(5, 'Kebab'),
(6, 'Mushrooms'),
(7, 'Onions'),
(8, 'Egg'),
(9, 'Peppers'),
(10, 'Schezwan Sauce'),
(11, 'Tomatoes'),
(12, 'Tomato Sauce');


-- Drop the rolls table if it exists
DROP TABLE IF EXISTS rolls;

-- Create the rolls table with roll_id and roll_name columns
CREATE TABLE rolls (
    roll_id integer,
    roll_name varchar(30)
);



-- Insert data into the rolls table
INSERT INTO rolls(roll_id, roll_name) 
VALUES 
(1, 'Non Veg Roll'),
(2, 'Veg Roll');


-- Drop the rolls_recipes table if it exists
DROP TABLE IF EXISTS rolls_recipes;

-- Create the rolls_recipes table with roll_id and ingredients columns
CREATE TABLE rolls_recipes (
    roll_id integer,
    ingredients varchar(24)
);


-- Insert data into the rolls_recipes table
INSERT INTO rolls_recipes(roll_id, ingredients) 
VALUES 
(1, '1,2,3,4,5,6,8,10'),
(2, '4,6,7,9,11,12');



-- Drop the driver_order table if it exists
DROP TABLE IF EXISTS driver_order;

-- Create the driver_order table with order_id, driver_id, pickup_time, distance, duration, and cancellation columns
CREATE TABLE driver_order (
    order_id integer,
    driver_id integer,
    pickup_time timestamp,
    distance varchar(7),
    duration varchar(10),
    cancellation varchar(23)
);


-- Insert data into the driver_order table
INSERT INTO driver_order(order_id, driver_id, pickup_time, distance, duration, cancellation) 
VALUES 
(1, 1, '2024-01-01 18:15:34', '20km', '32 minutes', ''),
(2, 1, '2024-01-01 19:10:54', '20km', '27 minutes', ''),
(3, 1, '2024-01-03 00:12:37', '13.4km', '20 mins', 'NaN'),
(4, 2, '2024-01-04 13:53:03', '23.4', '40', 'NaN'),
(5, 3, '2024-01-08 21:10:57', '10', '15', 'NaN'),
(6, 3, null, null, null, 'Cancellation'),
(7, 2, '2024-01-08 21:30:45', '25km', '25mins', null),
(8, 2, '2024-01-10 00:15:02', '23.4 km', '15 minute', null),
(9, 2, null, null, null, 'Customer Cancellation'),
(10, 1, '2024-01-11 18:50:20', '10km', '10minutes', null);



-- Drop the customer_orders table if it exists
DROP TABLE IF EXISTS customer_orders;


-- Create the customer_orders table with order_id, customer_id, roll_id, not_include_items, extra_items_included, and order_date columns
CREATE TABLE customer_orders (
    order_id integer,
    customer_id integer,
    roll_id integer,
    not_include_items varchar(4),
    extra_items_included varchar(4),
    order_date timestamp
);


-- Insert data into the customer_orders table
INSERT INTO customer_orders(order_id, customer_id, roll_id, not_include_items, extra_items_included, order_date)
VALUES 
(1, 101, 1, '', '', '2024-01-01 18:05:02'),
(2, 101, 1, '', '', '2024-01-01 19:00:52'),
(3, 102, 1, '', '', '2024-01-02 23:51:23'),
(4, 102, 2, '', 'NaN', '2024-01-02 23:51:23'),
(5, 103, 1, '4', '', '2024-01-04 13:23:46'),
(6, 103, 1, '4', '', '2024-01-04 13:23:46'),
(7, 103, 2, '4', '', '2024-01-04 13:23:46'),
(8, 104, 1, null, '1', '2024-01-08 21:00:29'),
(9, 101, 2, null, null, '2024-01-08 21:03:13'),
(10, 105, 2, null, '1', '2024-01-08 21:20:29'),
(11, 102, 1, null, null, '2024-01-09 23:54:33'),
(12, 103, 1, '4', '1,5', '2024-01-10 11:22:59'),
(13, 104, 1, null, null, '2024-01-11 18:34:49'),
(14, 104, 1, '2,6', '1,4', '2024-01-11 18:34:49');



-- Query to select all data from customer_orders
SELECT * FROM customer_orders;

-- Query to select all data from driver_order
SELECT * FROM driver_order;

-- Query to select all data from ingredients
SELECT * FROM ingredients;

-- Query to select all data from driver
SELECT * FROM driver;

-- Query to select all data from rolls
SELECT * FROM rolls;

-- Query to select all data from rolls_recipes
SELECT * FROM rolls_recipes;

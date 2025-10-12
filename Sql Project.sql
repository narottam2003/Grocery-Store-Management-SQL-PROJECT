CREATE DATABASE grocery_store_db CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE grocery_store_db;

-- 1. supplier
CREATE TABLE supplier (
  sup_id TINYINT PRIMARY KEY AUTO_INCREMENT,
  sup_name VARCHAR(255),
  address TEXT
) ENGINE=InnoDB;

-- 2. categories
CREATE TABLE categories (
  cat_id TINYINT PRIMARY KEY AUTO_INCREMENT,
  cat_name VARCHAR(255)
) ENGINE=InnoDB;

-- 3. employees
CREATE TABLE employees (
  emp_id TINYINT PRIMARY KEY AUTO_INCREMENT,
  emp_name VARCHAR(255),
  hire_date VARCHAR(255)
) ENGINE=InnoDB;

-- 4. customers
CREATE TABLE customers (
  cust_id SMALLINT PRIMARY KEY AUTO_INCREMENT,
  cust_name VARCHAR(255),
  address TEXT
) ENGINE=InnoDB;

-- 5. products
CREATE TABLE products (
  prod_id TINYINT PRIMARY KEY AUTO_INCREMENT,
  prod_name VARCHAR(255),
  sup_id TINYINT,
  cat_id TINYINT,
  price DECIMAL(10,2),
  FOREIGN KEY (sup_id) REFERENCES supplier(sup_id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (cat_id) REFERENCES categories(cat_id) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

-- 6. orders
CREATE TABLE orders (
  ord_id SMALLINT PRIMARY KEY AUTO_INCREMENT,
  cust_id SMALLINT,
  emp_id TINYINT,
  order_date VARCHAR(255),
  FOREIGN KEY (cust_id) REFERENCES customers(cust_id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (emp_id) REFERENCES employees(emp_id) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

-- 7. order_details
CREATE TABLE order_details (
  ord_detID SMALLINT AUTO_INCREMENT PRIMARY KEY,
  ord_id SMALLINT,
  prod_id TINYINT,
  quantity TINYINT,
  each_price DECIMAL(10,2),
  total_price DECIMAL(10,2),
  FOREIGN KEY (ord_id) REFERENCES orders(ord_id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (prod_id) REFERENCES products(prod_id) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

-- CATEGORIES Table

LOAD DATA LOCAL INFILE 'C:/Users/DIPU/Downloads/drive-download-20251002T104054Z-1-001/Categories.csv'
INTO TABLE categories
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(@CategoryID, @CategoryName)
SET cat_id = @CategoryID, cat_name = @CategoryName;

-- SUPPLIER Table (Maps SupplierID to sup_id, SupplierName to sup_name)

LOAD DATA LOCAL INFILE 'C:/Users/DIPU/Downloads/drive-download-20251002T104054Z-1-001/Suppliers.csv'
INTO TABLE supplier
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(@SupplierID, @SupplierName, @Address)
SET sup_id = @SupplierID, sup_name = @SupplierName, address = @Address;


-- EMPLOYEES Table (Maps EmployeeID to emp_id, Name to emp_name)

LOAD DATA LOCAL INFILE 'C:/Users/DIPU/Downloads/drive-download-20251002T104054Z-1-001/Store_Employees.csv'
INTO TABLE employees
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(@EmployeeID, @Name, @HireDate)
SET emp_id = @EmployeeID, emp_name = @Name, hire_date = @HireDate;

-- CUSTOMERS Table (Maps CustomerID to cust_id, Name to cust_name)

LOAD DATA LOCAL INFILE 'C:/Users/DIPU/Downloads/drive-download-20251002T104054Z-1-001/Customers.csv'
INTO TABLE customers
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(@CustomerID, @Name, @Address)
SET cust_id = @CustomerID, cust_name = @Name, address = @Address;

-- PRODUCTS Table (Maps ProductID to prod_id, Name to prod_name, etc.)

LOAD DATA LOCAL INFILE 'C:/Users/DIPU/Downloads/drive-download-20251002T104054Z-1-001/Products.csv'
INTO TABLE products
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(@ProductID, @Name, @SupplierID, @CategoryID, @Price)
SET prod_id = @ProductID, prod_name = @Name, sup_id = @SupplierID, cat_id = @CategoryID, price = ROUND(@Price,2);

-- ORDERS Table (Maps OrderID to ord_id, CustomerID to cust_id, etc.)

LOAD DATA LOCAL INFILE 'C:/Users/DIPU/Downloads/drive-download-20251002T104054Z-1-001/Orders.csv'
INTO TABLE orders
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(@OrderID, @CustomerID, @EmployeeID, @OrderDate)
SET ord_id = @OrderID, cust_id = @CustomerID, emp_id = @EmployeeID, order_date = @OrderDate;

-- ORDER_DETAILS Table (Maps OrderDetailID to ord_detID, ProductID to prod_id, etc.)
-- Note: PriceEach is mapped to each_price, TotalPrice to total_price
LOAD DATA LOCAL INFILE 'C:/Users/DIPU/Downloads/drive-download-20251002T104054Z-1-001/OrderDetails.csv'
INTO TABLE order_details
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'   
IGNORE 1 LINES
(ord_detID, ord_id, prod_id, quantity, each_price, total_price);

-- =============================================================
-- DATA IMPORT USING LOAD DATA LOCAL INFILE
-- ** IMPORTANT **: Replace [FULL_PATH_TO_YOUR_FILE_FOLDER] with your actual folder path.
-- =============================================================
select *from categories;
select *from customers;
select *from order_details;
select *from orders;
select *from Products;
select *from employees;
select *from supplier;

-- 1️. Customer Insights
-- Gain an understanding of customer engagement and purchasing behavior.
-- How many unique customers have placed orders?
SELECT COUNT(DISTINCT cust_id) AS unique_customers FROM orders;
-- Which customers have placed the highest number of orders?
SELECT c.cust_id, c.cust_name, COUNT(*) AS orders_count
FROM customers c  JOIN orders o USING (cust_id)
GROUP BY o.cust_id
ORDER BY orders_count DESC limit 1;
-- What is the total and average purchase value per customer?
SELECT o.cust_id, c.cust_name,
       SUM(od.total_price) AS total_spent,
       AVG(od.total_price) AS avg_line_value
FROM orders o
JOIN order_details od on o.ord_id=od.ord_id
JOIN customers c on o.cust_id=c.cust_id
GROUP BY o.cust_id;
-- Who are the top 5 customers by total purchase amount?
SELECT c.cust_id, c.cust_name, SUM(od.total_price) AS total_spent
FROM customers c
JOIN orders o USING (cust_id)
JOIN order_details od USING (ord_id)
GROUP BY c.cust_id, c.cust_name
ORDER BY total_spent DESC
LIMIT 5;

-- 2. Product Performance
-- Evaluate how well products are performing in terms of sales and revenue.
-- How many products exist in each category?
select c.cat_id,c.cat_name,count(p.prod_id) as N0_of_product
 from categories c join products p on c.cat_id= p.cat_id
 group by c.cat_id; 
 -- What is the average price of products by category?
SELECT cat.cat_name, AVG(p.price) AS avg_price
FROM products p JOIN categories cat ON p.cat_id = cat.cat_id
GROUP BY cat.cat_name;
-- Which products have the highest total sales volume (by quantity)?
SELECT p.prod_id, p.prod_name, SUM(od.quantity) AS qty_sold
FROM order_details od JOIN products p USING (prod_id)
GROUP BY p.prod_id, p.prod_name
ORDER BY qty_sold DESC limit 1;
-- What is the total revenue generated by each product?
SELECT
SUM(o.total_price) AS total_revenue, p.prod_name
FROM order_details o LEFT JOIN
products p ON o.prod_id= p.prod_id
GROUP BY prod_name;
-- How do product sales vary by category and supplier?
SELECT cat.cat_name, s.sup_name, SUM(od.total_price) AS revenue
FROM order_details od
JOIN products p ON od.prod_id=p.prod_id
JOIN categories cat ON p.cat_id = cat.cat_id
JOIN supplier s ON p.sup_id = s.sup_id
GROUP BY cat.cat_name, s.sup_name
ORDER BY cat.cat_name,revenue DESC;
-- 3. Sales and Order Trends
-- Analyze business performance through orders and revenue over time.
-- How many orders have been placed in total?
select count(*) as total from orders;
-- What is the average value per order?
SELECT AVG(t.order_value) AS avg_order_value
FROM (
  SELECT ord_id, SUM(total_price) AS order_value
  FROM order_details
  GROUP BY ord_id
) t;
-- On which dates were the most orders placed?
SELECT STR_TO_DATE(order_date, '%m/%e/%Y') AS order_dt, COUNT(*) AS orders_count
FROM orders
GROUP BY order_dt
ORDER BY orders_count DESC
limit 1;
-- What are the monthly trends in order volume and revenue?
SELECT
LEFT(o.order_date, 7) AS order_month,
COUNT(DISTINCT o.ord_id) AS order_volume,
SUM(od.total_price) AS total_revenue
FROM
orders o
JOIN
order_details od ON o.ord_id = od.ord_id
GROUP BY order_month
ORDER BY order_month;
-- How do order patterns vary across weekdays and weekends?
SELECT
  DAYNAME(STR_TO_DATE(order_date, '%Y/%m/%d')) AS weekday,
  MONTHNAME(STR_TO_DATE(order_date, '%Y/%m/%d')) AS month,
  COUNT(ord_id) AS total_orders
FROM orders
GROUP BY weekday, month
ORDER BY weekday, month;
-- 4️. Supplier Contribution
-- Identify the most active and profitable suppliers.
-- How many suppliers are there in the database?
SELECT COUNT(DISTINCT sup_id) AS suppliers FROM supplier;
-- Which supplier provides the most products?
SELECT s.sup_name, COUNT(*) AS product_count
FROM products p JOIN supplier s ON p.sup_id = s.sup_id
GROUP BY s.sup_name
ORDER BY product_count DESC
limit 1;
-- What is the average price of products from each supplier?
SELECT s.sup_name, AVG(p.price) AS avg_price
FROM products p JOIN supplier s ON p.sup_id = s.sup_id
GROUP BY s.sup_name
ORDER BY avg_price DESC;
-- Which suppliers contribute the most to total product sales (by revenue)?
SELECT s.sup_name, SUM(od.total_price) AS revenue
FROM order_details od
JOIN products p USING (prod_id)
JOIN supplier s ON p.sup_id = s.sup_id
GROUP BY s.sup_name
ORDER BY revenue DESC
LIMIT 1;
-- 5️. Employee Performance
-- Access how employees are handling and influencing sales.
-- How many employees have processed orders?
SELECT COUNT(DISTINCT emp_id) AS active_employees FROM orders;
-- Which employees have handled the most orders?
SELECT e.emp_name, COUNT(*) AS orders_handled
FROM orders o JOIN employees e USING (emp_id)
GROUP BY e.emp_name
ORDER BY orders_handled DESC
LIMIT 1;
-- What is the total sales value processed by each employee?
SELECT e.emp_name, SUM(od.total_price) AS sales_value
FROM orders o
JOIN employees e USING (emp_id)
JOIN order_details od USING (ord_id)
GROUP BY e.emp_name
ORDER BY sales_value DESC;
-- What is the average order value handled per employee?
SELECT
e.emp_id,
e.emp_name,
SUM(od.total_price) / COUNT(DISTINCT o.ord_id) AS avg_value
FROM
employees e
JOIN
orders o ON e.emp_id=O.emp_id
JOIN
order_details od ON o.ord_id=od.ord_id
GROUP BY e.emp_id
ORDER BY avg_value DESC;
-- 6️. Order Details Deep Dive
-- Explore item-level sales patterns and pricing behavior.
-- What is the relationship between quantity ordered and total price?
SELECT quantity, AVG(total_price) AS avg_total, COUNT(*) AS Order_count
FROM order_details
GROUP BY quantity
ORDER BY quantity;
-- What is the average quantity ordered per product?
SELECT p.prod_name, AVG(od.quantity) AS avg_qty
FROM order_details od JOIN products p USING (prod_id)
GROUP BY p.prod_name
ORDER BY avg_qty DESC;
-- How does the unit price vary across products and orders?
SELECT
p.prod_id,
p.prod_name,
od.each_price AS unit_price,
COUNT(od.ord_id) AS times_ordered
FROM
products p
JOIN
order_details od ON p.prod_id=od.prod_id
GROUP BY p.prod_id, od.each_price
ORDER BY p.prod_id, od.each_price;

-- =============================================================
-- END OF SCRIPT
-- =============================================================

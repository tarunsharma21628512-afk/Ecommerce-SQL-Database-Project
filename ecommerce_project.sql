DROP DATABASE IF EXISTS ecommerce_project;
CREATE DATABASE ecommerce_project;
USE ecommerce_project;

-- STEP 1: Customers
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15),
    city VARCHAR(50),
    registration_date DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- STEP 2: Categories
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL
);

-- STEP 3: Products
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category_id INT,
    price DECIMAL(10,2),
    stock_quantity INT,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-- STEP 4: Orders
CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- STEP 5: Order Items
CREATE TABLE order_items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    price DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- STEP 6: Suppliers
CREATE TABLE suppliers (
    supplier_id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_name VARCHAR(100) NOT NULL,
    contact_name VARCHAR(100),
    phone VARCHAR(15),
    email VARCHAR(100),
    city VARCHAR(50)
);

-- STEP 7: Purchase Orders
CREATE TABLE purchase_orders (
    purchase_order_id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_id INT,
    purchase_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10,2),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
);

-- STEP 8: Purchase Items
CREATE TABLE purchase_items (
    purchase_item_id INT AUTO_INCREMENT PRIMARY KEY,
    purchase_order_id INT,
    product_id INT,
    quantity INT,
    cost_price DECIMAL(10,2),
    FOREIGN KEY (purchase_order_id) REFERENCES purchase_orders(purchase_order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Sample Data
INSERT INTO customers (first_name, last_name, email, phone, city)
VALUES
('Tarun', 'Sharma', 'tarun@gmail.com', '9876543210', 'Bulandshahr'),
('Aman', 'Verma', 'aman@gmail.com', '9876500001', 'Delhi'),
('Rohit', 'Kumar', 'rohit@gmail.com', '9876500002', 'Noida');

INSERT INTO categories (category_name)
VALUES
('Electronics'),
('Clothing'),
('Books');

INSERT INTO products (product_name, category_id, price, stock_quantity)
VALUES
('Laptop', 1, 55000, 10),
('T-Shirt', 2, 800, 50),
('Python Book', 3, 500, 30);

INSERT INTO orders (customer_id, total_amount)
VALUES
(1, 55800),
(2, 500),
(3, 1600);

INSERT INTO order_items (order_id, product_id, quantity, price)
VALUES
(1, 1, 1, 55000),
(1, 2, 1, 800),
(2, 3, 1, 500),
(3, 2, 2, 800);

INSERT INTO suppliers (supplier_name, contact_name, phone, email, city)
VALUES
('Tech Supply Co.', 'Rahul Verma', '9876543210', 'rahul@techsupply.com', 'Delhi'),
('Fashion Hub', 'Amit Kumar', '9876501234', 'amit@fashionhub.com', 'Noida'),
('Book World', 'Neha Singh', '9876512345', 'neha@bookworld.com', 'Ghaziabad');

INSERT INTO purchase_orders (supplier_id, total_amount)
VALUES
(1, 275000),
(2, 16000),
(3, 10000);

INSERT INTO purchase_items (purchase_order_id, product_id, quantity, cost_price)
VALUES
(1, 1, 5, 55000),
(2, 2, 20, 800),
(3, 3, 20, 500);

-- Stock Update Logic
UPDATE products 
SET stock_quantity = stock_quantity - 1 
WHERE product_id = 1;

UPDATE products 
SET stock_quantity = stock_quantity - 1 
WHERE product_id = 2;

UPDATE products 
SET stock_quantity = stock_quantity + 5 
WHERE product_id = 1;

-- JOIN Report
SELECT 
    o.order_id,
    c.first_name,
    c.last_name,
    p.product_name,
    oi.quantity,
    oi.price,
    (oi.quantity * oi.price) AS total_price
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id;

-- View 1: Sales by Customer
CREATE VIEW sales_by_customer AS
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(oi.quantity * oi.price) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.first_name, c.last_name;

-- View 2: Sales by Product
CREATE VIEW sales_by_product AS
SELECT 
    p.product_id,
    p.product_name,
    SUM(oi.quantity) AS total_quantity_sold,
    SUM(oi.quantity * oi.price) AS total_sales
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name;

-- View 3: Daily Sales
CREATE VIEW daily_sales AS
SELECT 
    DATE(o.order_date) AS sales_date,
    SUM(oi.quantity * oi.price) AS total_sales
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY DATE(o.order_date);

-- View 4: Stock Report
CREATE VIEW stock_report AS
SELECT 
    p.product_id,
    p.product_name,
    c.category_name,
    p.price,
    p.stock_quantity
FROM products p
JOIN categories c ON p.category_id = c.category_id;

-- Check Views
SELECT * FROM sales_by_customer;
SELECT * FROM sales_by_product;
SELECT * FROM daily_sales;
SELECT * FROM stock_report;

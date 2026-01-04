-- In this SQL file, write (and comment!) the typical SQL queries users will run on your database
-- Inserting data in order to test queries

INSERT INTO categories (name, description) VALUES
('Electronics', 'Gadgets, phones, and computers'),
('Books', 'Paperback and hardcovers'),
('Clothing', 'Men and women fashion');

INSERT INTO addresses (country, city, zip_code, street, apartment) VALUES
('Poland', 'Warsaw', '00-001', 'Marszałkowska 1', '10'), -- Magazyn 1
('Poland', 'Poznan', '60-101', 'Półwiejska 5', NULL),   -- Magazyn 2
('Poland', 'Krakow', '30-001', 'Floriańska 15', '2B');  -- Klient

INSERT INTO warehouses (name, address_id) VALUES
('Central Warehouse WAW', 1),
('Quick Ship POZ', 2);

INSERT INTO products (name, description, price, category_id) VALUES
('iPhone 15', 'Latest Apple smartphone', 3999.99, 1), -- ID 1 (Electronics)
('MacBook Air', 'Lightweight laptop', 4999.00, 1),    -- ID 2 (Electronics)
('Harry Potter', 'Fantasy book', 49.99, 2);           -- ID 3 (Books)

INSERT INTO customers (first_name, last_name, email, password, phone_number, birth_date) VALUES
('Bartłomiej', 'Adamiec', 'badamiec10@gmail.com', 'hashed_secret_pass', '+48123456789', '1995-05-12'),
('Jan', 'Kowalski', 'jan@example.com', 'pass123', '+48987654321', '1990-01-01');

INSERT INTO customer_addresses (customer_id, address_id, address_type) VALUES
(1, 3, 'SHIPPING');

INSERT INTO inventory (product_id, warehouse_id, stock_level) VALUES
(1, 1, 100),
(1, 2, 20),
(2, 1, 50);

INSERT INTO carts (customer_id) VALUES (1);

INSERT INTO cart_items (cart_id, product_id, quantity) VALUES (1, 3, 2);

INSERT INTO orders (customer_id, shipping_address_id, total_amount, status) VALUES
(1, 3, 3999.99, 'shipped');

INSERT INTO order_items (order_id, product_id, quantity, unit_price_snapshot) VALUES
(1, 1, 1, 3999.99);

INSERT INTO payments (order_id, amount, status, provider) VALUES
(1, 3999.99, 'completed', 'blik');

-- QUERIES
-- Customer with email=badamiec10@gmail.com order status
SELECT o.status
FROM orders o
JOIN customers c
ON c.id = o.customer_id
WHERE email = 'badamiec10@gmail.com';

-- In which warehouse we have highest quantity of product with id=1
SELECT warehouse_name, country, city, street, zip_code, apartment
FROM logistics
WHERE product_id = 1
ORDER BY stock_level DESC
LIMIT 1;

-- Where is product with id=1
SELECT *
FROM logistics
WHERE product_id = 1;

-- All products in electronics category
SELECT p.name, p.id, p.price
FROM products p
JOIN categories c
ON p.category_id = c.id
WHERE c.name = 'Electronics';

-- Orders of customer with email=badamiec10@gmail.com
SELECT order_id
FROM customer_service
WHERE email = 'badamiec10@gmail.com';


-- Adding new customer
INSERT INTO customers (first_name, last_name, email, password, phone_number, birth_date)
VALUES ('Anna', 'Nowak', 'anna@example.com', 'securepass', '+48111222333', '2000-12-12');

-- Adding new product
INSERT INTO products (name, description, price, category_id)
VALUES ('Samsung TV', '4K Smart TV', 2500.00, (SELECT id FROM categories WHERE name = 'Electronics'));

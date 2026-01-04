-- CREATING DATABASE
-- Representing all of addresses
CREATE TABLE IF NOT EXISTS "addresses" (
    "id" INTEGER PRIMARY KEY,
    "country" TEXT NOT NULL DEFAULT 'Poland',
    "city" TEXT NOT NULL,
    "zip_code" TEXT NOT NULL,
    "street" TEXT NOT NULL,
    "apartment" TEXT
);

-- Representing product categories
CREATE TABLE IF NOT EXISTS "categories" (
    "id" INTEGER PRIMARY KEY,
    "name" TEXT NOT NULL UNIQUE,
    "description" TEXT NOT NULL
);

-- Representing products that we sell
CREATE TABLE IF NOT EXISTS "products" (
    "id" INTEGER PRIMARY KEY,
    "name" TEXT UNIQUE NOT NULL,
    "description" TEXT,
    "price" DECIMAL(10, 2) NOT NULL,
    "category_id" INTEGER,
    FOREIGN KEY ("category_id") REFERENCES "categories"("id")
);

-- Representing warehouses in which we hold our products
CREATE TABLE IF NOT EXISTS "warehouses" (
    "id" INTEGER PRIMARY KEY,
    "name" TEXT,
    "address_id" INTEGER NOT NULL,
    FOREIGN KEY ("address_id") REFERENCES "addresses"("id")
);

-- Representing how much of exact product we have and where is it
CREATE TABLE IF NOT EXISTS "inventory" (
    "product_id" INTEGER NOT NULL,
    "warehouse_id" INTEGER NOT NULL,
    "stock_level" INTEGER DEFAULT 0 CHECK("stock_level" >= 0),
    PRIMARY KEY ("product_id", "warehouse_id"),
    FOREIGN KEY ("product_id") REFERENCES "products"("id"),
    FOREIGN KEY ("warehouse_id") REFERENCES "warehouses"("id")
);

-- Representing customer and his account
CREATE TABLE IF NOT EXISTS "customers" (
    "id" INTEGER PRIMARY KEY,
    "first_name" TEXT NOT NULL,
    "last_name" TEXT NOT NULL,
    "email" TEXT UNIQUE NOT NULL,
    "password" TEXT NOT NULL,
    "phone_number" TEXT NOT NULL,
    "birth_date" DATE
);

-- Representing only customer addresses
CREATE TABLE IF NOT EXISTS "customer_addresses" (
    "customer_id" INTEGER NOT NULL,
    "address_id" INTEGER NOT NULL,
    "address_type" TEXT  NOT NULL CHECK("address_type" IN ('BILLING', 'SHIPPING')),
    PRIMARY KEY ("customer_id", "address_id"),
    FOREIGN KEY ("customer_id") REFERENCES "customers"("id") ON DELETE CASCADE,
    FOREIGN KEY ("address_id") REFERENCES "addresses"("id") ON DELETE CASCADE
);

-- Representing carts on website
CREATE TABLE IF NOT EXISTS "carts" (
    "id" INTEGER PRIMARY KEY,
    "customer_id" INTEGER NOT NULL,
    "created_at" DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY ("customer_id") REFERENCES "customers"("id") ON DELETE CASCADE
);

-- Representing items in exact cart.
CREATE TABLE IF NOT EXISTS "cart_items" (
    "id" INTEGER PRIMARY KEY,
    "cart_id" INTEGER NOT NULL,
    "product_id" INTEGER NOT NULL,
    "quantity" INTEGER NOT NULL CHECK("quantity" > 0),
    FOREIGN KEY ("cart_id") REFERENCES "carts"("id") ON DELETE CASCADE,
    FOREIGN KEY ("product_id") REFERENCES "products"("id") ON DELETE CASCADE
);

-- Representing orders. Carts that someone accutally wants to buy. More businness meaning
CREATE TABLE IF NOT EXISTS "orders" (
    "id" INTEGER PRIMARY KEY,
    "customer_id" INTEGER NOT NULL,
    "shipping_address_id" INTEGER NOT NULL,
    "total_amount" DECIMAL(10, 2) NOT NULL,
    "status" TEXT NOT NULL CHECK("status" IN ('received', 'unpaid', 'paid', 'shipped', 'delivered', 'cancelled')),
    "created_at" DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY ("customer_id") REFERENCES "customers"("id") ON DELETE CASCADE,
    FOREIGN KEY ("shipping_address_id") REFERENCES "addresses"("id") ON DELETE CASCADE
);

-- Representing items in exact order
CREATE TABLE IF NOT EXISTS "order_items" (
    "id" INTEGER PRIMARY KEY,
    "order_id" INTEGER NOT NULL,
    "product_id" INTEGER NOT NULL,
    "quantity" INTEGER NOT NULL CHECK("quantity" > 0),
    "unit_price_snapshot" DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY ("product_id") REFERENCES "products"("id") ON DELETE CASCADE,
    FOREIGN KEY ("order_id") REFERENCES "orders"("id") ON DELETE CASCADE
);

-- Representing payments in exact order
CREATE TABLE IF NOT EXISTS "payments" (
    "id" INTEGER PRIMARY KEY,
    "order_id" INTEGER NOT NULL,
    "amount" DECIMAL(10, 2) NOT NULL,
    "status" TEXT CHECK("status" IN ('pending', 'completed', 'failed')),
    "provider" TEXT CHECK("provider" IN ('payu', 'p24', 'tpay', 'autopay', 'stripe', 'blik', 'transfer')),
    FOREIGN KEY ("order_id") REFERENCES "orders"("id") ON DELETE CASCADE
);

-- MAKING VIEWS ON DATABASE
CREATE VIEW IF NOT EXISTS "customer_service" AS
SELECT
    c.first_name as first_name,
    c.last_name as last_name,
    c.email as email,
    o.id as order_id,
    p.status as payment_status
FROM orders o
JOIN customers c
ON o.customer_id = c.id
LEFT JOIN payments p
ON p.order_id = o.id;

CREATE VIEW IF NOT EXISTS "logistics" AS
SELECT
    i.stock_level as stock_level,
    w.name as warehouse_name,
    p.id as product_id,
    p.name as product_name,
    p.price as price,
    a.country as country,
    a.city as city,
    a.zip_code as zip_code,
    a.street as street,
    a.apartment as apartment
FROM inventory i
JOIN products p
ON p.id = i.product_id
JOIN warehouses w
ON i.warehouse_id = w.id
JOIN addresses a
ON a.id = w.address_id;

-- MAKING INDEXES ON DATABASE
CREATE INDEX "search_customers" ON "customers" ("first_name", "last_name");
CREATE INDEX "search_orders" ON "orders" ("customer_id");
CREATE INDEX "search_product_name" ON "products" ("name");
CREATE INDEX "search_inventory_product" ON "inventory" ("product_id");

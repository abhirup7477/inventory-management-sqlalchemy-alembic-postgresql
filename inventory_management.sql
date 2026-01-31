create database inventory_db;
create user inventory_user with encrypted password 'sunu';
grant all privileges on database inventory_db to inventory_user;

-- Grant schema privileges
GRANT USAGE, CREATE ON SCHEMA public TO inventory_user;

-- Allow future tables to be accessible
ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT ALL ON TABLES TO inventory_user;


--sql schema design and quaries

create extension if not exists "uuid-ossp";

create table categories(
	id uuid primary key default gen_random_uuid(),
	name text not null unique
);

create table products(
	id uuid primary key default gen_random_uuid(),
	product_name text not null,
	category_id uuid references categories(id) on delete cascade,
	cost decimal(10, 2) not null,
	quantity int check(quantity >= 0) not null,
	status text generated always as(
		case
			when quantity = 0 then 'Out of stock'
			when quantity < 5 then 'Low stock'
			else 'In stock'
		end
	) stored
);

create table orders(
	order_id uuid primary key default gen_random_uuid(),
	prod_id uuid references products(id) on delete cascade,
	quantity int not null default 1,
	order_date timestamp default now()
);

INSERT INTO categories (name) VALUES
	('Electronics'),
	('Clothing'),
	('Books'),
	('Home & Kitchen');

select * from categories;


INSERT INTO products (product_name, category_id, cost, quantity) 
SELECT 
	p.product_name, c.id, p.cost, p.quantity
FROM (
	VALUES
		('Smartphone', 'Electronics', 699.99, 10),
		('Laptop', 'Electronics', 1200.00, 5),
		('Headphones', 'Electronics', 99.99, 15),
		('T-Shirt', 'Clothing', 25.50, 50),
		('Jeans', 'Clothing', 60.00, 30),
		('Jacket', 'Clothing', 120.00, 20),
		('Cookbook', 'Books', 35.00, 25),
		('Novel', 'Books', 15.00, 0),
		('Blender', 'Home & Kitchen', 80.00, 8),
		('Coffee Maker', 'Home & Kitchen', 150.00, 2),
		('CNG', 'Home & Kitchen', 150.00, 0)
) AS p(product_name, category_name, cost, quantity)
JOIN categories c
	ON p.category_name = c.name;

select * from products;

insert into orders (prod_id, quantity)
select
	p.id, o.quantity
from (
	values
		('Smartphone', 2),
		('Smartphone', 1),
		('Laptop', 1),
		('T-Shirt', 3),
		('Jeans', 2),
		('Cookbook', 1),
		('Blender', 2)
) as o(product_name, quantity)
join products p
on p.product_name = o.product_name;

select * from orders;

SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'products';

SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'categories';

SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'orders';

--Select products that are "In Stock" (quantity > 0) and cost more than $50. 
select * from products where quantity > 0 and cost > 50;

--Join: Write a query using an INNER JOIN to show product names alongside their category names. 
select p.product_name as product_name, c.name as category_name 
from products p inner join categories c on p.category_id = c.id;

--Aggregation: Find the total value of inventory (price * quantity) grouped by category. 
select c.name as category, sum(p.cost * p.quantity) as total_inventory_value 
from products p join categories c on p.category_id = c.id group by c.name;

--BTREE index on product_name
create index idx_product_name on products (product_name);

--Transaction
-- Sample orders table
CREATE TABLE IF NOT EXISTS orders (
    order_id SERIAL PRIMARY KEY,
    product_id INT REFERENCES product(product_id),
    user_id INT,
    order_date TIMESTAMP DEFAULT NOW()
);

-- Simulate purchase
DO $$
DECLARE
    current_qty INT;
    prod_id UUID := '5da0dbd9-34e2-4625-af7f-461d617a72de';
BEGIN
    -- Start transaction
    BEGIN
        -- Check current stock
        SELECT quantity INTO current_qty
        FROM products
        WHERE id = prod_id
        FOR UPDATE;  -- lock the row

        IF current_qty > 0 THEN
            -- Subtract 1 from quantity
            UPDATE products
            SET quantity = quantity - 1
            WHERE id = prod_id;

            -- Insert order
            INSERT INTO orders(prod_id, quantity)
            VALUES (prod_id, 1);

            -- Commit if all good
            COMMIT;
            RAISE NOTICE 'Purchase successful!';

        ELSE
            -- Rollback if no stock
            ROLLBACK;
            RAISE NOTICE 'Purchase failed: Out of stock!';
        END IF;
    END;
END;
$$;


alter table categories owner to inventory_user;
alter table products owner to inventory_user;
alter table orders owner to inventory_user;
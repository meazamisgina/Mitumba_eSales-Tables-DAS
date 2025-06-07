CREATE SCHEMA mitumba_esales;
SET search_path TO mitumba_esales;


CREATE TYPE user_role AS ENUM ('customer', 'trader');
CREATE TYPE order_status AS ENUM ('Pending', 'Paid', 'Shipped', 'Delivered');
CREATE TYPE product_category AS ENUM ('High-Quality', 'Fashion Finds');
CREATE TYPE payment_method AS ENUM ('M-Pesa');
CREATE TYPE payment_status AS ENUM ('Pending', 'Success', 'Failed');


create extension if not exists "pgcrypto";


CREATE TABLE users (
    user_id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NULL,
    phone VARCHAR(15) UNIQUE NULL,
    password VARCHAR(255) NOT NULL,
    user_type user_role NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT email_or_phone_check CHECK (
        email IS NOT NULL OR phone IS NOT NULL
    )
);

CREATE TABLE products (
    product_id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    trader_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    category product_category NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    stock INT DEFAULT 1,
    description TEXT not NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE orders (
    order_id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    customer_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    status order_status DEFAULT 'Pending',
    total_price DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE order_items (
    order_item_id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    order_id UUID NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(product_id) ON DELETE CASCADE,
    quantity INT NOT NULL
);

CREATE TABLE transactions (
    transaction_id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    order_id UUID NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    customer_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    amount DECIMAL(10,2) NOT NULL,
    payment_method payment_method DEFAULT 'M-Pesa',
    status payment_status DEFAULT 'Pending',
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE reviews (
    review_id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    customer_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(product_id) ON DELETE CASCADE,
    rating INT CHECK (rating BETWEEN 1 AND 5) NULL,
    comment TEXT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);




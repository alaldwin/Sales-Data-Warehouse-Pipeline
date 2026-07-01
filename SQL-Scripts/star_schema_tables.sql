DROP SCHEMA IF EXISTS star_schema CASCADE;

CREATE SCHEMA star_schema;




-- ==========================
-- Dim Customer Table
-- ==========================

DROP TABLE IF EXISTS star_schema.dim_customer CASCADE;

CREATE TABLE star_schema.dim_customer (
	customerid INT PRIMARY KEY,
	customername VARCHAR(100),
	city VARCHAR(255),
	state VARCHAR(255),
	country VARCHAR(255),
	load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

TRUNCATE TABLE star_schema.dim_customer CASCADE;

INSERT INTO star_schema.dim_customer (
	customerid,
	customername,
	city,
	state,
	country
)

SELECT DISTINCT ON (customerid)
	customerid,
	customername,
	city,
	state,
	country
FROM 
	amazon
ORDER BY customerid;

SELECT * FROM star_schema.dim_customer







-- ==========================
-- dim_product
-- ==========================

DROP TABLE IF EXISTS star_schema.dim_product CASCADE;

CREATE TABLE star_schema.dim_product (
	productid INT PRIMARY KEY,
	productname VARCHAR(100),
	category VARCHAR(50),
	brand VARCHAR(50),
	unitprice DECIMAL(10, 2),
	load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

TRUNCATE TABLE star_schema.dim_product CASCADE;

INSERT INTO star_schema.dim_product (
	productid,
	productname,
	category,
	brand,
	unitprice
)

SELECT DISTINCT ON (productid)
	productid,
	productname,
	category,
	brand,
	unitprice
FROM
	amazon
ORDER BY 
	productid;

SELECT * FROM star_schema.dim_product







-- ==========================
-- dim seller
-- ==========================

DROP TABLE IF EXISTS star_schema.dim_seller CASCADE;

CREATE TABLE star_schema.dim_seller (
	sellerid INT PRIMARY KEY,
	load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

TRUNCATE TABLE star_schema.dim_seller CASCADE;

INSERT INTO star_schema.dim_seller (
	sellerid
)
SELECT DISTINCT ON (sellerid)
	sellerid
FROM 
	amazon
ORDER BY 
	sellerid;

SELECT * FROM star_schema.dim_seller








-- ==========================
-- dim date
-- ==========================

DROP TABLE IF EXISTS star_schema.dim_date CASCADE;

CREATE TABLE star_schema.dim_date (
    dateid DATE PRIMARY KEY,
    year INT NOT NULL,
    month INT NOT NULL,
    day INT NOT NULL,
    quarter INT NOT NULL,
    month_name VARCHAR(20),
    day_name VARCHAR(20)
);

TRUNCATE TABLE star_schema.dim_date CASCADE;

INSERT INTO star_schema.dim_date (
    dateid,
    year,
    month,
    day,
    quarter,
    month_name,
    day_name
)

SELECT DISTINCT
    orderdate::date AS orderid,
    EXTRACT(YEAR FROM orderdate)::INT AS year,
    EXTRACT(MONTH FROM orderdate)::INT AS month,
    EXTRACT(DAY FROM orderdate)::INT AS day,
    EXTRACT(QUARTER FROM orderdate) AS quarter,
    TRIM(TO_CHAR(orderdate, 'Month')) AS month_name,
    TRIM(TO_CHAR(orderdate, 'Day')) AS day_name
FROM amazon;

SELECT * FROM star_schema.dim_date







-- ==========================
-- Fact Orders Tables
-- ==========================

DROP TABLE IF EXISTS star_schema.fact_orders CASCADE;

CREATE TABLE star_schema.fact_orders (
	orderid INT PRIMARY KEY,
    customerid INT NOT NULL,
    productid INT NOT NULL,
    sellerid INT NOT NULL,
	orderdate DATE NOT NULL,
	quantity INT,
	unitprice DECIMAL(10, 2),
	discount DECIMAL(10, 2),
	tax DECIMAL(10, 2),
	shippingcost DECIMAL(10, 2),
	totalamount DECIMAL(10, 2),
	paymentmethod VARCHAR(50),
	orderstatus  VARCHAR(50),
	load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY(customerid)REFERENCES star_schema.dim_customer(customerid),
	FOREIGN KEY(productid)REFERENCES star_schema.dim_product(productid),
	FOREIGN KEY(sellerid)REFERENCES star_schema.dim_seller(sellerid),
	FOREIGN KEY(orderdate)REFERENCES star_schema.dim_date(dateid)
);

TRUNCATE TABLE star_schema.fact_orders CASCADE;

INSERT INTO star_schema.fact_orders (
 	orderid,
    customerid,
    productid,
    sellerid,
    orderdate,
    quantity,
    unitprice,
    discount,
    tax,
    shippingcost,
    totalamount,
    paymentmethod,
    orderstatus
)

SELECT
    orderid,
    customerid,
    productid,
    sellerid,
    orderdate,
    quantity,
    unitprice,
    discount,
    tax,
    shippingcost,
    totalamount,
    paymentmethod,
    orderstatus
FROM 
	amazon;

SELECT * FROM star_schema.fact_orders








-- ==========================
-- INDEXES
-- ==========================

CREATE INDEX idx_fact_customer
ON star_schema.fact_orders(customerid);

CREATE INDEX idx_fact_product
ON star_schema.fact_orders(productid);

CREATE INDEX idx_fact_seller
ON star_schema.fact_orders(sellerid);

CREATE INDEX idx_fact_orderdate
ON star_schema.fact_orders(orderdate);

CREATE INDEX idx_customer_country
ON star_schema.dim_customer(country);

CREATE INDEX idx_product_category
ON star_schema.dim_product(category);

-- Total Sales Volume by Country
SELECT
	RANK() OVER (
		ORDER BY SUM(fo.totalamount) DESC
	) AS sales_rank,
    dc.country,
    SUM(fo.totalamount) AS total_sales,
    ROUND(
		AVG(
		fo.shippingcost), 
		2
	) AS avg_shipping,
    COUNT(fo.orderid) AS order_count
FROM 
	star_schema.fact_orders AS fo
INNER JOIN 
	star_schema.dim_customer AS dc
    ON 
		fo.customerid = dc.customerid
GROUP BY
    dc.country
ORDER BY
    total_sales DESC;





-- Monthly Sales Trend

SELECT
	ROW_NUMBER() OVER (
		PARTITION BY d.year
		ORDER BY d.year, d.month_name
		ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
	) AS number_rows,
	d.year,
	d.month_name,
	SUM(o.totalamount) AS monthly_sales
FROM 
	star_schema.fact_orders AS o
INNER JOIN 
	star_schema.dim_date AS d
    ON 
		o.orderdate = d.dateid
GROUP BY
    d.year,
    d.month_name
ORDER BY
    d.year,
    d.month_name;





-- Yearly Sales

SELECT
	RANK() OVER (
		ORDER BY SUM(o.totalamount)
	) AS yearly_sales_rank,
	d.year,
	SUM(o.totalamount) AS yearly_sales
FROM 
	star_schema.fact_orders AS o
INNER JOIN 
	star_schema.dim_date AS d
	ON 
		o.orderdate = d.dateid
GROUP BY
	d.year
ORDER BY 
	yearly_sales_rank ASC;


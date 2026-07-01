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
	d.year,
	d.month,
	d.month_name,
	SUM(fo.totalamount) AS monthly_sales,
	LAG(SUM(fo.totalamount)) OVER (
		PARTITION BY d.year
		ORDER BY d.month
	) AS previous_month_sales
FROM 
	star_schema.fact_orders AS fo
INNER JOIN 
	star_schema.dim_date AS d
    ON 
		fo.orderdate = d.dateid
GROUP BY
    d.year,
	d.month,
    d.month_name
ORDER BY
    d.year,
	d.month;





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





-- Top 10 Products by Sales

WITH ranked_sales AS (
	SELECT
		RANK() OVER (
			ORDER BY SUM(fo.totalamount) DESC
		) AS sales_rank,
		dp.productname,
		SUM(fo.totalamount) AS total_sales,
		SUM(SUM(fo.totalamount)) OVER (
			ORDER BY SUM(fo.totalamount) DESC
		) AS cumulative_sales
	FROM 
		star_schema.fact_orders AS fo
	INNER JOIN 
		star_schema.dim_product AS dp
		ON 
			fo.productid = dp.productid
	GROUP BY 
		dp.productname
)
SELECT *
FROM
	ranked_sales
WHERE 
	sales_rank <= 10
ORDER BY 
	total_sales ASC;

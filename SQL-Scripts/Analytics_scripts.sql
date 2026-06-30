-- Total Sales Volume by Country
SELECT
	RANK() OVER (
		ORDER BY SUM(o.totalamount) DESC
	) AS sales_rank,
    c.country,
    SUM(o.totalamount) AS total_sales,
    AVG(o.shippingcost) AS avg_shipping,
    COUNT(o.orderid) AS order_count
FROM star_schema.fact_orders AS o
INNER JOIN star_schema.dim_customer AS c
    ON o.customerid = c.customerid
GROUP BY
    c.country
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
FROM star_schema.fact_orders AS o
INNER JOIN star_schema.dim_date AS d
    ON o.orderdate = d.dateid
GROUP BY
    d.year,
    d.month_name
ORDER BY
    d.year,
    d.month_name;

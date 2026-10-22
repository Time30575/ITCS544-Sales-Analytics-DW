CREATE OR REPLACE VIEW marts.vw_sales_analytics AS
SELECT
    f.source_row_id,
    f.order_id,
    d.order_date_value AS order_date,
    d.year AS order_year,
    d.month AS order_month,
    d.day AS order_day,
    a.region_value,
    a.country_value,
    p.product_type_value,
    c.sales_channel_value,
    f.unit_sold,
    f.unit_price,
    f.unit_cost,
    f.total_revenue,
    f.total_cost,
    f.total_profit
FROM marts.fact_sales AS f
LEFT JOIN marts.dim_order_date AS d
    ON f.order_date_id = d.order_date_id
LEFT JOIN marts.dim_area AS a
    ON f.area_sk = a.area_sk
LEFT JOIN marts.dim_product_type AS p
    ON f.product_type_sk = p.product_type_sk
LEFT JOIN marts.dim_sales_channel AS c
    ON f.sales_channel_sk = c.sales_channel_sk;

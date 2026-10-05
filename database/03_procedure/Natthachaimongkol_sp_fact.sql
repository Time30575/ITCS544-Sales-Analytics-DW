CREATE OR REPLACE PROCEDURE mart.sp_populate_fact_sales()
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO mart.fact_sales (
        order_id,
        region_id,
        product_type_id,
        sales_channel_id,
        order_date_id,
        unit_sold,
        unit_price,
        unit_cost,
        total_revenue,
        total_cost,
        total_profit
    )
    SELECT 
        n.order_id,
        MD5(CONCAT(COALESCE(d.region, ''), '_', COALESCE(d.country, ''))),
        MD5(d.item_type),
        MD5(d.sales_channel),
        MD5(d.order_date::text),
        n.unit_sold,
        n.unit_price,
        n.unit_cost,
        (n.unit_sold * n.unit_price) AS total_revenue,
        (n.unit_sold * n.unit_cost) AS total_cost,
        ((n.unit_sold * n.unit_price) - (n.unit_sold * n.unit_cost)) AS total_profit
    FROM staging.tb_stg_transaction_number n
    JOIN staging.tb_stg_transaction_dimension d ON n.order_id = d.order_id
    ON CONFLICT (order_id) DO UPDATE 
    SET region_id = EXCLUDED.region_id,
        product_type_id = EXCLUDED.product_type_id,
        sales_channel_id = EXCLUDED.sales_channel_id,
        order_date_id = EXCLUDED.order_date_id,
        unit_sold = EXCLUDED.unit_sold,
        unit_price = EXCLUDED.unit_price,
        unit_cost = EXCLUDED.unit_cost,
        total_revenue = EXCLUDED.total_revenue,
        total_cost = EXCLUDED.total_cost,
        total_profit = EXCLUDED.total_profit;

END;
$$;
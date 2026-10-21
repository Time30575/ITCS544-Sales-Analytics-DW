CREATE OR REPLACE PROCEDURE marts.sp_populate_fact_sales()
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO marts.fact_sales (
        source_row_id,
        order_id,
        product_type_sk,
        area_sk,
        sales_channel_sk,
        order_date_id,
        unit_sold,
        unit_price,
        unit_cost,
        total_revenue,
        total_cost,
        total_profit
    )
    SELECT
        n.source_row_id,
        n.order_id,
        product.product_type_sk,
        area.area_sk,
        channel.sales_channel_sk,
        order_date.order_date_id,
        n.units_sold::integer,
        n.unit_price::numeric(12, 2),
        n.unit_cost::numeric(12, 2),
        (n.units_sold::integer * n.unit_price::numeric) AS total_revenue,
        (n.units_sold::integer * n.unit_cost::numeric) AS total_cost,
        ((n.units_sold::integer * n.unit_price::numeric) -
         (n.units_sold::integer * n.unit_cost::numeric)) AS total_profit
    FROM staging.tb_stg_transaction_number AS n
    JOIN staging.tb_stg_transaction_dimension AS d
        ON n.source_row_id = d.source_row_id
    JOIN marts.dim_product_type AS product
        ON product.product_type_id = d.item_type
    LEFT JOIN marts.dim_area AS area
        ON area.country_value = d.country
       AND d.order_date::date >= area.effective_start_date
       AND (
            area.effective_end_date IS NULL
            OR d.order_date::date < area.effective_end_date
       )
    LEFT JOIN marts.dim_sales_channel AS channel
        ON channel.sales_channel_id = d.sales_channel
    LEFT JOIN marts.dim_order_date AS order_date
        ON order_date.order_date_value = d.order_date::date
    ON CONFLICT (source_row_id) DO UPDATE
    SET area_sk = EXCLUDED.area_sk,
        sales_channel_sk = EXCLUDED.sales_channel_sk,
        order_date_id = EXCLUDED.order_date_id,
        unit_sold = EXCLUDED.unit_sold,
        unit_price = EXCLUDED.unit_price,
        unit_cost = EXCLUDED.unit_cost,
        total_revenue = EXCLUDED.total_revenue,
        total_cost = EXCLUDED.total_cost,
        total_profit = EXCLUDED.total_profit;
END;
$$;

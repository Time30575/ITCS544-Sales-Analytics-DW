CREATE OR REPLACE PROCEDURE marts.sp_populate_dimensions()
LANGUAGE plpgsql
AS $$
BEGIN
    --Insert/Update Area Dimension
    INSERT INTO marts.dim_area (region_id, region_value, country_value)
    SELECT DISTINCT 
        MD5(CONCAT(COALESCE(region, ''), '_', COALESCE(country, ''))),
        region,
        country
    FROM staging.tb_stg_transaction_dimension
    WHERE region IS NOT NULL OR country IS NOT NULL
    ON CONFLICT (region_id) DO UPDATE 
    SET region_value = EXCLUDED.region_value,
        country_value = EXCLUDED.country_value;

    -- Insert/Update Product Type Dimension
    INSERT INTO marts.dim_product_type (product_type_id, product_type_value)
    SELECT DISTINCT 
        MD5(item_type),
        item_type
    FROM staging.tb_stg_transaction_dimension
    WHERE item_type IS NOT NULL
    ON CONFLICT (product_type_id) DO UPDATE 
    SET product_type_value = EXCLUDED.product_type_value;

    --Insert/Update Sales Channel Dimension
    INSERT INTO marts.dim_sales_channel (sales_channel_id, sales_channel_value)
    SELECT DISTINCT 
        MD5(sales_channel),
        sales_channel
    FROM staging.tb_stg_transaction_dimension
    WHERE sales_channel IS NOT NULL
    ON CONFLICT (sales_channel_id) DO UPDATE 
    SET sales_channel_value = EXCLUDED.sales_channel_value;

    --Insert/Update Order Date Dimension
    INSERT INTO marts.dim_order_date (order_date_id, order_date_value, day, month, year)
    SELECT DISTINCT 
        MD5(order_date::text),
        order_date::date,
        EXTRACT(DAY FROM order_date::date)::INT,
        EXTRACT(MONTH FROM order_date::date)::INT,
        EXTRACT(YEAR FROM order_date::date)::INT
    FROM staging.tb_stg_transaction_dimension
    WHERE order_date IS NOT NULL
    ON CONFLICT (order_date_id) DO UPDATE 
    SET order_date_value = EXCLUDED.order_date_value,
        day = EXCLUDED.day,
        month = EXCLUDED.month,
        year = EXCLUDED.year;

END;
$$;
CREATE OR REPLACE PROCEDURE marts.sp_populate_dimensions()
LANGUAGE plpgsql
AS $$
BEGIN
    IF EXISTS (
        SELECT country, order_date::date
        FROM staging.tb_stg_transaction_dimension
        WHERE country IS NOT NULL
          AND region IS NOT NULL
          AND order_date IS NOT NULL
        GROUP BY country, order_date::date
        HAVING COUNT(DISTINCT region) > 1
    ) THEN
        RAISE EXCEPTION
            'Conflicting region values found for the same country and order date';
    END IF;

    -- Create an area version for the first observed region and each subsequent
    -- change. effective_end_date is exclusive.
    WITH area_observations AS (
        SELECT DISTINCT country, region, order_date::date AS observed_on
        FROM staging.tb_stg_transaction_dimension
        WHERE country IS NOT NULL
          AND region IS NOT NULL
          AND order_date IS NOT NULL
    ),
    area_changes AS (
        SELECT
            country,
            region,
            observed_on,
            LAG(region) OVER (
                PARTITION BY country
                ORDER BY observed_on
            ) AS previous_region
        FROM area_observations
    )
    INSERT INTO marts.dim_area (
        country_value,
        region_value,
        effective_start_date,
        effective_end_date,
        is_current
    )
    SELECT
        country,
        region,
        observed_on,
        NULL,
        FALSE
    FROM area_changes
    WHERE previous_region IS DISTINCT FROM region
    ON CONFLICT (country_value, effective_start_date) DO UPDATE
    SET region_value = EXCLUDED.region_value;

    -- Recalculate version boundaries from the complete staged history.
    UPDATE marts.dim_area
    SET is_current = FALSE;

    WITH area_versions AS (
        SELECT
            area_sk,
            LEAD(effective_start_date) OVER (
                PARTITION BY country_value
                ORDER BY effective_start_date
            ) AS next_start_date
        FROM marts.dim_area
    )
    UPDATE marts.dim_area AS area
    SET effective_end_date = versions.next_start_date,
        is_current = versions.next_start_date IS NULL
    FROM area_versions AS versions
    WHERE area.area_sk = versions.area_sk;

    INSERT INTO marts.dim_product_type (product_type_id, product_type_value)
    SELECT DISTINCT item_type, item_type
    FROM staging.tb_stg_transaction_dimension
    WHERE item_type IS NOT NULL
    ON CONFLICT (product_type_id) DO UPDATE
    SET product_type_value = EXCLUDED.product_type_value;

    INSERT INTO marts.dim_sales_channel (sales_channel_id, sales_channel_value)
    SELECT DISTINCT sales_channel, sales_channel
    FROM staging.tb_stg_transaction_dimension
    WHERE sales_channel IS NOT NULL
    ON CONFLICT (sales_channel_id) DO UPDATE
    SET sales_channel_value = EXCLUDED.sales_channel_value;

    INSERT INTO marts.dim_order_date (
        order_date_id,
        order_date_value,
        day,
        month,
        year
    )
    SELECT DISTINCT
        MD5(order_date::date::text),
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

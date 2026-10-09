CREATE OR REPLACE PROCEDURE staging.etl_transaction_dimension()
LANGUAGE plpgsql
AS $$
BEGIN

    TRUNCATE TABLE staging.tb_stg_transaction_dimension;

    INSERT INTO staging.tb_stg_transaction_dimension (
        order_id,
        order_date,
        region,
        country,
        item_type,
        sales_channel
    )
    SELECT
        "Order ID",

        CASE
            WHEN "Order Date" LIKE '2020-%' THEN TO_CHAR(
                TO_DATE("Order Date", 'YYYY-MM-DD'),
                'MM/DD/YYYY'
            )
            WHEN "Order Date" LIKE '%-2020' THEN TO_CHAR(
                TO_DATE("Order Date", 'MM-DD-YYYY'),
                'MM/DD/YYYY'
            )
            WHEN "Order Date" LIKE '%/2020' THEN TO_CHAR(
                TO_DATE("Order Date", 'MM/DD/YYYY'),
                'MM/DD/YYYY'
            )
            ELSE "Order Date"
        END,

        "Region",

        CASE
            WHEN "Country" = 'US' THEN 'United States of America'
            WHEN "Country" = 'UK' THEN 'United Kingdom'
            ELSE "Country"
        END,

        "Item Type",

        CASE
            WHEN "Sales Channel" = 'Local' THEN 'Offline'
            ELSE "Sales Channel"
        END

    FROM source_system.tb_raw_transaction_dimension
    ;

END;
$$;
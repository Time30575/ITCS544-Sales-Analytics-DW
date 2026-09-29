CREATE OR REPLACE PROCEDURE staging.etl_transaction_number()
LANGUAGE plpgsql
AS $$
BEGIN

    TRUNCATE TABLE staging.tb_stg_transaction_number;

    INSERT INTO staging.tb_stg_transaction_number (
        order_id,
        ship_date,
        units_sold,
        unit_price,
        unit_cost
    )
    SELECT
        "Order ID",

        TO_CHAR(
            TO_DATE("Ship Date", 'YYYY-MM-DD'),
            'MM/DD/YYYY'
        ),

        "Units Sold",
        REPLACE("Unit Price", ',', '.'),
        REPLACE("Unit Cost", ',', '.')

    FROM source_system.tb_raw_transaction_number
    WHERE "Ship Date" LIKE '2020%';

END;
$$;
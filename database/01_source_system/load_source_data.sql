ALTER TABLE source_system.TB_RAW_TRANSACTION_DIMENSION
    ADD COLUMN IF NOT EXISTS source_row_id BIGINT GENERATED ALWAYS AS IDENTITY;
ALTER TABLE source_system.TB_RAW_TRANSACTION_NUMBER
    ADD COLUMN IF NOT EXISTS source_row_id BIGINT GENERATED ALWAYS AS IDENTITY;

TRUNCATE TABLE
    source_system.TB_RAW_TRANSACTION_DIMENSION,
    source_system.TB_RAW_TRANSACTION_NUMBER
RESTART IDENTITY;

\copy source_system.TB_RAW_TRANSACTION_DIMENSION ("Order ID", "Order Date", "Region", "Country", "Item Type", "Sales Channel") FROM '/docker-entrypoint-initdb.d/01_source_system/1m Sales Records - Dimension - Dirty.csv' WITH (FORMAT csv, HEADER true)
\copy source_system.TB_RAW_TRANSACTION_NUMBER ("Order ID", "Ship Date", "Units Sold", "Unit Price", "Unit Cost") FROM '/docker-entrypoint-initdb.d/01_source_system/1m Sales Records - Number - Dirty.csv' WITH (FORMAT csv, HEADER true)


-- The dirty files contain 1,048,575 data rows each (the 1,048,576th line is
-- the header). Load the combined CSV to a temporary table so its remaining
-- rows can be projected into the existing raw tables without extra columns.
DROP TABLE IF EXISTS pg_temp.tmp_sales_records_5m;
CREATE TEMP TABLE tmp_sales_records_5m (
    source_row_number BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    region TEXT,
    country TEXT,
    item_type TEXT,
    sales_channel TEXT,
    order_priority TEXT,
    order_date TEXT,
    order_id TEXT,
    ship_date TEXT,
    units_sold TEXT,
    unit_price TEXT,
    unit_cost TEXT,
    total_revenue TEXT,
    total_cost TEXT,
    total_profit TEXT
);

\copy tmp_sales_records_5m (region, country, item_type, sales_channel, order_priority, order_date, order_id, ship_date, units_sold, unit_price, unit_cost, total_revenue, total_cost, total_profit) FROM '/docker-entrypoint-initdb.d/01_source_system/5m Sales Records.csv' WITH (FORMAT csv, HEADER true)

INSERT INTO source_system.TB_RAW_TRANSACTION_DIMENSION (
    "Order ID", "Order Date", "Region", "Country", "Item Type", "Sales Channel"
)
SELECT order_id, order_date, region, country, item_type, sales_channel
FROM tmp_sales_records_5m
WHERE source_row_number >= 1048576;

INSERT INTO source_system.TB_RAW_TRANSACTION_NUMBER (
    "Order ID", "Ship Date", "Units Sold", "Unit Price", "Unit Cost"
)
SELECT order_id, ship_date, units_sold, unit_price, unit_cost
FROM tmp_sales_records_5m
WHERE source_row_number >= 1048576;

DROP TABLE tmp_sales_records_5m;

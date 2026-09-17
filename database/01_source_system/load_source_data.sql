TRUNCATE TABLE
    source_system.TB_RAW_TRANSACTION_DIMENSION,
    source_system.TB_RAW_TRANSACTION_NUMBER;

\copy source_system.TB_RAW_TRANSACTION_DIMENSION ("Order ID", "Order Date", "Region", "Country", "Item Type", "Sales Channel") FROM '/docker-entrypoint-initdb.d/01_source_system/5m Sales Records - Dimension - Dirty.csv' WITH (FORMAT csv, HEADER true)
\copy source_system.TB_RAW_TRANSACTION_NUMBER ("Order ID", "Ship Date", "Units Sold", "Unit Price", "Unit Cost") FROM '/docker-entrypoint-initdb.d/01_source_system/5m Sales Records - Number - Dirty.csv' WITH (FORMAT csv, HEADER true)

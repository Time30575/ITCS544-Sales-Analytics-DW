-- 1. Build out structural logical namespaces
-- This is acting as source system.
CREATE SCHEMA IF NOT EXISTS source_system;
-- this is landing area from source and cleanup with ETL.
CREATE SCHEMA IF NOT EXISTS staging;
-- this is mart for snowflake schema and reporting.
CREATE SCHEMA IF NOT EXISTS marts;



-- 2. Execute scripts relative to this file so Docker and host psql can both run it
\ir '01_source_system/Time_TB_RAW_TRANSACTION_DIMENSION.sql'
\ir '01_source_system/Time_TB_RAW_TRANSACTION_NUMBER.sql'
\ir '01_source_system/load_source_data.sql'

\ir '02_data_warehouse/02_mart/Time_table_mart_example.sql'
\ir '02_data_warehouse/02_staging/Time_table_staging_example.sql'

-- 3. Execute operational code objects
\ir '03_procedure/01_landing_procedure.sql'



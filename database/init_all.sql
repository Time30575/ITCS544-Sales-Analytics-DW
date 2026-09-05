-- 1. Build out structural logical namespaces
CREATE SCHEMA IF NOT EXISTS source_system;
CREATE SCHEMA IF NOT EXISTS landing;
CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS marts;

-- 2. Execute scripts sequentially relative to Docker's internal path
\i '/docker-entrypoint-initdb.d/scripts/01_source_system/create_source_tables.sql';
\i '/docker-entrypoint-initdb.d/scripts/02_data_warehouse/01_landing.sql';
\i '/docker-entrypoint-initdb.d/scripts/02_data_warehouse/02_staging.sql';
\i '/docker-entrypoint-initdb.d/scripts/02_data_warehouse/03_marts.sql';

-- 3. Execute operational code objects (Add this line at the bottom)
\i '/docker-entrypoint-initdb.d/scripts/03_procedures/prc_load_source_to_landing.sql';
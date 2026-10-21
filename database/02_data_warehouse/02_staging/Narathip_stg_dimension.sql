CREATE TABLE IF NOT EXISTS staging.tb_stg_transaction_dimension (
    source_row_id BIGINT NOT NULL,
    order_id VARCHAR(1000),
    order_date VARCHAR(100),
    region VARCHAR(100),
    country VARCHAR(100),
    item_type VARCHAR(100),
    sales_channel VARCHAR(100)
);

ALTER TABLE staging.tb_stg_transaction_dimension
    ADD COLUMN IF NOT EXISTS source_row_id BIGINT;

CREATE UNIQUE INDEX IF NOT EXISTS uq_stg_transaction_dimension_source_row
    ON staging.tb_stg_transaction_dimension (source_row_id);
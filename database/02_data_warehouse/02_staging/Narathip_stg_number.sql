CREATE TABLE IF NOT EXISTS staging.tb_stg_transaction_number (
    source_row_id BIGINT NOT NULL,
    order_id VARCHAR(1000),
    ship_date VARCHAR(100),
    units_sold VARCHAR(100),
    unit_price VARCHAR(100),
    unit_cost VARCHAR(100)
);

ALTER TABLE staging.tb_stg_transaction_number
    ADD COLUMN IF NOT EXISTS source_row_id BIGINT;

CREATE UNIQUE INDEX IF NOT EXISTS uq_stg_transaction_number_source_row
    ON staging.tb_stg_transaction_number (source_row_id);
CREATE TABLE IF NOT EXISTS staging.tb_stg_transaction_dimension (
    order_id VARCHAR(1000),
    order_date VARCHAR(100),
    region VARCHAR(100),
    country VARCHAR(100),
    item_type VARCHAR(100),
    sales_channel VARCHAR(100)
);
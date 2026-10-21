-- =================================================================
-- DIMENSIONAL TABLES
-- =================================================================

-- A country can move between regions. Keep each observed region assignment
-- as a separate Type 2 version; country_value is the business key.
CREATE TABLE IF NOT EXISTS marts.dim_area (
    area_sk BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    country_value VARCHAR(100) NOT NULL,
    region_value VARCHAR(100),
    effective_start_date DATE NOT NULL,
    effective_end_date DATE,
    is_current BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT uq_dim_area_country_start UNIQUE (country_value, effective_start_date),
    CONSTRAINT chk_dim_area_effective_dates
        CHECK (effective_end_date IS NULL OR effective_end_date > effective_start_date)
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_dim_area_current_country
    ON marts.dim_area (country_value)
    WHERE is_current;

-- These dimensions contain only stable codes/labels in the available source.
CREATE TABLE IF NOT EXISTS marts.dim_product_type (
    product_type_sk BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_type_id VARCHAR(100) NOT NULL UNIQUE,
    product_type_value VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS marts.dim_sales_channel (
    sales_channel_sk BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sales_channel_id VARCHAR(100) NOT NULL UNIQUE,
    sales_channel_value VARCHAR(100) NOT NULL
);

-- Calendar dates are fixed and do not need Type 2 history.
CREATE TABLE IF NOT EXISTS marts.dim_order_date (
    order_date_id VARCHAR(100) PRIMARY KEY,
    order_date_value DATE NOT NULL UNIQUE,
    day INT NOT NULL,
    month INT NOT NULL,
    year INT NOT NULL
);

-- Grain: one row per source transaction record. Order IDs are not unique in
-- the five-million-row source, so source_row_id preserves each input record.
CREATE TABLE IF NOT EXISTS marts.fact_sales (
    source_row_id BIGINT PRIMARY KEY,
    order_id VARCHAR(100) NOT NULL,
    product_type_sk BIGINT NOT NULL,

    area_sk BIGINT,
    sales_channel_sk BIGINT,
    order_date_id VARCHAR(100),

    unit_sold INT,
    unit_price DECIMAL(12, 2),
    unit_cost DECIMAL(12, 2),

    total_revenue DECIMAL(15, 2),
    total_cost DECIMAL(15, 2),
    total_profit DECIMAL(15, 2),

    CONSTRAINT fk_fact_area FOREIGN KEY (area_sk) REFERENCES marts.dim_area(area_sk),
    CONSTRAINT fk_fact_product_type FOREIGN KEY (product_type_sk)
        REFERENCES marts.dim_product_type(product_type_sk),
    CONSTRAINT fk_fact_sales_channel FOREIGN KEY (sales_channel_sk)
        REFERENCES marts.dim_sales_channel(sales_channel_sk),
    CONSTRAINT fk_fact_order_date FOREIGN KEY (order_date_id)
        REFERENCES marts.dim_order_date(order_date_id)
);

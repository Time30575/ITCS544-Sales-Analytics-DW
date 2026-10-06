-- =================================================================
-- DIMENSIONAL TABLES (4 Tables)
-- =================================================================

--Area Dimension Table
CREATE TABLE IF NOT EXISTS marts.dim_area (
    region_id VARCHAR(100) PRIMARY KEY,
    region_value VARCHAR(100),
    country_value VARCHAR(100)
);

--Product Type Dimension Table
CREATE TABLE IF NOT EXISTS marts.dim_product_type (
    product_type_id VARCHAR(100) PRIMARY KEY,
    product_type_value VARCHAR(100)
);

--Sales Channel Dimension Table
CREATE TABLE IF NOT EXISTS marts.dim_sales_channel (
    sales_channel_id VARCHAR(100) PRIMARY KEY,
    sales_channel_value VARCHAR(100) -- ค่า Online / Offline
);

--Order Date Dimension Table
CREATE TABLE IF NOT EXISTS marts.dim_order_date (
    order_date_id VARCHAR(100) PRIMARY KEY,
    order_date_value DATE,
    day INT,
    month INT,
    year INT
);

-- =================================================================
-- FACT TABLE (1 Table)
-- =================================================================

CREATE TABLE IF NOT EXISTS marts.fact_sales (
    order_id VARCHAR(100) PRIMARY KEY,
    
    region_id VARCHAR(100),
    product_type_id VARCHAR(100),
    sales_channel_id VARCHAR(100),
    order_date_id VARCHAR(100),
    
    unit_sold INT,
    unit_price DECIMAL(12, 2),
    unit_cost DECIMAL(12, 2),
    
    total_revenue DECIMAL(15, 2),
    total_cost DECIMAL(15, 2),
    total_profit DECIMAL(15, 2),

    CONSTRAINT fk_fact_area FOREIGN KEY (region_id) REFERENCES marts.dim_area(region_id),
    CONSTRAINT fk_fact_product_type FOREIGN KEY (product_type_id) REFERENCES marts.dim_product_type(product_type_id),
    CONSTRAINT fk_fact_sales_channel FOREIGN KEY (sales_channel_id) REFERENCES marts.dim_sales_channel(sales_channel_id),
    CONSTRAINT fk_fact_order_date FOREIGN KEY (order_date_id) REFERENCES marts.dim_order_date(order_date_id)
);
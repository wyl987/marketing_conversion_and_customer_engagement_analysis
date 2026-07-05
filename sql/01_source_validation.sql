-- confirm Database name
SELECT DB_NAME() AS current_database;

-- confirm the six source tables exist
SELECT 
    SCHEMA_NAME(schema_id) AS schema_name,
    name AS table_name,
    create_date,
    modify_date
FROM sys.tables
WHERE name IN (
    'customers',
    'geography',
    'products',
    'customer_journey',
    'customer_reviews',
    'engagement_data'
)
ORDER BY name;

-- check row counts
SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM dbo.customers
UNION ALL
SELECT 'geography', COUNT(*) FROM dbo.geography
UNION ALL
SELECT 'products', COUNT(*) FROM dbo.products
UNION ALL
SELECT 'customer_journey', COUNT(*) FROM dbo.customer_journey
UNION ALL
SELECT 'customer_reviews', COUNT(*) FROM dbo.customer_reviews
UNION ALL
SELECT 'engagement_data', COUNT(*) FROM dbo.engagement_data;

-- Check table columns
SELECT 
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME IN (
    'customers',
    'geography',
    'products',
    'customer_journey',
    'customer_reviews',
    'engagement_data'
)
ORDER BY TABLE_NAME, ORDINAL_POSITION;

-- check primary keys and foreign keys
SELECT 
    tc.TABLE_NAME,
    tc.CONSTRAINT_NAME,
    tc.CONSTRAINT_TYPE,
    kcu.COLUMN_NAME
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
LEFT JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu
    ON tc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME
WHERE tc.TABLE_NAME IN (
    'customers',
    'geography',
    'products',
    'customer_journey',
    'customer_reviews',
    'engagement_data'
)
ORDER BY tc.TABLE_NAME, tc.CONSTRAINT_TYPE, tc.CONSTRAINT_NAME;


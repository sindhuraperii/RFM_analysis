WITH rfm_metrics AS (
    SELECT 
        c.customer_id,
        CAST((julianday('now') - julianday(MAX(o.order_purchase_timestamp))) AS INTEGER) as recency_days,
        COUNT(DISTINCT o.order_id) as frequency,
        COALESCE(ROUND(SUM(op.payment_value), 2), 0) as monetary_value
    FROM 
        customers c
        LEFT JOIN orders o ON c.customer_id = o.customer_id
        LEFT JOIN order_payments op ON o.order_id = op.order_id
    GROUP BY 
        c.customer_id
),
rfm_filtered AS (
    SELECT *
    FROM rfm_metrics
    WHERE recency_days IS NOT NULL
),
rfm_with_percentiles AS (
    SELECT 
        customer_id,
        recency_days,
        frequency,
        monetary_value,
        PERCENT_RANK() OVER (ORDER BY recency_days ASC) as recency_percentile,
        PERCENT_RANK() OVER (ORDER BY monetary_value DESC) as monetary_percentile
    FROM 
        rfm_filtered
),
segments AS (
    SELECT 
        customer_id,
        recency_days,
        frequency,
        monetary_value,
        CASE 
            WHEN recency_percentile >= 0.75 AND monetary_percentile >= 0.75 THEN 'Best Customers'
            WHEN recency_percentile >= 0.75 AND monetary_percentile >= 0.5 THEN 'Loyal High Value'
            WHEN recency_percentile >= 0.75 THEN 'Loyal Low Value'
            WHEN recency_percentile >= 0.5 AND monetary_percentile >= 0.75 THEN 'At-Risk High Value'
            WHEN recency_percentile >= 0.5 AND monetary_percentile >= 0.5 THEN 'At-Risk Medium Value'
            WHEN recency_percentile >= 0.5 THEN 'At-Risk Low Value'
            WHEN monetary_percentile >= 0.75 THEN 'Lost High Value (Win-back)'
            WHEN monetary_percentile >= 0.5 THEN 'Lost Medium Value'
            ELSE 'Lost Low Value'
        END as segment
    FROM 
        rfm_with_percentiles
)
SELECT 
    segment,
    COUNT(*) as customer_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) as percentage,
    ROUND(SUM(monetary_value), 2) as total_revenue,
    ROUND(AVG(monetary_value), 2) as avg_customer_value
FROM 
    segments
GROUP BY 
    segment
ORDER BY 
    total_revenue DESC;
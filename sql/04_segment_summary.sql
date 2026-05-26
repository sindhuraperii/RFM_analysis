WITH rfm_metrics AS (
    SELECT 
        c.customer_id,
        CAST((julianday('now') - julianday(MAX(o.order_purchase_timestamp))) AS INTEGER) as recency_days,
        COUNT(DISTINCT o.order_id) as frequency,
        ROUND(SUM(op.payment_value), 2) as monetary_value
    FROM 
        customers c
        LEFT JOIN orders o ON c.customer_id = o.customer_id
        LEFT JOIN order_payments op ON o.order_id = op.order_id
    GROUP BY 
        c.customer_id
),
rfm_with_percentiles AS (
    SELECT 
        customer_id,
        recency_days,
        frequency,
        monetary_value,
        PERCENT_RANK() OVER (ORDER BY recency_days DESC) as recency_percentile,
        PERCENT_RANK() OVER (ORDER BY frequency ASC) as frequency_percentile,
        PERCENT_RANK() OVER (ORDER BY monetary_value ASC) as monetary_percentile
    FROM 
        rfm_metrics
),
rfm_with_scores AS (
    SELECT 
        customer_id,
        CASE 
            WHEN recency_percentile >= 0.8 THEN 5
            WHEN recency_percentile >= 0.6 THEN 4
            WHEN recency_percentile >= 0.4 THEN 3
            WHEN recency_percentile >= 0.2 THEN 2
            ELSE 1
        END as r_score,
        CASE 
            WHEN frequency_percentile >= 0.8 THEN 5
            WHEN frequency_percentile >= 0.6 THEN 4
            WHEN frequency_percentile >= 0.4 THEN 3
            WHEN frequency_percentile >= 0.2 THEN 2
            ELSE 1
        END as f_score,
        CASE 
            WHEN monetary_percentile >= 0.8 THEN 5
            WHEN monetary_percentile >= 0.6 THEN 4
            WHEN monetary_percentile >= 0.4 THEN 3
            WHEN monetary_percentile >= 0.2 THEN 2
            ELSE 1
        END as m_score
    FROM 
        rfm_with_percentiles
),
segments AS (
    SELECT 
        customer_id,
        CASE 
            WHEN r_score = 5 AND f_score = 5 AND m_score = 5 THEN 'Champions'
            WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Loyal Customers'
            WHEN r_score <= 2 AND f_score >= 3 THEN 'At-Risk'
            WHEN r_score = 5 AND f_score <= 2 AND m_score <= 2 THEN 'Promising'
            WHEN r_score <= 2 AND f_score <= 2 THEN 'Lost'
            WHEN r_score <= 2 AND f_score >= 3 AND m_score >= 3 THEN 'Hibernating'
            WHEN r_score >= 4 AND f_score <= 2 THEN 'New'
            ELSE 'Potential'
        END as segment
    FROM 
        rfm_with_scores
)
SELECT 
    segment,
    COUNT(*) as customer_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) as percentage
FROM 
    segments
GROUP BY 
    segment
ORDER BY 
    customer_count DESC;
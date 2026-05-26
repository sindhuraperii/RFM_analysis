# Data Dictionary - RFM Analysis

## Customer Data

| Column | Type | Description | Example |
|--------|------|-------------|---------|
| customer_id | TEXT | Unique customer identifier | cust_001 |
| customer_unique_id | TEXT | Kaggle hash ID | a1b2c3d4e5 |
| customer_state | TEXT | State code | SP, RJ, MG |
| recency_days | INTEGER | Days since last purchase | 45 |
| frequency | INTEGER | Total number of purchases | 3 |
| monetary_value | REAL | Total customer spending | 500.50 |

## RFM Scores

| Column | Type | Range | Meaning |
|--------|------|-------|---------|
| r_score | INTEGER | 1-5 | Recency score (5 = most recent) |
| f_score | INTEGER | 1-5 | Frequency score (5 = most frequent) |
| m_score | INTEGER | 1-5 | Monetary score (5 = highest spender) |
| rfm_cell | TEXT | 111-555 | Combined score (e.g., 555 = Champion) |

## Segments Overview

| Segment | Count | Revenue | Avg Value | Strategy |
|---------|-------|---------|-----------|----------|
| Champions | 16,274 | \.26M | \.54 | VIP Rewards |
| Loyal | 7,731 | \ | \.91 | Loyalty Program |
| Potential | 7,836 | \.91M | \.35 | Cross-sell |
| At Risk | 15,277 | \ | \.52 | Win-back |
| Can't Lose | 11,805 | \ | \.23 | Re-engage |
| Need Attention | 15,889 | \.65M | \.59 | Targeted Marketing |
| Lost | 19,642 | \.69M | \.87 | Final Offer |
| Others | 3,753 | \ | \.35 | General |

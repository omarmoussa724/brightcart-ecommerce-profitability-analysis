CREATE DATABASE IF NOT EXISTS brightcart;
USE brightcart;

DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
    order_id        VARCHAR(15)     NOT NULL PRIMARY KEY,
    customer_id     VARCHAR(10)     NOT NULL,
    order_date      DATE            NOT NULL,
    channel         VARCHAR(20)     NOT NULL,   -- Website | Mobile App | Marketplace | Social Commerce
    payment_method  VARCHAR(20),
    region          VARCHAR(20),
    items_ordered   INT,
    primary_category VARCHAR(30)    NOT NULL,   -- 8 categories
    gross_revenue   DECIMAL(10,2)   NOT NULL,
    discount_pct    DECIMAL(5,2)    DEFAULT 0,
    discount_amount DECIMAL(10,2)   DEFAULT 0,
    shipping_cost   DECIMAL(10,2)   DEFAULT 0,
    product_cost    DECIMAL(10,2)   NOT NULL,
    platform_fee    DECIMAL(10,2)   DEFAULT 0,
    transaction_fee DECIMAL(10,2)   DEFAULT 0,
    returned        VARCHAR(3)      NOT NULL,   -- Yes | No
    refund_amount   DECIMAL(10,2)   DEFAULT 0,
    net_revenue     DECIMAL(10,2),
    total_costs     DECIMAL(10,2),
    profit          DECIMAL(10,2)
);

CREATE TABLE products (
    product_id              VARCHAR(10)     NOT NULL PRIMARY KEY,
    product_name            VARCHAR(100),
    category                VARCHAR(30),
    sub_category            VARCHAR(50),
    unit_cost               DECIMAL(10,2),
    selling_price           DECIMAL(10,2),
    shipping_cost_per_unit  DECIMAL(10,2),
    weight_lbs              DECIMAL(6,2),
    supplier                VARCHAR(30)
);

CREATE TABLE marketing_spend (
    id                  INT AUTO_INCREMENT PRIMARY KEY,
    month               VARCHAR(7)      NOT NULL,   -- YYYY-MM
    platform            VARCHAR(30)     NOT NULL,   -- Google Ads | Facebook Ads | Instagram Ads | TikTok Ads | Email Marketing | Influencer
    spend               DECIMAL(10,2),
    impressions         INT,
    clicks              INT,
    conversions         INT,
    revenue_attributed  DECIMAL(12,2),
    cpc                 DECIMAL(8,4),
    cpa                 DECIMAL(8,4),
    roas                DECIMAL(8,4)
);

SELECT *
FROM marketing_spend;

SELECT *
FROM orders;

SELECT *
FROM products;

#Data Quality Check ---------------------
#1_Row Counts -------------------------

SELECT 'orders' AS table_name, COUNT(*) AS row_count 
FROM orders
UNION ALL
SELECT 'products', COUNT(*)             
FROM products
UNION ALL
SELECT 'marketing_spend', COUNT(*)             
FROM marketing_spend;

#2_Date Range ---------------------------------------

SELECT 
    MIN(order_date) AS earliest_order,
    MAX(order_date) AS latest_order
FROM orders;

#3_Distinct Channels & Categories ----------------------

SELECT DISTINCT channel 
FROM orders 
ORDER BY channel;

SELECT DISTINCT primary_category 
FROM orders 
ORDER BY primary_category;

#4_Cost Math -------------------------------------

SELECT COUNT(*) AS cost_math_errors
FROM orders
WHERE ABS((product_cost + shipping_cost + platform_fee + transaction_fee) - total_costs) > 0.05;

#5_Profit Math ---------------------------------

SELECT COUNT(*) AS profit_math_errors
FROM orders
WHERE ABS((net_revenue - total_costs) - profit) > 0.05;

#6_NULL Check ------------------------------------

SELECT
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_ids,
    SUM(CASE WHEN primary_category IS NULL THEN 1 ELSE 0 END) AS null_categories,
    SUM(CASE WHEN gross_revenue    IS NULL THEN 1 ELSE 0 END) AS null_revenue,
    SUM(CASE WHEN profit           IS NULL THEN 1 ELSE 0 END) AS null_profit
FROM orders;

-- ============================================================
-- QUESTION 1: Category Profitability
-- What is the average profit margin by product category?
-- Which are most / least profitable, and what drives the difference?
-- ============================================================
#1_Basic revenue & order count per category:

SELECT
    primary_category AS category,
    COUNT(*) AS total_orders,
    ROUND(SUM(gross_revenue), 2) AS total_gross_revenue,
    ROUND(AVG(gross_revenue), 2) AS avg_order_value
FROM orders
GROUP BY primary_category
ORDER BY total_gross_revenue DESC;

#2_Cost breakdown per category (what's eating the revenue):

SELECT *
FROM orders;

SELECT
    primary_category AS category,
    ROUND(SUM(product_cost), 2) AS total_product_cost,
    ROUND(SUM(shipping_cost), 2) AS total_shipping_cost,
    ROUND(SUM(platform_fee), 2) AS total_platform_fees,
    ROUND(SUM(transaction_fee), 2) AS total_transaction_fees,
    ROUND(SUM(discount_amount), 2) AS total_discounts,
    ROUND(SUM(refund_amount), 2) AS total_refunds,
    ROUND(SUM(total_costs), 2) AS total_costs
FROM orders
GROUP BY primary_category
ORDER BY total_costs DESC;

#3_ Profit & margin per category:

SELECT *
FROM orders;

SELECT
    primary_category AS category,
    ROUND(SUM(net_revenue), 2) AS total_net_revenue,
    ROUND(SUM(total_costs), 2) AS total_costs,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(AVG(profit), 2) AS avg_profit_per_order,
    ROUND(SUM(profit) / SUM(net_revenue) * 100, 2) AS profit_margin_pct
FROM orders
GROUP BY primary_category
ORDER BY profit_margin_pct DESC;

-- ============================================================
-- QUESTION 2: Channel Profitability
-- How does profitability differ across sales channels?
-- Which channel has best/worst profit per order after platform fees?
-- ============================================================

#1_Revenue & order count by channel:

SELECT *
FROM orders;

SELECT
    channel,
    COUNT(*) AS total_orders,
    ROUND(SUM(gross_revenue), 2) AS total_gross_revenue,
    ROUND(AVG(gross_revenue), 2) AS avg_order_value,
    ROUND(SUM(platform_fee), 2) AS total_platform_fees
FROM orders
GROUP BY channel
ORDER BY total_gross_revenue DESC;

#2_Profit per channel after all fees:

SELECT *
FROM orders;

SELECT
    channel,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(AVG(profit), 2) AS avg_profit_per_order,
    ROUND(SUM(profit) / SUM(net_revenue) * 100, 2) AS profit_margin_pct,
    ROUND(SUM(platform_fee) + SUM(transaction_fee), 2) AS total_fees_paid
FROM orders
GROUP BY channel
ORDER BY avg_profit_per_order DESC;

#3_Return rate & refunds by channel:

SELECT *
FROM orders;

SELECT
    channel,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN returned = 'Yes' THEN 1 ELSE 0 END) AS returned_orders,
    ROUND(SUM(CASE WHEN returned = 'Yes' THEN 1 ELSE 0 END) 
          * 100.0 / COUNT(*), 2) AS return_rate_pct,
    ROUND(SUM(refund_amount), 2) AS total_refunds
FROM orders
GROUP BY channel
ORDER BY return_rate_pct DESC;

-- ============================================================
-- QUESTION 3: Return Rate Analysis
-- Return rate by category and channel.
-- Total revenue lost to returns.
-- ============================================================

#1_ Return rate by category:

SELECT *
FROM orders;

SELECT
    primary_category AS category,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN returned = 'Yes' THEN 1 ELSE 0 END) AS returned_orders,
    ROUND(SUM(CASE WHEN returned = 'Yes' THEN 1 ELSE 0 END)
          * 100.0 / COUNT(*), 2) AS return_rate_pct,
    ROUND(SUM(refund_amount), 2) AS total_revenue_lost
FROM orders
GROUP BY primary_category
ORDER BY return_rate_pct DESC;

#2_Total revenue lost to returns:

SELECT *
FROM orders;

SELECT
    COUNT(*) AS total_orders,
    SUM(CASE WHEN returned = 'Yes' THEN 1 ELSE 0 END) AS total_returned_orders,
    ROUND(SUM(CASE WHEN returned = 'Yes' THEN 1 ELSE 0 END)
          * 100.0 / COUNT(*), 2) AS overall_return_rate_pct,
    ROUND(SUM(refund_amount), 2) AS total_revenue_lost,
    ROUND(SUM(refund_amount) / SUM(gross_revenue) * 100, 2) AS refunds_as_pct_of_revenue
FROM orders;

-- ============================================================
-- QUESTION 4: Marketing ROI & ROAS by Platform
-- Which advertising platform delivers the best ROAS?
-- Are any platforms spending without positive return?
-- ============================================================

#1_Total spend & revenue by platform:

SELECT *
FROM marketing_spend;

SELECT
    platform,
    ROUND(SUM(spend), 2) AS total_spend,
    ROUND(SUM(revenue_attributed), 2) AS total_revenue,
    ROUND(SUM(conversions), 0) AS total_conversions,
    ROUND(SUM(clicks), 0) AS total_clicks
FROM marketing_spend
GROUP BY platform
ORDER BY total_spend DESC;

#2_ROAS, CPC & CPA by platform:

SELECT *
FROM marketing_spend;

SELECT
    platform,
    ROUND(SUM(spend), 2) AS total_spend,
    ROUND(SUM(revenue_attributed), 2) AS total_revenue,
    ROUND(SUM(revenue_attributed) / SUM(spend), 2) AS roas,
    ROUND(SUM(spend) / SUM(clicks), 4) AS avg_cpc,
    ROUND(SUM(spend) / SUM(conversions), 2) AS avg_cpa,
    ROUND(SUM(clicks) * 100.0 / SUM(impressions), 3) AS ctr_pct
FROM marketing_spend
GROUP BY platform
ORDER BY roas DESC;


-- ============================================================
-- QUESTION 5: Budget Cut Recommendation
-- If the CEO cuts 20% of marketing budget, where to cut?
-- ============================================================

#1_Spend share + what 20% cut looks like per platform:

SELECT *
FROM marketing_spend;

SELECT
    platform,
    ROUND(SUM(spend), 2) AS total_spend,
    ROUND(SUM(spend) * 100.0 / (SELECT SUM(spend) FROM marketing_spend), 2) AS spend_share_pct,
    ROUND(SUM(revenue_attributed) / SUM(spend), 2) AS roas,
    ROUND(SUM(spend) * 0.20, 2) AS cut_amount_20pct
FROM marketing_spend
GROUP BY platform
ORDER BY roas ASC;

#2_Worst performing month per platform:

SELECT *
FROM marketing_spend;

SELECT
    platform,
    month,
    ROUND(spend, 2) AS spend,
    ROUND(revenue_attributed, 2) AS revenue,
    ROUND(revenue_attributed / spend, 2) AS roas
FROM marketing_spend
WHERE roas = (
    SELECT MIN(roas)
    FROM marketing_spend AS m2
    WHERE m2.platform = marketing_spend.platform
)
ORDER BY roas ASC;


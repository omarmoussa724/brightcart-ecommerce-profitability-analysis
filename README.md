# BrightCart — E-Commerce Profitability Analysis

## Project Overview
A financial analyst project analyzing true profitability for BrightCart,
a DTC e-commerce retailer with $277K+ in gross revenue across 8 product
categories and 4 sales channels. Built with MySQL + Power BI.

## Business Questions Answered
1. Which product categories are most/least profitable after all costs?
2. Which sales channel has the best profit per order after platform fees?
3. How much revenue is lost to returns? Which categories are worst?
4. Which marketing platform delivers the best ROAS?
5. Where should the CEO cut 20% of the marketing budget?

## Key Findings
- Electronics leads with 31.13% profit margin ($13.9K total profit)
- Marketplace channel pays $9,612 in fees — more than its profit ($6,451)
- $20,582 lost to returns — 7.2% return rate, up 200% vs 2024
- TikTok Ads delivers 24x ROAS at $0.15 CPC — most underinvested platform
- Cutting Email + Facebook Ads by 20% saves $26,182 with minimal impact

## Tech Stack
- MySQL 8.0 — data loading, quality checks, analysis queries
- Power BI Desktop — interactive 5-page dashboard

## Dataset
- orders.csv — 2,000 order-level transactions (Jan 2024 – Jan 2026)
- products.csv — 207 SKUs with cost and pricing data
- marketing_spend.csv — 144 rows, 6 platforms × 24 months

## Dashboard Pages
1. Executive Overview — KPI cards + trend analysis
2. Category Profitability — margin ranking + cost drivers
3. Channel Analysis — platform fees impact + profit comparison
4. Return Rate Analysis — category/channel breakdown + monthly trend
5. Marketing ROI & Budget — ROAS by platform + cut recommendation

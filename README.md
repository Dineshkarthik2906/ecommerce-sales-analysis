# 🛒 E-Commerce Sales Analysis — Olist Dataset

![SQL](https://img.shields.io/badge/SQL-MS%20SQL%20Server-blue?logo=microsoftsqlserver)
![Excel](https://img.shields.io/badge/Excel-Dashboard-green?logo=microsoftexcel)
![PowerBI](https://img.shields.io/badge/Power%20BI-Dashboard-yellow?logo=powerbi)
![Dataset](https://img.shields.io/badge/Dataset-99K%2B%20Orders-orange)

## 📌 Project Overview

An end-to-end data analytics project on the **Olist Brazilian E-Commerce dataset** — a real-world dataset containing 99,441 orders from 2016 to 2018. This project covers the complete analytics workflow: data exploration in SQL, interactive dashboards in Excel, and a multi-page visual report in Power BI.

---

## 🎯 Business Questions Answered

- Which product categories generate the most revenue?
- How has monthly revenue grown from 2016 to 2018?
- Who are the top customers and sellers by lifetime value?
- What payment methods do customers prefer?
- Does shipping delay impact customer satisfaction?
- Which Brazilian states drive the most sales?
- What percentage of customers return for repeat purchases?

---

## 📂 Project Structure

```
ecommerce-sales-analysis/
│
├── olist_analysis_mssql.sql       # 10 analytical SQL queries + schema
├── Olist_Ecommerce_Analysis.xlsx  # Excel dashboard with 6 charts
├── Olist_Dashboard.pbix           # Power BI 3-page interactive dashboard
├── screenshots/                   # Query results and dashboard screenshots
│   ├── sql/
│   ├── excel/
│   └── powerbi/
└── README.md
```

---

## 🗃️ Dataset

**Source:** [Olist Brazilian E-Commerce — Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

| Table | Rows | Description |
|---|---|---|
| olist_orders_dataset | 99,441 | Order headers |
| olist_order_items_dataset | 112,650 | Line items per order |
| olist_order_payments_dataset | 103,886 | Payment transactions |
| olist_order_reviews_dataset | 99,224 | Customer reviews |
| olist_customers_dataset | 99,441 | Customer details |
| olist_products_dataset | 32,951 | Product catalog |
| olist_sellers_dataset | 3,095 | Seller information |
| olist_geolocation_dataset | 1,000,163 | ZIP code coordinates |
| product_category_name_translation | 72 | PT → EN category names |

---

## 🗄️ SQL Analysis (MS SQL Server)

10 production-quality queries covering:

| # | Query | Skills Used |
|---|---|---|
| 1 | Revenue & Profit by Product Category | GROUP BY, JOINs |
| 2 | Monthly Revenue Trend | FORMAT, DATE functions |
| 3 | Top 10 Customers by Lifetime Spend | TOP, multi-table JOIN |
| 4 | Payment Method Analysis | Window functions |
| 5 | Customer Review Score Distribution | CASE WHEN |
| 6 | Repeat vs One-Time Customers | CTE, subquery |
| 7 | Cumulative Revenue + MoM Growth | LAG, running total |
| 8 | Top Sellers by Revenue & Rating | Multi-table JOIN |
| 9 | Customer Spend Tier Segmentation | NTILE |
| 10 | Shipping Delay vs Review Score | DATEDIFF, CTE |
| Bonus | State-wise Revenue Heatmap | Aggregation |

---

## 📊 Excel Dashboard

A 6-chart interactive dashboard built from SQL query outputs:

- Top 10 Categories by Revenue — Horizontal Bar Chart
- Monthly Revenue Trend (2016–2018) — Line Chart
- Revenue by Payment Type — Pie Chart
- Customer Review Score Distribution — Color-coded Column Chart
- Delivery Status vs Avg Review Score — Color-coded Bar Chart
- Top 10 States by Revenue — Horizontal Bar Chart

**KPI Summary Row:**
| Total Revenue | Total Orders | Avg Order Value | Avg Review Score |
|---|---|---|---|
| R$ 13,591,644 | 99,441 | R$ 121 | 4.09 ⭐ |

---

## 📈 Power BI Dashboard (3 Pages)

### Page 1 — Sales Overview
- KPI Cards: Total Revenue, Total Orders, Avg Order Value, Avg Review Score
- Monthly Revenue Trend Line Chart
- Revenue by Category Bar Chart

### Page 2 — Customer & Payment Analysis
- Revenue by Payment Type — Donut Chart
- Revenue by State — Bar Chart (Top 10)
- Customer Sentiment — Pie Chart

### Page 3 — Delivery & Satisfaction
- Delivery Status vs Avg Review Score — Color-coded Bar Chart
- Review Score Distribution — Column Chart
- KPI Cards: On Time %, Avg Delivery Days, Total Orders

---

## 🔍 Key Insights

| # | Insight |
|---|---|
| 1 | **Health & Beauty** is the top revenue category at R$ 1.26M |
| 2 | **November 2017** saw a 52% MoM revenue spike — Black Friday effect |
| 3 | **96.88%** of customers are one-time buyers — critical retention gap |
| 4 | **Credit card** dominates at 78.34% of all payments |
| 5 | Late deliveries reduce review scores by **60%** — from 4.29 to 1.70 |
| 6 | **São Paulo** drives 49% of total platform revenue |
| 7 | Platform grew **24x** from R$ 40K (Oct 2016) to R$ 977K (May 2018) |

---

## 🛠️ Tools & Technologies

| Tool | Purpose |
|---|---|
| MS SQL Server (SSMS) | Data storage, querying, analysis |
| Microsoft Excel | Data cleaning, pivot tables, dashboard |
| Power BI Desktop | Interactive multi-page visual dashboard |
| Kaggle | Real-world dataset source |
| GitHub | Version control and portfolio hosting |

---

## 👤 Author

**Dinesh Karthik T**
- 📧 dineshkarthikthulasi@gmail.com
- 💼 [LinkedIn](https://linkedin.com/in/dinesh-karthik-2400a8286)
- 🐙 [GitHub](https://github.com/Dineshkarthik2906)

---

## 📌 How to Use

1. **SQL:** Open `olist_analysis_mssql.sql` in SSMS — import Olist CSVs first
2. **Excel:** Open `Olist_Ecommerce_Analysis.xlsx` — all charts are pre-built
3. **Power BI:** Open `Olist_Dashboard.pbix` — connect to your local SQL Server

---

*This project was built as part of a data analyst portfolio to demonstrate end-to-end analytics skills using real-world data.*

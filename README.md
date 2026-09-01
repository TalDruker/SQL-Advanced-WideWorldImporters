# SQL-Advanced-WideWorldImporters

Welcome to my SQL Server development and business analytics portfolio! This repository showcases advanced T-SQL programming skills using the enterprise-level sample database **WideWorldImporters**.

Each query within this project has been crafted to solve complex operational and strategic business problems through:
 **Advanced Data Analytics & CTEs** — Multi-level common table expressions for structured data pipelines.
 **Window Functions & Ranking** — Leveraging `ROW_NUMBER`, `DENSE_RANK`, and `LAG` for temporal and comparative analytics.
 **Performance-Minded Query Design** — Efficient aggregation, string manipulation, and conditional logic.
 **Business Intelligence KPIs** — Year-over-Year (YoY) growth tracking, trend projections, and predictive customer churn analysis.

The goal is to demonstrate real-world problem solving, robust query structuring, and deep technical proficiency in the T-SQL language.

---

##  Query Catalog & Business Insights

* **Q1: Financial Income & YoY Growth** — Multi-level CTEs calculating yearly revenue, linear projections, and growth rates.
* **Q2: Top Customer Segmentation** — Dynamic customer ranking per year and quarter using `DENSE_RANK`.
* **Q3: Stock Item Profitability** — Inventory item margin analysis based on extended price minus tax.
* **Q4: Nominal Product Price Ranking** — Ranking active items by margin variance (Recommended Retail Price vs. Unit Price).
* **Q5: Supplier Catalog Consolidation** — Relational string flattening and aggregation using `STRING_AGG`.
* **Q6: Global Geographic Customer Profiling** — Granular multi-table joins mapping revenue across continents, countries, and cities.
* **Q7: Cumulative Monthly Sales & Totals** — Running financial totals alongside annual grand totals via `UNION ALL`.
* **Q8: Multi-Year Order Volume Pivoting** — Conditional aggregation (`CASE` statements) mapping order trends across operational years (2013–2016).
* **Q9: Predictive Customer Churn Analytics** — Advanced interval tracking (`LAG`, interval benchmarking) to flag potential customer churn.
* **Q10: Customer Category Market Share** — Pattern matching and distribution share calculations across the customer base.

---

##  Technical Stack & Environment
* **Database Management System:** Microsoft SQL Server (T-SQL)
* **Sample Database:** WideWorldImporters
* **Core Concepts:** Subqueries, CTEs, Window Functions, Conditional Aggregation, String Manipulation, Date/Time Arithmetic.

Stay tuned as more advanced scripts and analytical modules are added!

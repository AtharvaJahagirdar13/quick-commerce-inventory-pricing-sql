# 📊 Inventory & Pricing Analysis for Quick-Commerce (SQL)

<p align="center">
  <img src="https://img.shields.io/badge/SQL-PostgreSQL-blue?style=flat-square">
  <img src="https://img.shields.io/badge/Data-Analytics-green?style=flat-square">
  <img src="https://img.shields.io/badge/Kaggle-Dataset-orange?style=flat-square">
</p>

**TL;DR:**  
SQL-driven analysis on transactional retail data to identify revenue-driving SKUs, demand volatility, pricing sensitivity, and inventory risks. Designed queries that support real business decisions such as replenishment prioritization, pricing strategy, and assortment optimization.

---

## 🧩 Problem

Quick-commerce businesses operate on thin margins and fast inventory cycles.  
This project answers key operational and pricing questions using **only SQL**:

* Which SKUs drive the majority of revenue?
* Which products have volatile demand and higher stock-out risk?
* Where is revenue concentration creating business risk?
* Which products are price-sensitive vs price-stable?
* Which SKUs should be prioritized for replenishment or delisting?

---

## 📦 Dataset

* Dataset: **Online Retail II**
* Source: Kaggle (UCI Machine Learning Repository)

**Primary Table:** `retail`

**Columns:**
* `invoice` – Order identifier  
* `stockcode` – SKU / product ID  
* `description` – Product name  
* `quantity` – Units sold  
* `invoicedate` – Transaction timestamp  
* `price` – Unit selling price  
* `customer_id` – Customer identifier  
* `country` – Market / geography  

**Dataset Link:**  
https://www.kaggle.com/datasets/lakshmi25npathi/online-retail-dataset

---

## 🛠 What I Did

1. Created a normalized transactional table in PostgreSQL  
2. Performed data quality checks (invalid prices, quantities, nulls)  
3. Built a reusable `sales_base` view for standardized revenue analysis  
4. Designed business-driven SQL queries (not just descriptive reporting)  
5. Used CTEs, window functions, correlations, and aggregations  
6. Clearly documented assumptions and analytical limitations  

---

## 📌 Key Business Questions Answered

* **Revenue Concentration (ABC Analysis)**  
  Identified SKUs contributing ~80% of total revenue.

* **Demand Velocity**  
  Calculated average daily demand per SKU to guide replenishment decisions.

* **Inventory Risk (Volatility Proxy)**  
  Flagged SKUs with highly unstable demand patterns.

* **Pricing Sensitivity**  
  Measured correlation between price and demand to identify elastic products.

* **Stock-Out Inference**  
  Detected demand gaps as indicators of potential stock-out events.

* **Customer Concentration**  
  Identified high-revenue customers and dependency risk.

* **Geographic Revenue Risk**  
  Analyzed country-level revenue concentration.

* **Assortment Optimization**  
  Flagged low-performing SKUs for delisting consideration.

---

## 💡 Key Insights

* A small percentage of SKUs contribute the majority of revenue  
* Several products show high demand volatility and require safety stock buffers  
* Certain SKUs are highly price-sensitive, making price increases risky  
* Demand gaps indicate potential lost revenue due to stock-outs  
* Revenue concentration across customers and regions increases business risk  
* Long-tail SKUs add operational complexity with minimal revenue impact  

---



## 📈 Business Recommendations

* **Prioritize A-class SKUs**  
  Ensure high availability and pricing focus for revenue-critical products.

* **Increase safety stock for volatile-demand SKUs**  
  Reduces lost revenue from unexpected demand spikes.

* **Avoid aggressive price increases on elastic products**  
  Minimizes volume-driven revenue loss.

* **Investigate SKUs with frequent demand gaps**  
  Potential stock-out or supply chain issues.

* **Rationalize low-performing SKUs**  
  Reduce inventory clutter and holding costs.

* **Diversify geographic revenue exposure**  
  Lower dependency on a single market.

---

## 📂 Repository Structure

```text
├── retail_inventory_pricing_analysis.sql
├── README.md

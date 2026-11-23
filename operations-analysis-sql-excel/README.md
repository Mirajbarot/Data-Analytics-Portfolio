# Operations Analysis — Online Retail Sales (SQL + Excel / Power BI)

## Business question

An online retailer selling giftware wants to understand its sales: how much it sells, where the revenue comes from, which products drive it, when demand peaks, and how much is lost to returns and cancellations.

## Dataset

**Online Retail, UCI Machine Learning Repository** — real transactional data from a UK-based online retailer, 1 December 2010 to 9 December 2011: 541,909 rows, 25,900 invoices, 38 countries. Amounts are in GBP.

- Download: https://archive.ics.uci.edu/ml/machine-learning-databases/00352/Online%20Retail.xlsx
- Dataset page: https://archive.ics.uci.edu/dataset/352/online+retail
- Source: Chen, Sain & Guo (2012), "Data Mining for the Online Retail Industry", University of Bedfordshire.
- Notes on the data: an InvoiceNo starting with "C" is a cancelled order; rows with a negative Quantity are returned goods; some rows have no CustomerID (guest orders).

## Tools

- SQL (SQLite) — all analysis
- Microsoft Excel / Power BI — monthly revenue trend (see `monthly_revenue.csv`, ready to import)

## Key findings

All numbers below come from the queries in `online_retail_operations_analysis.sql`, run against the downloaded data. "Sales" means positive-quantity rows with a positive unit price on non-cancelled invoices.

### 1. The retailer sold £10.67 million

- **19,960 sales invoices, 5,588,376 units, £10,666,684.54 revenue**
- **Average order value: £534.40**
- Including returns and cancellations, total revenue in the file is £9,747,747.93 — the gap is the returns problem (see finding 5).

### 2. The UK is the business — 84.61% of revenue

- **United Kingdom: £9,025,222.08** (18,019 invoices)
- Next best: Netherlands £285,446.34, EIRE £283,453.96, Germany £228,867.14, France £209,715.11
- International sales exist across 38 countries, but no single overseas market reaches even £300,000 — the business is heavily concentrated at home.

### 3. A cake stand and paper craft lead product sales

- **REGENCY CAKESTAND 3 TIER: £174,484.74** (13,879 units) — the top real product
- **PAPER CRAFT, LITTLE BIRDIE: £168,469.60** (80,995 units — the highest volume of any product)
- **WHITE HANGING HEART T-LIGHT HOLDER: £106,292.77** (37,891 units)
- One honest catch: the raw top-10 list is headed by "DOTCOM POSTAGE" (£206,248.77), which is a delivery charge, not a product — and "Manual" (£78,112.82) is an adjustment line. I excluded those when naming the real best-sellers.

### 4. The Christmas build-up is the peak — November is the biggest month

- **November 2011: £1,509,496.33** (2,769 invoices) — the peak month
- October 2011: £1,154,979.30; September 2011: £1,058,590.17
- February 2011 was the weakest full month: £523,631.89
- December 2011 looks low (£638,792.68) only because the data ends on 9 December 2011 — it is a partial month, not a slow month.

### 5. Returns cost 8.41% of sales revenue

- **10,624 return rows, 484,531 units returned, £896,812.49 in value** — 8.41% of sales revenue
- **3,836 cancelled invoices** — 14.81% of all 25,900 invoices
- Returns and cancellations together are the biggest leak in the operation.

### 6. The customer base is broad, with a few very large buyers

- Top customer **14646 (Netherlands) spent £280,206.02** across 73 orders
- **Top 10 customers account for 17.26%** of identified-customer spend — important, but not a dangerous concentration
- Customer **14911 (EIRE) placed the most orders: 201**
- **1,428 guest invoices (7.15%)** have no CustomerID — orders the retailer cannot follow up on

## What I would recommend

1. **Stock up before September** — revenue jumps from ~£760,000 a month in summer to over £1.5 million in November; the top sellers (Regency Cakestand, Paper Craft Little Birdie) must be in stock by September.
2. **Tackle returns** — 8.41% of revenue and nearly 15% of invoices cancelled is the biggest fixable leak; review which products are returned most.
3. **Grow the next markets** — Netherlands, EIRE and Germany are the strongest overseas markets; the UK cannot carry all growth.
4. **Capture guest customers** — 7.15% of orders have no customer record, so the retailer cannot re-market to them.
5. **Keep the top 10 buyers close** — they drive over 17% of spend, including one customer spending £280,206 in a year.

## Files

- `online_retail_operations_analysis.sql` — all queries used, with the results in comments
- `monthly_revenue.csv` — monthly revenue trend, exported from the queries (ready to open in Excel or import into Power BI)

-- Operations Analysis: Online Retail Sales (SQL)
-- Analyst: Miraj Barot
-- Tools: SQL (SQLite), Microsoft Excel, Power BI
--
-- Dataset: Online Retail, UCI Machine Learning Repository
--   File used: Online Retail.xlsx (541,909 rows), converted to CSV
--   Download: https://archive.ics.uci.edu/ml/machine-learning-databases/00352/Online%20Retail.xlsx
--   Dataset page: https://archive.ics.uci.edu/dataset/352/online+retail
--   Source: Chen, Sain & Guo (2012), "Data Mining for the Online Retail
--   Industry", University of Bedfordshire.
--   Real transactional data from a UK-based online retailer selling
--   giftware, 1 December 2010 to 9 December 2011. Amounts are in GBP.
--   InvoiceNo starting with 'C' = cancelled order. Negative Quantity
--   rows = returned goods.
--
-- How to reproduce:
--   1. Download the file above and convert it to CSV.
--   2. Create the table below and import the CSV (header row removed
--      first). InvoiceDate is stored as text in MM/DD/YYYY HH:MM:SS.
--
--   CREATE TABLE online_retail (
--     InvoiceNo TEXT, StockCode TEXT, Description TEXT,
--     Quantity INTEGER, InvoiceDate TEXT, UnitPrice REAL,
--     CustomerID TEXT, Country TEXT);
--
--   3. Run the queries below. "Sales" means positive-quantity rows with
--      a positive unit price on non-cancelled invoices. Every number in
--      the project README comes from these queries.

-- Q1. How much did the retailer sell, and what is the average order?
SELECT
    COUNT(DISTINCT InvoiceNo) AS total_invoices,
    SUM(Quantity) AS total_units_sold,
    ROUND(SUM(Quantity * UnitPrice), 2) AS gross_revenue_all_rows
FROM online_retail;
-- Result: 25,900 invoices | 5,176,450 units | 9,747,747.93 GBP
--   (all rows, including returns and cancellations)

SELECT
    COUNT(DISTINCT InvoiceNo) AS sales_invoices,
    SUM(Quantity) AS units_sold,
    ROUND(SUM(Quantity * UnitPrice), 2) AS revenue_gbp,
    ROUND(SUM(Quantity * UnitPrice) / COUNT(DISTINCT InvoiceNo), 2)
        AS avg_order_value_gbp
FROM online_retail
WHERE Quantity > 0 AND UnitPrice > 0 AND substr(InvoiceNo, 1, 1) <> 'C';
-- Result: 19,960 sales invoices | 5,588,376 units |
--   10,666,684.54 GBP revenue | 534.40 GBP average order value

-- Q2. Where does revenue come from? (top 10 countries)
SELECT
    Country,
    COUNT(DISTINCT InvoiceNo) AS invoices,
    SUM(Quantity) AS units,
    ROUND(SUM(Quantity * UnitPrice), 2) AS revenue_gbp
FROM online_retail
WHERE Quantity > 0 AND UnitPrice > 0 AND substr(InvoiceNo, 1, 1) <> 'C'
GROUP BY Country
ORDER BY revenue_gbp DESC
LIMIT 10;
-- Result: United Kingdom 9,025,222.08 (18,019 invoices),
--   Netherlands 285,446.34, EIRE 283,453.96, Germany 228,867.14,
--   France 209,715.11, Australia 138,521.31, Spain 61,577.11,
--   Switzerland 57,089.90, Belgium 41,196.34, Sweden 38,378.33

-- Q2b. UK share of revenue
SELECT
    ROUND(100.0 * SUM(CASE WHEN Country = 'United Kingdom'
        THEN Quantity * UnitPrice ELSE 0 END)
        / SUM(Quantity * UnitPrice), 2) AS uk_share_pct
FROM online_retail
WHERE Quantity > 0 AND UnitPrice > 0 AND substr(InvoiceNo, 1, 1) <> 'C';
-- Result: 84.61%

-- Q3. What are the best-selling products? (top 10 by revenue)
SELECT
    Description,
    SUM(Quantity) AS units_sold,
    ROUND(SUM(Quantity * UnitPrice), 2) AS revenue_gbp
FROM online_retail
WHERE Quantity > 0 AND UnitPrice > 0 AND substr(InvoiceNo, 1, 1) <> 'C'
GROUP BY Description
ORDER BY revenue_gbp DESC
LIMIT 10;
-- Result: DOTCOM POSTAGE 206,248.77 (706 units - a delivery charge,
--   not a product), REGENCY CAKESTAND 3 TIER 174,484.74 (13,879 units),
--   PAPER CRAFT, LITTLE BIRDIE 168,469.60 (80,995 units),
--   WHITE HANGING HEART T-LIGHT HOLDER 106,292.77 (37,891 units),
--   PARTY BUNTING 99,504.33, JUMBO BAG RED RETROSPOT 94,340.05,
--   MEDIUM CERAMIC TOP STORAGE JAR 81,700.92 (78,033 units),
--   Manual 78,112.82 (adjustment line), POSTAGE 78,101.88
--   (delivery charge), RABBIT NIGHT LIGHT 66,964.99

-- Q4. When is the peak season? (monthly revenue)
SELECT
    substr(InvoiceDate, 7, 4) || '-' || substr(InvoiceDate, 1, 2) AS month,
    COUNT(DISTINCT InvoiceNo) AS invoices,
    ROUND(SUM(Quantity * UnitPrice), 2) AS revenue_gbp
FROM online_retail
WHERE Quantity > 0 AND UnitPrice > 0 AND substr(InvoiceNo, 1, 1) <> 'C'
GROUP BY month
ORDER BY month;
-- Result: 2010-12 823,746.14 | 2011-01 691,364.56 | 2011-02 523,631.89 |
--   2011-03 717,639.36 | 2011-04 537,808.62 | 2011-05 770,536.02 |
--   2011-06 761,739.90 | 2011-07 719,221.19 | 2011-08 759,138.38 |
--   2011-09 1,058,590.17 | 2011-10 1,154,979.30 | 2011-11 1,509,496.33 |
--   2011-12 638,792.68 (partial month - data ends 9 Dec 2011)

-- Q5. How big is the returns problem?
SELECT
    COUNT(*) AS return_rows,
    SUM(Quantity) AS units_returned,
    ROUND(SUM(Quantity * UnitPrice), 2) AS return_value_gbp
FROM online_retail
WHERE Quantity < 0;
-- Result: 10,624 return rows | -484,531 units | -896,812.49 GBP
--   = 8.41% of sales revenue (896,812.49 / 10,666,684.54)

SELECT COUNT(DISTINCT InvoiceNo) AS cancelled_invoices
FROM online_retail
WHERE substr(InvoiceNo, 1, 1) = 'C';
-- Result: 3,836 cancelled invoices out of 25,900 total (14.81%)

-- Q6. How concentrated is the customer base? (top 10 customers)
SELECT
    CustomerID,
    Country,
    COUNT(DISTINCT InvoiceNo) AS orders,
    ROUND(SUM(Quantity * UnitPrice), 2) AS spend_gbp
FROM online_retail
WHERE Quantity > 0 AND UnitPrice > 0 AND substr(InvoiceNo, 1, 1) <> 'C'
    AND CustomerID <> ''
GROUP BY CustomerID, Country
ORDER BY spend_gbp DESC
LIMIT 10;
-- Result: 14646 (Netherlands) 280,206.02, 73 orders |
--   18102 (United Kingdom) 259,657.30, 60 orders |
--   17450 (United Kingdom) 194,550.79, 46 orders |
--   16446 (United Kingdom) 168,472.50, 2 orders |
--   14911 (EIRE) 143,825.06, 201 orders (most frequent buyer) |
--   12415 (Australia) 124,914.53 | 14156 (EIRE) 117,379.63 |
--   17511 (United Kingdom) 91,062.38 | 16029 (United Kingdom) 81,024.84 |
--   12346 (United Kingdom) 77,183.60, 1 order

-- Q6b. Guest orders (no CustomerID) as a share of sales invoices
SELECT
    COUNT(DISTINCT InvoiceNo) AS guest_invoices,
    ROUND(100.0 * COUNT(DISTINCT InvoiceNo) /
        (SELECT COUNT(DISTINCT InvoiceNo) FROM online_retail
         WHERE Quantity > 0 AND UnitPrice > 0
         AND substr(InvoiceNo, 1, 1) <> 'C'), 2)
        AS guest_invoice_share_pct
FROM online_retail
WHERE Quantity > 0 AND UnitPrice > 0 AND substr(InvoiceNo, 1, 1) <> 'C'
    AND CustomerID = '';
-- Result: 1,428 guest invoices | 7.15% of sales invoices

-- Q6c. Top 10 customers' share of identified-customer spend
SELECT
    ROUND(100.0 * (SELECT SUM(spend) FROM
        (SELECT SUM(Quantity * UnitPrice) AS spend FROM online_retail
         WHERE Quantity > 0 AND UnitPrice > 0
         AND substr(InvoiceNo, 1, 1) <> 'C' AND CustomerID <> ''
         GROUP BY CustomerID ORDER BY spend DESC LIMIT 10))
        / (SELECT SUM(Quantity * UnitPrice) FROM online_retail
           WHERE Quantity > 0 AND UnitPrice > 0
           AND substr(InvoiceNo, 1, 1) <> 'C' AND CustomerID <> ''), 2)
        AS top10_share_pct;
-- Result: 17.26%

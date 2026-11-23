-- Financial Analysis: Bank Telemarketing — SQL
-- Analyst: Miraj Barot
-- Tools: SQL (SQLite), Microsoft Excel
--
-- Dataset: Bank Marketing, UCI Machine Learning Repository
--   File used: bank-additional-full.csv (41,188 clients, 20 attributes)
--   Download: https://archive.ics.uci.edu/ml/machine-learning-databases/00222/bank-additional.zip
--   Dataset page: https://archive.ics.uci.edu/dataset/222/bank+marketing
--   Source: Moro, Cortez & Rita (2014), "A Data-Driven Approach to Predict the
--   Success of Bank Telemarketing", Decision Support Systems.
--   The data covers direct marketing campaigns of a Portuguese bank
--   (May 2008 to November 2010). Target variable y = the client subscribed
--   to a term deposit (yes/no).
--
-- How to reproduce:
--   1. Download and unzip the file above.
--   2. Create the table below and import the CSV (semicolon-separated,
--      header row removed first):
--
--   CREATE TABLE bank_marketing (
--     age INTEGER, job TEXT, marital TEXT, education TEXT,
--     "default" TEXT, housing TEXT, loan TEXT, contact TEXT,
--     month TEXT, day_of_week TEXT, duration INTEGER, campaign INTEGER,
--     pdays INTEGER, previous INTEGER, poutcome TEXT,
--     emp_var_rate REAL, cons_price_idx REAL, cons_conf_idx REAL,
--     euribor3m REAL, nr_employed REAL, y TEXT);
--
--   3. Run the queries below. Every number in the project README comes
--      from these queries.

-- Q1. What share of clients subscribed overall?
SELECT
    COUNT(*) AS total_clients,
    SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END) AS subscribed,
    ROUND(100.0 * SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END) / COUNT(*), 2)
        AS subscription_rate_pct
FROM bank_marketing;
-- Result: 41,188 clients | 4,640 subscribed | 11.27%

-- Q2. Which occupations subscribe most?
SELECT
    job,
    COUNT(*) AS clients,
    SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END) AS subscribed,
    ROUND(100.0 * SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END) / COUNT(*), 2)
        AS rate_pct
FROM bank_marketing
GROUP BY job
ORDER BY rate_pct DESC;
-- Result: student 31.43% (275/875), retired 25.23% (434/1,720),
--   unemployed 14.20%, admin. 12.97%, management 11.22%, unknown 11.21%,
--   technician 10.83%, self-employed 10.49%, housemaid 10.00%,
--   entrepreneur 8.52%, services 8.14%, blue-collar 6.89% (638/9,254)

-- Q3. When should the bank call? (subscription rate by campaign month)
SELECT
    month,
    COUNT(*) AS clients,
    SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END) AS subscribed,
    ROUND(100.0 * SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END) / COUNT(*), 2)
        AS rate_pct
FROM bank_marketing
GROUP BY month
ORDER BY CASE month
    WHEN 'mar' THEN 1 WHEN 'apr' THEN 2 WHEN 'may' THEN 3
    WHEN 'jun' THEN 4 WHEN 'jul' THEN 5 WHEN 'aug' THEN 6
    WHEN 'sep' THEN 7 WHEN 'oct' THEN 8 WHEN 'nov' THEN 9
    WHEN 'dec' THEN 10 END;
-- Result: mar 50.55% (276/546), dec 48.90% (89/182), sep 44.91% (256/570),
--   oct 43.87% (315/718), apr 20.48% (539/2,632), aug 10.60%, jun 10.51%,
--   nov 10.14%, jul 9.05%, may 6.43% (886/13,769).
--   Note: mar/sep/oct/dec have far fewer contacts than may, so treat the
--   high rates as promising but small-sample signals.

-- Q4. Which contact channel works best?
SELECT
    contact,
    COUNT(*) AS clients,
    SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END) AS subscribed,
    ROUND(100.0 * SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END) / COUNT(*), 2)
        AS rate_pct
FROM bank_marketing
GROUP BY contact
ORDER BY rate_pct DESC;
-- Result: cellular 14.74% (3,853/26,144), telephone 5.23% (787/15,044)

-- Q5. How long do the calls last for subscribers vs non-subscribers?
SELECT
    y AS subscribed,
    COUNT(*) AS clients,
    ROUND(AVG(duration), 1) AS avg_call_seconds,
    ROUND(AVG(duration) / 60.0, 1) AS avg_call_minutes,
    MIN(duration) AS min_seconds,
    MAX(duration) AS max_seconds
FROM bank_marketing
GROUP BY y;
-- Result: subscribers averaged 553.2 seconds (9.2 min) vs 220.8 seconds
--   (3.7 min) for non-subscribers.
--   Note: call duration is only known after the call ends, so it cannot
--   be used to choose who to call. It shows that interested clients stay
--   on the line longer; it does not prove longer calls cause subscriptions.

-- Q6. Does the outcome of a previous campaign predict subscription?
SELECT
    poutcome,
    COUNT(*) AS clients,
    SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END) AS subscribed,
    ROUND(100.0 * SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END) / COUNT(*), 2)
        AS rate_pct
FROM bank_marketing
GROUP BY poutcome
ORDER BY rate_pct DESC;
-- Result: success 65.11% (894/1,373), failure 14.23% (605/4,252),
--   nonexistent 8.83% (3,141/35,563)

-- Q7. Who subscribes — by education level?
SELECT
    education,
    COUNT(*) AS clients,
    SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END) AS subscribed,
    ROUND(100.0 * SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END) / COUNT(*), 2)
        AS rate_pct
FROM bank_marketing
GROUP BY education
ORDER BY rate_pct DESC;
-- Result: illiterate 22.22% (4/18 - too small to trust), unknown 14.50%,
--   university.degree 13.72% (1,670/12,168), professional.course 11.35%,
--   high.school 10.84%, basic.4y 10.25%, basic.6y 8.20%, basic.9y 7.82%

-- Q8. Who subscribes — by age band?
SELECT
    CASE
        WHEN age < 30 THEN 'Under 30'
        WHEN age < 40 THEN '30-39'
        WHEN age < 50 THEN '40-49'
        WHEN age < 60 THEN '50-59'
        ELSE '60+'
    END AS age_band,
    COUNT(*) AS clients,
    SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END) AS subscribed,
    ROUND(100.0 * SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END) / COUNT(*), 2)
        AS rate_pct
FROM bank_marketing
GROUP BY age_band
ORDER BY age_band;
-- Result: 60+ 39.56% (472/1,193), Under 30 16.26% (922/5,669),
--   50-59 10.16%, 30-39 10.13%, 40-49 7.92%

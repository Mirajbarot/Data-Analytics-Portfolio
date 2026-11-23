# Financial Analysis — Bank Telemarketing (SQL)

## Business question

A bank runs direct marketing campaigns by phone to sell term deposits. I wanted to find out which clients are most likely to subscribe, so the bank can spend its calling time where it converts best.

## Dataset

**Bank Marketing, UCI Machine Learning Repository** — `bank-additional-full.csv`: 41,188 clients contacted in direct marketing campaigns of a Portuguese bank, May 2008 to November 2010.

- Download: https://archive.ics.uci.edu/ml/machine-learning-databases/00222/bank-additional.zip
- Dataset page: https://archive.ics.uci.edu/dataset/222/bank+marketing
- Source: Moro, Cortez & Rita (2014), "A Data-Driven Approach to Predict the Success of Bank Telemarketing", *Decision Support Systems*.
- Target variable: `y` — the client subscribed to a term deposit (yes/no).

## Tools

- SQL (SQLite) — all analysis
- Microsoft Excel — summary tables (see `subscription_rate_by_job.csv`)

## Key findings

All numbers below come from the queries in `bank_marketing_analysis.sql`, run against the downloaded data.

### 1. Only about 1 in 9 clients subscribes

4,640 of 41,188 clients subscribed — a **subscription rate of 11.27%**. The campaign converts a small minority, so targeting matters more than volume.

### 2. Students and retired clients subscribe most

- **Students: 31.43%** (275 of 875) — nearly 3x the average
- **Retired: 25.23%** (434 of 1,720)
- **Blue-collar: 6.89%** (638 of 9,254) — the lowest rate, even though blue-collar workers were the second-largest group contacted
- Admin staff were the largest group (10,422 clients) at 12.97%

### 3. Timing matters — but the busy month converts worst

- **March: 50.55%** (276 of 546), September: 44.91%, October: 43.87%, December: 48.90% (only 182 contacts — small sample)
- **May had the most contacts (13,769 — a third of all calls) but the lowest rate at 6.43%**
- The high-rate months had far fewer contacts, so I treat them as a promising signal to test, not a guarantee — but May's volume with the worst return is a clear scheduling problem.

### 4. Call clients on their mobile

- **Cellular: 14.74%** (3,853 of 26,144)
- **Telephone: 5.23%** (787 of 15,044)
- Mobile contact converts at nearly 3x the rate of landline.

### 5. Successful calls last longer — but that is not a lever

Calls that ended in a subscription averaged **553.2 seconds (9.2 minutes)** vs **220.8 seconds (3.7 minutes)** for calls that did not. I am careful with this one: call duration is only known after the call ends, so it cannot be used to choose who to call. It shows that interested clients stay on the line longer — not that longer calls cause subscriptions.

### 6. Previous subscribers are the best prospects by far

- Clients who subscribed in a previous campaign re-subscribed **65.11%** of the time (894 of 1,373)
- Previous campaign failed: 14.23%
- Never contacted before: 8.83%

### 7. Who subscribes — education and age

- University degree holders: **13.72%** (1,670 of 12,168); clients with only basic 9 years of schooling: 7.82%
- Clients aged **60+: 39.56%** (472 of 1,193) — the highest of any age band; under-30s: 16.26%; ages 40–49 were the lowest at 7.92%

## What I would recommend

1. **Call previous subscribers first** — at 65.11%, they convert about 6x better than first-time contacts.
2. **Prioritise retired clients and students**, and review why blue-collar clients convert at half the average.
3. **Prefer cellular contact** over landline.
4. **Investigate May** — the highest-volume month delivered the lowest conversion; the campaign calendar needs rebalancing.
5. **Do not use call duration as a targeting rule** — it is an outcome, not a cause.

## Files

- `bank_marketing_analysis.sql` — all queries used, with the results in comments
- `subscription_rate_by_job.csv` — subscription rate by occupation, exported from the queries (ready to open in Excel)

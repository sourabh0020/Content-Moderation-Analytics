# 🛡️ Content Moderation Analytics

### End-to-End Trust & Safety Data Analytics Project — Python · SQL Server · Power BI

<p align="left">
  <img src="https://img.shields.io/badge/Python-Pandas-3776AB?logo=python&logoColor=white" />
  <img src="https://img.shields.io/badge/SQL-Server-CC2927?logo=microsoftsqlserver&logoColor=white" />
  <img src="https://img.shields.io/badge/Power_BI-Dashboard-F2C811?logo=powerbi&logoColor=black" />
  <img src="https://img.shields.io/badge/Rows-1M%2B-success" />
  <img src="https://img.shields.io/badge/Status-Complete-brightgreen" />
</p>

An end-to-end analytics project simulating the work of a Data Analyst inside a **Trust & Safety / Content Moderation** operation — taking a raw, 1,000,844-row ticket dataset through **Python cleaning → SQL Server modeling → SQL business analysis → a 4-page interactive Power BI dashboard**, built to surface real operational issues a moderation team could act on.

This project combines domain knowledge from **4.6 years in Trust & Safety operations (ByteDance / TikTok)** with a self-taught SQL, Python, and Power BI toolset.

---

## 📑 Table of Contents

- [Objective](#-objective)
- [Business Questions](#-business-questions)
- [Tech Stack](#-tech-stack)
- [Dataset](#-dataset)
- [Project Workflow](#-project-workflow)
- [Data Cleaning Highlights](#-data-cleaning-highlights)
- [SQL Analysis](#-sql-analysis)
- [Dashboard](#-dashboard)
- [Key Findings](#-key-findings)
- [Recommendations](#-recommendations)
- [Repository Structure](#-repository-structure)
- [How to Reproduce](#-how-to-reproduce)
- [Contact](#-contact)

---

## 🎯 Objective

Build the analytics layer a Data / MIS / BI Analyst would own for a Trust & Safety operation:

- ✅ Profile and clean a large, messy, real-world-style operational dataset
- ✅ Design a proper star schema (fact + 3 dimension tables) in SQL Server
- ✅ Answer 8 recurring operational business questions with SQL
- ✅ Build a 4-page Power BI dashboard for **three different audiences** — Executive Summary, Moderator Performance, Quality/Risk/Policy, and an individual Moderator Drill-Through
- ✅ Turn the analysis into **concrete operational recommendations**, not just charts

---

## ❓ Business Questions

| # | Question | Why it matters |
|---|---|---|
| 1 | How many tickets were processed, and what were the overall KPIs? | Baseline health of the operation |
| 2 | How has moderation volume changed month over month, by AI vs. human? | Capacity planning, anomaly detection |
| 3 | Which violation categories drive the highest workload? | Where to focus policy & automation |
| 4 | Which moderators handle the highest workload while maintaining quality? | Performance management & coaching |
| 5 | Which team leads have the strongest / weakest teams? | Team-level accountability |
| 6 | Does performance vary by shift (Morning/Evening/Night)? | Staffing & scheduling |
| 7 | Which regions carry the highest workload and risk? | Regional resourcing |
| 8 | Which categories get the most successful appeals? | Signals inconsistent moderation decisions |

---

## 🧰 Tech Stack

| Stage | Tools |
|---|---|
| Data profiling & cleaning | **Python** (Pandas, Jupyter Notebook) |
| Data modeling & analysis | **SQL Server** (star schema, FK constraints, indexing, aggregate queries) |
| Dashboarding | **Power BI** (DAX, slicers, drill-through, conditional formatting) |

---

## 🗂️ Dataset

A synthetic but realistic 12-month Trust & Safety dataset (Aug 2025 – Jul 2026), modeled as a **star schema**:

| Table | Rows | Description |
|---|---|---|
| `fact_content_moderation` | 1,000,844 | One row per moderation ticket decision (AI or human) |
| `dim_moderator` | 501 | Moderator details (region, shift, team lead) |
| `dim_team_lead` | 26 | Team lead reference table (25 human + 1 automated-system row) |
| `dim_category` | 6 | Violation category & severity level |

**Key fact columns:** `moderator_id`, `category_id`, `severity_level`, `region`, `shift_type`, `handling_time_seconds`, `action_taken`, `is_appealed`, `overturn_status`, `is_audited`, `qa_result`, `created_timestamp`

---

## 🔄 Project Workflow

```
Raw CSV (1,000,844 rows + 3 dimension files)
      │
      ▼
Python (Pandas) — profiling, cleaning, feature engineering
      │
      ▼
SQL Server — star schema, FK constraints, indexes
      │
      ▼
SQL — 8 business-question queries
      │
      ▼
Power BI — 4-page interactive dashboard + drill-through
```

---

## 🧹 Data Cleaning Highlights

Every cleaning decision was **validated against the data first**, not assumed:

- 🔍 **Missing `region` (169,160 rows, 16.9%)** → traced back to exactly **117 moderators** with no region in the source moderator dimension itself. Filled with `"Unknown"` in both fact and dimension tables instead of dropping data or guessing.
- ✅ **`qa_result` / `overturn_status` nulls** → validated with crosstabs against `is_audited` / `is_appealed`. Confirmed 100% business-rule-driven — `qa_result` only populated for the 14,433 audited rows, `overturn_status` only populated for the 80,256 appealed rows. No changes needed.
- ✅ **Duplicate checks** → zero duplicate `ticket_id` / `content_id`; one duplicate moderator *name* found across two distinct moderator IDs (a valid real-world case, not an error).
- 🗓️ **Feature engineering** → derived `year`, `quarter`, `month`, `month_name`, `day`, `day_name`, `week`, `hour`, `date` from timestamps for fast Power BI slicing on a 1M-row table.

📓 Full notebook: [Content_moderation_data_analysis.ipynb](https://github.com/sourabh0020/Content-Moderation-Analytics/blob/main/Jupyter_Notebok/Content_moderation_data_analysis.ipynb)

---

## 🗄️ SQL Analysis

Star schema built in SQL Server with foreign keys and targeted indexes for query performance on the 1M-row fact table:

```sql
CREATE INDEX IX_Fact_CreatedTimestamp ON fact_content_moderation(created_timestamp);
CREATE INDEX IX_Fact_Category         ON fact_content_moderation(category_id);
CREATE INDEX IX_Fact_Moderator        ON fact_content_moderation(moderator_id);
CREATE INDEX IX_Fact_Region           ON fact_content_moderation(region);
```

All 8 business questions were answered with dedicated aggregate queries joining the fact table to the relevant dimensions — including the query behind the project's headline finding:

```sql
SELECT c.violation_category,
       ROUND(100.0 * SUM(CASE WHEN f.overturn_status = 'Overturned' THEN 1 ELSE 0 END)
             / NULLIF(SUM(CASE WHEN f.is_appealed = 1 THEN 1 ELSE 0 END), 0), 2) AS overturn_rate_pct
FROM fact_content_moderation f
INNER JOIN dim_category c ON f.category_id = c.category_id
GROUP BY c.violation_category
ORDER BY overturn_rate_pct DESC;
```

📄 Full queries: [Content_moderation_Analysis_Query.sql](https://github.com/sourabh0020/Content-Moderation-Analytics/blob/main/SQL/Content_moderation_Analysis_Query.sql)

---

## 📊 Dashboard

A 4-page Power BI report built to give leadership, workforce managers, and QA/policy teams each a view suited to their decisions.

### 1️⃣ Executive Summary — Leadership View

Provides a high-level view of moderation volume, workforce mix, quality, handling efficiency, and escalation trends.

Key metrics include:

- Total Cases · Human Cases · Automation Cases
- Accuracy · Average Handling Time (AHT) · Escalation Rate
- Cases by Severity
- Cases by Violation Category
- Monthly Cases Trend by Moderator Type (AI vs. human)

**Dashboard image:** https://github.com/sourabh0020/Content-Moderation-Analytics/blob/main/Dashboard/Executive%20Dashboard.png

> **993K** total cases · **716K** human cases (72%) · **277K** automation cases (27.9%) · **83.4%** accuracy · **55.7 sec** avg handling time · **15.3%** escalation rate

### 2️⃣ Moderator Performance — Workforce & QA View

Analyzes moderator-level productivity and quality to identify high performers, performance gaps, and coaching priorities.

Key analysis includes:

- Total Cases · Total Moderators · Cases per Moderator
- Accuracy · Average AHT
- Top 15 Moderators by Cases
- Moderator Accuracy vs. AHT scatter
- Cases by Shift
- Lowest-performing Team Leads by Accuracy

**Dashboard image:** https://github.com/sourabh0020/Content-Moderation-Analytics/blob/main/Dashboard/Mods%20Performance.png

> **716K** human-moderated cases · **500** active moderators · **1.43K** cases/moderator avg · **83.4%** accuracy · **55.7 sec** avg AHT · Night shift carries the largest share (34.79%), ahead of Evening (32.8%) and Morning (32.41%)

### 3️⃣ Quality, Risk & Policy — QA & Policy View

Provides a policy-level view of moderation quality, appeals, overturns, escalation, audits, and severity risk.

Key metrics and analysis include:

- Accuracy · Total Appeals · Appeal Rate · Appeal Overturn Rate
- Escalation Rate · Audit Coverage
- Accuracy by Policy Category
- Action Distribution by Policy Category
- Policy Appeal & Overturn Details table

**Dashboard image:** https://github.com/sourabh0020/Content-Moderation-Analytics/blob/main/Dashboard/Quality%2Crisk%20perfromance.png

> **83.45%** accuracy · **80K** total appeals (**8.02%** appeal rate) · **17.99%** overturn rate · **15.3%** escalation rate · **1.44%** audit coverage

### 4️⃣ Moderator Drill-Through — Individual Investigation

A drill-through page built for 1:1 performance conversations between a team lead and an individual moderator.

Right-click any moderator on the Top 15 list to open their scorecard:

- Total Cases · Accuracy · Average AHT · Appeal Rate · Overturn Rate · Critical Cases
- Monthly Cases Trend
- Accuracy by Violation Category
- Cases by Severity Level and Month

**Dashboard image:** https://github.com/sourabh0020/Content-Moderation-Analytics/blob/main/Dashboard/Mod%20detailed%20drill%20through%20page.png

> Example — moderator **Matthew Moore**: **2,869** total cases · **80.4%** accuracy · **53.9 sec** avg AHT · **9.06%** appeal rate · **19.23%** overturn rate · **390** critical-severity cases

---

## 🔑 Key Findings

- 🤖 **Automation already handles over a quarter of total volume** — 277K of 993K cases (27.9%) are auto-actioned by the AI system. Human moderation still accounts for 716K cases, so headcount dependency remains substantial.

- 📊 **Moderation workload is concentrated in a few categories** — Spam/Scam is the single largest category at **34.94%** of volume, followed by Harassment/Bullying (**24.95%**) and Hate Speech (**15.03%**). Harm to Minors is the smallest by volume (**4.96%**) but among the most severe.

- 🚩 **One team's performance is a clear outlier** — Abigail Shaffer's team posts **59.06% accuracy**, more than 20 points below the next-lowest team lead (Monica Herrera, 81.67%) and well below the org-wide average of 83.4%. This is the single clearest outlier on the entire dashboard.

- ⚖️ **High workload doesn't guarantee high quality** — Matthew Moon leads volume at **2.9K cases**, roughly double the next tier of moderators (~1.5K each) — worth a quick sanity check before treating raw volume as a performance signal on its own.

- ⚠️ **Hate Speech is the strongest policy-risk signal** — despite ranking only 3rd by volume and sitting mid-pack on appeal rate, Hate Speech has a **34.9% overturn rate** — roughly double every other category (14.6%–15.2%). This points to inconsistent policy application, not case volume.

- 📈 **Overall accuracy leaves room for improvement** — the dashboard reports **83.4% overall accuracy**, with the two most severe categories, Violent Extremism (77.78%) and Sexual Content (79.28%), measuring the *lowest* — the opposite of where risk should be concentrated.

- 🏷️ **Case severity skews toward Low and High** — approximately **347K Low-severity** and **298K High-severity** cases, while Critical cases still account for **100K** (10% of total) — a meaningful queue that needs guaranteed coverage regardless of shift.

- 🕐 **Audit coverage is thin relative to what it supports** — only **1.44%** of cases are audited, yet the headline 83.4% accuracy figure is extrapolated from that sample across all 993K cases.

---

## ✅ Recommendations

### Immediate

1. **Run calibration sessions on Hate Speech guidelines** — its 34.9% overturn rate is roughly double every other category and points to inconsistent decision-making, not case difficulty.
2. **Treat Abigail Shaffer's team as a priority coaching/audit case** — a 20+ point accuracy gap this isolated is unlikely to be explained by category mix alone.
3. **Re-audit a larger sample of Hate Speech and Violent Extremism decisions** before using the accuracy KPI for individual performance decisions — current audit coverage is just 1.44%.

### Near-term

4. **Expand automation in Spam/Scam** — it's already the largest category and one of the highest-accuracy ones (87.04%), making it a strong next candidate for further AI coverage, freeing human capacity for lower-accuracy categories.
5. **Investigate the volume gap behind Matthew Moon's 2.9K-case lead** — confirm whether it reflects workload imbalance or simply a long-tenured/full-time moderator before treating it as a straightforward "top performer."
6. **Preserve the current shift balance** — Night (34.79%), Evening (32.8%), and Morning (32.41%) are already close to an even three-way split; no shift is structurally under-resourced.

### Ongoing

7. **Track Appeal Overturn Rate by Policy Category** as a recurring quality KPI, watching for any category that drifts materially above the ~15% baseline.
8. **Evaluate moderators on accuracy and AHT together**, not workload alone, using the Accuracy-vs-AHT scatter on the Moderator Performance page.
9. **Use the moderator drill-through in 1:1 coaching conversations** to move from an org-wide signal to the specific categories and months driving an individual's numbers.
10. **Review region-level cuts with the "Unknown" label in mind** — 16.9% of tickets carry an Unknown region post-cleaning, so any regional breakdown is a minimum, not a complete picture, for those 117 moderators.

---

## 📁 Repository Structure

```
Content-Moderation-Analytics/
│
├── README.md
├── Jupyter_Notebok/
│   └── Content_moderation_data_analysis.ipynb     # Python cleaning & feature engineering
├── SQL/
│   └── Content_moderation_Analysis_Query.sql      # Star schema + 8 business-question queries
├── Dashboard/
│   ├── Executive Dashboard.png
│   ├── Mods Performance.png
│   ├── Quality,risk perfromance.png
│   └── Mod detailed drill through page.png
├── Content_Moderation_Analytics_Dashboard.pdf     # Full Power BI dashboard export
└── Content_Moderation_Analytics_Project_Documentation.docx  # Full project write-up
```

---

## ▶️ How to Reproduce

1. Run `Jupyter_Notebok/Content_moderation_data_analysis.ipynb` on the raw CSVs to clean and export the fact/dimension tables.
2. Load the cleaned CSVs into SQL Server and run the schema + queries in `SQL/Content_moderation_Analysis_Query.sql`.
3. Connect Power BI to SQL Server and rebuild the visuals, or open the `.pdf` export to view the finished dashboard.

---

## 📬 Contact

**Sourabh Yadav** — Data Analyst | SQL · Power BI · Python

📧 sourabhsubh20@gmail.com
🔗 LinkedIn: https://linkedin.com/in/sourabhyadav96 · GitHub: https://github.com/sourabh0020

⭐ If you found this project useful, consider giving it a star!

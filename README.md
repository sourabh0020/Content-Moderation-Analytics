# 🛡️ Content Moderation Analytics

### End-to-End Trust & Safety Data Analytics Project — Python · SQL Server · Power BI

<p align="left">
  <img src="https://img.shields.io/badge/Python-Pandas-3776AB?logo=python&logoColor=white" />
  <img src="https://img.shields.io/badge/SQL-Server-CC2927?logo=microsoftsqlserver&logoColor=white" />
  <img src="https://img.shields.io/badge/Power_BI-Dashboard-F2C811?logo=powerbi&logoColor=black" />
  <img src="https://img.shields.io/badge/Rows-1M%2B-success" />
  <img src="https://img.shields.io/badge/Status-Complete-brightgreen" />
</p>

An end-to-end analytics project simulating the work of a Data Analyst inside a **Trust & Safety / Content Moderation** operation — taking a raw, 1M+ row ticket dataset through **Python cleaning → SQL Server modeling → SQL business analysis → a 4-page interactive Power BI dashboard**, built to surface real operational issues a moderation team could act on.

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
- ✅ Design a proper star schema (fact + dimension tables) in SQL Server
- ✅ Answer 8 recurring operational business questions with SQL
- ✅ Build a multi-page Power BI dashboard for **three different audiences** — leadership, workforce/QA managers, and team leads
- ✅ Turn the analysis into **concrete operational recommendations**, not just charts

---

## ❓ Business Questions

| # | Question | Why it matters |
|---|---|---|
| 1 | How many tickets were processed, and what were the overall KPIs? | Baseline health of the operation |
| 2 | How has moderation volume changed month over month? | Capacity planning, anomaly detection |
| 3 | Which violation categories drive the highest workload? | Where to focus policy & automation |
| 4 | Which moderators handle the highest workload while maintaining quality? | Performance management & coaching |
| 5 | Which team leads have the strongest / weakest teams? | Team-level accountability |
| 6 | Does performance vary by shift (Morning/Evening/Night)? | Staffing & scheduling |
| 7 | Which regions have the highest workload and risk? | Regional resourcing |
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
| `fact_content_moderation` | 1,000,844 | One row per moderation ticket |
| `dim_moderator` | 501 | Moderator details (region, shift, team lead) |
| `dim_team_lead` | 26 | Team lead reference table |
| `dim_category` | 6 | Violation category & severity level |

**Key fact columns:** `moderator_id`, `category_id`, `severity_level`, `region`, `shift_type`, `handling_time_seconds`, `action_taken`, `is_appealed`, `overturn_status`, `is_audited`, `qa_result`, `created_timestamp`

---

## 🔄 Project Workflow

```
Raw CSV (1M+ rows)
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
Power BI — 4-page interactive dashboard
```

---

## 🧹 Data Cleaning Highlights

Every cleaning decision was **validated against the data first**, not assumed:

- 🔍 **Missing `region` (169,160 rows)** → traced back to exactly **117 moderators** with no region in the source moderator dimension itself. Filled with `"Unknown"` in both fact and dimension tables instead of dropping data or guessing.
- ✅ **`qa_result` / `overturn_status` nulls** → validated with crosstabs against `is_audited` / `is_appealed`. Confirmed 100% business-rule-driven (only populated when audited/appealed) — no changes needed.
- ✅ **Duplicate checks** → zero duplicate `ticket_id` / `content_id`; one duplicate moderator *name* found (unique IDs though — valid real-world case, not an error).
- 🗓️ **Feature engineering** → derived `year`, `quarter`, `month`, `month_name`, `day_name`, `week`, `hour`, `date` from timestamps for fast Power BI slicing on a 1M-row table.

📓 Full notebook: [`Content_moderation_data_analysis.ipynb`](https://github.com/sourabh0020/Content-Moderation-Analytics/blob/main/Jupyter_Notebok/Content_moderation_data_analysis.ipynb)

---

## 🗄️ SQL Analysis

Star schema built in SQL Server with foreign keys and targeted indexes for query performance on the 1M-row fact table:

```sql
CREATE INDEX IX_Fact_CreatedTimestamp ON fact_content_moderation(created_timestamp);
CREATE INDEX IX_Fact_Category         ON fact_content_moderation(category_id);
CREATE INDEX IX_Fact_Moderator        ON fact_content_moderation(moderator_id);
CREATE INDEX IX_Fact_Region           ON fact_content_moderation(region);
```

All 8 business questions were answered with dedicated aggregate queries joining the fact table to the relevant dimensions.

📄 Full queries: [`Content_moderation_Analysis_Query.sql`](https://github.com/sourabh0020/Content-Moderation-Analytics/blob/main/SQL/Content_moderation_Analysis_Query.sql)

---

## 📊 Dashboard

A 4-page Power BI report designed to provide a complete view of **Trust & Safety content moderation operations**, covering executive performance, moderator productivity, individual moderator investigation, and policy/quality risk.

### 1️⃣ Executive Overview — Leadership View

Provides a high-level view of moderation volume, workforce mix, quality, handling efficiency, and escalation trends.

Key metrics include:

- Total Cases
- Human Cases
- Automation Cases
- Accuracy
- Average Handling Time (AHT)
- Escalation Rate
- Cases by Severity
- Cases by Policy Category
- Monthly Cases Trend

![Overview Dashboard](https://github.com/sourabh0020/Content-Moderation-Analytics/blob/main/Dashboard/Executive%20Dashboard.png)

> **993K** total cases · **716K** human cases · **277K** automation cases · **83.4%** accuracy · **55.7 sec** avg handling time · **15.3%** escalation rate

### 2️⃣ Moderator Performance — Workforce & QA View

Analyzes moderator-level productivity and quality to identify high performers, performance gaps, and potential coaching priorities.

Key analysis includes:

- Total Cases
- Total Moderators
- Cases per Moderator
- Accuracy
- Average AHT
- Top 15 Moderators by Cases
- Moderator Accuracy vs AHT
- Cases by Shift
- Lowest-performing Team Leads by Accuracy
- Moderator Performance Details

![Moderators Overview](https://github.com/sourabh0020/Content-Moderation-Analytics/blob/main/Dashboard/Mods%20Performance.png)

> **716K** human-moderated cases · **500** moderators · **1.43K** cases/moderator · **83.4%** accuracy · **55.7 sec** avg handling time

### 3️⃣ Quality, Risk & Policy — QA & Policy View

Provides a policy-level view of moderation quality, appeals, overturns, escalation, audits, and severity risk.

Key metrics and analysis include:

- Accuracy
- Total Appeals
- Appeal Rate
- Appeal Overturn Rate
- Escalation Rate
- Audit Coverage
- Accuracy by Policy Category
- Appeal Cases by Policy Category
- Action Distribution by Policy Category
- Cases by Severity
- Appeal Overturn Rate by Policy Category
- Policy Appeal & Overturn Details


![Team & Operations](https://github.com/sourabh0020/Content-Moderation-Analytics/blob/main/Dashboard/Quality%2Crisk%20perfromance.png)

> **83.45%** accuracy · **80K** appeals · **8.02%** appeal rate · **17.99%** appeal overturn rate · **15.3%** escalation rate · **1.44%** audit coverage

### 4️⃣ Moderator Detail Analysis — Individual Investigation

A drill-through page designed for investigating the performance of an individual moderator.

Right-click a moderator from the **Moderator Performance** page to analyze:

- Total Cases
- Accuracy
- Average AHT
- Appeal Rate
- Overturn Rate
- Critical Cases
- Monthly Cases Trend
- Accuracy by Violation Category
- Cases by Severity Level and Month

(https://github.com/sourabh0020/Content-Moderation-Analytics/blob/main/Dashboard/Mod%20detailed%20drill%20through%20page.png)

---

## 🔑 Key Findings

- 🤖 **Automation already handles a significant share of workload** — 277K of 993K cases are classified as automation cases, representing approximately **27.9%** of total moderation volume. Human moderation still accounts for 716K cases, indicating substantial ongoing workforce dependency.

- 📊 **Moderation workload is concentrated in a few policy categories** — Spam/Scam accounts for approximately **347K cases**, followed by Harassment/Bullying at **248K**. These two categories represent the largest share of overall moderation workload and should be closely monitored for capacity and process optimization.

- 🚩 **Moderator performance varies significantly** — the Moderator Performance page identifies meaningful differences in workload and quality across moderators and team leads. The lowest-performing team leads by accuracy should be investigated further before making workforce or coaching decisions.

- ⚖️ **High workload does not automatically indicate high performance** — Matthew Moore handled approximately **2.9K cases**, substantially above the ~1.5K cases handled by many other moderators. His individual drill-through shows **80.4% accuracy**, highlighting the importance of evaluating productivity together with quality.

- ⚠️ **Hate Speech is the strongest policy-risk signal** — Hate Speech has an **8.02% overall appeal rate context** and, more importantly, an **approximately 34.9% appeal overturn rate**, substantially higher than the ~14.6%–15.2% range observed across the other major policy categories. This indicates potential policy interpretation or decision-consistency issues.

- 📈 **Overall moderation quality remains below a perfect decision-accuracy benchmark** — the dashboard reports approximately **83.4% overall accuracy**, meaning there is a meaningful opportunity to improve decision consistency through calibration, coaching, and QA.

- 🏷️ **Case severity is heavily concentrated in High and Medium categories** — approximately **298K High-severity** and **248K Medium-severity** cases are processed, while Critical cases account for approximately **100K** cases. This makes High/Medium-severity workflows important areas for operational monitoring.

- 🕐 **Handling efficiency should be evaluated alongside quality** — overall Average Handling Time is approximately **55.7 seconds**. The Moderator Accuracy vs AHT analysis provides a way to identify moderators who are simultaneously slow and inaccurate versus those who achieve high quality at efficient handling times.

---

## ✅ Recommendations

### Immediate

1. **Prioritize Hate Speech policy calibration** because its **34.9% overturn rate** is materially higher than other policy categories. Review ambiguous policy definitions, common decision errors, and escalation guidance.

2. **Investigate low-accuracy teams and moderators** using the Moderator Performance page and individual drill-through page to determine whether performance gaps are concentrated in specific policy categories or severity levels.

3. **Review high-volume moderators together with quality metrics** rather than treating ticket volume as a standalone productivity indicator. Matthew Moore is a good example: high workload should be evaluated alongside his **80.4% accuracy**.

### Near-term

4. **Target coaching using the Accuracy vs AHT analysis**:
   - Low accuracy + high AHT → priority coaching
   - Low accuracy + low AHT → quality-risk investigation
   - High accuracy + high AHT → productivity improvement
   - High accuracy + low AHT → potential best-practice benchmark

5. **Review the highest-volume policy categories**, particularly Spam/Scam and Harassment/Bullying, for opportunities to improve workflow efficiency, automation coverage, and policy clarity.

6. **Evaluate automation opportunities carefully** using both workload and quality metrics. The current dataset shows **277K automation cases (~27.9%)**, so future automation expansion should be supported by QA/error monitoring rather than volume alone.

### Ongoing

7. **Monitor Appeal Overturn Rate by Policy Category** as a recurring policy-quality KPI, with particular attention to categories significantly above the overall benchmark.

8. **Track productivity and quality together** — Cases/Moderator, AHT, Accuracy, Appeals, and Overturn Rate should be evaluated as a combined performance framework.

9. **Use the moderator drill-through during coaching conversations** to move from an overall performance signal to the specific categories, months, and severity levels contributing to the issue.

10. **Maintain a monthly executive review** covering workload, human vs automation mix, accuracy, AHT, escalation, appeals, and policy overturn trends.

## 📁 Repository Structure

```
content-moderation-analytics/
│
├── README.md
├── Content_moderation_data_analysis.ipynb     # Python cleaning & feature engineering
├── Content_moderation_Analysis_Query.sql      # SQL modeling + 8 business-question queries
├── Content_Moderation_Analytics_Dashboard.pdf # Full Power BI dashboard export
├── Content_Moderation_Analytics_Project_Documentation.docx  # Full project write-up
└── assets/
    ├── 01_overview_dashboard.jpg
    ├── 02_moderators_overview.jpg
    ├── 03_team_operations.jpg
    └── 04_drillthrough_moderator.png
```

---

## ▶️ How to Reproduce

1. Run `Content_moderation_data_analysis.ipynb` on the raw CSVs to clean and export the fact/dimension tables.
2. Load the cleaned CSVs into SQL Server and run the schema + queries in `Content_moderation_Analysis_Query.sql`.
3. Connect Power BI to SQL Server and rebuild the visuals, or open the `.pdf` export to view the finished dashboard.

---

## 📬 Contact

**Sourabh**
📧 sourabhsubh20@gmail.com
🔗 [LinkedIn](https://linkedin.com/in/sourabhyadav96) · [GitHub](https://github.com/sourabh0020)

⭐ If you found this project useful, consider giving it a star!

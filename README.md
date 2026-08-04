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

📓 Full notebook: [`Content_moderation_data_analysis.ipynb`](./Content_moderation_data_analysis.ipynb)

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

📄 Full queries: [`Content_moderation_Analysis_Query.sql`](./Content_moderation_Analysis_Query.sql)

---

## 📊 Dashboard

A 4-page Power BI report built for **three different audiences**, plus a drill-through page for individual moderator investigation.

### 1️⃣ Overview — Leadership View
KPIs, category/severity breakdown, monthly trend, action-taken mix.

![Overview Dashboard](./assets/01_overview_dashboard.jpg)

> **993K** total tickets · **40.12s** avg handling time · **83.45%** accuracy · **8.02%** appeal rate · **27.94%** AI automation · **10.08%** Critical cases

### 2️⃣ Moderators Overview — Workforce / QA Manager View
Individual moderator workload, speed, and accuracy.

![Moderators Overview](./assets/02_moderators_overview.jpg)

> **500** moderators · **1.43K** avg tickets/moderator · sortable table with conditional-format accuracy

### 3️⃣ Team & Operations — Team Lead / Ops View
Team-lead accuracy heatmap, regional workload, shift comparison.

![Team & Operations](./assets/03_team_operations.jpg)

> **25** teams · **5** regions · Team Lead × Severity accuracy heatmap

### 4️⃣ Drill-Through — Individual Moderator Detail
Right-click any moderator on Page 2 to drill into their personal trend, category-level accuracy, and severity breakdown by month.

<img src="./assets/04_drillthrough_moderator.png" width="600" />

---

## 🔑 Key Findings

- 🤖 **Automation headroom** — only 27.94% of tickets are AI-reviewed, despite Spam/Scam (347K tickets, Low severity) being an ideal automation target.
- 🚩 **One team lead is a clear outlier** — Abigail Shaffer's team runs at 87.16s avg handling time (vs. ~54s everywhere else) *and* has the lowest accuracy across all four severity levels — slow **and** inaccurate, not a speed/quality tradeoff.
- ⚖️ **Uneven workload** — Matthew Moore processed 2.9K tickets vs. a ~1.5K norm — worth an accuracy audit before treating it as a positive outlier.
- 📉 **Volume anomaly** — February 2026 drops to 76.6K tickets against an 82K–85K baseline — the sharpest deviation in the 12-month trend.
- ⚠️ **Overturn rate by category** is the cleanest signal of policy inconsistency in the dataset — more useful than a single moderator's accuracy score.
- 🕐 **Shift timing isn't a quality driver** — accuracy is flat across Morning/Evening/Night (84% / 84% / 83%).

---

## ✅ Recommendations

**Immediate**
1. Calibration review for Abigail Shaffer's team using the drill-through page to isolate whether the gap is category-specific or broad.
2. QA sample audit of Matthew Moore's decisions before treating his ticket volume as a positive signal.
3. Investigate the February 2026 volume drop with the reporting/ingestion owner.

**Near-term**
4. Expand AI-automation rules within Spam/Scam and other Low-severity categories, monitored against QA pass rate.
5. Use the overturn-rate-by-category ranking to prioritize policy clarification sessions.
6. Set a standing monthly review of the Team & Operations heatmap.

**Ongoing**
7. Track tickets/moderator alongside accuracy — never in isolation.
8. Make the drill-through page the default first step in every coaching conversation.

---

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

create database ContentModerationDB;

use ContentModerationDB;

SELECT COUNT(*) AS FactRows
FROM dbo.fact_content_moderation;

SELECT COUNT(*) AS CategoryRows
FROM dbo.dim_category;

SELECT COUNT(*) AS TeamLeadRows
FROM dbo.dim_team_lead;

SELECT COUNT(*) AS ModeratorRows
FROM dbo.dim_moderator;

/*
Output: 
FactRows
1000844
------------
CategoryRows
6
------------
TeamLeadRows
26
------------
ModeratorRows
501
*/

--- Creating FK constraint as PK is already created while importing as flat file 

ALTER TABLE fact_content_moderation
ADD CONSTRAINT FK_fact_moderator
FOREIGN KEY (moderator_id)
REFERENCES dim_moderator(moderator_id);

ALTER TABLE fact_content_moderation
ADD CONSTRAINT FK_fact_teamlead
FOREIGN KEY (team_lead_id)
REFERENCES dim_team_lead(team_lead_id);

ALTER TABLE fact_content_moderation
ADD CONSTRAINT FK_fact_category
FOREIGN KEY (category_id)
REFERENCES dim_category(category_id);

-- Create Indexes

CREATE INDEX IX_Fact_CreatedTimestamp
ON fact_content_moderation(created_timestamp);

CREATE INDEX IX_Fact_Category
ON fact_content_moderation(category_id);

CREATE INDEX IX_Fact_Moderator
ON fact_content_moderation(moderator_id);

CREATE INDEX IX_Fact_Region
ON fact_content_moderation(region);
------------------------------------------------------------------------------------------------------------------------------
/*
1. Overall Moderation Performance

Business Question:

How many tickets were processed, and what were the overall moderation KPIs?
*/
SELECT
    COUNT(*) AS total_tickets,
    AVG(CAST(handling_time_seconds AS decimal(10,2))) AS avg_handling_time_seconds,
    SUM(CASE WHEN moderator_id = 'AI_AUTO' THEN 1 ELSE 0 END) AS ai_reviewed_tickets,
    SUM(CASE WHEN moderator_id <> 'AI_AUTO' THEN 1 ELSE 0 END) AS human_reviewed_tickets,
    Cast(
        100.0 * SUM(CASE WHEN moderator_id = 'AI_AUTO' THEN 1 ELSE 0 END)
        / COUNT(*) as decimal(10,2))
     AS ai_automation_rate_pct,
    Cast(
        100.0 * SUM(CASE WHEN is_appealed = 1 THEN 1 ELSE 0 END)
        / COUNT(*)as decimal(10,2))
     AS appeal_rate_pct,
    SUM(CASE WHEN is_audited = 1 THEN 1 ELSE 0 END) AS audited_cases,
    SUM(CASE WHEN qa_result = 'Pass' THEN 1 ELSE 0 END) AS qa_passed_cases,
    SUM(CASE WHEN qa_result = 'Fail' THEN 1 ELSE 0 END) AS qa_failed_cases,
    Cast(
        100.0 * SUM(CASE WHEN qa_result = 'Pass' THEN 1 ELSE 0 END)
        / NULLIF(SUM(CASE WHEN is_audited = 1 THEN 1 ELSE 0 END),2)
        as decimal(10,2))
     AS qa_pass_rate_pct
FROM fact_content_moderation;

select top 20* from fact_content_moderation

/*
2. Monthly Moderation Trend

Business Question:
How has moderation volume changed month over month?
*/
SELECT
    YEAR(created_timestamp) AS year,
    MONTH(created_timestamp) AS month_number,
    DATENAME(MONTH, created_timestamp) AS month_name,
    COUNT(ticket_id) AS total_tickets,
    SUM(CASE
            WHEN moderator_id = 'AI_AUTO' THEN 1 ELSE 0 END) AS ai_reviewed,
    SUM(CASE
            WHEN moderator_id <> 'AI_AUTO' THEN 1 ELSE 0 END) AS human_reviewed
FROM fact_content_moderation
GROUP BY YEAR(created_timestamp),
         MONTH(created_timestamp),
         DATENAME(MONTH, created_timestamp)
ORDER BY
    year,month_number;

/*
3. Category Performance
Business Question:
Which violation categories generate the highest workload and require the most moderation effort?
*/

SELECT
    c.violation_category,
    c.severity_level,
    COUNT(f.ticket_id) AS total_tickets,
    ROUND(AVG(CAST(f.handling_time_seconds AS FLOAT)),2) AS avg_handling_time_seconds,
    SUM(CASE
            WHEN f.moderator_id = 'AI_AUTO' THEN 1 ELSE 0 END) AS ai_reviewed,
    SUM(CASE
            WHEN f.moderator_id <> 'AI_AUTO' THEN 1 ELSE 0 END) AS human_reviewed,
    Cast(
        100.0 * SUM(CASE WHEN f.is_appealed = 1 THEN 1 ELSE 0 END) / COUNT(*) as decimal(10,2)) AS appeal_rate_pct
FROM fact_content_moderation f
INNER JOIN dim_category c
ON f.category_id = c.category_id
GROUP BY
    c.violation_category,c.severity_level
ORDER BY
    total_tickets DESC;

/*
4. Moderator Performance

Business Question 4
Which moderators handled the highest workload while maintaining quality?
*/

SELECT
    f.moderator_id,
    m.moderator_name,
    t.team_lead_name,
    m.region,
    m.shift_type,
    COUNT(f.ticket_id) AS total_tickets,
    ROUND(AVG(CAST(f.handling_time_seconds AS FLOAT)),2) AS avg_handling_time_seconds,
    SUM(CASE
            WHEN f.qa_result = 'Pass' THEN 1 ELSE 0 END) AS qa_pass,
    SUM(CASE
            WHEN f.qa_result = 'Fail' THEN 1 ELSE 0 END) AS qa_fail,
    Cast(
        100.0 * SUM(CASE WHEN f.qa_result='Pass' THEN 1 ELSE 0 END)/
        NULLIF(SUM(CASE WHEN f.is_audited=1 THEN 1 ELSE 0 END),0)
        as decimal(10,2)) AS Accuracy_pct,
    Cast(
        100.0 * SUM(CASE WHEN f.is_appealed=1 THEN 1 ELSE 0 END)
        / COUNT(*)
        as decimal(10,2)) AS appeal_rate
FROM fact_content_moderation f
INNER JOIN dim_moderator m
    ON f.moderator_id = m.moderator_id
INNER JOIN dim_team_lead t
    ON f.team_lead_id = t.team_lead_id
WHERE f.moderator_id <> 'AI_AUTO'
GROUP BY
    f.moderator_id,m.moderator_name,t.team_lead_name,m.region,m.shift_type
ORDER BY
    total_tickets DESC;

/*
5. Team Lead Performance

Business Question:
Which Team Leads have the strongest and weakest performing moderation teams?
*/
SELECT
    t.team_lead_id,
    t.team_lead_name,
    COUNT(f.ticket_id) AS total_tickets,
    COUNT(DISTINCT f.moderator_id) AS total_moderators,
    ROUND(AVG(CAST(f.handling_time_seconds AS FLOAT)),2) AS avg_handling_time_seconds,
    ROUND(
        100.0 *
        SUM(CASE WHEN f.qa_result='Pass' THEN 1 ELSE 0 END)
        /NULLIF(SUM(CASE WHEN f.is_audited=1 THEN 1 ELSE 0 END),0),2) AS accuracy_pct,
    ROUND(
        100.0 *
        SUM(CASE WHEN f.is_appealed=1 THEN 1 ELSE 0 END)
        /COUNT(*),2) AS appeal_rate_pct
FROM fact_content_moderation f
INNER JOIN dim_team_lead t
ON f.team_lead_id = t.team_lead_id
WHERE f.moderator_id <> 'AI_AUTO'
GROUP BY
    t.team_lead_id,t.team_lead_name
ORDER BY
    accuracy_pct DESC,avg_handling_time_seconds ASC;

/*
6. Shift Analysis

Business Question:
Does moderator performance vary across Morning, Evening, and Night shifts?
*/
SELECT
    m.shift_type,
    COUNT(f.ticket_id) AS total_tickets,
    COUNT(DISTINCT f.moderator_id) AS total_moderators,
    ROUND(AVG(CAST(f.handling_time_seconds AS FLOAT)),2) AS avg_handling_time_seconds,
    ROUND(
        100.0 *SUM(CASE WHEN f.qa_result = 'Pass' THEN 1 ELSE 0 END)
        /NULLIF(SUM(CASE WHEN f.is_audited = 1 THEN 1 ELSE 0 END),0),
        2) AS accuracy_pct,
    ROUND(
        100.0 *SUM(CASE WHEN f.is_appealed = 1 THEN 1 ELSE 0 END)
        /COUNT(*),2) AS appeal_rate_pct
FROM fact_content_moderation f
INNER JOIN dim_moderator m
ON f.moderator_id = m.moderator_id
WHERE f.moderator_id <> 'AI_AUTO'
GROUP BY
    m.shift_type
ORDER BY
    avg_handling_time_seconds;

/*
7. Regional Operations
Business Question:
Which regions experience the highest moderation workload and operational risk?
*/

SELECT
    m.region,
    COUNT(f.ticket_id) AS total_tickets,
    ROUND(AVG(CAST(f.handling_time_seconds AS FLOAT)),2) AS avg_handling_time_seconds,
    SUM(CASE
            WHEN c.severity_level = 'Critical' THEN 1 ELSE 0 END) AS critical_cases,
    ROUND(
        100.0 *SUM(CASE WHEN f.qa_result = 'Pass' THEN 1 ELSE 0 END)
        /NULLIF(SUM(CASE WHEN f.is_audited = 1 THEN 1 ELSE 0 END),0),2) AS accuracy_pct,
    ROUND(
        100.0 *SUM(CASE WHEN f.is_appealed = 1 THEN 1 ELSE 0 END)
        /COUNT(*),2) AS appeal_rate_pct
FROM fact_content_moderation f
INNER JOIN dim_moderator m
    ON f.moderator_id = m.moderator_id
INNER JOIN dim_category c
    ON f.category_id = c.category_id
WHERE f.moderator_id <> 'AI_AUTO'
GROUP BY
    m.region
ORDER BY
    total_tickets DESC;

/*
8. Appeal & Overturn Analysis Business Question: Which categories receive the most successful appeals, indicating inconsistent moderation decisions?
*/

SELECT
    c.violation_category,COUNT(f.ticket_id) AS total_tickets,
    SUM(CASE
            WHEN f.is_appealed = 1 THEN 1 ELSE 0 END) AS appealed_cases,
    SUM(CASE
            WHEN f.overturn_status = 'Overturned' THEN 1 ELSE 0 END) AS overturned_cases,
    ROUND(
        100.0 * SUM(CASE WHEN f.is_appealed = 1 THEN 1 ELSE 0 END)
        /COUNT(*),2) AS appeal_rate_pct,
    ROUND(
        100.0 * SUM(CASE WHEN f.overturn_status = 'Overturned' THEN 1 ELSE 0 END)
        /NULLIF(SUM(CASE WHEN f.is_appealed = 1 THEN 1 ELSE 0 END),0),2) AS overturn_rate_pct
FROM fact_content_moderation f
INNER JOIN dim_category c
ON f.category_id = c.category_id
GROUP BY
    c.violation_category
ORDER BY
    overturn_rate_pct DESC;


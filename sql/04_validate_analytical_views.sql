-- 1. Preview analytical views

SELECT *
FROM dbo.vw_journey_stage_summary
ORDER BY journey_stage_order;

SELECT *
FROM dbo.vw_engagement_channel_summary
ORDER BY engagement_events DESC;


--2. Validate vw_journey_stage_summary grain; Expected: one row per journey stage
SELECT
    COUNT(*) AS summary_row_count,
    COUNT(DISTINCT journey_stage) AS distinct_stage_count
FROM dbo.vw_journey_stage_summary;

SELECT
    journey_stage,
    COUNT(*) AS row_count
FROM dbo.vw_journey_stage_summary
GROUP BY journey_stage
HAVING COUNT(*) > 1;

SELECT
    journey_stage,
    journey_stage_order
FROM dbo.vw_journey_stage_summary
ORDER BY journey_stage_order;


-- 3. Reconcile journey summary totals to vw_fact_journey

SELECT
    'total_journey_events' AS check_name,
    (SELECT COUNT(*) FROM dbo.vw_fact_journey) AS source_value,
    (SELECT SUM(total_journey_events) FROM dbo.vw_journey_stage_summary) AS summary_value, 
    (SELECT COUNT(*) FROM dbo.vw_fact_journey)
        - (SELECT SUM(total_journey_events) FROM dbo.vw_journey_stage_summary) AS difference;

SELECT
    'purchase_outcomes' AS check_name,
    (SELECT COUNT(*) FROM dbo.vw_fact_journey WHERE outcome = 'Purchased') AS source_value,
    (SELECT SUM(purchase_outcomes) FROM dbo.vw_journey_stage_summary) AS summary_value,
    (SELECT COUNT(*) FROM dbo.vw_fact_journey WHERE outcome = 'Purchased')
        - (SELECT SUM(purchase_outcomes) FROM dbo.vw_journey_stage_summary) AS difference;

SELECT
    'no_action_events' AS check_name,
    (SELECT COUNT(*) FROM dbo.vw_fact_journey WHERE outcome = 'No action') AS source_value,
    (SELECT SUM(no_action_events) FROM dbo.vw_journey_stage_summary) AS summary_value,
    (SELECT COUNT(*) FROM dbo.vw_fact_journey WHERE outcome = 'No action')
        - (SELECT SUM(no_action_events) FROM dbo.vw_journey_stage_summary) AS difference;

SELECT
    'estimated_revenue' AS check_name,
    CAST((SELECT SUM(estimated_revenue) FROM dbo.vw_fact_journey) AS DECIMAL(18,2)) AS source_value,
    CAST((SELECT SUM(estimated_revenue) FROM dbo.vw_journey_stage_summary) AS DECIMAL(18,2)) AS summary_value,
    CAST(
        (SELECT SUM(estimated_revenue) FROM dbo.vw_fact_journey)
        - (SELECT SUM(estimated_revenue) FROM dbo.vw_journey_stage_summary)
        AS DECIMAL(18,2)
    ) AS difference;


-- 4. Check journey summary rate fields; Expected: no rows returned

SELECT
    journey_stage,
    purchase_outcome_rate,
    no_action_rate
FROM dbo.vw_journey_stage_summary
WHERE purchase_outcome_rate < 0
   OR purchase_outcome_rate > 1
   OR no_action_rate < 0
   OR no_action_rate > 1;


-- 5. Validate vw_engagement_channel_summary grain; Expected: one row per engagement channel

SELECT
    COUNT(*) AS summary_row_count,
    COUNT(DISTINCT channel) AS distinct_channel_count
FROM dbo.vw_engagement_channel_summary;

SELECT
    channel,
    COUNT(*) AS row_count
FROM dbo.vw_engagement_channel_summary
GROUP BY channel
HAVING COUNT(*) > 1;


-- 6. Reconcile engagement summary totals to vw_fact_engagement

SELECT
    'engagement_events' AS check_name,
    (SELECT COUNT(*) FROM dbo.vw_fact_engagement) AS source_value,
    (SELECT SUM(engagement_events) FROM dbo.vw_engagement_channel_summary) AS summary_value,
    (SELECT COUNT(*) FROM dbo.vw_fact_engagement)
        - (SELECT SUM(engagement_events) FROM dbo.vw_engagement_channel_summary) AS difference;

SELECT
    'high_engagement_events' AS check_name,
    (SELECT COUNT(*) FROM dbo.vw_fact_engagement WHERE engagement_band = 'High Engagement') AS source_value,
    (SELECT SUM(high_engagement_events) FROM dbo.vw_engagement_channel_summary) AS summary_value,
    (SELECT COUNT(*) FROM dbo.vw_fact_engagement WHERE engagement_band = 'High Engagement')
        - (SELECT SUM(high_engagement_events) FROM dbo.vw_engagement_channel_summary) AS difference;

SELECT
    'campaign_conversions' AS check_name,
    (SELECT SUM(CASE WHEN conversion_flag = 1 THEN 1 ELSE 0 END) FROM dbo.vw_fact_engagement) AS source_value,
    (SELECT SUM(campaign_conversions) FROM dbo.vw_engagement_channel_summary) AS summary_value,
    (SELECT SUM(CASE WHEN conversion_flag = 1 THEN 1 ELSE 0 END) FROM dbo.vw_fact_engagement)
        - (SELECT SUM(campaign_conversions) FROM dbo.vw_engagement_channel_summary) AS difference;

SELECT
    'unsubscribe_events' AS check_name,
    (SELECT SUM(CASE WHEN unsubscribe_flag = 1 THEN 1 ELSE 0 END) FROM dbo.vw_fact_engagement) AS source_value,
    (SELECT SUM(unsubscribe_events) FROM dbo.vw_engagement_channel_summary) AS summary_value,
    (SELECT SUM(CASE WHEN unsubscribe_flag = 1 THEN 1 ELSE 0 END) FROM dbo.vw_fact_engagement)
        - (SELECT SUM(unsubscribe_events) FROM dbo.vw_engagement_channel_summary) AS difference;


-- 7. Check engagement event share; Expected: 1

SELECT
    SUM(engagement_event_share_rate) AS total_engagement_event_share_rate
FROM dbo.vw_engagement_channel_summary;


-- 8. Check engagement summary rate fields; Expected: no rows returned

SELECT
    channel,
    engagement_event_share_rate,
    high_engagement_rate,
    campaign_conversion_rate,
    unsubscribe_rate
FROM dbo.vw_engagement_channel_summary
WHERE engagement_event_share_rate < 0
   OR engagement_event_share_rate > 1
   OR high_engagement_rate < 0
   OR high_engagement_rate > 1
   OR campaign_conversion_rate < 0
   OR campaign_conversion_rate > 1
   OR unsubscribe_rate < 0
   OR unsubscribe_rate > 1;



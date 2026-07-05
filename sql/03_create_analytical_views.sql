USE PortfolioProject_MarketingAnalytics;
GO

CREATE OR ALTER VIEW vw_journey_stage_summary AS

WITH touchpoint_list AS (
	SELECT DISTINCT 
		journey_stage,
		journey_stage_order,
		touchpoint_type
	FROM dbo.vw_fact_journey
),
distinct_touchpoints AS (
	SELECT 
		journey_stage_order,
		STRING_AGG(CAST(touchpoint_type AS NVARCHAR(MAX)), ', ') 
			WITHIN GROUP (ORDER BY touchpoint_type) AS touch_point_list

	FROM touchpoint_list
	GROUP BY journey_stage_order
), 
stage_statistic AS (
	SELECT 
		DISTINCT journey_stage,
		journey_stage_order,
		Count(*) AS total_journey_events,--Counts all journey records in each stage
		Count(DISTINCT customer_id) AS unique_customers, --Shows how many distinct customers reached each stage
		sum(CASE 
			WHEN outcome = 'Purchased' THEN 1
			ELSE 0
		END) AS purchase_outcomes,--Actual purchase outcomes in each stages
		SUM (
			CASE
				WHEN outcome = 'No action' THEN 1
				ELSE 0
			END
		) AS no_action_events, --Count of rows where outcome = 'No action'
		AVG(duration_seconds) AS average_duration_seconds,
		SUM(estimated_revenue) AS estimated_revenue
	FROM dbo.vw_fact_journey
	GROUP BY journey_stage, journey_stage_order 
)

SELECT 
	s.journey_stage,
	s.journey_stage_order,
	d.touch_point_list,
	s.total_journey_events,
	s.unique_customers,
	s.purchase_outcomes,
	CAST(CAST(s.purchase_outcomes as DECIMAL(18,4)) / NULLIF(s.total_journey_events, 0) as DECIMAL(10,2)) as purchase_outcome_rate, --Purchases divided by stage events
	s.no_action_events,
	CAST(CAST (s.no_action_events as DECIMAL(18,4)) / NULLIF(s.total_journey_events, 0) as DECIMAL(10,2)) as no_action_rate,	-- No-action events divided by total journey events
	average_duration_seconds, 
	estimated_revenue 

FROM stage_statistic as s
LEFT JOIN distinct_touchpoints AS d ON s.journey_stage_order = d.journey_stage_order
GROUP BY s.journey_stage, s.journey_stage_order, d.touch_point_list, s.total_journey_events, s.unique_customers, s.purchase_outcomes, 
		s.no_action_events, s.average_duration_seconds, 
		s.estimated_revenue 


CREATE OR ALTER VIEW vw_engagement_channel_summary AS
WITH campaign_type_list AS (
	SELECT DISTINCT 
		channel,
		campaign_type 
	FROM dbo.vw_fact_engagement
),
distinct_campaign_type AS (
	SELECT 
		channel,
		STRING_AGG(campaign_type, ', ')
			WITHIN GROUP (ORDER BY campaign_type) AS agg_campaign_type
	FROM campaign_type_list
	GROUP BY channel
),

channel_statistics AS (
	SELECT 
		DISTINCT e.channel,
		COUNT(*) AS engagement_events, --Count total engagement events.
		COUNT(DISTINCT e.customer_id) as engaged_customers, --Count distinct customers.
		COUNT(DISTINCT e.campaign_id) as campaign_count, --Count distinct campaigns.
		AVG(e.engagement_score) as average_engagement_score, --Average engagement_score.
		AVG(e.time_spent_seconds) as average_time_spent_seconds,--Average time_spent_seconds.
		SUM(
			CASE 
				WHEN e.engagement_band = 'High Engagement' THEN 1 
				ELSE 0
			END
		) AS high_engagement_events, --Count rows where engagement_band = 'High Engagement'.
		SUM(CAST(e.conversion_flag AS INT)) as campaign_conversions,--Sum conversion_flag.
		SUM(CAST(e.unsubscribe_flag AS INT)) as unsubscribe_events --Sum unsubscribe_flag.
	
	FROM dbo.vw_fact_engagement as e
	GROUP by e.channel
)

SELECT 
	s.channel,
	d.agg_campaign_type,
	s.engagement_events,
	CAST(
		CAST(s.engagement_events AS Decimal(14,4)) / NULLIF(SUM(s.engagement_events) OVER (), 0) AS Decimal(10,2)
	) AS engagement_event_share_rate, 
	s.engaged_customers,
	s.campaign_count,
	s.average_engagement_score,
	s.average_time_spent_seconds,
	s.high_engagement_events,
	CAST (
		CAST(s.high_engagement_events AS Decimal(14,4))/ NULLIF(s.engagement_events,0 )AS Decimal (10,2)
	) AS high_engagement_rate,
	s.campaign_conversions,
	CAST (
		CAST(s.campaign_conversions AS Decimal(14,4)) / NULLIF(s.engagement_events, 0) AS Decimal (10,2)
	) AS campaign_conversion_rate,
	s.unsubscribe_events,
	CAST (
		CAST(s.unsubscribe_events AS Decimal(14,4)) / NULLIF(s.engagement_events,0) AS Decimal (10,2)
	) AS unsubscribe_rate

FROM channel_statistics as s 
LEFT JOIN distinct_campaign_type as d
	ON s.channel = d.channel
GROUP BY s.channel, d.agg_campaign_type, s.engagement_events, s.engaged_customers, s.campaign_count, s.average_engagement_score, 
	s.average_time_spent_seconds, s.high_engagement_events, s.campaign_conversions, s.unsubscribe_events
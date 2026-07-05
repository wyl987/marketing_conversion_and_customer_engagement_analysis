USE PortfolioProject_MarketingAnalytics;
GO
--dbo.vw_dim_customer
CREATE OR ALTER VIEW dbo.vw_dim_customer AS
SELECT
	c.customer_id,
	c.gender,
	c.age_group,
	c.income_band,
	c.membership_tier,
	c.acquisition_channel,
	c.email_opt_in,
	c.sms_opt_in, 
	c.geography_id,
	g.state,
	g.suburb_name,
	g.suburb_postcode
FROM dbo.customers c
LEFT JOIN dbo.geography g 
	ON c.geography_id = g.geography_id;
GO

--dbo.vw_dim_product
CREATE OR ALTER VIEW dbo.vw_dim_product AS
SELECT 
    product_id,
    product_name,
    category,
    brand,
    unit_price,
    cost_price,
    unit_price - cost_price AS estimated_margin_per_unit,
    launch_date,
    active_flag
FROM dbo.products;
GO


--dbo.vw_fact_journey
CREATE OR ALTER VIEW dbo.vw_fact_journey AS
SELECT 
	j.journey_id,
	j.customer_id,
	j.product_id,
	j.session_id,
	CAST(j.event_timestamp AS DATE) AS journey_date,
	j.event_timestamp,
	j.journey_stage, -- special treatment for journey_stage column
	CASE j.journey_stage
		WHEN 'Awareness' THEN 1
		WHEN 'Consideration' THEN 2
		WHEN 'Purchase' THEN 3
		WHEN 'Post-purchase' THEN 4
		WHEN 'Retention' THEN 5
		ELSE NULL
	END AS journey_stage_order,
	j.touchpoint_type,
	j.channel,
	j.device_type,
	j.duration_seconds,
	j.outcome,
	CASE 
		WHEN j.outcome = 'Purchased' THEN 1
		ELSE 0
	END AS conversion_flag,
	CASE
		WHEN j.outcome = 'Purchased' THEN p.unit_price
		ELSE 0
	END AS estimated_revenue,
	j.next_best_action
from dbo.customer_journey j
LEFT JOIN dbo.products p 
	on j.product_id = p.product_id
GO

-- select * from dbo.engagement_data;
CREATE OR ALTER VIEW dbo.vw_fact_engagement AS
SELECT 
	ed.engagement_id,
	ed.customer_id,
	ed.campaign_id,
	ed.product_id,
	CAST(ed.engagement_timestamp AS DATE) AS engagement_date,
	ed.engagement_timestamp,
	ed.campaign_type,
	ed.channel,
	ed.event_type,
	ed.engagement_score,
	CASE 
		WHEN ed.engagement_score >=80 THEN 'High Engagement'
		WHEN ed.engagement_score >=50 THEN 'Medium  Engagement'
		ELSE 'Low Engagement'
	END AS engagement_band,
	ed.time_spent_seconds,
	ed.conversion_flag,
	ed.unsubscribe_flag
FROM dbo.engagement_data as ed;
	
GO

--dbo.vw_fact_reviews
CREATE OR ALTER VIEW vw_fact_reviews AS
SELECT
	r.review_id,
	r.customer_id,
	r.product_id,
	CAST(r.review_date AS DATE) AS review_date,
	r.rating,
	r.sentiment,
	r.review_title,
	r.review_text,
	r.verified_purchase_flag,
	r.helpful_votes,
	r.response_required_flag,
	CASE 
		WHEN r.rating < 3 AND r.response_required_flag = 1 THEN 'High Priority'
		WHEN r.rating < 3 AND r.response_required_flag = 0 THEN 'Medium Priority'
		WHEN r.rating >= 3 AND r.response_required_flag = 1 THEN 'Medium Priority'
		ELSE 'Low Priority'
	END AS priority_level
FROM dbo.customer_reviews as r
GO
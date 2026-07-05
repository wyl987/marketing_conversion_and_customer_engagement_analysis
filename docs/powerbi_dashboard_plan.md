# Power BI Dashboard Plan

This document outlines the planned Power BI report for the Nam Nam Australia marketing analytics project.

The report has not been built yet. This plan will be updated after the Power BI model, DAX measures and dashboard pages are completed.

## Data connection

Power BI will connect to SQL Server and use the SQL extraction views as the main model sources:

- `vw_dim_customer`
- `vw_dim_product`
- `vw_fact_journey`
- `vw_fact_engagement`
- `vw_fact_reviews`

A `DimDate` table will be created in Power Query or Power BI.

The two SQL summary views may also be loaded for reference visuals:

- `vw_journey_stage_summary`
- `vw_engagement_channel_summary`

## Model design

The report will use a star schema.

Dimensions:

- `DimCustomer`
- `DimProduct`
- `DimDate`

Facts:

- `FactJourney`
- `FactEngagement`
- `FactReviews`

The main interactive visuals should be based on the fact and dimension tables. The SQL summary views can be used for simple summary tables or validation screenshots.

## Planned report pages

### 1. Executive Summary

Purpose: give a high-level view of journey outcomes, engagement performance and customer feedback.

Possible KPIs:

- total journey events
- unique customers
- purchase outcomes
- purchase outcome rate
- estimated revenue
- engagement events
- campaign conversion rate
- unsubscribe rate
- average rating
- negative review rate

Possible visuals:

- KPI cards
- trend by month
- top journey stages by purchase outcome rate
- engagement channel summary
- review sentiment summary

### 2. Journey & Touchpoint Analysis

Purpose: understand how customers interact across lifecycle stages and touchpoints.

Main questions:

- which journey stages have the most activity
- which stages have the strongest purchase outcome rate
- which stages have the highest no-action rate
- which touchpoints sit under each stage
- which touchpoints are linked with purchase outcomes

Possible visuals:

- journey stage bar chart
- purchase outcome rate by stage
- no-action rate by stage
- touchpoint drill-down table
- matrix: stage by outcome
- slicers for channel, device type and product category

Important note:

This page should not describe the data as a strict checkout funnel. The journey table is a lifecycle interaction log.

### 3. Campaign Engagement

Purpose: analyse campaign channel performance.

Main questions:

- which channels create the largest share of engagement events
- which channels have higher engagement scores
- which channels have stronger campaign conversion rates
- which channels show unsubscribe risk
- which campaign types are used by each channel

Possible visuals:

- engagement events by channel
- engagement event share by channel
- campaign conversion rate by channel
- unsubscribe rate by channel
- average engagement score by channel
- engagement band distribution
- campaign type slicer

### 4. Product & Review Performance

Purpose: identify products or categories with stronger or weaker customer feedback.

Main questions:

- which product categories have high review volume
- which products have lower average ratings
- which products have more negative sentiment
- which products require response follow-up
- are high-interest products also receiving good feedback

Possible visuals:

- average rating by category
- sentiment split by category
- response-required count by product
- negative review table
- product/category slicers

### 5. Customer Segmentation

Purpose: compare purchase and engagement behaviour across customer groups.

Main questions:

- which customer groups have stronger purchase outcome rates
- how do membership tiers compare
- which acquisition channels bring more active customers
- which states or suburbs show stronger customer activity
- how does review sentiment differ by customer segment

Possible visuals:

- purchase outcome rate by membership tier
- estimated revenue by income band
- engagement score by acquisition channel
- review sentiment by segment
- map or table by state/suburb

## Planned DAX measures

### Journey measures

- Total Journey Events
- Unique Journey Customers
- Purchase Outcomes
- Purchase Outcome Rate
- No Action Events
- No Action Rate
- Estimated Revenue
- Average Journey Duration

### Engagement measures

- Engagement Events
- Engaged Customers
- Campaign Count
- Average Engagement Score
- High Engagement Events
- High Engagement Rate
- Campaign Conversions
- Campaign Conversion Rate
- Unsubscribe Events
- Unsubscribe Rate

### Review measures

- Review Count
- Average Rating
- Positive Reviews
- Neutral Reviews
- Negative Reviews
- Negative Review Rate
- Response Required Count

## Formatting notes

- Rate measures should be formatted as percentages in Power BI.
- Estimated revenue should be labelled clearly as estimated revenue.
- Raw IDs should be hidden from report users unless needed for drill-through.
- `journey_stage_order` should be used to sort journey stages.
- `journey_stage` should not be sorted alphabetically.

## Draft page flow

Recommended page order:

1. Executive Summary
2. Journey & Touchpoint Analysis
3. Campaign Engagement
4. Product & Review Performance
5. Customer Segmentation

This order starts with the business summary, then moves into the supporting analysis pages.

## To be added later

After the Power BI report is built, this document should be updated with:

- final model screenshot
- final dashboard screenshots
- list of final DAX measures
- key insights
- recommendations
- known limitations

# Data Model Design

This document explains how the SQL Server tables are prepared for the planned Power BI model.

## Model approach

The Power BI report will use a star schema.

The main model will be built from the SQL extraction views:

| Power BI table | Source view | Type | Grain |
|---|---|---|---|
| `DimCustomer` | `vw_dim_customer` | Dimension | One row per customer |
| `DimProduct` | `vw_dim_product` | Dimension | One row per product |
| `DimDate` | Created in Power Query / Power BI | Dimension | One row per calendar date |
| `FactJourney` | `vw_fact_journey` | Fact | One row per journey interaction event |
| `FactEngagement` | `vw_fact_engagement` | Fact | One row per campaign engagement event |
| `FactReviews` | `vw_fact_reviews` | Fact | One row per customer review |

The two analytical summary views are supporting views. They are useful for checking SQL output and showing summary tables, but they do not replace the star schema.

## Source-to-model mapping

| Source table | Model output | Notes |
|---|---|---|
| `customers` | `DimCustomer` | Customer attributes such as age group, gender, membership tier, income band and acquisition channel |
| `geography` | `DimCustomer` | Joined into the customer dimension for state, suburb and postcode |
| `products` | `DimProduct` | Product name, brand, category, unit price and active flag |
| `customer_journey` | `FactJourney` | Journey stage, touchpoint, channel, device, outcome and estimated revenue |
| `engagement_data` | `FactEngagement` | Campaign channel, campaign type, engagement score, conversion and unsubscribe flags |
| `customer_reviews` | `FactReviews` | Rating, sentiment, verified purchase flag and response-required flag |

## Dimension design

### `DimCustomer`

Grain: one row per customer.

Key fields:

- `customer_id`
- age group
- gender
- income band
- membership tier
- acquisition channel
- state
- suburb
- postcode

`customers` and `geography` are combined into one customer dimension. This keeps the Power BI model simpler and avoids an unnecessary snowflake structure.

### `DimProduct`

Grain: one row per product.

Key fields:

- `product_id`
- product name
- category
- brand
- unit price
- cost price
- active flag
- launch date

`unit_price` is used for estimated revenue calculations because there is no transaction table.

### `DimDate`

Grain: one row per calendar date.

The date table will be created in Power Query or Power BI. It will connect to:

- `FactJourney[journey_date]`
- `FactEngagement[engagement_date]`
- `FactReviews[review_date]`

## Fact table design

### `FactJourney`

Grain: one row per journey interaction event.

Key fields:

- `journey_id`
- `customer_id`
- `product_id`
- `session_id`
- `journey_date`
- `journey_stage`
- `journey_stage_order`
- `touchpoint_type`
- `channel`
- `device_type`
- `duration_seconds`
- `outcome`
- `conversion_flag`
- `estimated_revenue`
- `next_best_action`

The `customer_journey` table is treated as a customer lifecycle interaction log. It is not treated as a strict checkout funnel.

`journey_stage` gives the lifecycle context. `touchpoint_type` gives the more specific interaction. `outcome` gives the result of the interaction.

Purchase logic:

```text
conversion_flag = 1 when outcome = 'Purchased'
```

Estimated revenue logic:

```text
estimated_revenue = product unit price when outcome = 'Purchased'
```

Otherwise, estimated revenue is 0.

This is used because purchase outcomes can occur across more than one journey stage.

### `FactEngagement`

Grain: one row per campaign engagement event.

Key fields:

- `engagement_id`
- `customer_id`
- `campaign_id`
- `product_id`
- `engagement_date`
- `campaign_type`
- `channel`
- `event_type`
- `engagement_score`
- `engagement_band`
- `time_spent_seconds`
- `conversion_flag`
- `unsubscribe_flag`

`engagement_band` groups engagement scores into reporting categories:

| Score range | Band |
|---:|---|
| 80–100 | High Engagement |
| 50–79 | Medium Engagement |
| 0–49 | Low Engagement |

`conversion_flag` in this table is a campaign-level conversion flag. It is separate from the journey conversion flag.

### `FactReviews`

Grain: one row per customer review.

Key fields:

- `review_id`
- `customer_id`
- `product_id`
- `review_date`
- `rating`
- `sentiment`
- `review_title`
- `review_text`
- `verified_purchase_flag`
- `helpful_votes`
- `response_required_flag`

The `sentiment` field is used for positive, neutral and negative review analysis. A separate rating group was not added because it would duplicate similar logic.

## Planned relationships

| From | To | Relationship |
|---|---|---|
| `DimCustomer[customer_id]` | `FactJourney[customer_id]` | One-to-many |
| `DimCustomer[customer_id]` | `FactEngagement[customer_id]` | One-to-many |
| `DimCustomer[customer_id]` | `FactReviews[customer_id]` | One-to-many |
| `DimProduct[product_id]` | `FactJourney[product_id]` | One-to-many |
| `DimProduct[product_id]` | `FactEngagement[product_id]` | One-to-many |
| `DimProduct[product_id]` | `FactReviews[product_id]` | One-to-many |
| `DimDate[Date]` | `FactJourney[journey_date]` | One-to-many |
| `DimDate[Date]` | `FactEngagement[engagement_date]` | One-to-many |
| `DimDate[Date]` | `FactReviews[review_date]` | One-to-many |

The model should use single-direction filtering from dimensions to facts.

## Analytical SQL summary views

Two SQL summary views were created before building the Power BI report.

### `vw_journey_stage_summary`

Grain: one row per journey stage.

Purpose: summarise lifecycle stage activity and outcomes.

Current fields:

- `journey_stage`
- `journey_stage_order`
- `touch_point_list`
- `total_journey_events`
- `unique_customers`
- `purchase_outcomes`
- `purchase_outcome_rate`
- `no_action_events`
- `no_action_rate`
- `average_duration_seconds`
- `estimated_revenue`

This view is intentionally simple. It is a stage-level summary, not a customer-level funnel progression table.

### `vw_engagement_channel_summary`

Grain: one row per engagement channel.

Purpose: summarise marketing campaign performance by channel.

Current fields:

- `channel`
- `agg_campaign_type`
- `engagement_events`
- `engagement_event_share_rate`
- `engaged_customers`
- `campaign_count`
- `average_engagement_score`
- `average_time_spent_seconds`
- `high_engagement_events`
- `high_engagement_rate`
- `campaign_conversions`
- `campaign_conversion_rate`
- `unsubscribe_events`
- `unsubscribe_rate`

This view uses a SQL window function for `engagement_event_share_rate`. The calculation compares each channel's engagement event count with the total engagement event count across all channels.

## Rate fields

Rate fields are stored as decimal ratios.

Examples:

| Value | Meaning |
|---:|---|
| `0.01` | 1% |
| `0.26` | 26% |
| `0.45` | 45% |

This keeps the SQL output consistent with how Power BI can format measures later.

## Estimated revenue limitation

The dataset does not include transaction IDs, order quantity, discount, tax, payment or refund data.

Estimated revenue is based on purchased journey outcomes and product unit price only. It should be used for relative comparison, not as audited revenue.

## Design notes

- The main Power BI report should use the dimension and fact views.
- The analytical summary views can be loaded as reference tables if useful.
- Do not directly join raw fact tables to each other in Power BI.
- Customer, product and date dimensions should be used to filter the fact tables.

# Nam Nam Australia Marketing Conversion & Customer Engagement Analytics

## Project status

This project is currently in progress.

Completed so far:

- SQL Server source tables loaded
- basic source validation completed
- analytical model design completed
- SQL extraction views created
- two SQL analytical summary views created
- SQL preview screenshots captured

Next stage:

- connect Power BI to SQL Server
- build the star schema model
- create DAX measures
- design dashboard pages
- add final insights and recommendations

## Project overview

Nam Nam Australia is a fictional Australian retail business used for this portfolio project. The project analyses customer journey activity, marketing engagement, product feedback and customer segments using SQL Server and Power BI.

The current stage of the project focuses on the SQL layer. The Power BI report has not been built yet, so the dashboard screenshots, final insights and recommendations will be added later.

## Business problem

Nam Nam Australia has customer, product, journey, engagement, review and geography data available in SQL Server, but the data needs to be turned into a reporting model that can answer practical business questions.

The main problem is that management does not yet have a clear view of:

- which journey stages and touchpoints are linked with purchase outcomes;
- which campaign channels generate engagement, conversion and unsubscribe risk;
- which customer groups show stronger purchase behaviour;
- which products or categories may need attention based on customer feedback.

This project builds the SQL and Power BI reporting layer needed to answer those questions.

## Key analysis questions

1. Which journey stages have the highest activity and purchase outcome rate?
2. Which touchpoints sit under each journey stage?
3. Which campaign channels create the largest share of engagement events?
4. Which campaign channels have stronger campaign conversion rates?
5. Which channels show higher unsubscribe risk?
6. Which customer segments are more likely to purchase?
7. Which product categories receive strong interest but weaker customer sentiment?
8. What actions should Nam Nam Australia prioritise to improve conversion, engagement and customer experience?

## Important data interpretation

The `customer_journey` table is treated as a customer lifecycle interaction log, not a strict checkout funnel.

Each row represents one journey interaction event. The key fields are interpreted as follows:

| Field | Meaning |
|---|---|
| `journey_stage` | Broad lifecycle context, such as Awareness, Consideration, Purchase, Post-purchase or Retention |
| `touchpoint_type` | Specific interaction within the stage, such as Ad impression, Product page view, Checkout start or Reorder reminder |
| `outcome` | Result of the interaction, such as Purchased, Added to cart, No action or Requested support |
| `channel` | Source or channel of the interaction |
| `device_type` | Device used for the interaction |
| `duration_seconds` | Length of the interaction |
| `next_best_action` | Suggested follow-up action |

Because purchase outcomes can occur across multiple journey stages, journey conversion is based on:

```text
outcome = 'Purchased'
```

It is not based only on:

```text
journey_stage = 'Purchase'
```

The Purchase stage is treated as a purchase-intent stage. The Purchased outcome is treated as the actual conversion result.

## Data limitation: estimated revenue

The dataset does not include a dedicated transaction or order table. For that reason, revenue in this project is treated as estimated revenue.

Estimated revenue is calculated from journey rows where:

```text
outcome = 'Purchased'
```

and the related product unit price.

This metric is useful for comparing relative performance across stages, products, channels and customer groups. It should not be read as audited sales revenue.

## Tools used

| Tool | Use |
|---|---|
| SQL Server Express / SSMS | Source database, validation, extraction views and analytical SQL views |
| Power Query | Planned for Power BI data preparation and date table creation |
| Power BI | Planned for data model, DAX measures and dashboard pages |
| DAX | Planned for interactive KPI calculations |
| GitHub | Project documentation, SQL scripts and screenshots |

## Source tables

The project uses six source tables in SQL Server:

| Source table | Area |
|---|---|
| `customers` | Customer profile and segmentation data |
| `geography` | State, suburb and postcode data |
| `products` | Product, category, brand and price data |
| `customer_journey` | Journey stage, touchpoint, channel, device and outcome data |
| `engagement_data` | Campaign engagement, conversion and unsubscribe data |
| `customer_reviews` | Review rating, sentiment and response-required data |

## SQL extraction views

The extraction views are the main source tables for the planned Power BI star schema.

| SQL view | Planned Power BI table | Purpose |
|---|---|---|
| `vw_dim_customer` | `DimCustomer` | Customer profile and geography attributes |
| `vw_dim_product` | `DimProduct` | Product, category, brand and pricing attributes |
| `vw_fact_journey` | `FactJourney` | Journey lifecycle, touchpoint, outcome and estimated revenue analysis |
| `vw_fact_engagement` | `FactEngagement` | Campaign engagement, conversion and unsubscribe analysis |
| `vw_fact_reviews` | `FactReviews` | Rating, sentiment and customer feedback analysis |

## Analytical SQL views completed

Two analytical summary views have been created in SQL Server.

These views are not a replacement for the Power BI star schema. They are small SQL summaries that make selected business checks easier to review and document.

| SQL view | Grain | Purpose |
|---|---|---|
| `vw_journey_stage_summary` | One row per journey stage | Summarises lifecycle stage activity, touchpoints, purchase outcomes, no-action rate and estimated revenue |
| `vw_engagement_channel_summary` | One row per engagement channel | Summarises campaign channel activity, event share, engagement strength, conversion and unsubscribe risk |

The analytical view creation script should be saved in:

```text
sql/03_create_analytical_views.sql
```

The validation checks should be saved in:

```text
sql/04_validate_analytical_views.sql
```

## SQL preview screenshots

### Journey stage summary

![Journey stage summary SQL preview](screenshots/sql_vw_journey_stage_summary.png)

### Engagement channel summary

![Engagement channel summary SQL preview](screenshots/sql_vw_engagement_channel_summary.png)

## Planned Power BI model

The Power BI model will be built as a star schema.

| Model table | Type | Grain |
|---|---|---|
| `DimCustomer` | Dimension | One row per customer |
| `DimProduct` | Dimension | One row per product |
| `DimDate` | Dimension | One row per calendar date |
| `FactJourney` | Fact | One row per journey interaction event |
| `FactEngagement` | Fact | One row per campaign engagement event |
| `FactReviews` | Fact | One row per customer review |

The two analytical summary views may also be loaded into Power BI for reference tables or SQL summary visuals, but the main interactive model should use the fact and dimension views.

## Planned dashboard pages

The Power BI report is planned to include these pages:

| Page | Purpose |
|---|---|
| Executive Summary | High-level KPIs and main findings |
| Journey & Touchpoint Analysis | Journey stage, touchpoint, purchase outcome and no-action analysis |
| Campaign Engagement | Channel, campaign type, engagement score, conversion and unsubscribe analysis |
| Product & Review Performance | Product/category review performance and feedback issues |
| Customer Segmentation | Customer performance by age group, membership tier, income band, acquisition channel and geography |

## Current SQL view notes

### `vw_journey_stage_summary`

Current columns include:

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

The rate fields are stored as decimal ratios. For example, `0.45` means 45%.

### `vw_engagement_channel_summary`

Current columns include:

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

The `engagement_event_share_rate` column uses a SQL window function to compare each channel's engagement events with the total engagement events across all channels.

## Repository structure

```text
nam-nam-australia-marketing-analytics/
├── README.md
├── docs/
│   ├── data_model_design.md
│   ├── sql_analytical_views.md
│   ├── powerbi_dashboard_plan.md
│   └── project_status.md
├── sql/
│   ├── README.md
│   ├── 01_source_validation.sql
│   ├── 02_create_extraction_views.sql
│   ├── 03_create_analytical_views.sql
│   └── 04_validate_analytical_views.sql
├── screenshots/
│   ├── sql_vw_journey_stage_summary.png
│   └── sql_vw_engagement_channel_summary.png
└── powerbi/
    └── .gitkeep
```

## Next steps

1. Add the SQL scripts to the `sql/` folder.
2. Push the current in-progress project to GitHub.
3. Connect Power BI to the SQL Server views.
4. Build the star schema model.
5. Create DAX measures.
6. Build dashboard pages.
7. Replace placeholder sections with final screenshots, insights and recommendations.

## Skills shown so far

- SQL Server source validation
- SQL view design
- star schema planning
- journey data interpretation
- campaign engagement analysis
- grouped SQL summaries
- CTEs
- SQL window function for event share calculation
- project documentation for GitHub

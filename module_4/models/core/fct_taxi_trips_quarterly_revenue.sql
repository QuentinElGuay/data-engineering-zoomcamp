{{ config(materialized="table") }}

with
    trips_data as (select * from {{ ref("fact_trips") }}),
    revenues as (
        select
            year,
            quarter,
            year_quarter,
            service_type,
            sum(total_amount) as quarter_revenue,
        from trips_data
        WHERE year IN (2019, 2020)
        group by 1, 2, 3, 4
    ),
    lag_revenues AS (
        SELECT
            year_quarter,
            service_type,
            quarter_revenue,
            LAG(quarter_revenue) OVER (PARTITION BY service_type, quarter ORDER BY year) as lag_quarter_revenue
        FROM revenues r
    ),
    final AS (
        SELECT
            year_quarter,
            service_type,
            quarter_revenue,
            lag_quarter_revenue,
            quarter_revenue - lag_quarter_revenue AS YoY_quarter_revenue,
            ((quarter_revenue - lag_quarter_revenue) / lag_quarter_revenue) * 100.0 AS YoY_quarter_growth
        FROM lag_revenues
        WHERE lag_quarter_revenue IS NOT NULL
        ORDER BY 2, 6 DESC
    )
select *
from final

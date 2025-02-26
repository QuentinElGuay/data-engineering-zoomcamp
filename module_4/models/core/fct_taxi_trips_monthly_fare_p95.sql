{{ config(materialized="table") }}


with
    trips_data as (select * from `de-zoomcamp-course-450712.dbt_qleguay.fact_trips`),
    filtered_trips as (
        select year, month, service_type, fare_amount
        from trips_data
        where
            year in (2019, 2020)
            and fare_amount > 0
            and trip_distance > 0
            and payment_type_description in ('Cash', 'Credit card')
    ),
    percentiles as (
        select
            service_type,
            year,
            month,
            percentile_cont(fare_amount, 0.9) over (
                partition by service_type, year, month
            ) as p90,
            percentile_cont(fare_amount, 0.95) over (
                partition by service_type, year, month
            ) as p95,
            percentile_cont(fare_amount, 0.97) over (
                partition by service_type, year, month
            ) as p97
        from filtered_trips
    ),
    final as (select distinct service_type, year, month, p90, p95, p97 from percentiles)
select *
from final
where year = 2020 and month = 4

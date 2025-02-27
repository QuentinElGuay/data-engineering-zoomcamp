{{
    config(
        materialized='table'
    )
}}

with fhv_tripdata as (
    select *, 
        'FHV' as service_type
    from {{ ref('stg_fhv_tripdata') }}
), 
dim_zones as (
    select * from {{ ref('dim_zones') }}
    where borough != 'Unknown'
),
trips AS (
    select
        fhv_tripdata.tripid, 
        fhv_tripdata.vendorid, 
        fhv_tripdata.service_type,
        fhv_tripdata.pickup_locationid, 
        pickup_zone.borough as pickup_borough, 
        pickup_zone.zone as pickup_zone, 
        fhv_tripdata.dropoff_locationid,
        dropoff_zone.borough as dropoff_borough, 
        dropoff_zone.zone as dropoff_zone,
        fhv_tripdata.pickup_datetime, 
        fhv_tripdata.dropoff_datetime,
        TIMESTAMP_DIFF(dropoff_datetime, pickup_datetime, second) as trip_duration,
        extract(year from fhv_tripdata.pickup_datetime) as year,
        extract(month from fhv_tripdata.dropoff_datetime) as month
    
    from fhv_tripdata
    inner join dim_zones as pickup_zone
    on fhv_tripdata.pickup_locationid = pickup_zone.locationid
    inner join dim_zones as dropoff_zone
    on fhv_tripdata.dropoff_locationid = dropoff_zone.locationid
),
percentiles as (
    select distinct
        year,
        month,
        pickup_locationid,
        -- pickup_borough, 
        pickup_zone,
        dropoff_locationid,
        -- dropoff_borough,
        dropoff_zone,
        percentile_cont(trip_duration, 0.9) over (
            partition by year, month, pickup_locationid, dropoff_locationid
        ) as p90
    
    from trips
)

SELECT *
FROM percentiles

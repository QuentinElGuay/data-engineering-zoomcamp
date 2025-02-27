{{
    config(
        materialized='view'
    )
}}

with fhv as 
(
  select *
  from {{ source('staging','external_fhv_tripdata') }}
  where dispatching_base_num is not null
)

select
    -- identifiers
    {{ dbt_utils.generate_surrogate_key(['dispatching_base_num', 'pickup_datetime']) }} as tripid,
    "vendispatching_base_numdorid" as vendorid,
    {{ dbt.safe_cast("PUlocationID", api.Column.translate_type("integer")) }} as pickup_locationid,
    {{ dbt.safe_cast("DOlocationID", api.Column.translate_type("integer")) }} as dropoff_locationid,

    -- timestamps
    cast(pickup_datetime as timestamp) as pickup_datetime,
    cast(dropOff_datetime as timestamp) as dropoff_datetime,

    -- other data
    {{ dbt.safe_cast("SR_Flag", api.Column.translate_type("integer")) }} as sr_flag,
    Affiliated_base_number AS afiliated_base_number

from fhv

-- dbt build --select <model_name> --vars '{'is_test_run': 'false'}'
{% if var('is_test_run', default=true) %}

  limit 100

{% endif %}

{{
  config(
    materialized=var("snowplow__incremental_materialization"),
    unique_key='event_id',
    upsert_date_key='derived_tstamp',
    partition_by = snowplow_utils.get_partition_by(bigquery_partition_by = {
      "field": "derived_tstamp",
      "data_type": "timestamp"
    }),
    tags=["derived"]
  )
}}

select *

from {{ ref('snowplow_ecommerce_checkout_interactions_this_run') }}
where {{ snowplow_utils.is_run_with_new_events('snowplow_ecommerce') }}

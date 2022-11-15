{{
  config(
    materialized=var("snowplow__incremental_materialization"),
    unique_key='identifying_userid',
    upsert_date_key='start_tstamp',
    partition_by = snowplow_utils.get_partition_by(bigquery_partition_by = {
      "field": "start_tstamp",
      "data_type": "timestamp"
    }),
    tags=["derived"]
  )
}}

select *

from {{ ref('snowplow_ecommerce_users_this_run') }}
where {{ snowplow_utils.is_run_with_new_events('snowplow_ecommerce') }}

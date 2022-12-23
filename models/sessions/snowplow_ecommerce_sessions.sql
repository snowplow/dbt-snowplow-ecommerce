{{
  config(
    materialized=var("snowplow__incremental_materialization"),
    unique_key='domain_sessionid',
    upsert_date_key='start_tstamp',
    sql_header=snowplow_utils.set_query_tag(var('snowplow__query_tag', 'snowplow_dbt')),
    partition_by = snowplow_utils.get_partition_by(bigquery_partition_by = {
      "field": "start_tstamp",
      "data_type": "timestamp"
    }),
    tags=["derived"]
  )
}}

select *

from {{ ref('snowplow_ecommerce_sessions_this_run') }}
where {{ snowplow_utils.is_run_with_new_events('snowplow_ecommerce') }}

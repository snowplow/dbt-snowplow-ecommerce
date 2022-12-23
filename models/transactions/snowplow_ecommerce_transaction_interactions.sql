{{
  config(
    materialized=var("snowplow__incremental_materialization"),
    unique_key='transaction_id',
    upsert_date_key='derived_tstamp',
    sql_header=snowplow_utils.set_query_tag(var('snowplow__query_tag', 'snowplow_dbt')),
    partition_by = snowplow_utils.get_partition_by(bigquery_partition_by = {
      "field": "derived_tstamp",
      "data_type": "timestamp"
    }),
    tags=["derived"]
  )
}}

select *

from {{ ref('snowplow_ecommerce_transaction_interactions_this_run') }}
where {{ snowplow_utils.is_run_with_new_events('snowplow_ecommerce') }}

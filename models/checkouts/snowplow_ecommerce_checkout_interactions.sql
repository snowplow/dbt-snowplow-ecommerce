{{
  config(
    materialized="incremental",
    unique_key='event_id',
    upsert_date_key='derived_tstamp',
    sql_header=snowplow_utils.set_query_tag(var('snowplow__query_tag', 'snowplow_dbt')),
    partition_by = snowplow_utils.get_value_by_target_type(bigquery_val = {
      "field": "derived_tstamp",
      "data_type": "timestamp"
    }, databricks_val='derived_tstamp_date'),
    tags=["derived"],
    tblproperties={
      'delta.autoOptimize.optimizeWrite' : 'true',
      'delta.autoOptimize.autoCompact' : 'true'
    },
    snowplow_optimize=true
  )
}}

select *

from {{ ref('snowplow_ecommerce_checkout_interactions_this_run') }}
where {{ snowplow_utils.is_run_with_new_events('snowplow_ecommerce') }}

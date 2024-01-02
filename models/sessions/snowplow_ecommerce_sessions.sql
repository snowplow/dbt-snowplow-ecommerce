{{
  config(
    materialized="incremental",
    on_schema_change='append_new_columns',
    unique_key='domain_sessionid',
    upsert_date_key='start_tstamp',
    sql_header=snowplow_utils.set_query_tag(var('snowplow__query_tag', 'snowplow_dbt')),
    partition_by = snowplow_utils.get_value_by_target_type(bigquery_val = {
      "field": "start_tstamp",
      "data_type": "timestamp"
    }, databricks_val='start_tstamp_date'),
    tags=["derived"],
    tblproperties={
      'delta.autoOptimize.optimizeWrite' : 'true',
      'delta.autoOptimize.autoCompact' : 'true'
    },
    snowplow_optimize=true
  )
}}

select *
  {% if target.type in ['databricks', 'spark'] -%}
  , DATE(start_tstamp) as start_tstamp_date
  {%- endif %}
from {{ ref('snowplow_ecommerce_sessions_this_run') }}
where {{ snowplow_utils.is_run_with_new_events('snowplow_ecommerce') }}

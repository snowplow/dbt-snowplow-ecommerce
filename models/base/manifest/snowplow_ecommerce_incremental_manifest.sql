{{
  config(
    materialized='incremental',
    sql_header=snowplow_utils.set_query_tag(var('snowplow__query_tag', 'snowplow_dbt')),
    full_refresh=snowplow_ecommerce.allow_refresh(),
    tblproperties={
      'delta.autoOptimize.optimizeWrite' : 'true',
      'delta.autoOptimize.autoCompact' : 'true'
    }
  )
}}

{% set incremental_manifest_query = snowplow_utils.base_create_snowplow_incremental_manifest() %}

{{ incremental_manifest_query }}

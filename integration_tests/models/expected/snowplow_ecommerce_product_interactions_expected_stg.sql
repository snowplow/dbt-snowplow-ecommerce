{#
Copyright (c) 2022-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}


{%- if target.type == 'snowflake' -%}
  {%- set warehouse_suffix = 'snowflake' -%}
{%- elif target.type == 'bigquery' -%}
  {%- set warehouse_suffix = 'bigquery' -%}
{%- elif target.type in ['databricks', 'spark'] -%}
  {%- set warehouse_suffix = 'databricks' -%}
{%- else -%}
  {%- set warehouse_suffix = 'default' -%}
{%- endif %}

select *

from {{ ref('snowplow_ecommerce_product_interactions_expected_' ~ warehouse_suffix) }}

{#
Copyright (c) 2022-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{{
  config(
    tags=["this_run"],
    sort='derived_tstamp',
    dist='product_event_id'
  )
}}

{%- set lower_limit, upper_limit = snowplow_utils.return_limits_from_model(ref('snowplow_ecommerce_base_sessions_this_run'),
                                                                            'start_tstamp',
                                                                            'end_tstamp') %}


with {{ snowplow_utils.get_sde_or_context(var('snowplow__atomic_schema', 'atomic'), var('snowplow__context_ecommerce_product'), lower_limit, upper_limit, 'ecommerce_product', single_entity = false, database = var("snowplow__database", target.database)) }},

product_info as (
  select
    {{ dbt_utils.generate_surrogate_key(['t.event_id', 'r.ecommerce_product_id', 'r.ecommerce_product__index']) }} as product_event_id,
    t.event_id,
    t.page_view_id,
    t.app_id,

    -- session fields
    t.domain_sessionid,
    t.event_in_session_index,

    -- user fields
    t.domain_userid,
    t.network_userid,
    t.user_id,
    t.ecommerce_user_id,

    -- timestamp fields
    t.derived_tstamp,
    DATE(derived_tstamp) as derived_tstamp_date,

    -- ecommerce product fields
    r.ecommerce_product_id as product_id,
    r.ecommerce_product_category as product_category,
    {{ snowplow_utils.get_split_to_array('ecommerce_product_category', 'r', var('snowplow__categories_separator', '/')) }} as product_categories_split,
    r.ecommerce_product_currency as product_currency,
    r.ecommerce_product_price as product_price,
    r.ecommerce_product_brand as product_brand,
    r.ecommerce_product_creative_id as product_creative_id,
    r.ecommerce_product_inventory_status as product_inventory_status,
    r.ecommerce_product_list_price as product_list_price,
    r.ecommerce_product_name as product_name,
    r.ecommerce_product_position as product_list_position,
    r.ecommerce_product_quantity as product_quantity,
    r.ecommerce_product_size as product_size,
    r.ecommerce_product_variant as product_variant,
    t.ecommerce_action_type,
    t.ecommerce_action_name,

    -- ecommerce action booleans
    t.ecommerce_action_type IN ('product_view', 'list_view') as is_product_view,
    CASE WHEN t.ecommerce_action_type IN ('product_view', 'list_view') THEN t.ecommerce_action_type END as product_view_type,
    t.ecommerce_action_type = 'add_to_cart' as is_add_to_cart,
    t.ecommerce_action_type = 'remove_from_cart' as is_remove_from_cart,
    CASE WHEN t.ecommerce_action_type = 'list_view' THEN t.ecommerce_action_name END as product_list_name,
    t.ecommerce_action_type = 'transaction' as is_product_transaction,

    t.ecommerce_user_is_guest,
    t.ecommerce_user_email,
    t.transaction_id

    {%- if var('snowplow__product_passthroughs', []) -%}
      {%- set passthrough_names = [] -%}
      {%- for identifier in var('snowplow__product_passthroughs', []) %}
      {# Check if it's a simple column or a sql+alias #}
      {%- if identifier is mapping -%}
          ,{{identifier['sql']}} as {{identifier['alias']}}
          {%- do passthrough_names.append(identifier['alias']) -%}
      {%- else -%}
          ,t.{{identifier}}
          {%- do passthrough_names.append(identifier) -%}
      {%- endif -%}
      {% endfor -%}
    {%- endif %}


  from {{ ref('snowplow_ecommerce_base_events_this_run') }} t
  inner join {{ var('snowplow__context_ecommerce_product') }} r on t.event_id = r.ecommerce_product__id and t.collector_tstamp = r.ecommerce_product__tstamp and mod(r.ecommerce_product__index, t.event_id_dedupe_count) = 0 -- ensure only a single match per total number of dupes

)

select
  product_event_id,
  -- event fields
  event_id,
  page_view_id,
  app_id,

  -- session fields
  domain_sessionid,
  event_in_session_index,

  -- user fields
  domain_userid,
  network_userid,
  user_id,
  ecommerce_user_id,

  -- timestamp fields
  derived_tstamp,
  derived_tstamp_date,

  -- ecommerce action fields
  ecommerce_action_type,
  ecommerce_action_name,

  -- ecommerce product fields
  product_id,
  product_category,
  {%- for i in range(var("snowplow__number_category_levels", 4)) %}
  {% if target.type in ['postgres'] %}
  product_categories_split[{{i+1}}]::varchar as product_subcategory_{{i+1}},
  {% else %}
  product_categories_split[{{i}}]::varchar as product_subcategory_{{i+1}},
  {% endif %}
  {%- endfor %}
  product_currency,
  product_price,
  product_brand,
  product_creative_id,
  product_inventory_status,
  product_list_price,
  product_name,
  product_list_position,
  product_quantity,
  product_size,
  product_variant,

  -- ecommerce action booleans
  is_product_view,
  product_view_type,
  is_add_to_cart,
  is_remove_from_cart,
  product_list_name,
  is_product_transaction,

  -- transaction and user fields
  transaction_id,
  ecommerce_user_email,
  ecommerce_user_is_guest


  {%- if var('snowplow__product_passthroughs', []) -%}
    {%- for col in passthrough_names %}
      , {{col}}
    {%- endfor -%}
  {%- endif %}

from product_info

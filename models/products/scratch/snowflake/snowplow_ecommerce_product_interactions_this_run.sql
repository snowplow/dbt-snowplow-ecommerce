{{
  config(
    tags=["this_run"],
    sql_header=snowplow_utils.set_query_tag(var('snowplow__query_tag', 'snowplow_dbt'))
  )
}}

with product_info as (
  select
    {{ dbt_utils.generate_surrogate_key(['t.event_id', 'r.value:id', 'r.index']) }} as product_event_id,
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
    r.value:id::string as product_id,
    r.value:category::string as product_category,
    SPLIT(r.value:category, '{{ var("snowplow__categories_separator", "/") }}') as product_categories_split,
    r.value:currency::string as product_currency,
    r.value:price::decimal(9,2) as product_price,
    r.value:brand::string as product_brand,
    r.value:creative_id::string as product_creative_id,
    r.value:inventory_status::string as product_inventory_status,
    r.value:list_price::decimal(9,2) as product_list_price,
    r.value:name::string as product_name,
    r.value:position::integer as product_list_position,
    r.value:quantity::integer as product_quantity,
    r.value:size::string as product_size,
    r.value:variant::string as product_variant,
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


  from {{ ref('snowplow_ecommerce_base_events_this_run') }} as t,
  LATERAL FLATTEN(input => t.contexts_com_snowplowanalytics_snowplow_ecommerce_product_1) r

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

  -- ecommerce product fields
  product_id,
  product_category,
  {%- for i in range(var("snowplow__number_category_levels", 4)) %}
  product_categories_split[{{i}}]::string as product_subcategory_{{i+1}},
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

from product_info

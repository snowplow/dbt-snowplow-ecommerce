{{
  config(
    tags=["this_run"]
  )
}}

with product_info as (
  select
    t.event_id,
    t.page_view_id,

    r.id as product_id,
    r.category as product_category,
    SPLIT(r.category, '{{ var("snowplow__categories_separator", "/") }}') as product_categories_split,
    r.currency as product_currency,
    r.price as product_price,
    r.brand as product_brand,
    r.creative_id as product_creative_id,
    r.inventory_status as product_inventory_status,
    r.list_price as product_list_price,
    r.name as product_name,
    r.position as product_list_position,
    r.quantity as product_quantity,
    r.size as product_size,
    r.variant as product_variant,
    t.ecommerce_action_type,
    t.ecommerce_action_name,
    t.ecommerce_user_id,
    t.ecommerce_user_is_guest,
    t.ecommerce_user_email,
    t.transaction_id


  from {{ ref('snowplow_ecommerce_base_events_this_run') }} as t, unnest(t.contexts_ecommerce_tracking_product_1_0_0) r

)

select
  {{ dbt_utils.surrogate_key(['e.event_id', 'pi.product_id']) }} as product_event_id,
  -- event fields
  e.event_id,
  e.page_view_id,

  -- session fields
  e.domain_sessionid,
  e.page_view_in_session_index,

  -- user fields
  e.domain_userid,
  e.network_userid,
  e.user_id,
  pi.ecommerce_user_id,

  -- timestamp fields
  e.derived_tstamp,
  DATE(derived_tstamp) as derived_tstamp_date,

  -- ecommerce product fields
  pi.product_id,
  pi.product_category,
  {%- for i in range(var("snowplow__number_category_levels", 4)) %}
  pi.product_categories_split[safe_offset({{i}})] as product_subcategory_{{i+1}},
  {%- endfor %}
  pi.product_currency,
  pi.product_price,
  pi.product_brand,
  pi.product_creative_id,
  pi.product_inventory_status,
  pi.product_list_price,
  pi.product_name,
  pi.product_list_position,
  pi.product_quantity,
  pi.product_size,
  pi.product_variant,

  -- ecommerce action booleans
  pi.ecommerce_action_type IN ('product_view', 'list_view') as is_product_view,
  CASE WHEN pi.ecommerce_action_type IN ('product_view', 'list_view') THEN pi.ecommerce_action_type END as product_view_type,
  pi.ecommerce_action_type = 'add_to_cart' as is_add_to_cart,
  pi.ecommerce_action_type = 'remove_from_cart' as is_remove_from_cart,
  CASE WHEN pi.ecommerce_action_type = 'list_view' THEN pi.ecommerce_action_name END as product_list_name,
  pi.ecommerce_action_type = 'transaction' as is_product_transaction,

  -- transaction and user fields
  pi.transaction_id,
  pi.ecommerce_user_email,
  pi.ecommerce_user_is_guest

from product_info as pi
join {{ ref('snowplow_ecommerce_base_events_this_run') }} as e on pi.event_id = e.event_id

{{
  config(
    tags=["this_run"]
  )
}}

with prep as (

  select
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
    t.transaction_id,

    POSEXPLODE(contexts_com_snowplowanalytics_snowplow_ecommerce_product_1) as (index, contexts_com_snowplowanalytics_snowplow_ecommerce_product_1)

  from {{ ref('snowplow_ecommerce_base_events_this_run') }} as t

), product_info as (
  select
    {{ dbt_utils.generate_surrogate_key(['event_id', 'contexts_com_snowplowanalytics_snowplow_ecommerce_product_1.id', 'index']) }} as product_event_id,
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
    contexts_com_snowplowanalytics_snowplow_ecommerce_product_1.id::string as product_id,
    contexts_com_snowplowanalytics_snowplow_ecommerce_product_1.category::string as product_category,
    {%- for i in range(var("snowplow__number_category_levels", 4)) %}
    split_part(contexts_com_snowplowanalytics_snowplow_ecommerce_product_1.category::string, '{{ var("snowplow__categories_separator", "/") }}', {{i+1}}) as product_subcategory_{{i+1}},
    {%- endfor %}
    contexts_com_snowplowanalytics_snowplow_ecommerce_product_1.currency::string as product_currency,
    contexts_com_snowplowanalytics_snowplow_ecommerce_product_1.price::decimal(9,2) as product_price,
    contexts_com_snowplowanalytics_snowplow_ecommerce_product_1.brand::string as product_brand,
    contexts_com_snowplowanalytics_snowplow_ecommerce_product_1.creative_id::string as product_creative_id,
    contexts_com_snowplowanalytics_snowplow_ecommerce_product_1.inventory_status::string as product_inventory_status,
    contexts_com_snowplowanalytics_snowplow_ecommerce_product_1.list_price::float as product_list_price,
    contexts_com_snowplowanalytics_snowplow_ecommerce_product_1.name::string as product_name,
    contexts_com_snowplowanalytics_snowplow_ecommerce_product_1.position::integer as product_list_position,
    contexts_com_snowplowanalytics_snowplow_ecommerce_product_1.quantity::integer as product_quantity,
    contexts_com_snowplowanalytics_snowplow_ecommerce_product_1.size::string as product_size,
    contexts_com_snowplowanalytics_snowplow_ecommerce_product_1.variant::string as product_variant,
    ecommerce_action_type,
    ecommerce_action_name,

    -- ecommerce action booleans
    is_product_view,
    product_view_type,
    is_add_to_cart,
    is_remove_from_cart,
    product_list_name,
    is_product_transaction,

    ecommerce_user_is_guest,
    ecommerce_user_email,
    transaction_id


  from prep

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
  CASE WHEN product_subcategory_{{i+1}} = '' THEN NULL ELSE product_subcategory_{{i+1}} END as product_subcategory_{{i+1}}, -- in case the product itself has less than the maximum number of category levels, we stay consistent with BQ/Snowflake
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

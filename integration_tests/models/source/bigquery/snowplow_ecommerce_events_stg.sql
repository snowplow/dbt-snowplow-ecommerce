with prep as (
select
  *
  except(contexts_com_snowplowanalytics_snowplow_web_page_1_0_0,
    contexts_com_snowplowanalytics_snowplow_ecommerce_user_1_0_0,
    contexts_com_snowplowanalytics_snowplow_ecommerce_page_1_0_0,
    unstruct_event_com_snowplowanalytics_snowplow_ecommerce_snowplow_ecommerce_action_1_0_0,
    contexts_com_snowplowanalytics_snowplow_ecommerce_cart_1_0_0,
    contexts_com_snowplowanalytics_snowplow_ecommerce_product_1_0_0,
    contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1_0_0,
    contexts_com_snowplowanalytics_snowplow_ecommerce_transaction_1_0_0
  ),
  JSON_EXTRACT_ARRAY(contexts_com_snowplowanalytics_snowplow_web_page_1_0_0) AS contexts_com_snowplowanalytics_snowplow_web_page_1_0_0,
  JSON_EXTRACT_ARRAY(contexts_com_snowplowanalytics_snowplow_ecommerce_user_1_0_0) as contexts_com_snowplowanalytics_snowplow_ecommerce_user_1_0_0,
  JSON_EXTRACT_ARRAY(contexts_com_snowplowanalytics_snowplow_ecommerce_page_1_0_0) as contexts_com_snowplowanalytics_snowplow_ecommerce_page_1_0_0,
  PARSE_JSON(unstruct_event_com_snowplowanalytics_snowplow_ecommerce_snowplow_ecommerce_action_1_0_0) as unstruct_event_com_snowplowanalytics_snowplow_ecommerce_snowplow_ecommerce_action_1_0_0,
  JSON_EXTRACT_ARRAY(contexts_com_snowplowanalytics_snowplow_ecommerce_cart_1_0_0) as contexts_com_snowplowanalytics_snowplow_ecommerce_cart_1_0_0,
  JSON_EXTRACT_ARRAY(contexts_com_snowplowanalytics_snowplow_ecommerce_product_1_0_0) as contexts_com_snowplowanalytics_snowplow_ecommerce_product_1_0_0,
  JSON_EXTRACT_ARRAY(contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1_0_0) as contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1_0_0,
  JSON_EXTRACT_ARRAY(contexts_com_snowplowanalytics_snowplow_ecommerce_transaction_1_0_0) as contexts_com_snowplowanalytics_snowplow_ecommerce_transaction_1_0_0



from {{ ref('snowplow_ecommerce_events') }}
)

-- recreate repeated record field i.e. array of structs as is originally in BQ events table
select
  * except(contexts_com_snowplowanalytics_snowplow_web_page_1_0_0,
    contexts_com_snowplowanalytics_snowplow_ecommerce_user_1_0_0,
    contexts_com_snowplowanalytics_snowplow_ecommerce_page_1_0_0,
    unstruct_event_com_snowplowanalytics_snowplow_ecommerce_snowplow_ecommerce_action_1_0_0,
    contexts_com_snowplowanalytics_snowplow_ecommerce_cart_1_0_0,
    contexts_com_snowplowanalytics_snowplow_ecommerce_product_1_0_0,
    contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1_0_0,
    contexts_com_snowplowanalytics_snowplow_ecommerce_transaction_1_0_0
  ),
  array(
    select as struct CAST(JSON_EXTRACT_scalar(json_array, '$.id') AS STRING) as id
    from unnest(contexts_com_snowplowanalytics_snowplow_web_page_1_0_0) as json_array
    ) as contexts_com_snowplowanalytics_snowplow_web_page_1_0_0,
  array(
    select as struct CAST(JSON_EXTRACT_scalar(json_array, '$.id') AS STRING) as id,
                     CAST(JSON_EXTRACT_scalar(json_array, '$.email') AS STRING) as email,
                     CAST(JSON_EXTRACT_scalar(json_array, '$.is_guest') AS BOOLEAN) as is_guest
    from unnest(contexts_com_snowplowanalytics_snowplow_ecommerce_user_1_0_0) as json_array
    ) as contexts_com_snowplowanalytics_snowplow_ecommerce_user_1_0_0,
  array(
    select as struct CAST(JSON_EXTRACT_scalar(json_array, '$.type') AS STRING) as type,
                     CAST(JSON_EXTRACT_scalar(json_array, '$.language') AS STRING) as language,
                     CAST(JSON_EXTRACT_scalar(json_array, '$.locale') AS STRING) as locale,
    from unnest(contexts_com_snowplowanalytics_snowplow_ecommerce_page_1_0_0) as json_array
    ) as contexts_com_snowplowanalytics_snowplow_ecommerce_page_1_0_0,
  struct (CAST(JSON_EXTRACT_scalar(unstruct_event_com_snowplowanalytics_snowplow_ecommerce_snowplow_ecommerce_action_1_0_0,'$.type') AS STRING) as type,
                     CAST(JSON_EXTRACT_scalar(unstruct_event_com_snowplowanalytics_snowplow_ecommerce_snowplow_ecommerce_action_1_0_0, '$.name') AS STRING) as name
    ) as unstruct_event_com_snowplowanalytics_snowplow_ecommerce_snowplow_ecommerce_action_1_0_0,
  array(
    select as struct CAST(JSON_EXTRACT_scalar(json_array, '$.cart_id') AS STRING) as cart_id,
                     CAST(JSON_EXTRACT_scalar(json_array, '$.currency') AS STRING) as currency,
                     CAST(JSON_EXTRACT_scalar(json_array, '$.total_value') AS NUMERIC) as total_value
    from unnest(contexts_com_snowplowanalytics_snowplow_ecommerce_cart_1_0_0) as json_array
    ) as contexts_com_snowplowanalytics_snowplow_ecommerce_cart_1_0_0,
  array(
    select as struct CAST(JSON_EXTRACT_scalar(json_array,'$.id') as STRING) as id,
                     CAST(JSON_EXTRACT_scalar(json_array,'$.name') as STRING) AS name,
                     CAST(JSON_EXTRACT_scalar(json_array,'$.category') as STRING) AS category,
                     CAST(JSON_EXTRACT_scalar(json_array,'$.price') as NUMERIC) AS price,
                     CAST(JSON_EXTRACT_scalar(json_array,'$.list_price') as NUMERIC) AS list_price,
                     CAST(JSON_EXTRACT_scalar(json_array,'$.quantity') as INTEGER) AS quantity,
                     CAST(JSON_EXTRACT_scalar(json_array,'$.size') as STRING) AS size,
                     CAST(JSON_EXTRACT_scalar(json_array,'$.variant') as STRING) AS variant,
                     CAST(JSON_EXTRACT_scalar(json_array,'$.brand') as STRING) AS brand,
                     CAST(JSON_EXTRACT_scalar(json_array,'$.inventory_status') as STRING) AS inventory_status,
                     CAST(JSON_EXTRACT_scalar(json_array,'$.position') as INTEGER) AS position,
                     CAST(JSON_EXTRACT_scalar(json_array,'$.currency') as STRING) AS currency,
                     CAST(JSON_EXTRACT_scalar(json_array,'$.creative_id') as STRING) AS creative_id
    from unnest(contexts_com_snowplowanalytics_snowplow_ecommerce_product_1_0_0) as json_array
    ) as contexts_com_snowplowanalytics_snowplow_ecommerce_product_1_0_1,
  array(
    select as struct CAST(JSON_EXTRACT_scalar(json_array, '$.step') AS INTEGER) as step,
                     CAST(JSON_EXTRACT_scalar(json_array, '$.account_type') AS STRING) as account_type,
                     CAST(JSON_EXTRACT_scalar(json_array, '$.billing_full_address') AS STRING) as billing_full_address,
                     CAST(JSON_EXTRACT_scalar(json_array, '$.billing_postcode') AS STRING) as billing_postcode,
                     CAST(JSON_EXTRACT_scalar(json_array, '$.coupon_code') AS STRING) as coupon_code,
                     CAST(JSON_EXTRACT_scalar(json_array, '$.delivery_method') AS STRING) as delivery_method,
                     CAST(JSON_EXTRACT_scalar(json_array, '$.delivery_provider') AS STRING) as delivery_provider,
                     CAST(JSON_EXTRACT_scalar(json_array, '$.marketing_opt_in') AS BOOLEAN) as marketing_opt_in,
                     CAST(JSON_EXTRACT_scalar(json_array, '$.payment_method') AS STRING) as payment_method,
                     CAST(JSON_EXTRACT_scalar(json_array, '$.proof_of_payment') AS STRING) as proof_of_payment,
                     CAST(JSON_EXTRACT_scalar(json_array, '$.shipping_full_address') AS STRING) as shipping_full_address,
                     CAST(JSON_EXTRACT_scalar(json_array, '$.shipping_postcode') AS STRING) as shipping_postcode
    from unnest(contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1_0_0) as json_array
    ) as contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1_0_0,
  array(
    select as struct CAST(JSON_EXTRACT_scalar(json_array,'$.transaction_id') as STRING) AS transaction_id,
                     CAST(JSON_EXTRACT_scalar(json_array, '$.currency') AS STRING) as currency,
                     CAST(JSON_EXTRACT_scalar(json_array, '$.payment_method') AS STRING) as payment_method,
                     CAST(JSON_EXTRACT_scalar(json_array, '$.revenue') AS NUMERIC) as revenue,
                     CAST(JSON_EXTRACT_scalar(json_array, '$.total_quantity') AS INTEGER) as total_quantity,
                     CAST(JSON_EXTRACT_scalar(json_array, '$.credit_order') AS STRING) as credit_order,
                     CAST(JSON_EXTRACT_scalar(json_array, '$.discount_amount') AS NUMERIC) as discount_amount,
                     CAST(JSON_EXTRACT_scalar(json_array, '$.discount_code') AS BOOLEAN) as discount_code,
                     CAST(JSON_EXTRACT_scalar(json_array, '$.shipping') AS NUMERIC) as shipping,
                     CAST(JSON_EXTRACT_scalar(json_array, '$.tax') AS NUMERIC) as tax
    from unnest(contexts_com_snowplowanalytics_snowplow_ecommerce_transaction_1_0_0) as json_array
    ) as contexts_com_snowplowanalytics_snowplow_ecommerce_transaction_1_0_0

from prep

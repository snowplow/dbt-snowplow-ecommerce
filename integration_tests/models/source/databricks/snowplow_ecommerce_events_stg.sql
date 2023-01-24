-- Contexts are given as json string in csv. Parse json
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
  				 contexts_com_snowplowanalytics_snowplow_ecommerce_transaction_1_0_0)
  ,
  from_json(contexts_com_snowplowanalytics_snowplow_web_page_1_0_0, 'array<struct<id:string>>') as contexts_com_snowplowanalytics_snowplow_web_page_1,
  from_json(contexts_com_snowplowanalytics_snowplow_ecommerce_user_1_0_0, 'array<struct<id:string, email:string, is_guest:string>>') as contexts_com_snowplowanalytics_snowplow_ecommerce_user_1,
  from_json(contexts_com_snowplowanalytics_snowplow_ecommerce_page_1_0_0, 'array<struct<type:string, language:string, locale:string>>') as contexts_com_snowplowanalytics_snowplow_ecommerce_page_1,
  from_json(unstruct_event_com_snowplowanalytics_snowplow_ecommerce_snowplow_ecommerce_action_1_0_0, 'struct<type:string, name:string>') as unstruct_event_com_snowplowanalytics_snowplow_ecommerce_snowplow_ecommerce_action_1,
  from_json(contexts_com_snowplowanalytics_snowplow_ecommerce_cart_1_0_0, 'array<struct<currency:string, total_value:decimal(7,2), cart_id:string>>') as contexts_com_snowplowanalytics_snowplow_ecommerce_cart_1,
  from_json(contexts_com_snowplowanalytics_snowplow_ecommerce_product_1_0_0, 'array<struct<category:string, currency:string, id:string, price:decimal(7,2), brand:string, creative_id:string, inventory_status:string, list_price:decimal(7,2), name:string, position:string, quantity:string, size:string, variant:string>>') as contexts_com_snowplowanalytics_snowplow_ecommerce_product_1,
  from_json(contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1_0_0, 'array<struct<step:string, account_type:string, billing_full_address:string, billing_postcode:string, coupon_code:string, delivery_method:string, delivery_provider:string, marketing_opt_in:boolean, payment_method:string, proof_of_payment:string, shipping_full_address:string, shipping_postcode:string>>') as contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1,
  from_json(contexts_com_snowplowanalytics_snowplow_ecommerce_transaction_1_0_0, 'array<struct<currency:string, payment_method:string, revenue:decimal(7,2), total_quantity:string, transaction_id:string, credit_order:boolean, discount_amount:decimal(7,2), discount_code:string, shipping:decimal(7,2), tax:decimal(7,2)>>') as contexts_com_snowplowanalytics_snowplow_ecommerce_transaction_1


from {{ ref('snowplow_ecommerce_events') }}
)
select
	*

from prep

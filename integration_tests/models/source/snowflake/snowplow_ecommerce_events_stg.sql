{#
Copyright (c) 2022-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

-- page view context is given as json string in csv. Parse json
with prep as (
select
  *,
  parse_json(contexts_com_snowplowanalytics_snowplow_web_page_1_0_0) as contexts_com_snowplowanalytics_snowplow_web_page_1,
  parse_json(contexts_com_snowplowanalytics_snowplow_ecommerce_user_1_0_0) as contexts_com_snowplowanalytics_snowplow_ecommerce_user_1,
  parse_json(contexts_com_snowplowanalytics_snowplow_ecommerce_page_1_0_0) as contexts_com_snowplowanalytics_snowplow_ecommerce_page_1,
  parse_json(unstruct_event_com_snowplowanalytics_snowplow_ecommerce_snowplow_ecommerce_action_1_0_0) as unstruct_event_com_snowplowanalytics_snowplow_ecommerce_snowplow_ecommerce_action_1,
  parse_json(contexts_com_snowplowanalytics_snowplow_ecommerce_cart_1_0_0) as contexts_com_snowplowanalytics_snowplow_ecommerce_cart_1,
  parse_json(contexts_com_snowplowanalytics_snowplow_ecommerce_product_1_0_0) as contexts_com_snowplowanalytics_snowplow_ecommerce_product_1,
  parse_json(contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1_0_0) as contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1,
  parse_json(contexts_com_snowplowanalytics_snowplow_ecommerce_transaction_1_0_0) as contexts_com_snowplowanalytics_snowplow_ecommerce_transaction_1,
  parse_json(contexts_com_snowplowanalytics_snowplow_client_session_1_0_1) as contexts_com_snowplowanalytics_snowplow_client_session_1,
  parse_json(contexts_com_snowplowanalytics_mobile_screen_1_0_0) as contexts_com_snowplowanalytics_mobile_screen_1


from {{ ref('snowplow_ecommerce_events') }}
), flatten as (
select
  *
  exclude(
    contexts_com_snowplowanalytics_snowplow_web_page_1_0_0,
    contexts_com_snowplowanalytics_snowplow_ecommerce_user_1_0_0,
    contexts_com_snowplowanalytics_snowplow_ecommerce_page_1_0_0,
    unstruct_event_com_snowplowanalytics_snowplow_ecommerce_snowplow_ecommerce_action_1_0_0,
    contexts_com_snowplowanalytics_snowplow_ecommerce_cart_1_0_0,
    contexts_com_snowplowanalytics_snowplow_ecommerce_product_1_0_0,
    contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1_0_0,
    contexts_com_snowplowanalytics_snowplow_ecommerce_transaction_1_0_0,
    contexts_com_snowplowanalytics_mobile_screen_1_0_0,
    contexts_com_snowplowanalytics_snowplow_client_session_1_0_1
  ),
    contexts_com_snowplowanalytics_snowplow_web_page_1[0].id as page_view_id,
    contexts_com_snowplowanalytics_snowplow_ecommerce_user_1[0].id as ecommerce_user_id,
    contexts_com_snowplowanalytics_snowplow_ecommerce_user_1[0].email as ecommerce_user_email,
    contexts_com_snowplowanalytics_snowplow_ecommerce_user_1[0].is_guest as ecommerce_user_is_guest,
    contexts_com_snowplowanalytics_snowplow_ecommerce_page_1[0].type as ecommerce_page_type,
    contexts_com_snowplowanalytics_snowplow_ecommerce_page_1[0].language as ecommerce_page_language,
    contexts_com_snowplowanalytics_snowplow_ecommerce_page_1[0].locale as ecommerce_page_locale,
    unstruct_event_com_snowplowanalytics_snowplow_ecommerce_snowplow_ecommerce_action_1:type as ecommerce_action_type,
    unstruct_event_com_snowplowanalytics_snowplow_ecommerce_snowplow_ecommerce_action_1:name as ecommerce_action_name,
    contexts_com_snowplowanalytics_snowplow_ecommerce_cart_1[0].cart_id as ecommerce_cart_id,
    contexts_com_snowplowanalytics_snowplow_ecommerce_cart_1[0].currency as ecommerce_cart_currency,
    contexts_com_snowplowanalytics_snowplow_ecommerce_cart_1[0].total_value as ecommerce_cart_total_value,
    contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1[0].step as checkout_step_number,
    contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1[0].account_type as checkout_account_type,
    contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1[0].billing_full_address as checkout_billing_full_address,
    contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1[0].billing_postcode as checkout_billing_postcode,
    contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1[0].coupon_code as checkout_coupon_code,
    contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1[0].delivery_method as checkout_delivery_method,
    contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1[0].delivery_provider as checkout_delivery_provider,
    contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1[0].marketing_opt_in as checkout_marketing_opt_in,
    contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1[0].payment_method as checkout_payment_method,
    contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1[0].proof_of_payment as checkout_proof_of_payment,
    contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1[0].shipping_full_address as checkout_shipping_full_address,
    contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1[0].shipping_postcode as checkout_shipping_postcode,
    contexts_com_snowplowanalytics_snowplow_ecommerce_transaction_1[0].transaction_id as ecommerce_transaction_id,
    contexts_com_snowplowanalytics_snowplow_ecommerce_transaction_1[0].currency as ecommerce_currency,
    contexts_com_snowplowanalytics_snowplow_ecommerce_transaction_1[0].payment_method as ecommerce_payment_method,
    contexts_com_snowplowanalytics_snowplow_ecommerce_transaction_1[0].revenue as ecommerce_revenue,
    contexts_com_snowplowanalytics_snowplow_ecommerce_transaction_1[0].total_quantity as ecommerce_total_quantity,
    contexts_com_snowplowanalytics_snowplow_ecommerce_transaction_1[0].credit_order as ecommerce_credit_order,
    contexts_com_snowplowanalytics_snowplow_ecommerce_transaction_1[0].discount_amount as ecommerce_discount_amount,
    contexts_com_snowplowanalytics_snowplow_ecommerce_transaction_1[0].discount_code as ecommerce_discount_code,
    contexts_com_snowplowanalytics_snowplow_ecommerce_transaction_1[0].shipping as ecommerce_shipping,
    contexts_com_snowplowanalytics_snowplow_ecommerce_transaction_1[0].tax as ecommerce_tax,
    contexts_com_snowplowanalytics_snowplow_client_session_1[0].eventIndex as event_index,
    contexts_com_snowplowanalytics_snowplow_client_session_1[0].firstEventId as first_event_id,
    contexts_com_snowplowanalytics_snowplow_client_session_1[0].firstEventTimestamp as first_event_timestamp,
    contexts_com_snowplowanalytics_snowplow_client_session_1[0].previousSessionId as previous_session_id,
    contexts_com_snowplowanalytics_snowplow_client_session_1[0].sessionId as session_id,
    contexts_com_snowplowanalytics_snowplow_client_session_1[0].sessionIndex as session_index,
    contexts_com_snowplowanalytics_snowplow_client_session_1[0].storageMechanism as storage_mechanism,
    contexts_com_snowplowanalytics_snowplow_client_session_1[0].userId as mobile_user_id,
    contexts_com_snowplowanalytics_mobile_screen_1[0].id as screen_view_id,
    contexts_com_snowplowanalytics_mobile_screen_1[0].name as screen_view_name

  from prep
)


select
  *
  exclude(
    contexts_com_snowplowanalytics_snowplow_web_page_1,
    contexts_com_snowplowanalytics_snowplow_ecommerce_user_1,
    contexts_com_snowplowanalytics_snowplow_ecommerce_page_1,
    unstruct_event_com_snowplowanalytics_snowplow_ecommerce_snowplow_ecommerce_action_1,
    contexts_com_snowplowanalytics_snowplow_ecommerce_cart_1,
    contexts_com_snowplowanalytics_snowplow_ecommerce_product_1,
    contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1,
    contexts_com_snowplowanalytics_snowplow_ecommerce_transaction_1,
    contexts_com_snowplowanalytics_mobile_screen_1,
    contexts_com_snowplowanalytics_snowplow_client_session_1,
    EVENT,
    TXN_ID,
    PAGE_VIEW_ID,
    ECOMMERCE_USER_ID,
    ECOMMERCE_USER_EMAIL,
    ECOMMERCE_USER_IS_GUEST,
    ECOMMERCE_PAGE_TYPE,
    ECOMMERCE_PAGE_LANGUAGE,
    ECOMMERCE_PAGE_LOCALE,
    ECOMMERCE_ACTION_TYPE,
    ECOMMERCE_ACTION_NAME,
    ECOMMERCE_CART_ID,
    ECOMMERCE_CART_CURRENCY,
    ECOMMERCE_CART_TOTAL_VALUE,
    CHECKOUT_STEP_NUMBER,
    CHECKOUT_ACCOUNT_TYPE,
    CHECKOUT_BILLING_FULL_ADDRESS,
    CHECKOUT_BILLING_POSTCODE,
    CHECKOUT_COUPON_CODE,
    CHECKOUT_DELIVERY_METHOD,
    CHECKOUT_DELIVERY_PROVIDER,
    CHECKOUT_MARKETING_OPT_IN,
    CHECKOUT_PAYMENT_METHOD,
    CHECKOUT_PROOF_OF_PAYMENT,
    CHECKOUT_SHIPPING_FULL_ADDRESS,
    CHECKOUT_SHIPPING_POSTCODE,
    ECOMMERCE_TRANSACTION_ID,
    ECOMMERCE_CURRENCY,
    ECOMMERCE_PAYMENT_METHOD,
    ECOMMERCE_REVENUE,
    ECOMMERCE_TOTAL_QUANTITY,
    ECOMMERCE_CREDIT_ORDER,
    ECOMMERCE_DISCOUNT_AMOUNT,
    ECOMMERCE_DISCOUNT_CODE,
    ECOMMERCE_SHIPPING,
    ECOMMERCE_TAX,
    EVENT_INDEX,
    FIRST_EVENT_ID,
    FIRST_EVENT_TIMESTAMP,
    PREVIOUS_SESSION_ID,
    SESSION_ID,
    SESSION_INDEX,
    STORAGE_MECHANISM,
    MOBILE_USER_ID,
    SCREEN_VIEW_ID,
    SCREEN_VIEW_NAME
  ),
  object_construct('type', ecommerce_action_type, 'name', ecommerce_action_name) as unstruct_event_com_snowplowanalytics_snowplow_ecommerce_snowplow_ecommerce_action_1,
  -- we do this complicated nonsense because Snowflake's `parse_json` function returns a null object if any of the fields inside the JSON are null...
  TO_VARIANT(ARRAY_CONSTRUCT(OBJECT_CONSTRUCT_KEEP_NULL('id', page_view_id))) as contexts_com_snowplowanalytics_snowplow_web_page_1,
  TO_VARIANT(ARRAY_CONSTRUCT(OBJECT_CONSTRUCT_KEEP_NULL('id',ecommerce_user_id,'email',ecommerce_user_email,'is_guest',ecommerce_user_is_guest))) as contexts_com_snowplowanalytics_snowplow_ecommerce_user_1,
  TO_VARIANT(ARRAY_CONSTRUCT(OBJECT_CONSTRUCT_KEEP_NULL('type',ecommerce_page_type,'language',ecommerce_page_language,'locale',ecommerce_page_locale))) as contexts_com_snowplowanalytics_snowplow_ecommerce_page_1,
  TO_VARIANT(ARRAY_CONSTRUCT(OBJECT_CONSTRUCT_KEEP_NULL('cart_id',ecommerce_cart_id,'currency',ecommerce_cart_currency,'total_value',ecommerce_cart_total_value))) as contexts_com_snowplowanalytics_snowplow_ecommerce_cart_1,
  contexts_com_snowplowanalytics_snowplow_ecommerce_product_1,
  TO_VARIANT(ARRAY_CONSTRUCT(OBJECT_CONSTRUCT_KEEP_NULL('step',checkout_step_number,'account_type',checkout_account_type,'billing_full_address',checkout_billing_full_address,'billing_postcode',checkout_billing_postcode,'coupon_code',checkout_coupon_code,'delivery_method',checkout_delivery_method,'delivery_provider',checkout_delivery_provider,'marketing_opt_in',checkout_marketing_opt_in,'payment_method',checkout_payment_method,'proof_of_payment',checkout_proof_of_payment,'shipping_full_address',checkout_shipping_full_address,'shipping_postcode',checkout_shipping_postcode))) as contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1,
  TO_VARIANT(ARRAY_CONSTRUCT(OBJECT_CONSTRUCT_KEEP_NULL('transaction_id',ecommerce_transaction_id,'currency',ecommerce_currency,'payment_method',ecommerce_payment_method,'revenue',ecommerce_revenue,'total_quantity',ecommerce_total_quantity,'credit_order',ecommerce_credit_order,'discount_amount',ecommerce_discount_amount,'discount_code',ecommerce_discount_code,'shipping',ecommerce_shipping,'tax',ecommerce_tax))) as contexts_com_snowplowanalytics_snowplow_ecommerce_transaction_1,
  TO_VARIANT(ARRAY_CONSTRUCT(OBJECT_CONSTRUCT_KEEP_NULL('eventIndex',event_index,'firstEventId',first_event_id,'firstEventTimestamp',first_event_timestamp,'previousSessionId',previous_session_id,'sessionId',session_id,'sessionIndex',session_index,'storageMechanism',storage_mechanism,'userId',mobile_user_id))) as contexts_com_snowplowanalytics_snowplow_client_session_1,
  TO_VARIANT(ARRAY_CONSTRUCT(OBJECT_CONSTRUCT_KEEP_NULL('id',screen_view_id,'name',screen_view_name))) as contexts_com_snowplowanalytics_mobile_screen_1

from flatten

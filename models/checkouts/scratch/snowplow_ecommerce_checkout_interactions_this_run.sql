{#
Copyright (c) 2022-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{{
  config(
    tags=["this_run"],
    sql_header=snowplow_utils.set_query_tag(var('snowplow__query_tag', 'snowplow_dbt'))
  )
}}

select
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
  DATE(derived_tstamp) as derived_tstamp_date,

  -- ecommerce action fields
  ecommerce_action_type,
  ecommerce_action_name,
  ecommerce_page_type,

  -- checkout step fields
  CASE WHEN ecommerce_action_type = 'transaction' THEN {{ var("snowplow__number_checkout_steps", 4) }}
    ELSE checkout_step_number END as checkout_step_number,
  checkout_account_type,
  checkout_billing_full_address,
  checkout_billing_postcode,
  checkout_coupon_code,
  checkout_delivery_method,
  checkout_delivery_provider,
  checkout_marketing_opt_in,
  checkout_payment_method,
  checkout_proof_of_payment,
  checkout_shipping_full_address,
  checkout_shipping_postcode,
  event_in_session_index = 1 as session_entered_at_step,
  ecommerce_action_type = 'transaction' as checkout_succeeded,

  -- ecommerce user fields
  ecommerce_user_email,
  ecommerce_user_is_guest

  {%- if var('snowplow__checkout_passthroughs', []) -%}
    {%- for identifier in var('snowplow__checkout_passthroughs', []) %}
    {# Check if it's a simple column or a sql+alias #}
    {%- if identifier is mapping -%}
        ,{{identifier['sql']}} as {{identifier['alias']}}
    {%- else -%}
        ,{{identifier}}
    {%- endif -%}
    {% endfor -%}
  {%- endif %}

from {{ ref("snowplow_ecommerce_base_events_this_run") }}
where ecommerce_action_type IN ('transaction', 'checkout_step') -- the two checkout step action types. Either you've initiated the checkout or you've finished with a transaction step

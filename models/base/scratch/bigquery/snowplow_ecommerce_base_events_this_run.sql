{{
  config(
    tags=["this_run"]
  )
}}

{%- set lower_limit, upper_limit = snowplow_utils.return_limits_from_model(ref('snowplow_ecommerce_base_sessions_this_run'),
                                                                          'start_tstamp',
                                                                          'end_tstamp') %}


select
  *,
  row_number() over (partition by ev.domain_sessionid order by ev.derived_tstamp) AS page_view_in_session_index,

from (
  -- without downstream joins, it's safe to dedupe by picking the first event_id found.
  select
    array_agg(e order by e.collector_tstamp limit 1)[offset(0)].*

  from (

  select
    a.contexts_com_snowplowanalytics_snowplow_web_page_1_0_0[safe_offset(0)].id as page_view_id,
    b.domain_userid,
    a.contexts_ecommerce_tracking_user_1_0_0[safe_offset(0)].id as ecommerce_user_id,
    a.contexts_ecommerce_tracking_user_1_0_0[safe_offset(0)].email as ecommerce_user_email,
    a.contexts_ecommerce_tracking_user_1_0_0[safe_offset(0)].is_guest as ecommerce_user_is_guest,

    -- unpacking the ecommerce checkout step object
    a.contexts_ecommerce_tracking_checkout_step_1_0_0[safe_offset(0)].step as checkout_step_number,
    a.contexts_ecommerce_tracking_checkout_step_1_0_0[safe_offset(0)].account_type as checkout_account_type,
    a.contexts_ecommerce_tracking_checkout_step_1_0_0[safe_offset(0)].billing_full_address as checkout_billing_full_address,
    a.contexts_ecommerce_tracking_checkout_step_1_0_0[safe_offset(0)].billing_postcode as checkout_billing_postcode,
    a.contexts_ecommerce_tracking_checkout_step_1_0_0[safe_offset(0)].coupon_code as checkout_coupon_code,
    a.contexts_ecommerce_tracking_checkout_step_1_0_0[safe_offset(0)].delivery_method as checkout_delivery_method,
    a.contexts_ecommerce_tracking_checkout_step_1_0_0[safe_offset(0)].delivery_provider as checkout_delivery_provider,
    a.contexts_ecommerce_tracking_checkout_step_1_0_0[safe_offset(0)].marketing_opt_in as checkout_marketing_opt_in,
    a.contexts_ecommerce_tracking_checkout_step_1_0_0[safe_offset(0)].payment_method as checkout_payment_method,
    a.contexts_ecommerce_tracking_checkout_step_1_0_0[safe_offset(0)].proof_of_payment as checkout_proof_of_payment,
    a.contexts_ecommerce_tracking_checkout_step_1_0_0[safe_offset(0)].shipping_full_address as checkout_shipping_full_address,
    a.contexts_ecommerce_tracking_checkout_step_1_0_0[safe_offset(0)].shipping_postcode as checkout_shipping_postcode,

    -- unpacking the ecommerce page object
    a.contexts_ecommerce_tracking_page_1_0_0[safe_offset(0)].type as ecommerce_page_type,
    a.contexts_ecommerce_tracking_page_1_0_0[safe_offset(0)].language as ecommerce_page_language,
    a.contexts_ecommerce_tracking_page_1_0_0[safe_offset(0)].locale as ecommerce_page_locale,

    -- unpacking the ecommerce transaction object
    a.contexts_ecommerce_tracking_transaction_1_0_0[safe_offset(0)].transaction_id as transaction_id,
    a.contexts_ecommerce_tracking_transaction_1_0_0[safe_offset(0)].currency as transaction_currency,
    a.contexts_ecommerce_tracking_transaction_1_0_0[safe_offset(0)].payment_method as transaction_payment_method,
    a.contexts_ecommerce_tracking_transaction_1_0_0[safe_offset(0)].revenue as transaction_revenue,
    a.contexts_ecommerce_tracking_transaction_1_0_0[safe_offset(0)].total_quantity as transaction_total_quantity,
    a.contexts_ecommerce_tracking_transaction_1_0_0[safe_offset(0)].credit_order as transaction_credit_order,
    a.contexts_ecommerce_tracking_transaction_1_0_0[safe_offset(0)].discount_amount as transaction_discount_amount,
    a.contexts_ecommerce_tracking_transaction_1_0_0[safe_offset(0)].discount_code as transaction_discount_code,
    a.contexts_ecommerce_tracking_transaction_1_0_0[safe_offset(0)].shipping as transaction_shipping,
    a.contexts_ecommerce_tracking_transaction_1_0_0[safe_offset(0)].tax as transaction_tax,

    -- unpacking the ecommerce cart object
    a.contexts_ecommerce_tracking_cart_1_0_0[safe_offset(0)].cart_id as cart_id,
    a.contexts_ecommerce_tracking_cart_1_0_0[safe_offset(0)].currency as cart_currency,
    a.contexts_ecommerce_tracking_cart_1_0_0[safe_offset(0)].total_value as cart_total_value,

    -- unpacking the ecommerce action object
    a.unstruct_event_ecommerce_tracking_action_1_0_0.type as ecommerce_action_type,
    a.unstruct_event_ecommerce_tracking_action_1_0_0.name as ecommerce_action_name,


    a.* except(contexts_com_snowplowanalytics_snowplow_web_page_1_0_0,
               domain_userid,
               contexts_ecommerce_tracking_user_1_0_0,
               contexts_ecommerce_tracking_checkout_step_1_0_0,
               contexts_ecommerce_tracking_page_1_0_0,
               contexts_ecommerce_tracking_transaction_1_0_0,
               contexts_ecommerce_tracking_cart_1_0_0,
               unstruct_event_ecommerce_tracking_action_1_0_0
               )


    from {{ var('snowplow__events') }} as a
    inner join {{ ref('snowplow_ecommerce_base_sessions_this_run') }} as b
    on a.domain_sessionid = b.session_id

    where a.collector_tstamp <= {{ snowplow_utils.timestamp_add('day', var("snowplow__max_session_days", 3), 'b.start_tstamp') }}
    and a.dvce_sent_tstamp <= {{ snowplow_utils.timestamp_add('day', var("snowplow__days_late_allowed", 3), 'a.dvce_created_tstamp') }}
    and a.collector_tstamp >= {{ lower_limit }}
    and a.collector_tstamp <= {{ upper_limit }}
    {% if var('snowplow__derived_tstamp_partitioned', true) and target.type == 'bigquery' | as_bool() %}
      and a.derived_tstamp >= {{ snowplow_utils.timestamp_add('hour', -1, lower_limit) }}
      and a.derived_tstamp <= {{ upper_limit }}
    {% endif %}
    and {{ snowplow_utils.app_id_filter(var("snowplow__app_id",[])) }}
    and lower(a.event_name) in {{ var("snowplow__ecommerce_event_names", "('snowplow_ecommerce_action')") }}
  ) e
  group by e.event_id
) ev

{{
  config(
    tags=["this_run"],
    sql_header=snowplow_utils.set_query_tag(var('snowplow__query_tag', 'snowplow_dbt'))
  )
}}

{%- set lower_limit, upper_limit = snowplow_utils.return_limits_from_model(ref('snowplow_ecommerce_base_sessions_this_run'),
                                                                          'start_tstamp',
                                                                          'end_tstamp') %}

with prep as (

  select
    a.contexts_com_snowplowanalytics_snowplow_web_page_1[0]:id::varchar as page_view_id,
    b.domain_userid,

    -- unpacking the ecommerce user object
    {% if var('snowplow__disable_ecommerce_user_context', false) -%}
    cast(NULL as {{ type_string() }}) as ecommerce_user_id,
    cast(NULL as {{ type_string() }}) as ecommerce_user_email,
    cast(NULL as {{ type_boolean() }}) as ecommerce_user_is_guest,
    {%- else -%}
    a.contexts_com_snowplowanalytics_snowplow_ecommerce_user_1[0]:id::varchar as ecommerce_user_id,
    a.contexts_com_snowplowanalytics_snowplow_ecommerce_user_1[0]:email::varchar as ecommerce_user_email,
    a.contexts_com_snowplowanalytics_snowplow_ecommerce_user_1[0]:is_guest::boolean as ecommerce_user_is_guest,
    {%- endif %}

    -- unpacking the ecommerce checkout step object
    {% if var('snowplow__disable_ecommerce_checkouts', false) -%}
    cast(NULL as {{ type_int() }}) as checkout_step_number,
    cast(NULL as {{ type_string() }}) as checkout_account_type,
    cast(NULL as {{ type_string() }}) as checkout_billing_full_address,
    cast(NULL as {{ type_string() }}) as checkout_billing_postcode,
    cast(NULL as {{ type_string() }}) as checkout_coupon_code,
    cast(NULL as {{ type_string() }}) as checkout_delivery_method,
    cast(NULL as {{ type_string() }}) as checkout_delivery_provider,
    cast(NULL as {{ type_boolean() }}) as checkout_marketing_opt_in,
    cast(NULL as {{ type_string() }}) as checkout_payment_method,
    cast(NULL as {{ type_string() }}) as checkout_proof_of_payment,
    cast(NULL as {{ type_string() }}) as checkout_shipping_full_address,
    cast(NULL as {{ type_string() }}) as checkout_shipping_postcode,
    {%- else -%}
    a.contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1[0]:step::int as checkout_step_number,
    a.contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1[0]:account_type::varchar as checkout_account_type,
    a.contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1[0]:billing_full_address::varchar as checkout_billing_full_address,
    a.contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1[0]:billing_postcode::varchar as checkout_billing_postcode,
    a.contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1[0]:coupon_code::varchar as checkout_coupon_code,
    a.contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1[0]:delivery_method::varchar as checkout_delivery_method,
    a.contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1[0]:delivery_provider::varchar as checkout_delivery_provider,
    a.contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1[0]:marketing_opt_in::boolean as checkout_marketing_opt_in,
    a.contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1[0]:payment_method::varchar as checkout_payment_method,
    a.contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1[0]:proof_of_payment::varchar as checkout_proof_of_payment,
    a.contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1[0]:shipping_full_address::varchar as checkout_shipping_full_address,
    a.contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1[0]:shipping_postcode::varchar as checkout_shipping_postcode,
    {%- endif %}

    -- unpacking the ecommerce page object
    {% if var('snowplow__disable_ecommerce_page_context', false) -%}
    CAST(NULL as {{ type_string() }}) as ecommerce_page_type,
    CAST(NULL as {{ type_string() }}) as ecommerce_page_language,
    CAST(NULL as {{ type_string() }}) as ecommerce_page_locale,

    {%- else -%}
    a.contexts_com_snowplowanalytics_snowplow_ecommerce_page_1[0]:type::varchar as ecommerce_page_type,
    a.contexts_com_snowplowanalytics_snowplow_ecommerce_page_1[0]:language::varchar as ecommerce_page_language,
    a.contexts_com_snowplowanalytics_snowplow_ecommerce_page_1[0]:locale::varchar as ecommerce_page_locale,
    {%- endif %}

    -- unpacking the ecommerce transaction object
    {% if var('snowplow__disable_ecommerce_transactions', false) -%}
    CAST(NULL AS {{ type_string() }}) as transaction_id,
    CAST(NULL AS {{ type_string() }}) as transaction_currency,
    CAST(NULL AS {{ type_string() }}) as transaction_payment_method,
    CAST(NULL AS decimal(9,2)) as transaction_revenue,
    CAST(NULL AS {{ type_int() }}) as transaction_total_quantity,
    CAST(NULL AS {{ type_boolean() }}) as transaction_credit_order,
    CAST(NULL AS decimal(9,2)) as transaction_discount_amount,
    CAST(NULL AS {{ type_string() }}) as transaction_discount_code,
    CAST(NULL AS decimal(9,2)) as transaction_shipping,
    CAST(NULL AS decimal(9,2)) as transaction_tax,
    {%- else -%}
    a.contexts_com_snowplowanalytics_snowplow_ecommerce_transaction_1[0]:transaction_id::varchar as transaction_id,
    a.contexts_com_snowplowanalytics_snowplow_ecommerce_transaction_1[0]:currency::varchar as transaction_currency,
    a.contexts_com_snowplowanalytics_snowplow_ecommerce_transaction_1[0]:payment_method::varchar as transaction_payment_method,
    a.contexts_com_snowplowanalytics_snowplow_ecommerce_transaction_1[0]:revenue::decimal(9,2) as transaction_revenue,
    a.contexts_com_snowplowanalytics_snowplow_ecommerce_transaction_1[0]:total_quantity::int as transaction_total_quantity,
    a.contexts_com_snowplowanalytics_snowplow_ecommerce_transaction_1[0]:credit_order::boolean as transaction_credit_order,
    a.contexts_com_snowplowanalytics_snowplow_ecommerce_transaction_1[0]:discount_amount::decimal(9,2) as transaction_discount_amount,
    a.contexts_com_snowplowanalytics_snowplow_ecommerce_transaction_1[0]:discount_code::varchar as transaction_discount_code,
    a.contexts_com_snowplowanalytics_snowplow_ecommerce_transaction_1[0]:shipping::decimal(9,2) as transaction_shipping,
    a.contexts_com_snowplowanalytics_snowplow_ecommerce_transaction_1[0]:tax::decimal(9,2) as transaction_tax,
    {%- endif %}

    -- unpacking the ecommerce cart object
    {% if var('snowplow__disable_ecommerce_carts', false) -%}
    CAST(NULL AS {{ type_string() }}) as cart_id,
    CAST(NULL AS {{ type_string() }}) as cart_currency,
    CAST(NULL AS decimal(9,2)) as cart_total_value,
    {%- else -%}
    a.contexts_com_snowplowanalytics_snowplow_ecommerce_cart_1[0]:cart_id::varchar as cart_id,
    a.contexts_com_snowplowanalytics_snowplow_ecommerce_cart_1[0]:currency::varchar as cart_currency,
    a.contexts_com_snowplowanalytics_snowplow_ecommerce_cart_1[0]:total_value::decimal(9,2) as cart_total_value,
    {%- endif%}

    -- unpacking the ecommerce action object
    a.unstruct_event_com_snowplowanalytics_snowplow_ecommerce_snowplow_ecommerce_action_1:type::varchar as ecommerce_action_type,
    a.unstruct_event_com_snowplowanalytics_snowplow_ecommerce_snowplow_ecommerce_action_1:name::varchar as ecommerce_action_name,

    a.* exclude(contexts_com_snowplowanalytics_snowplow_web_page_1, domain_userid)


  from {{ var('snowplow__events') }} as a
  inner join {{ ref('snowplow_ecommerce_base_sessions_this_run') }} as b
  on a.domain_sessionid = b.session_id

  where a.collector_tstamp <= {{ snowplow_utils.timestamp_add('day', var("snowplow__max_session_days", 3), 'b.start_tstamp') }}
  and a.dvce_sent_tstamp <= {{ snowplow_utils.timestamp_add('day', var("snowplow__days_late_allowed", 3), 'a.dvce_created_tstamp') }}
  and a.collector_tstamp >= {{ lower_limit }}
  and a.collector_tstamp <= {{ upper_limit }}
  and {{ snowplow_utils.app_id_filter(var("snowplow__app_id",[])) }}
  and {{ snowplow_ecommerce.event_name_filter(var("snowplow__ecommerce_event_names", "['snowplow_ecommerce_action']")) }}

  qualify row_number() over (partition by a.event_id order by a.collector_tstamp) = 1
)

select *,
       dense_rank() over (partition by domain_sessionid order by derived_tstamp) AS event_in_session_index

from prep

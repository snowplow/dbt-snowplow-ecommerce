{#
Copyright (c) 2022-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{% macro get_checkout_context_fields() %}
    {{ return(adapter.dispatch('get_checkout_context_fields', 'snowplow_ecommerce')()) }}
{%- endmacro -%}

{% macro postgres__get_checkout_context_fields() %}
    {% if var('snowplow__disable_ecommerce_checkouts', false) %}
        , cast(NULL as {{ type_int() }}) as checkout_step_number
        , cast(NULL as {{ type_string() }}) as checkout_account_type
        , cast(NULL as {{ type_string() }}) as checkout_billing_full_address
        , cast(NULL as {{ type_string() }}) as checkout_billing_postcode
        , cast(NULL as {{ type_string() }}) as checkout_coupon_code
        , cast(NULL as {{ type_string() }}) as checkout_delivery_method
        , cast(NULL as {{ type_string() }}) as checkout_delivery_provider
        , cast(NULL as {{ type_boolean() }}) as checkout_marketing_opt_in
        , cast(NULL as {{ type_string() }}) as checkout_payment_method
        , cast(NULL as {{ type_string() }}) as checkout_proof_of_payment
        , cast(NULL as {{ type_string() }}) as checkout_shipping_full_address
        , cast(NULL as {{ type_string() }}) as checkout_shipping_postcode
    {% else %}
        , checkout__step as checkout_step_number
        , checkout__account_type as checkout_account_type
        , checkout__billing_full_address as checkout_billing_full_address
        , checkout__billing_postcode as checkout_billing_postcode
        , checkout__coupon_code as checkout_coupon_code
        , checkout__delivery_method as checkout_delivery_method
        , checkout__delivery_provider as checkout_delivery_provider
        , checkout__marketing_opt_in as checkout_marketing_opt_in
        , checkout__payment_method as checkout_payment_method
        , checkout__proof_of_payment as checkout_proof_of_payment
        , checkout__shipping_full_address as checkout_shipping_full_address
        , checkout__shipping_postcode as checkout_shipping_postcode
    {% endif %}
{% endmacro %}

{% macro bigquery__get_checkout_context_fields() %}

    {% if var('snowplow__disable_ecommerce_checkouts', false) %}
        , cast(NULL as {{ type_int() }}) as checkout_step_number
        , cast(NULL as {{ type_string() }}) as checkout_account_type
        , cast(NULL as {{ type_string() }}) as checkout_billing_full_address
        , cast(NULL as {{ type_string() }}) as checkout_billing_postcode
        , cast(NULL as {{ type_string() }}) as checkout_coupon_code
        , cast(NULL as {{ type_string() }}) as checkout_delivery_method
        , cast(NULL as {{ type_string() }}) as checkout_delivery_provider
        , cast(NULL as {{ type_boolean() }}) as checkout_marketing_opt_in
        , cast(NULL as {{ type_string() }}) as checkout_payment_method
        , cast(NULL as {{ type_string() }}) as checkout_proof_of_payment
        , cast(NULL as {{ type_string() }}) as checkout_shipping_full_address
        , cast(NULL as {{ type_string() }}) as checkout_shipping_postcode
    {% else %}
        ,{{ snowplow_utils.get_optional_fields(
            enabled=true,
            fields=checkout_step_fields(),
            col_prefix='contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1_',
            relation=source('atomic', 'events') if project_name != 'snowplow_ecommerce_integration_tests' else ref('snowplow_ecommerce_events_stg'),
            relation_alias=none) }}
    {% endif %}
{% endmacro %}

{% macro spark__get_checkout_context_fields() %}
    {% if var('snowplow__disable_ecommerce_checkouts', false) %}
        , cast(NULL as {{ type_int() }}) as checkout_step_number
        , cast(NULL as {{ type_string() }}) as checkout_account_type
        , cast(NULL as {{ type_string() }}) as checkout_billing_full_address
        , cast(NULL as {{ type_string() }}) as checkout_billing_postcode
        , cast(NULL as {{ type_string() }}) as checkout_coupon_code
        , cast(NULL as {{ type_string() }}) as checkout_delivery_method
        , cast(NULL as {{ type_string() }}) as checkout_delivery_provider
        , cast(NULL as {{ type_boolean() }}) as checkout_marketing_opt_in
        , cast(NULL as {{ type_string() }}) as checkout_payment_method
        , cast(NULL as {{ type_string() }}) as checkout_proof_of_payment
        , cast(NULL as {{ type_string() }}) as checkout_shipping_full_address
        , cast(NULL as {{ type_string() }}) as checkout_shipping_postcode
    {% else %}
        , CAST(contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1[0].step AS int) AS checkout_step_number
        , CAST(contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1[0].account_type AS string) AS checkout_account_type
        , CAST(contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1[0].billing_full_address AS string) AS checkout_billing_full_address
        , CAST(contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1[0].billing_postcode AS string) AS checkout_billing_postcode
        , CAST(contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1[0].coupon_code AS string) AS checkout_coupon_code
        , CAST(contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1[0].delivery_method AS string) AS checkout_delivery_method
        , CAST(contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1[0].delivery_provider AS string) AS checkout_delivery_provider
        , CAST(contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1[0].marketing_opt_in AS boolean) AS checkout_marketing_opt_in
        , CAST(contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1[0].payment_method AS string) AS checkout_payment_method
        , CAST(contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1[0].proof_of_payment AS string) AS checkout_proof_of_payment
        , CAST(contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1[0].shipping_full_address AS string) AS checkout_shipping_full_address
        , CAST(contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1[0].shipping_postcode AS string) AS checkout_shipping_postcode
    {% endif %}
{% endmacro %}

{% macro snowflake__get_checkout_context_fields() %}
    {% if var('snowplow__disable_ecommerce_checkouts', false) %}
        , cast(NULL as {{ type_int() }}) as checkout_step_number
        , cast(NULL as {{ type_string() }}) as checkout_account_type
        , cast(NULL as {{ type_string() }}) as checkout_billing_full_address
        , cast(NULL as {{ type_string() }}) as checkout_billing_postcode
        , cast(NULL as {{ type_string() }}) as checkout_coupon_code
        , cast(NULL as {{ type_string() }}) as checkout_delivery_method
        , cast(NULL as {{ type_string() }}) as checkout_delivery_provider
        , cast(NULL as {{ type_boolean() }}) as checkout_marketing_opt_in
        , cast(NULL as {{ type_string() }}) as checkout_payment_method
        , cast(NULL as {{ type_string() }}) as checkout_proof_of_payment
        , cast(NULL as {{ type_string() }}) as checkout_shipping_full_address
        , cast(NULL as {{ type_string() }}) as checkout_shipping_postcode
    {% else %}
        , contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1[0]:step::int as checkout_step_number
        , contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1[0]:account_type::varchar as checkout_account_type
        , contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1[0]:billing_full_address::varchar as checkout_billing_full_address
        , contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1[0]:billing_postcode::varchar as checkout_billing_postcode
        , contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1[0]:coupon_code::varchar as checkout_coupon_code
        , contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1[0]:delivery_method::varchar as checkout_delivery_method
        , contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1[0]:delivery_provider::varchar as checkout_delivery_provider
        , contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1[0]:marketing_opt_in::boolean as checkout_marketing_opt_in
        , contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1[0]:payment_method::varchar as checkout_payment_method
        , contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1[0]:proof_of_payment::varchar as checkout_proof_of_payment
        , contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1[0]:shipping_full_address::varchar as checkout_shipping_full_address
        , contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1[0]:shipping_postcode::varchar as checkout_shipping_postcode
    {% endif %}
{% endmacro %}

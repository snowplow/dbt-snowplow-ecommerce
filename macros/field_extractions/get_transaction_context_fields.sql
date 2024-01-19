{#
Copyright (c) 2022-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{% macro get_transaction_context_fields() %}
    {{ return(adapter.dispatch('get_transaction_context_fields', 'snowplow_ecommerce')()) }}
{%- endmacro -%}

{% macro postgres__get_transaction_context_fields() %}
    {% if var('snowplow__disable_ecommerce_transactions', false) %}
        , cast(NULL as {{ type_string() }}) as transaction_id
        , cast(NULL as {{ type_string() }}) as transaction_currency
        , cast(NULL as {{ type_string() }}) as transaction_payment_method
        , cast(NULL as decimal(9,2)) as transaction_revenue
        , cast(NULL as {{ type_int() }}) as transaction_total_quantity
        , cast(NULL as {{ type_boolean() }}) as transaction_credit_order
        , cast(NULL as decimal(9,2)) as transaction_discount_amount
        , cast(NULL as {{ type_string() }}) as transaction_discount_code
        , cast(NULL as decimal(9,2)) as transaction_shipping
        , cast(NULL as decimal(9,2)) as transaction_tax
    {% else %}
        , transaction__transaction_id as transaction_id
        , transaction__currency as transaction_currency
        , transaction__payment_method as transaction_payment_method
        , transaction__revenue as transaction_revenue
        , transaction__total_quantity as transaction_total_quantity
        , transaction__credit_order as transaction_credit_order
        , transaction__discount_amount as transaction_discount_amount
        , transaction__discount_code as transaction_discount_code
        , transaction__shipping as transaction_shipping
        , transaction__tax as transaction_tax
    {% endif %}
{% endmacro %}

{% macro bigquery__get_transaction_context_fields() %}

    {% if var('snowplow__disable_ecommerce_transactions', false) %}
        , cast(NULL as {{ type_string() }}) as transaction_id
        , cast(NULL as {{ type_string() }}) as transaction_currency
        , cast(NULL as {{ type_string() }}) as transaction_payment_method
        , cast(NULL as decimal(9,2)) as transaction_revenue
        , cast(NULL as {{ type_int() }}) as transaction_total_quantity
        , cast(NULL as {{ type_boolean() }}) as transaction_credit_order
        , cast(NULL as decimal(9,2)) as transaction_discount_amount
        , cast(NULL as {{ type_string() }}) as transaction_discount_code
        , cast(NULL as decimal(9,2)) as transaction_shipping
        , cast(NULL as decimal(9,2)) as transaction_tax
    {% else %}
        ,{{ snowplow_utils.get_optional_fields(
            enabled=true,
            fields=transaction_fields(),
            col_prefix='contexts_com_snowplowanalytics_snowplow_ecommerce_transaction_1_',
            relation=source('atomic', 'events') if project_name != 'snowplow_ecommerce_integration_tests' else ref('snowplow_ecommerce_events_stg'),
            relation_alias=none) }}
    {% endif %}
{% endmacro %}

{% macro spark__get_transaction_context_fields() %}
    {% if var('snowplow__disable_ecommerce_transactions', false) %}
        , cast(NULL as {{ type_string() }}) as transaction_id
        , cast(NULL as {{ type_string() }}) as transaction_currency
        , cast(NULL as {{ type_string() }}) as transaction_payment_method
        , cast(NULL as decimal(9,2)) as transaction_revenue
        , cast(NULL as {{ type_int() }}) as transaction_total_quantity
        , cast(NULL as {{ type_boolean() }}) as transaction_credit_order
        , cast(NULL as decimal(9,2)) as transaction_discount_amount
        , cast(NULL as {{ type_string() }}) as transaction_discount_code
        , cast(NULL as decimal(9,2)) as transaction_shipping
        , cast(NULL as decimal(9,2)) as transaction_tax
    {% else %}
        , contexts_com_snowplowanalytics_snowplow_ecommerce_transaction_1[0].transaction_id::string as transaction_id
        , contexts_com_snowplowanalytics_snowplow_ecommerce_transaction_1[0].currency::string as transaction_currency
        , contexts_com_snowplowanalytics_snowplow_ecommerce_transaction_1[0].payment_method::string as transaction_payment_method
        , contexts_com_snowplowanalytics_snowplow_ecommerce_transaction_1[0].revenue::decimal(9,2) as transaction_revenue
        , contexts_com_snowplowanalytics_snowplow_ecommerce_transaction_1[0].total_quantity::int as transaction_total_quantity
        , contexts_com_snowplowanalytics_snowplow_ecommerce_transaction_1[0].credit_order::boolean as transaction_credit_order
        , contexts_com_snowplowanalytics_snowplow_ecommerce_transaction_1[0].discount_amount::decimal(9,2) as transaction_discount_amount
        , contexts_com_snowplowanalytics_snowplow_ecommerce_transaction_1[0].discount_code::string as transaction_discount_code
        , contexts_com_snowplowanalytics_snowplow_ecommerce_transaction_1[0].shipping::decimal(9,2) as transaction_shipping
        , contexts_com_snowplowanalytics_snowplow_ecommerce_transaction_1[0].tax::decimal(9,2) as transaction_tax
    {% endif %}
{% endmacro %}

{% macro snowflake__get_transaction_context_fields() %}
    {% if var('snowplow__disable_ecommerce_transactions', false) %}
        , cast(NULL as {{ type_string() }}) as transaction_id
        , cast(NULL as {{ type_string() }}) as transaction_currency
        , cast(NULL as {{ type_string() }}) as transaction_payment_method
        , cast(NULL as decimal(9,2)) as transaction_revenue
        , cast(NULL as {{ type_int() }}) as transaction_total_quantity
        , cast(NULL as {{ type_boolean() }}) as transaction_credit_order
        , cast(NULL as decimal(9,2)) as transaction_discount_amount
        , cast(NULL as {{ type_string() }}) as transaction_discount_code
        , cast(NULL as decimal(9,2)) as transaction_shipping
        , cast(NULL as decimal(9,2)) as transaction_tax
    {% else %}
        , contexts_com_snowplowanalytics_snowplow_ecommerce_transaction_1[0]:transaction_id::varchar as transaction_id
        , contexts_com_snowplowanalytics_snowplow_ecommerce_transaction_1[0]:currency::varchar as transaction_currency
        , contexts_com_snowplowanalytics_snowplow_ecommerce_transaction_1[0]:payment_method::varchar as transaction_payment_method
        , contexts_com_snowplowanalytics_snowplow_ecommerce_transaction_1[0]:revenue::decimal(9,2) as transaction_revenue
        , contexts_com_snowplowanalytics_snowplow_ecommerce_transaction_1[0]:total_quantity::int as transaction_total_quantity
        , contexts_com_snowplowanalytics_snowplow_ecommerce_transaction_1[0]:credit_order::boolean as transaction_credit_order
        , contexts_com_snowplowanalytics_snowplow_ecommerce_transaction_1[0]:discount_amount::decimal(9,2) as transaction_discount_amount
        , contexts_com_snowplowanalytics_snowplow_ecommerce_transaction_1[0]:discount_code::varchar as transaction_discount_code
        , contexts_com_snowplowanalytics_snowplow_ecommerce_transaction_1[0]:shipping::decimal(9,2) as transaction_shipping
        , contexts_com_snowplowanalytics_snowplow_ecommerce_transaction_1[0]:tax::decimal(9,2) as transaction_tax
    {% endif %}
{% endmacro %}

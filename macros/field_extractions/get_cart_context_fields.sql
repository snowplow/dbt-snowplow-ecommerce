{#
Copyright (c) 2022-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{% macro get_cart_context_fields() %}
    {{ return(adapter.dispatch('get_cart_context_fields', 'snowplow_ecommerce')()) }}
{%- endmacro -%}

{% macro postgres__get_cart_context_fields() %}
    {% if var('snowplow__disable_ecommerce_carts', false) %}
        , cast(NULL as {{ type_string() }}) as cart_id
        , cast(NULL as {{ type_string() }}) as cart_currency
        , cast(NULL as decimal(9,2)) as cart_total_value
    {% else %}
        , cart__cart_id as cart_id
        , cart__currency as cart_currency
        , cart__total_value as cart_total_value
    {% endif %}
{% endmacro %}

{% macro bigquery__get_cart_context_fields() %}

    {% if var('snowplow__disable_ecommerce_carts', false) %}
        , cast(NULL as {{ type_string() }}) as cart_id
        , cast(NULL as {{ type_string() }}) as cart_currency
        , cast(NULL as decimal(9,2)) as cart_total_value
    {% else %}
        , {{ snowplow_utils.get_optional_fields(
            enabled=true,
            fields=cart_fields(),
            col_prefix='contexts_com_snowplowanalytics_snowplow_ecommerce_cart_1',
            relation=source('atomic', 'events') if project_name != 'snowplow_ecommerce_integration_tests' else ref('snowplow_ecommerce_events_stg'),
            relation_alias=none) }}
    {% endif %}
{% endmacro %}

{% macro spark__get_cart_context_fields() %}
    {% if var('snowplow__disable_ecommerce_carts', false) %}
        , cast(NULL as {{ type_string() }}) as cart_id
        , cast(NULL as {{ type_string() }}) as cart_currency
        , cast(NULL as decimal(9,2)) as cart_total_value
    {% else %}
        , CAST(contexts_com_snowplowanalytics_snowplow_ecommerce_cart_1[0].cart_id AS string) as cart_id
        , CAST(contexts_com_snowplowanalytics_snowplow_ecommerce_cart_1[0].currency AS string) as cart_currency
        , CAST(contexts_com_snowplowanalytics_snowplow_ecommerce_cart_1[0].total_value AS decimal(9,2)) as cart_total_value
    {% endif %}
{% endmacro %}

{% macro snowflake__get_cart_context_fields() %}
    {% if var('snowplow__disable_ecommerce_carts', false) %}
        , cast(NULL as {{ type_string() }}) as cart_id
        , cast(NULL as {{ type_string() }}) as cart_currency
        , cast(NULL as decimal(9,2)) as cart_total_value
    {% else %}
        , contexts_com_snowplowanalytics_snowplow_ecommerce_cart_1[0]:cart_id::varchar as cart_id
        , contexts_com_snowplowanalytics_snowplow_ecommerce_cart_1[0]:currency::varchar as cart_currency
        , contexts_com_snowplowanalytics_snowplow_ecommerce_cart_1[0]:total_value::decimal(9,2) as cart_total_value
    {% endif %}
{% endmacro %}

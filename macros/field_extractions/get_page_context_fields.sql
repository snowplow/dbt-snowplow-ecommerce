{#
Copyright (c) 2022-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{% macro get_page_context_fields() %}
    {{ return(adapter.dispatch('get_page_context_fields', 'snowplow_ecommerce')()) }}
{%- endmacro -%}

{% macro postgres__get_page_context_fields() %}
    {% if var('snowplow__disable_ecommerce_page_context', false) %}
        , cast(NULL as {{ type_string() }}) as ecommerce_page_type
        , cast(NULL as {{ type_string() }}) as ecommerce_page_language
        , cast(NULL as {{ type_string() }}) as ecommerce_page_locale
    {% else %}
        , ecommerce_page__type as ecommerce_page_type
        , ecommerce_page__language as ecommerce_page_language
        , ecommerce_page__locale as ecommerce_page_locale
    {% endif %}
{% endmacro %}

{% macro bigquery__get_page_context_fields() %}

    {% if var('snowplow__disable_ecommerce_page_context', false) %}
        , cast(NULL as {{ type_string() }}) as ecommerce_page_type
        , cast(NULL as {{ type_string() }}) as ecommerce_page_language
        , cast(NULL as {{ type_string() }}) as ecommerce_page_locale
    {% else %}
        ,{{ snowplow_utils.get_optional_fields(
            enabled=true,
            fields=tracking_page_fields(),
            col_prefix='contexts_com_snowplowanalytics_snowplow_ecommerce_page_1_',
            relation=source('atomic', 'events') if project_name != 'snowplow_ecommerce_integration_tests' else ref('snowplow_ecommerce_events_stg'),
            relation_alias=none) }}
    {% endif %}
{% endmacro %}

{% macro spark__get_page_context_fields() %}
    {% if var('snowplow__disable_ecommerce_page_context', false) %}
        , cast(NULL as {{ type_string() }}) as ecommerce_page_type
        , cast(NULL as {{ type_string() }}) as ecommerce_page_language
        , cast(NULL as {{ type_string() }}) as ecommerce_page_locale
    {% else %}
        , contexts_com_snowplowanalytics_snowplow_ecommerce_page_1[0].type::string as ecommerce_page_type
        , contexts_com_snowplowanalytics_snowplow_ecommerce_page_1[0].language::string as ecommerce_page_language
        , contexts_com_snowplowanalytics_snowplow_ecommerce_page_1[0].locale::string as ecommerce_page_locale
    {% endif %}
{% endmacro %}

{% macro snowflake__get_page_context_fields() %}
    {% if var('snowplow__disable_ecommerce_page_context', false) %}
        , cast(NULL as {{ type_string() }}) as ecommerce_page_type
        , cast(NULL as {{ type_string() }}) as ecommerce_page_language
        , cast(NULL as {{ type_string() }}) as ecommerce_page_locale
    {% else %}
        , contexts_com_snowplowanalytics_snowplow_ecommerce_page_1[0]:type::varchar as ecommerce_page_type
        , contexts_com_snowplowanalytics_snowplow_ecommerce_page_1[0]:language::varchar as ecommerce_page_language
        , contexts_com_snowplowanalytics_snowplow_ecommerce_page_1[0]:locale::varchar as ecommerce_page_locale
    {% endif %}
{% endmacro %}

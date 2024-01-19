{#
Copyright (c) 2022-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{% macro get_screen_view_context_fields() %}
    {{ return(adapter.dispatch('get_screen_view_context_fields', 'snowplow_ecommerce')()) }}
{%- endmacro -%}

{% macro postgres__get_screen_view_context_fields() %}
    {% if var('snowplow__enable_mobile_events', false) %}
        , mob_sc_view__id as screen_view_id
        , mob_sc_view__name as screen_view_name
    {% else %}
        , cast(NULL as {{ type_string() }}) as screen_view_id
        , cast(NULL as {{ type_string() }}) as screen_view_name
    {% endif %}
{% endmacro %}

{% macro bigquery__get_screen_view_context_fields() %}

    {% if var('snowplow__enable_mobile_events', false) %}
        ,{{ snowplow_utils.get_optional_fields(
            enabled=true,
            fields=mobile_screen_view_context_fields(),
            col_prefix='contexts_com_snowplowanalytics_mobile_screen_1_',
            relation=source('atomic', 'events') if project_name != 'snowplow_ecommerce_integration_tests' else ref('snowplow_ecommerce_events_stg'),
            relation_alias=none) }}
    {% else %}
        , cast(NULL as {{ type_string() }}) as screen_view_id
        , cast(NULL as {{ type_string() }}) as screen_view_name
    {% endif %}
{% endmacro %}

{% macro spark__get_screen_view_context_fields() %}
    {% if var('snowplow__enable_mobile_events', false) %}
        , contexts_com_snowplowanalytics_mobile_screen_1[0].id::string as screen_view_id
        , contexts_com_snowplowanalytics_mobile_screen_1[0].name::string as screen_view_name
    {% else %}
        , cast(NULL as {{ type_string() }}) as screen_view_id
        , cast(NULL as {{ type_string() }}) as screen_view_name
    {% endif %}
{% endmacro %}

{% macro snowflake__get_screen_view_context_fields() %}
    {% if var('snowplow__enable_mobile_events', false) %}
        , contexts_com_snowplowanalytics_mobile_screen_1[0]:id::varchar as screen_view_id
        , contexts_com_snowplowanalytics_mobile_screen_1[0]:name::varchar as screen_view_name
    {% else %}
        , cast(NULL as {{ type_string() }}) as screen_view_id
        , cast(NULL as {{ type_string() }}) as screen_view_name
    {% endif %}
{% endmacro %}

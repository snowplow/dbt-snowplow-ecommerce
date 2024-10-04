{#
Copyright (c) 2022-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{% macro get_page_view_context_fields() %}
    {{ return(adapter.dispatch('get_page_view_context_fields', 'snowplow_ecommerce')()) }}
{%- endmacro -%}

{% macro postgres__get_page_view_context_fields() %}
    {% if var('snowplow__enable_mobile_events', false) %}
        , coalesce(
            mob_sc_view__id,
            page_view__id
        ) as page_view_id
    {% else %}
        , page_view__id as page_view_id
    {% endif %}
{% endmacro %}

{% macro bigquery__get_page_view_context_fields() %}
    {% if var('snowplow__enable_mobile_events', false) %}
        , coalesce(
            {{ snowplow_utils.get_optional_fields(
            enabled=true,
            fields=[{'field': 'id', 'dtype': 'string'}],
            col_prefix='contexts_com_snowplowanalytics_mobile_screen_1_',
            relation=source('atomic', 'events') if project_name != 'snowplow_ecommerce_integration_tests' else ref('snowplow_ecommerce_events_stg'),
            relation_alias=none,
            include_field_alias=false) }},
            {{ snowplow_utils.get_optional_fields(
            enabled=true,
            fields=page_view_fields(),
            col_prefix='contexts_com_snowplowanalytics_snowplow_web_page_1_',
            relation=source('atomic', 'events') if project_name != 'snowplow_ecommerce_integration_tests' else ref('snowplow_ecommerce_events_stg'),
            relation_alias=none,
            include_field_alias=false) }}
        ) as page_view_id
    {% else %}
        ,{{ snowplow_utils.get_optional_fields(
            enabled=true,
            fields=page_view_fields(),
            col_prefix='contexts_com_snowplowanalytics_snowplow_web_page_1_',
            relation=source('atomic', 'events') if project_name != 'snowplow_ecommerce_integration_tests' else ref('snowplow_ecommerce_events_stg'),
            relation_alias=none) }}
    {% endif %}
{% endmacro %}

{% macro spark__get_page_view_context_fields() %}
    {% if var('snowplow__enable_mobile_events', false) %}
        , coalesce(CAST(contexts_com_snowplowanalytics_mobile_screen_1[0].id AS string), CAST(contexts_com_snowplowanalytics_snowplow_web_page_1[0].id AS string)) as page_view_id
    {% else %}
        , CAST(contexts_com_snowplowanalytics_snowplow_web_page_1[0].id AS string) as page_view_id
    {% endif %}
{% endmacro %}

{% macro snowflake__get_page_view_context_fields() %}
    {% if var('snowplow__enable_mobile_events', false) %}
        , coalesce(contexts_com_snowplowanalytics_mobile_screen_1[0]:id::varchar, contexts_com_snowplowanalytics_snowplow_web_page_1[0]:id::varchar) as page_view_id
    {% else %}
        , contexts_com_snowplowanalytics_snowplow_web_page_1[0]:id::varchar as page_view_id
    {% endif %}
{% endmacro %}

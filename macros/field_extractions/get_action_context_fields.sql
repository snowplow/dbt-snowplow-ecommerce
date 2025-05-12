{#
Copyright (c) 2022-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{% macro get_action_context_fields() %}
    {{ return(adapter.dispatch('get_action_context_fields', 'snowplow_ecommerce')()) }}
{%- endmacro -%}

{% macro postgres__get_action_context_fields() %}
    , ecommerce_action_type
    , ecommerce_action_name
{% endmacro %}

{% macro bigquery__get_action_context_fields() %}
    ,{{ snowplow_utils.get_optional_fields(
        enabled=true,
        fields=tracking_action_fields(),
        col_prefix='unstruct_event_com_snowplowanalytics_snowplow_ecommerce_snowplow_ecommerce_action_1',
        relation=source('atomic', 'events') if project_name != 'snowplow_ecommerce_integration_tests' else ref('snowplow_ecommerce_events_stg'),
        relation_alias=none) }}
{% endmacro %}

{% macro spark__get_action_context_fields() %}
    , CAST(unstruct_event_com_snowplowanalytics_snowplow_ecommerce_snowplow_ecommerce_action_1.type AS string) as ecommerce_action_type
    , CAST(unstruct_event_com_snowplowanalytics_snowplow_ecommerce_snowplow_ecommerce_action_1.name AS string) as ecommerce_action_name
{% endmacro %}

{% macro snowflake__get_action_context_fields() %}
    , unstruct_event_com_snowplowanalytics_snowplow_ecommerce_snowplow_ecommerce_action_1:type::varchar as ecommerce_action_type
    , unstruct_event_com_snowplowanalytics_snowplow_ecommerce_snowplow_ecommerce_action_1:name::varchar as ecommerce_action_name
{% endmacro %}

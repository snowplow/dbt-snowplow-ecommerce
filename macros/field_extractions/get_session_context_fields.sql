{#
Copyright (c) 2022-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{% macro get_session_context_fields() %}
    {{ return(adapter.dispatch('get_session_context_fields', 'snowplow_ecommerce')()) }}
{%- endmacro -%}

{% macro postgres__get_session_context_fields() %}
    {% if var('snowplow__enable_mobile_events', false) %}
        , session__event_index as event_index
        , session__first_event_id as first_event_id
        , session__first_event_timestamp as first_event_timestamp
        , session__previous_session_id as previous_session_id
        , session__session_id as session_id
        , session__session_index as session_index
        , session__storage_mechanism as storage_mechanism
        , session__user_id as mobile_user_id
    {% else %}
        , cast(NULL as {{ type_int() }}) as event_index
        , cast(NULL as {{ type_string() }}) as first_event_id
        , cast(NULL as {{ type_timestamp() }}) as first_event_timestamp
        , cast(NULL as {{ type_string() }}) as previous_session_id
        , cast(NULL as {{ type_string() }}) as session_id
        , cast(NULL as {{ type_int() }}) as session_index
        , cast(NULL as {{ type_string() }}) as storage_mechanism
        , cast(NULL as {{ type_string() }}) as mobile_user_id
    {% endif %}
{% endmacro %}

{% macro bigquery__get_session_context_fields() %}

    {% if var('snowplow__enable_mobile_events', false) %}
        ,{{ snowplow_utils.get_optional_fields(
            enabled=true,
            fields=mobile_session_context_fields(),
            col_prefix='contexts_com_snowplowanalytics_snowplow_client_session_1_',
            relation=source('atomic', 'events') if project_name != 'snowplow_ecommerce_integration_tests' else ref('snowplow_ecommerce_events_stg'),
            relation_alias=none) }}
    {% else %}
        , cast(NULL as {{ type_int() }}) as event_index
        , cast(NULL as {{ type_string() }}) as first_event_id
        , cast(NULL as {{ type_timestamp() }}) as first_event_timestamp
        , cast(NULL as {{ type_string() }}) as previous_session_id
        , cast(NULL as {{ type_string() }}) as session_id
        , cast(NULL as {{ type_int() }}) as session_index
        , cast(NULL as {{ type_string() }}) as storage_mechanism
        , cast(NULL as {{ type_string() }}) as mobile_user_id
    {% endif %}
{% endmacro %}

{% macro spark__get_session_context_fields() %}
    {% if var('snowplow__enable_mobile_events', false) %}
        , CAST(contexts_com_snowplowanalytics_snowplow_client_session_1[0].event_index AS int) as event_index
        , CAST(contexts_com_snowplowanalytics_snowplow_client_session_1[0].first_event_id AS string) as first_event_id
        , CAST(contexts_com_snowplowanalytics_snowplow_client_session_1[0].first_event_timestamp AS timestamp) as first_event_timestamp
        , CAST(contexts_com_snowplowanalytics_snowplow_client_session_1[0].previous_session_id AS string) as previous_session_id
        , CAST(contexts_com_snowplowanalytics_snowplow_client_session_1[0].session_id AS string) as session_id
        , CAST(contexts_com_snowplowanalytics_snowplow_client_session_1[0].session_index AS int) as session_index
        , CAST(contexts_com_snowplowanalytics_snowplow_client_session_1[0].storage_mechanism AS string) as storage_mechanism
        , CAST(contexts_com_snowplowanalytics_snowplow_client_session_1[0].user_id AS string) as mobile_user_id
    {% else %}
        , cast(NULL as {{ type_int() }}) as event_index
        , cast(NULL as {{ type_string() }}) as first_event_id
        , cast(NULL as {{ type_timestamp() }}) as first_event_timestamp
        , cast(NULL as {{ type_string() }}) as previous_session_id
        , cast(NULL as {{ type_string() }}) as session_id
        , cast(NULL as {{ type_int() }}) as session_index
        , cast(NULL as {{ type_string() }}) as storage_mechanism
        , cast(NULL as {{ type_string() }}) as mobile_user_id
    {% endif %}
{% endmacro %}

{% macro snowflake__get_session_context_fields() %}
    {% if var('snowplow__enable_mobile_events', false) %}
        , contexts_com_snowplowanalytics_snowplow_client_session_1[0]:eventIndex::int as event_index
        , contexts_com_snowplowanalytics_snowplow_client_session_1[0]:firstEventId::varchar as first_event_id
        , contexts_com_snowplowanalytics_snowplow_client_session_1[0]:firstEventTimestamp::timestamp as first_event_timestamp
        , contexts_com_snowplowanalytics_snowplow_client_session_1[0]:previousSessionId::varchar as previous_session_id
        , contexts_com_snowplowanalytics_snowplow_client_session_1[0]:sessionId::varchar as session_id
        , contexts_com_snowplowanalytics_snowplow_client_session_1[0]:sessionIndex::int as session_index
        , contexts_com_snowplowanalytics_snowplow_client_session_1[0]:storageMechanism::varchar as storage_mechanism
        , contexts_com_snowplowanalytics_snowplow_client_session_1[0]:userId::varchar as mobile_user_id
    {% else %}
        , cast(NULL as {{ type_int() }}) as event_index
        , cast(NULL as {{ type_string() }}) as first_event_id
        , cast(NULL as {{ type_timestamp() }}) as first_event_timestamp
        , cast(NULL as {{ type_string() }}) as previous_session_id
        , cast(NULL as {{ type_string() }}) as session_id
        , cast(NULL as {{ type_int() }}) as session_index
        , cast(NULL as {{ type_string() }}) as storage_mechanism
        , cast(NULL as {{ type_string() }}) as mobile_user_id
    {% endif %}
{% endmacro %}

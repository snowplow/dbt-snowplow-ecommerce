{#
Copyright (c) 2022-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{% macro session_identifiers() %}
    {{ return(adapter.dispatch('session_identifiers', 'snowplow_ecommerce')()) }}
{% endmacro %}


{% macro default__session_identifiers() %}

    {% if var('snowplow__session_identifiers') %}
        {{ return(var('snowplow__session_identifiers')) }}

    {% else %}

        {% if var('snowplow__enable_mobile_events') %}
            {{ return([{'schema': 'contexts_com_snowplowanalytics_snowplow_client_session_1', 'field': 'session_id'}, {'schema': 'atomic', 'field': 'domain_sessionid'}] )}}

        {% else %}
            {{ return([{'schema': 'atomic', 'field': 'domain_sessionid'}] )}}

        {% endif %}
    {% endif %}

{% endmacro %}


{% macro snowflake__session_identifiers() %}

    {% if var('snowplow__session_identifiers') %}
        {{ return(var('snowplow__session_identifiers')) }}

    {% else %}

        {% if var('snowplow__enable_mobile_events') %}
            {{ return([{'schema': 'contexts_com_snowplowanalytics_snowplow_client_session_1', 'field': 'sessionId'}, {'schema': 'atomic', 'field': 'domain_sessionid'}] )}}

        {% else %}
            {{ return([{'schema': 'atomic', 'field': 'domain_sessionid'}] )}}

        {% endif %}
    {% endif %}

{% endmacro %}

{% macro bigquery__session_identifiers() %}

    {% if var('snowplow__session_identifiers') %}
        {{ return(var('snowplow__session_identifiers')) }}

    {% else %}

        {% if var('snowplow__enable_mobile_events') %}
            {{ return([{'schema': 'contexts_com_snowplowanalytics_snowplow_client_session_1_*', 'field': 'session_id'}, {'schema': 'atomic', 'field': 'domain_sessionid'}] )}}

        {% else %}
            {{ return([{'schema': 'atomic', 'field': 'domain_sessionid'}] )}}

        {% endif %}
    {% endif %}


{% endmacro %}

{% macro postgres__session_identifiers() %}

    {% if var('snowplow__session_identifiers') %}
        {{ return(var('snowplow__session_identifiers')) }}

    {% else %}

        {% if var('snowplow__enable_mobile_events') %}
            {{ return([{'schema': var('snowplow__session_context'), 'field': 'session_id', 'prefix': 'session_'},{'schema': 'atomic', 'field': 'domain_sessionid', 'prefix': 'session_'}] )}}

        {% else %}
            {{ return([{'schema': 'atomic', 'field': 'domain_sessionid', 'prefix': 'session_'}] )}}

        {% endif %}
    {% endif %}

{% endmacro %}

{% macro user_identifiers() %}
    {{ return(adapter.dispatch('user_identifiers', 'snowplow_ecommerce')()) }}
{% endmacro %}


{% macro default__user_identifiers() %}

    {% if var('snowplow__user_identifiers') %}
        {{ return(var('snowplow__user_identifiers')) }}

    {% else %}

        {% if var('snowplow__enable_mobile_events') %}
            {{ return([{'schema': 'contexts_com_snowplowanalytics_snowplow_client_session_1', 'field': 'user_id'}, {'schema': 'atomic', 'field': 'domain_userid'}] )}}

        {% else %}
            {{ return([{'schema': 'atomic', 'field': 'domain_userid'}] )}}

        {% endif %}
    {% endif %}

{% endmacro %}


{% macro snowflake__user_identifiers() %}

    {% if var('snowplow__user_identifiers') %}
        {{ return(var('snowplow__user_identifiers')) }}

    {% else %}

        {% if var('snowplow__enable_mobile_events') %}
            {{ return([{'schema': 'contexts_com_snowplowanalytics_snowplow_client_session_1', 'field': 'userId'}, {'schema': 'atomic', 'field': 'domain_userid'}] )}}

        {% else %}
            {{ return([{'schema': 'atomic', 'field': 'domain_userid'}] )}}

        {% endif %}
    {% endif %}


{% endmacro %}

{% macro bigquery__user_identifiers() %}

    {% if var('snowplow__user_identifiers') %}
        {{ return(var('snowplow__user_identifiers')) }}

    {% else %}

        {% if var('snowplow__enable_mobile_events') %}
            {{ return([{'schema': 'contexts_com_snowplowanalytics_snowplow_client_session_1_*', 'field': 'user_id'}, {'schema': 'atomic', 'field': 'domain_userid'}] )}}

        {% else %}
            {{ return([{'schema': 'atomic', 'field': 'domain_userid'}] )}}

        {% endif %}
    {% endif %}


{% endmacro %}

{% macro postgres__user_identifiers() %}

    {% if var('snowplow__user_identifiers') %}
        {{ return(var('snowplow__user_identifiers')) }}

    {% else %}

        {% if var('snowplow__enable_mobile_events') %}
            {{ return([{'schema': var('snowplow__session_context'), 'field': 'user_id', 'prefix': 'session_'}, {'schema': 'atomic', 'field': 'domain_userid', 'prefix': 'session_'}] )}}

        {% else %}
            {{ return([{'schema': 'atomic', 'field': 'domain_userid', 'prefix': 'session_'}] )}}

        {% endif %}
    {% endif %}

{% endmacro %}

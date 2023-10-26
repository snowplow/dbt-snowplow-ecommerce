{% macro get_user_context_fields() %}
    {{ return(adapter.dispatch('get_user_context_fields', 'snowplow_ecommerce')()) }}
{%- endmacro -%}

{% macro postgres__get_user_context_fields() %}
    {% if var('snowplow__disable_ecommerce_user_context', false) %}
        , cast(NULL as {{ type_string() }}) as ecommerce_user_id
        , cast(NULL as {{ type_string() }}) as ecommerce_user_email
        , cast(NULL as {{ type_boolean() }}) as ecommerce_user_is_guest
    {% else %}
        , ecommerce_user__id as ecommerce_user_id
        , ecommerce_user__email as ecommerce_user_email
        , ecommerce_user__is_guest  as ecommerce_user_is_guest
    {% endif %}
{% endmacro %}

{% macro bigquery__get_user_context_fields() %}

    {% if var('snowplow__disable_ecommerce_user_context', false) %}
        , cast(NULL as {{ type_string() }}) as ecommerce_user_id
        , cast(NULL as {{ type_string() }}) as ecommerce_user_email
        , cast(NULL as {{ type_boolean() }}) as ecommerce_user_is_guest
    {% else %}
        ,{{ snowplow_utils.get_optional_fields(
            enabled=true,
            fields=user_fields(),
            col_prefix='contexts_com_snowplowanalytics_snowplow_ecommerce_user_1_',
            relation=source('atomic', 'events') if project_name != 'snowplow_ecommerce_integration_tests' else ref('snowplow_ecommerce_events_stg'),
            relation_alias=none) }}
    {% endif %}
{% endmacro %}

{% macro spark__get_user_context_fields() %}
    {% if var('snowplow__disable_ecommerce_user_context', false) %}
        , cast(NULL as {{ type_string() }}) as ecommerce_user_id
        , cast(NULL as {{ type_string() }}) as ecommerce_user_email
        , cast(NULL as {{ type_boolean() }}) as ecommerce_user_is_guest
    {% else %}
        , contexts_com_snowplowanalytics_snowplow_ecommerce_user_1[0].id::string as ecommerce_user_id
        , contexts_com_snowplowanalytics_snowplow_ecommerce_user_1[0].email::string as ecommerce_user_email
        , contexts_com_snowplowanalytics_snowplow_ecommerce_user_1[0].is_guest::boolean as ecommerce_user_is_guest
    {% endif %}
{% endmacro %}

{% macro snowflake__get_user_context_fields() %}
    {% if var('snowplow__disable_ecommerce_user_context', false) %}
        , cast(NULL as {{ type_string() }}) as ecommerce_user_id
        , cast(NULL as {{ type_string() }}) as ecommerce_user_email
        , cast(NULL as {{ type_boolean() }}) as ecommerce_user_is_guest
    {% else %}
        , contexts_com_snowplowanalytics_snowplow_ecommerce_user_1[0]:id::varchar as ecommerce_user_id
        , contexts_com_snowplowanalytics_snowplow_ecommerce_user_1[0]:email::varchar as ecommerce_user_email
        , contexts_com_snowplowanalytics_snowplow_ecommerce_user_1[0]:isGuest::boolean as ecommerce_user_is_guest
    {% endif %}
{% endmacro %}

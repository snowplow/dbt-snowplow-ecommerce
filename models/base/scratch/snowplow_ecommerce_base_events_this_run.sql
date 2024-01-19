{{
    config(
        sort='collector_tstamp',
        dist='event_id',
        tags=["this_run"]
    )
}}

{# Setting sdes or contexts for Postgres / Redshift. Dbt passes variables by reference so need to use copy to avoid altering the list multiple times #}
{% set contexts = var('snowplow__entities_or_sdes', []).copy() %}


{% do contexts.append({'schema': var('snowplow__sde_ecommerce_action'), 'prefix': 'ecommerce_action', 'single_entity': False}) %}
{% do contexts.append({'schema': var('snowplow__context_web_page'), 'prefix': 'page_view_', 'single_entity': True}) %}

{% if not var('snowplow__disable_ecommerce_user_context', false) -%}
    {% do contexts.append({'schema': var('snowplow__context_ecommerce_user'), 'prefix': 'ecommerce_user_', 'single_entity': True}) %}
{% endif -%}

{% if not var('snowplow__disable_ecommerce_checkouts', false) -%}
    {% do contexts.append({'schema': var('snowplow__context_ecommerce_checkout_step'), 'prefix': 'checkout_', 'single_entity': True}) %}
{% endif -%}

{% if not var('snowplow__disable_ecommerce_page_context', false) -%}
    {% do contexts.append({'schema': var('snowplow__context_ecommerce_page'), 'prefix': 'ecommerce_page_', 'single_entity': True}) %}
{% endif -%}

{% if not var('snowplow__disable_ecommerce_transactions', false) -%}
    {% do contexts.append({'schema': var('snowplow__context_ecommerce_transaction'), 'prefix': 'transaction_', 'single_entity': True}) %}
{% endif -%}

{% if not var('snowplow__disable_ecommerce_carts', false) -%}
    {% do contexts.append({'schema': var('snowplow__context_ecommerce_cart'), 'prefix': 'cart_', 'single_entity': True}) %}
{% endif -%}


{% if var('snowplow__enable_mobile_events') %}

    {% do contexts.append({'schema': var('snowplow__context_mobile_session'), 'prefix': 'mob_session_', 'single_entity': True}) %}
    {% do contexts.append({'schema': var('snowplow__context_screen'), 'prefix': 'mob_sc_view_', 'single_entity': True}) %}

{% endif -%}


{% set base_events_query = snowplow_utils.base_create_snowplow_events_this_run(
                            sessions_this_run_table='snowplow_ecommerce_base_sessions_this_run',
                            session_identifiers= session_identifiers(),
                            session_sql=var('snowplow__session_sql', none),
                            session_timestamp=var('snowplow__session_timestamp', 'collector_tstamp'),
                            derived_tstamp_partitioned=var('snowplow__derived_tstamp_partitioned', true),
                            days_late_allowed=var('snowplow__days_late_allowed', 3),
                            max_session_days=var('snowplow__max_session_days', 3),
                            app_ids=var('snowplow__app_id', []),
                            snowplow_events_database=var('snowplow__database', target.database) if target.type not in ['databricks', 'spark'] else var('snowplow__databricks_catalog', 'hive_metastore') if target.type in ['databricks'] else var('snowplow__atomic_schema', 'atomic'),
                            snowplow_events_schema=var('snowplow__atomic_schema', 'atomic'),
                            snowplow_events_table=var('snowplow__events_table', 'events'),
                            entities_or_sdes=contexts
    ) %}

{% set base_query_cols = get_column_schema_from_query( 'select * from (' + base_events_query +') a') %}

with base_query as (
    {{ base_events_query }}
), prep as (
    {% if target.type in ['postgres', 'redshift']%}
        select
            {% for col in base_query_cols | map(attribute='name') | list -%}
                {% if col.lower() == 'session_identifier' -%}
                    session_identifier as domain_sessionid
                {%- elif col.lower() == 'domain_sessionid' -%}
                    domain_sessionid as original_domain_sessionid
                {%- elif col.lower() == 'user_identifier' -%}
                    user_identifier as domain_userid
                {%- elif col.lower() == 'domain_userid' -%}
                    domain_userid as original_domain_userid
                {%- else -%}
                    {{col.lower()}}
                {%- endif -%}
                {%- if not loop.last -%},{%- endif %}
            {% endfor %}
    {% else %}
        select * {% if target.type in ['databricks', 'bigquery'] %}except{% else %}exclude{% endif %}(session_identifier, domain_sessionid, user_identifier, domain_userid)

        , session_identifier as domain_sessionid
        , domain_sessionid as original_domain_sessionid
        , user_identifier as domain_userid
        , domain_userid as original_domain_userid
    {% endif %}

    from base_query

),

field_extract as (
    select *
        -- extract commonly used contexts / sdes (prefixed)
        {{ get_user_context_fields() }}
        {{ get_checkout_context_fields() }}
        {{ get_page_context_fields() }}
        {{ get_transaction_context_fields() }}
        {{ get_cart_context_fields() }}
        {{ get_page_view_context_fields() }}
        {{ get_session_context_fields() }}
        {{ get_screen_view_context_fields () }}

        {% if target.type not in ['redshift', 'postgres'] -%}
            {{ get_action_context_fields() }}
        {%- endif %}        

    from prep

    where 1 = 1
    and {{ snowplow_ecommerce.event_name_filter(var("snowplow__ecommerce_event_names", "['snowplow_ecommerce_action']")) }}
),


transaction_dedupe as (
    select 
        *
        , case when ecommerce_action_type != 'transaction' or ecommerce_action_type is null then 1 else row_number() over (partition by domain_sessionid, transaction_id order by derived_tstamp) end AS transaction_id_index
    from
        field_extract

)

select 
    *
    , dense_rank() over (partition by domain_sessionid order by derived_tstamp) AS event_in_session_index
from 
    transaction_dedupe
where 
    transaction_id_index = 1

{#
Copyright (c) 2022-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{{
    config(
        tags=["this_run"],
        sql_header=snowplow_utils.set_query_tag(var('snowplow__query_tag', 'snowplow_dbt'))
    )
}}

with cart_session_stats AS (
    {% if var('snowplow__disable_ecommerce_carts', false) -%}
        select
        CAST(NULL as {{ type_string() }}) as domain_sessionid,
        CAST(NULL as {{ type_int() }}) as number_unique_cart_ids,
        CAST(NULL as {{ type_int() }}) as number_carts_created,
        CAST(NULL as {{ type_int() }}) as number_carts_emptied,
        CAST(NULL as {{ type_int() }}) as number_carts_transacted,
        CAST(NULL as {{ type_timestamp() }}) as first_cart_created,
        CAST(NULL as {{ type_timestamp() }}) as last_cart_created,
        CAST(NULL as {{ type_timestamp() }}) as first_cart_transacted,
        CAST(NULL as {{ type_timestamp() }}) as last_cart_transacted,
        CAST(NULL as {{ type_boolean() }}) as session_cart_abandoned

    {%- else -%}
        select
            t.*,
            number_carts_transacted < number_carts_created as session_cart_abandoned

        from (
            select domain_sessionid,

            COUNT(DISTINCT cart_id) as number_unique_cart_ids,
            COUNT(DISTINCT CASE WHEN cart_created THEN event_id END) as number_carts_created,
            COUNT(DISTINCT CASE WHEN cart_emptied THEN event_id END) as number_carts_emptied,
            COUNT(DISTINCT CASE WHEN cart_transacted THEN event_id END) as number_carts_transacted,

            MIN(CASE WHEN cart_created THEN derived_tstamp END) as first_cart_created,
            MAX(CASE WHEN cart_created THEN derived_tstamp END) as last_cart_created,

            MIN(CASE WHEN cart_transacted THEN derived_tstamp END) as first_cart_transacted,
            MAX(CASE WHEN cart_transacted THEN derived_tstamp END) as last_cart_transacted


            from {{ ref('snowplow_ecommerce_cart_interactions_this_run') }}
            group by 1

        ) as t
    {%- endif %}
), checkout_session_stats AS (
    {% if var('snowplow__disable_ecommerce_checkouts', false) -%}
        select
            CAST(NULL as {{ type_string() }}) as domain_sessionid,
            CAST(NULL as {{ type_boolean() }}) as session_entered_at_checkout,
            CAST(NULL as {{ type_int() }}) as number_unique_checkout_steps_attempted,
            CAST(NULL as {{ type_int() }}) as number_checkout_steps_visited,
            CAST(NULL as {{ type_boolean() }}) as checkout_succeeded,
            CAST(NULL as {{ type_timestamp() }}) as first_checkout_attempted,
            CAST(NULL as {{ type_timestamp() }}) as last_checkout_attempted,
            CAST(NULL as {{ type_timestamp() }}) as first_checkout_succeeded,
            CAST(NULL as {{ type_timestamp() }}) as last_checkout_succeeded
    {%- else -%}
        select
            domain_sessionid,

            CAST(MAX(CAST(session_entered_at_step as {{ type_int() }})) as {{ type_boolean() }}) as session_entered_at_checkout,
            COUNT(DISTINCT checkout_step_number) as number_unique_checkout_steps_attempted,
            COUNT(DISTINCT event_id) as number_checkout_steps_visited,
            CAST(MAX(CAST(checkout_succeeded as {{ type_int() }})) as {{ type_boolean() }}) as checkout_succeeded,

            MIN(CASE WHEN checkout_step_number = 1 THEN derived_tstamp END) as first_checkout_attempted,
            MAX(CASE WHEN checkout_step_number = 1 THEN derived_tstamp END) as last_checkout_attempted,
            MIN(CASE WHEN checkout_succeeded THEN derived_tstamp END) as first_checkout_succeeded,
            MAX(CASE WHEN checkout_succeeded THEN derived_tstamp END) as last_checkout_succeeded

        from {{ ref('snowplow_ecommerce_checkout_interactions_this_run') }}
        group by 1

    {%- endif %}
), product_session_stats AS (
    {% if var('snowplow__disable_ecommerce_products', false) -%}
        select
            CAST(NULL as {{ type_string() }}) AS domain_sessionid,
            CAST(NULL as {{ type_timestamp() }}) AS first_product_view,
            CAST(NULL as {{ type_timestamp() }}) AS last_product_view,
            CAST(NULL as {{ type_timestamp() }}) AS first_product_add_to_cart,
            CAST(NULL as {{ type_timestamp() }}) AS last_product_add_to_cart,
            CAST(NULL as {{ type_timestamp() }}) AS first_product_remove_from_cart,
            CAST(NULL as {{ type_timestamp() }}) AS last_product_remove_from_cart,
            CAST(NULL as {{ type_timestamp() }}) AS first_product_transaction,
            CAST(NULL as {{ type_timestamp() }}) AS last_product_transaction,
            CAST(NULL as {{ type_int() }}) AS number_product_views,
            CAST(NULL as {{ type_int() }}) AS number_add_to_carts,
            CAST(NULL as {{ type_int() }}) AS number_remove_from_carts,
            CAST(NULL as {{ type_int() }}) AS number_product_transactions,
            CAST(NULL as {{ type_int() }}) AS number_distinct_products_viewed
    {%- else -%}
        select
            domain_sessionid,

            MIN(CASE WHEN is_product_view THEN derived_tstamp END) AS first_product_view,
            MAX(CASE WHEN is_product_view THEN derived_tstamp END) AS last_product_view,
            MIN(CASE WHEN is_add_to_cart THEN derived_tstamp END) AS first_product_add_to_cart,
            MAX(CASE WHEN is_add_to_cart THEN derived_tstamp END) AS last_product_add_to_cart,
            MIN(CASE WHEN is_remove_from_cart THEN derived_tstamp END) AS first_product_remove_from_cart,
            MAX(CASE WHEN is_remove_from_cart THEN derived_tstamp END) AS last_product_remove_from_cart,
            MIN(CASE WHEN is_product_transaction THEN derived_tstamp END) AS first_product_transaction,
            MAX(CASE WHEN is_product_transaction THEN derived_tstamp END) AS last_product_transaction,

            COUNT(DISTINCT CASE WHEN is_product_view THEN event_id END) AS number_product_views,
            COUNT(DISTINCT CASE WHEN is_add_to_cart THEN event_id END) AS number_add_to_carts,
            COUNT(DISTINCT CASE WHEN is_remove_from_cart THEN event_id END) AS number_remove_from_carts,
            COUNT(DISTINCT CASE WHEN is_product_transaction THEN event_id END) AS number_product_transactions,
            COUNT(DISTINCT CASE WHEN is_product_view THEN product_id END) as number_distinct_products_viewed


        from {{ ref('snowplow_ecommerce_product_interactions_this_run') }}
        group by 1

    {%- endif %}
), transaction_session_stats AS (
    {% if var('snowplow__disable_ecommerce_transactions', false) -%}
        select
            CAST(NULL as {{ type_string() }}) AS domain_sessionid,
            CAST(NULL as {{ type_timestamp() }}) AS first_transaction_completed,
            CAST(NULL as {{ type_timestamp() }}) AS last_transaction_completed,
            CAST(NULL as {{ type_float() }}) AS total_transaction_revenue,
            CAST(NULL as {{ type_int() }}) AS total_transaction_quantity,
            CAST(NULL as {{ type_int() }}) AS total_number_transactions,
            CAST(NULL as {{ type_int() }}) AS total_transacted_products

    {%- else -%}
        select
            domain_sessionid,

            MIN(derived_tstamp) AS first_transaction_completed,
            MAX(derived_tstamp) AS last_transaction_completed,
            SUM(transaction_revenue) as total_transaction_revenue,
            SUM(transaction_total_quantity) as total_transaction_quantity,
            COUNT(DISTINCT transaction_id) as total_number_transactions,
            SUM(number_products) as total_transacted_products

        from {{ ref('snowplow_ecommerce_transaction_interactions_this_run') }}
        group by 1
    {%- endif %}
), session_apps as (
    select domain_sessionid,
            app_id,

            {%- if var('snowplow__session_passthroughs', []) -%}
                {%- set passthrough_names = [] -%}
                {%- for identifier in var('snowplow__session_passthroughs', []) %}
                {# Check if it's a simple column or a sql+alias #}
                {%- if identifier is mapping -%}
                    {{identifier['sql']}} as {{identifier['alias']}},
                    {%- do passthrough_names.append(identifier['alias']) -%}
                {%- else -%}
                    t.{{identifier}},
                    {%- do passthrough_names.append(identifier) -%}
                {%- endif -%}
                {% endfor -%}
            {%- endif %}

            row_number() over (partition by domain_sessionid order by derived_tstamp, dvce_created_tstamp) as event_session_index


    from {{ ref('snowplow_ecommerce_base_events_this_run') }} as t
)
select
    s.session_identifier as domain_sessionid,
    s.user_identifier as domain_userid,
    s.start_tstamp,
    s.end_tstamp,
    sa.app_id,

    {%- if var('snowplow__session_passthroughs', []) -%}
        {%- for col in passthrough_names %}
            sa.{{col}},
        {%- endfor -%}
    {%- endif %}

    coalesce(css.number_unique_cart_ids, 0) as number_unique_cart_ids,
    coalesce(css.number_carts_created, 0) as number_carts_created,
    coalesce(css.number_carts_emptied, 0) as number_carts_emptied,
    coalesce(css.number_carts_transacted, 0) as number_carts_transacted,

    css.first_cart_created,
    css.last_cart_created,
    css.first_cart_transacted,
    css.last_cart_transacted,
    css.session_cart_abandoned, -- keep this null on purpose, can't abandon what you never had

    coalesce(chss.session_entered_at_checkout, false) as session_entered_at_checkout,
    coalesce(chss.number_unique_checkout_steps_attempted, 0) as number_unique_checkout_steps_attempted,
    coalesce(chss.number_checkout_steps_visited, 0) as number_checkout_steps_visited,
    chss.checkout_succeeded, -- keep this null on purpose, success cannot be true/false if never tried
    chss.first_checkout_attempted,
    chss.last_checkout_attempted,
    chss.first_checkout_succeeded,
    chss.last_checkout_succeeded,

    pss.first_product_view,
    pss.last_product_view,
    pss.first_product_add_to_cart,
    pss.last_product_add_to_cart,
    pss.first_product_remove_from_cart,
    pss.last_product_remove_from_cart,
    pss.first_product_transaction,
    pss.last_product_transaction,
    coalesce(pss.number_product_views, 0) as number_product_views,
    coalesce(pss.number_add_to_carts, 0) as number_add_to_carts,
    coalesce(pss.number_remove_from_carts, 0) as number_remove_from_carts,
    coalesce(pss.number_product_transactions, 0) as number_product_transactions,

    tss.first_transaction_completed,
    tss.last_transaction_completed,
    coalesce(tss.total_transaction_revenue, 0.0) as total_transaction_revenue,
    coalesce(tss.total_transaction_quantity, 0) as total_transaction_quantity,
    coalesce(tss.total_number_transactions, 0) as total_number_transactions,
    coalesce(tss.total_transacted_products, 0) as total_transacted_products



from {{ ref('snowplow_ecommerce_base_sessions_this_run') }} as s
inner join session_apps as sa on s.session_identifier = sa.domain_sessionid and sa.event_session_index = 1
left join cart_session_stats as css on s.session_identifier = css.domain_sessionid
left join checkout_session_stats as chss on s.session_identifier = chss.domain_sessionid
left join product_session_stats as pss on s.session_identifier = pss.domain_sessionid
left join transaction_session_stats as tss on s.session_identifier = tss.domain_sessionid

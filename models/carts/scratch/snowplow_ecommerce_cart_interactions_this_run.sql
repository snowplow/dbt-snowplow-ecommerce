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

with cart_product_interactions AS (
    select
        e.event_id,
        {% if var('snowplow__disable_ecommerce_products', false) -%}
            cast(NULL as {{ type_float() }}) as product_value_added
        {%- else -%}
            SUM(pi.product_price) as product_value_added
        {%- endif %}


    from {{ ref('snowplow_ecommerce_base_events_this_run') }} as e
    {% if not var('snowplow__disable_ecommerce_products', false) -%}
        left join {{ ref('snowplow_ecommerce_product_interactions_this_run') }} as pi on e.event_id = pi.event_id AND pi.is_add_to_cart
    {%- endif %}
    where e.ecommerce_action_type IN ('add_to_cart', 'remove_from_cart', 'transaction')
    group by 1

), final as (
    select
        -- event fields
        e.event_id,
        page_view_id,
        app_id,

        -- session fields
        domain_sessionid,
        event_in_session_index,

        -- user fields
        domain_userid,
        network_userid,
        user_id,
        ecommerce_user_id,

        -- timestamp fields
        derived_tstamp,
        DATE(derived_tstamp) as derived_tstamp_date,

        -- ecommerce cart fields
        cart_id,
        cart_currency,
        cart_total_value,
        product_value_added = cart_total_value as cart_created,
        cart_total_value = 0 as cart_emptied,
        ecommerce_action_type = 'transaction' as cart_transacted,

        -- ecommerce action field
        ecommerce_action_type

        {%- if var('snowplow__cart_passthroughs', []) -%}
            {%- for identifier in var('snowplow__cart_passthroughs', []) %}
            {# Check if it's a simple column or a sql+alias #}
            {%- if identifier is mapping -%}
                ,{{identifier['sql']}} as {{identifier['alias']}}
            {%- else -%}
                ,e.{{identifier}}
            {%- endif -%}
            {% endfor -%}
        {%- endif %}

    from {{ ref('snowplow_ecommerce_base_events_this_run') }} as e
    inner join cart_product_interactions as cpi on e.event_id = cpi.event_id
)

select *

from final

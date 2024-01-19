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

with transaction_info AS (
    select
        e.transaction_id,

        {% if (var("snowplow__use_product_quantity", false) and not var("snowplow__disable_ecommerce_products", false) | as_bool() )  -%}
        SUM(pi.product_quantity) as number_products
        {%- else -%}
        COUNT(*) as number_products -- count all products added
        {%- endif %}

    from {{ ref('snowplow_ecommerce_base_events_this_run') }} as e
    {% if not var("snowplow__disable_ecommerce_products", false)  -%}
    left join {{ ref('snowplow_ecommerce_product_interactions_this_run') }} as pi on e.transaction_id = pi.transaction_id AND pi.is_product_transaction
    {%- endif %}
    where e.ecommerce_action_type = 'transaction'
    group by 1
), final as (
    select
        e.event_id,
        e.page_view_id,
        e.app_id,

        -- session fields
        e.domain_sessionid,
        e.event_in_session_index,

        -- user fields
        e.domain_userid,
        e.network_userid,
        e.user_id,
        e.ecommerce_user_id,

        -- timestamp fields
        e.derived_tstamp,
        DATE(e.derived_tstamp) as derived_tstamp_date,

        -- ecommerce transaction fields
        e.transaction_id,
        e.transaction_currency as transaction_currency,
        e.transaction_payment_method,
        e.transaction_revenue,
        e.transaction_total_quantity,
        e.transaction_credit_order,
        e.transaction_discount_amount,
        e.transaction_discount_code,
        e.transaction_shipping,
        e.transaction_tax,

        -- ecommerce user fields
        e.ecommerce_user_email,
        e.ecommerce_user_is_guest,

        ti.number_products

        {%- if var('snowplow__transaction_passthroughs', []) -%}
            {%- for identifier in var('snowplow__transaction_passthroughs', []) %}
            {# Check if it's a simple column or a sql+alias #}
            {%- if identifier is mapping -%}
                ,{{identifier['sql']}} as {{identifier['alias']}}
            {%- else -%}
                ,e.{{identifier}}
            {%- endif -%}
            {% endfor -%}
        {%- endif %}


    from {{ ref('snowplow_ecommerce_base_events_this_run') }} as e
    inner join transaction_info as ti on e.transaction_id = ti.transaction_id
)

select *

from final

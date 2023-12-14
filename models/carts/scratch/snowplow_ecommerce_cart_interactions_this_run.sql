{{
    config(
        tags=["this_run"],
        sql_header=snowplow_utils.set_query_tag(var('snowplow__query_tag', 'snowplow_dbt'))
    )
}}

with cart_product_interactions AS (
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

        -- ecommerce cart fields
        e.cart_id,
        e.cart_currency,
        e.cart_total_value,

        -- ecommerce action field
        e.ecommerce_action_type,
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
    group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

)

select
    -- event fields
    event_id,
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
    derived_tstamp_date,

    -- ecommerce cart fields
    cart_id,
    cart_currency,
    cart_total_value,
    product_value_added = cart_total_value as cart_created,
    cart_total_value = 0 as cart_emptied,
    ecommerce_action_type = 'transaction' as cart_transacted,

    -- ecommerce action field
    ecommerce_action_type


from cart_product_interactions

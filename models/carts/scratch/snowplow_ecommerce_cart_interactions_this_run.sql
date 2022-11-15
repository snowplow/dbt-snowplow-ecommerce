{{
    config(
        tags=["this_run"]
    )
}}

with cart_product_interactions AS (
    select
        e.event_id,
        SUM(pi.product_price) as product_value_added


    from {{ ref('snowplow_ecommerce_base_events_this_run') }} as e
    join {{ ref('snowplow_ecommerce_product_interactions_this_run') }} as pi on e.event_id = pi.event_id AND pi.is_add_to_cart
    group by 1
)

select
    -- event fields
    e.event_id,
    e.page_view_id,

    -- session fields
    e.domain_sessionid,
    e.page_view_in_session_index,

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
    cpi.product_value_added = e.cart_total_value as cart_created,
    e.cart_total_value = 0 as cart_emptied,
    e.ecommerce_action_type = 'transaction' as cart_transacted,

    -- ecommerce action field
    e.ecommerce_action_type


from {{ ref('snowplow_ecommerce_base_events_this_run') }} as e
left join cart_product_interactions as cpi on e.event_id = cpi.event_id
where e.ecommerce_action_type IN ('add_to_cart', 'remove_from_cart', 'transaction')

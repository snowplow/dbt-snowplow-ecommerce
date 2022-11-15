{{
    config(
        tags=["this_run"]
    )
}}

with users as (
    select
        identifying_userid,
        start_tstamp

    from {{ ref('snowplow_ecommerce_userids_this_run') }}
)


select
    u.identifying_userid,
    '{{ var("snowplow__user_id", "domain_userid") }}' as user_id_field,
    MIN(u.start_tstamp) as start_tstamp,

    -- cart interactions
    MIN(CASE WHEN ca_i.cart_created THEN ca_i.derived_tstamp END) as first_cart_created,
    MAX(CASE WHEN ca_i.cart_created THEN ca_i.derived_tstamp END) as latest_cart_created,
    COUNT(DISTINCT CASE WHEN ca_i.cart_created THEN ca_i.event_id END) as number_carts_created,
    COUNT(DISTINCT CASE WHEN ca_i.cart_emptied THEN ca_i.event_id END) as number_carts_emptied,
    COUNT(DISTINCT CASE WHEN ca_i.cart_transacted THEN ca_i.event_id END) as number_carts_transacted,
    MIN(CASE WHEN ca_i.cart_transacted THEN ca_i.derived_tstamp END) as first_cart_transacted,
    MAX(CASE WHEN ca_i.cart_transacted THEN ca_i.derived_tstamp END) as latest_cart_transacted,

    -- checkout interactions
    MIN(CASE WHEN ch_i.checkout_step_number = 1 THEN ch_i.derived_tstamp END) as first_checkout_attempted,
    MAX(CASE WHEN ch_i.checkout_step_number = 1 THEN ch_i.derived_tstamp END) as latest_checkout_attempted,
    MIN(CASE WHEN ch_i.checkout_succeeded THEN ch_i.derived_tstamp END) as first_checkout_succeeded,
    MAX(CASE WHEN ch_i.checkout_succeeded THEN ch_i.derived_tstamp END) as latest_checkout_succeeded,

    -- product interactions
    MIN(CASE WHEN pi.is_product_view THEN pi.derived_tstamp END) AS first_product_view,
    MAX(CASE WHEN pi.is_product_view THEN pi.derived_tstamp END) AS latest_product_view,
    MIN(CASE WHEN pi.is_add_to_cart THEN pi.derived_tstamp END) AS first_product_add_to_cart,
    MAX(CASE WHEN pi.is_add_to_cart THEN pi.derived_tstamp END) AS latest_product_add_to_cart,
    MIN(CASE WHEN pi.is_remove_from_cart THEN pi.derived_tstamp END) AS first_product_remove_from_cart,
    MAX(CASE WHEN pi.is_remove_from_cart THEN pi.derived_tstamp END) AS latest_product_remove_from_cart,
    MIN(CASE WHEN pi.is_product_transaction THEN pi.derived_tstamp END) AS first_product_transaction,
    MAX(CASE WHEN pi.is_product_transaction THEN pi.derived_tstamp END) AS latest_product_transaction,

    COUNT(DISTINCT CASE WHEN pi.is_product_view THEN pi.event_id END) AS number_product_views,
    COUNT(DISTINCT CASE WHEN pi.is_add_to_cart THEN pi.event_id END) AS number_add_to_carts,
    COUNT(DISTINCT CASE WHEN pi.is_remove_from_cart THEN pi.event_id END) AS number_remove_from_carts,
    COUNT(DISTINCT CASE WHEN pi.is_product_transaction THEN pi.event_id END) AS number_product_transactions,

    -- transaction interactions
    MIN(ti.derived_tstamp) AS first_transaction_completed,
    MAX(ti.derived_tstamp) AS latest_transaction_completed,
    SUM(ti.transaction_revenue) as total_transaction_revenue,
    SUM(ti.transaction_total_quantity) as total_transaction_quantity,
    COUNT(DISTINCT ti.transaction_id) as total_number_transactions,
    SUM(ti.number_products) as total_transacted_products


from users as u
left join {{ ref('snowplow_ecommerce_cart_interactions') }} as ca_i on u.identifying_userid = ca_i.{{ var("snowplow__user_id", "domain_userid") }}
left join {{ ref('snowplow_ecommerce_checkout_interactions') }} as ch_i on u.identifying_userid = ch_i.{{ var("snowplow__user_id", "domain_userid") }}
left join {{ ref('snowplow_ecommerce_product_interactions') }} as pi on u.identifying_userid = pi.{{ var("snowplow__user_id", "domain_userid") }}
left join {{ ref('snowplow_ecommerce_transaction_interactions') }} as ti on u.identifying_userid = ti.{{ var("snowplow__user_id", "domain_userid") }}

GROUP BY 1,2

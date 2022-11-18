{{
    config(
        tags=["this_run"]
    )
}}

with cart_session_stats AS (
    with carts_intermediate AS (
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
    )
    select
        *,
        number_carts_transacted < number_carts_created as session_cart_abandoned

    from carts_intermediate
), checkout_session_stats AS (
    select
        domain_sessionid,

        MAX(session_entered_at_step) as session_entered_at_step,
        COUNT(DISTINCT checkout_step_number) as number_unique_checkout_steps_attempted,
        COUNT(DISTINCT event_id) as number_checkout_steps_visited,
        MAX(checkout_succeeded) as checkout_succeeded,

        MIN(CASE WHEN checkout_step_number = 1 THEN derived_tstamp END) as first_checkout_attempted,
        MAX(CASE WHEN checkout_step_number = 1 THEN derived_tstamp END) as last_checkout_attempted,
        MIN(CASE WHEN checkout_succeeded THEN derived_tstamp END) as first_checkout_succeeded,
        MAX(CASE WHEN checkout_succeeded THEN derived_tstamp END) as last_checkout_succeeded

    from {{ ref('snowplow_ecommerce_checkout_interactions_this_run') }}
    group by 1
), product_session_stats AS (
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
        COUNT(DISTINCT CASE WHEN is_product_transaction THEN event_id END) AS number_product_transactions


    from {{ ref('snowplow_ecommerce_product_interactions_this_run') }}
    group by 1
), transaction_session_stats AS (
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
)
select
    s.session_id as domain_sessionid,
    s.start_tstamp,

    css.number_unique_cart_ids,
    css.number_carts_created,
    css.number_carts_emptied,
    css.number_carts_transacted,

    css.first_cart_created,
    css.last_cart_created,
    css.first_cart_transacted,
    css.last_cart_transacted,
    css.session_cart_abandoned,

    chss.session_entered_at_step,
    chss.number_unique_checkout_steps_attempted,
    chss.number_checkout_steps_visited,
    chss.checkout_succeeded,
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
    pss.number_product_views,
    pss.number_add_to_carts,
    pss.number_remove_from_carts,
    pss.number_product_transactions,

    tss.first_transaction_completed,
    tss.last_transaction_completed,
    tss.total_transaction_revenue,
    tss.total_transaction_quantity,
    tss.total_number_transactions,
    tss.total_transacted_products



from {{ ref('snowplow_ecommerce_base_sessions_this_run') }} as s
left join cart_session_stats as css on s.session_id = css.domain_sessionid
left join checkout_session_stats as chss on s.session_id = chss.domain_sessionid
left join product_session_stats as pss on s.session_id = pss.domain_sessionid
left join transaction_session_stats as tss on s.session_id = tss.domain_sessionid

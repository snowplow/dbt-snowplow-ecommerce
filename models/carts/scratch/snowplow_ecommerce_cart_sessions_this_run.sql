{{
    config(
        tags=["this_run"]
    )
}}

with cart_session_stats AS (
    select domain_sessionid,
       MAX(ecommerce_user_id) as ecommerce_user_id,
       MIN(derived_tstamp) as start_tstamp,

       COUNT(DISTINCT cart_id) as number_unique_cart_ids,
       COUNT(DISTINCT CASE WHEN cart_created THEN event_id END) as number_carts_created,
       COUNT(DISTINCT CASE WHEN cart_emptied THEN event_id END) as number_carts_emptied,
       COUNT(DISTINCT CASE WHEN cart_transacted THEN event_id END) as number_carts_transacted


    from {{ ref('snowplow_ecommerce_cart_interactions_this_run') }}
    group by 1
)

select
    *,
    number_carts_transacted < number_carts_created as session_cart_abandoned

from cart_session_stats

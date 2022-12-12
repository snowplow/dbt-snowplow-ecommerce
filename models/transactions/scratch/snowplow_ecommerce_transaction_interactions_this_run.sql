{{
    config(
        tags=["this_run"]
    )
}}

with transaction_info AS (
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

        -- ecommerce transaction fields
        e.transaction_id as transaction_id,
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

        {% if var("snowplow__use_product_quanity", false) -%}
        SUM(pi.product_quantity) as number_products
        {%- else -%}
        COUNT(*) as number_products -- count all products added
        {%- endif %}

    from {{ ref('snowplow_ecommerce_base_events_this_run') }} as e
    left join {{ ref('snowplow_ecommerce_product_interactions_this_run') }} as pi on e.transaction_id = pi.transaction_id AND pi.is_product_transaction
    where ecommerce_action_type = 'transaction'
    group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22
)

select *

from transaction_info

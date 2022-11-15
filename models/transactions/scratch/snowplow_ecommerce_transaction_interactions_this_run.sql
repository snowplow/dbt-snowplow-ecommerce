{{
    config(
        tags=["this_run"]
    )
}}

with transaction_info AS (
    select
        -- event fields
        event_id,
        page_view_id,

        -- session fields
        domain_sessionid,
        page_view_in_session_index,

        -- user fields
        domain_userid,
        network_userid,
        user_id,
        ecommerce_user_id,

        -- timestamp fields
        derived_tstamp,
        DATE(derived_tstamp) as derived_tstamp_date,

        -- ecommerce transaction fields
        transaction_id as transaction_id,
        transaction_currency as transaction_currency,
        transaction_payment_method,
        transaction_revenue,
        transaction_total_quantity,
        transaction_credit_order,
        transaction_discount_amount,
        transaction_discount_code,
        transaction_shipping,
        transaction_tax,

        -- ecommerce user fields
        ecommerce_user_email,
        ecommerce_user_is_guest

    from {{ ref('snowplow_ecommerce_base_events_this_run') }}
    where ecommerce_action_type = 'transaction'
), transaction_product_info AS (
    select
        ti.transaction_id,
        {% if var("snowplow__use_product_quanity", false) -%}
        SUM(pi.product_quantity) as number_products
        {%- else -%}
        COUNT(*) as number_products -- count all products added
        {%- endif %}

    from transaction_info as ti
    left join {{ ref('snowplow_ecommerce_product_interactions_this_run') }} as pi on ti.transaction_id = pi.transaction_id AND pi.is_product_transaction
    group by 1
)

select
    ti.*,
    tpi.number_products,

from transaction_info as ti
left join transaction_product_info as tpi on ti.transaction_id = tpi.transaction_id

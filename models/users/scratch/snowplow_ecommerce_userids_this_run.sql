{{
    config(
        tags=["this_run"]
    )
}}

select
    {{ var("snowplow__user_id", "domain_userid")}} as identifying_userid,
    MIN(derived_tstamp) as start_tstamp

from {{ ref('snowplow_ecommerce_base_events_this_run') }}
GROUP BY 1

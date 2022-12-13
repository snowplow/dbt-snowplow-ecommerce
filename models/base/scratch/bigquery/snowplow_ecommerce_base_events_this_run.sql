{{
  config(
    tags=["this_run"]
  )
}}

{%- set lower_limit, upper_limit = snowplow_utils.return_limits_from_model(ref('snowplow_ecommerce_base_sessions_this_run'),
                                                                          'start_tstamp',
                                                                          'end_tstamp') %}


select
  *,
  row_number() over (partition by ev.domain_sessionid order by ev.derived_tstamp) AS page_view_in_session_index,

from (
  -- without downstream joins, it's safe to dedupe by picking the first event_id found.
  select
    array_agg(e order by e.collector_tstamp limit 1)[offset(0)].*

  from (

  select
    a.contexts_com_snowplowanalytics_snowplow_web_page_1_0_0[safe_offset(0)].id as page_view_id,
    b.domain_userid,

    -- unpacking the ecommerce user object
    {{ snowplow_utils.get_optional_fields(
        enabled=true,
        fields=user_fields(),
        col_prefix='contexts_ecommerce_tracking_user_1',
        relation=source('atomic', 'events'),
        relation_alias='a') }},

    -- unpacking the ecommerce checkout step object
    {{ snowplow_utils.get_optional_fields(
        enabled=true,
        fields=checkout_step_fields(),
        col_prefix='contexts_ecommerce_tracking_checkout_step_1',
        relation=source('atomic', 'events'),
        relation_alias='a') }},

    -- unpacking the ecommerce page object
    {{ snowplow_utils.get_optional_fields(
        enabled=true,
        fields=tracking_page_fields(),
        col_prefix='contexts_ecommerce_tracking_page_1',
        relation=source('atomic', 'events'),
        relation_alias='a') }},

    -- unpacking the ecommerce transaction object
    {{ snowplow_utils.get_optional_fields(
        enabled=true,
        fields=transaction_fields(),
        col_prefix='contexts_ecommerce_tracking_transaction_1',
        relation=source('atomic', 'events'),
        relation_alias='a') }},

    -- unpacking the ecommerce cart object
    {{ snowplow_utils.get_optional_fields(
        enabled=true,
        fields=cart_fields(),
        col_prefix='contexts_ecommerce_tracking_cart_1',
        relation=source('atomic', 'events'),
        relation_alias='a') }},

    -- unpacking the ecommerce action object
    {{ snowplow_utils.get_optional_fields(
        enabled=true,
        fields=tracking_action_fields(),
        col_prefix='unstruct_event_ecommerce_tracking_action_1',
        relation=source('atomic', 'events'),
        relation_alias='a') }},

    a.*

    from {{ var('snowplow__events') }} as a
    inner join {{ ref('snowplow_ecommerce_base_sessions_this_run') }} as b
    on a.domain_sessionid = b.session_id

    where a.collector_tstamp <= {{ snowplow_utils.timestamp_add('day', var("snowplow__max_session_days", 3), 'b.start_tstamp') }}
    and a.dvce_sent_tstamp <= {{ snowplow_utils.timestamp_add('day', var("snowplow__days_late_allowed", 3), 'a.dvce_created_tstamp') }}
    and a.collector_tstamp >= {{ lower_limit }}
    and a.collector_tstamp <= {{ upper_limit }}
    {% if var('snowplow__derived_tstamp_partitioned', true) and target.type == 'bigquery' | as_bool() %}
      and a.derived_tstamp >= {{ snowplow_utils.timestamp_add('hour', -1, lower_limit) }}
      and a.derived_tstamp <= {{ upper_limit }}
    {% endif %}
    and {{ snowplow_utils.app_id_filter(var("snowplow__app_id",[])) }}
    and {{ snowplow_ecommerce.event_name_filter(var("snowplow__ecommerce_event_names", "['snowplow_ecommerce_action']")) }}
  ) e
  group by e.event_id
) ev

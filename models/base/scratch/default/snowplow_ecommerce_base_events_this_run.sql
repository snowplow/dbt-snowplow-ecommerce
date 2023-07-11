{{
    config(
        sort='collector_tstamp',
        dist='event_id',
        tags=["this_run"]
    )
}}

{%- set lower_limit, upper_limit = snowplow_utils.return_limits_from_model(ref('snowplow_ecommerce_base_sessions_this_run'),
                                                                            'start_tstamp',
                                                                            'end_tstamp') %}

/* Dedupe logic: Per dupe event_id keep earliest row ordered by collector_tstamp.
   If multiple earliest rows, take arbitrary one using row_number(). */

with

{% if var('snowplow__enable_mobile_events', false) -%}
    {{ snowplow_utils.get_sde_or_context(var('snowplow__atomic_schema', 'atomic'), var('snowplow__context_mobile_session'), lower_limit, upper_limit, 'mob_session') }},
    {{ snowplow_utils.get_sde_or_context(var('snowplow__atomic_schema', 'atomic'), var('snowplow__context_screen'), lower_limit, upper_limit, 'mob_sc_view') }},
{%- endif %}

events_this_run AS (
    select
        a.app_id,
        a.platform,
        a.etl_tstamp,
        a.collector_tstamp,
        a.dvce_created_tstamp,
        a.event,
        a.event_id,
        a.txn_id,
        a.name_tracker,
        a.v_tracker,
        a.v_collector,
        a.v_etl,
        a.user_id,
        a.user_ipaddress,
        a.user_fingerprint,
        b.domain_userid, -- take domain_userid from manifest. This ensures only 1 domain_userid per session.
        a.domain_sessionidx,
        a.network_userid,
        a.geo_country,
        a.geo_region,
        a.geo_city,
        a.geo_zipcode,
        a.geo_latitude,
        a.geo_longitude,
        a.geo_region_name,
        a.ip_isp,
        a.ip_organization,
        a.ip_domain,
        a.ip_netspeed,
        a.page_url,
        a.page_title,
        a.page_referrer,
        a.page_urlscheme,
        a.page_urlhost,
        a.page_urlport,
        a.page_urlpath,
        a.page_urlquery,
        a.page_urlfragment,
        a.refr_urlscheme,
        a.refr_urlhost,
        a.refr_urlport,
        a.refr_urlpath,
        a.refr_urlquery,
        a.refr_urlfragment,
        a.refr_medium,
        a.refr_source,
        a.refr_term,
        a.mkt_medium,
        a.mkt_source,
        a.mkt_term,
        a.mkt_content,
        a.mkt_campaign,
        a.se_category,
        a.se_action,
        a.se_label,
        a.se_property,
        a.se_value,
        a.tr_orderid,
        a.tr_affiliation,
        a.tr_total,
        a.tr_tax,
        a.tr_shipping,
        a.tr_city,
        a.tr_state,
        a.tr_country,
        a.ti_orderid,
        a.ti_sku,
        a.ti_name,
        a.ti_category,
        a.ti_price,
        a.ti_quantity,
        a.pp_xoffset_min,
        a.pp_xoffset_max,
        a.pp_yoffset_min,
        a.pp_yoffset_max,
        a.useragent,
        a.br_name,
        a.br_family,
        a.br_version,
        a.br_type,
        a.br_renderengine,
        a.br_lang,
        a.br_features_pdf,
        a.br_features_flash,
        a.br_features_java,
        a.br_features_director,
        a.br_features_quicktime,
        a.br_features_realplayer,
        a.br_features_windowsmedia,
        a.br_features_gears,
        a.br_features_silverlight,
        a.br_cookies,
        a.br_colordepth,
        a.br_viewwidth,
        a.br_viewheight,
        a.os_name,
        a.os_family,
        a.os_manufacturer,
        a.os_timezone,
        a.dvce_type,
        a.dvce_ismobile,
        a.dvce_screenwidth,
        a.dvce_screenheight,
        a.doc_charset,
        a.doc_width,
        a.doc_height,
        a.tr_currency,
        a.tr_total_base,
        a.tr_tax_base,
        a.tr_shipping_base,
        a.ti_currency,
        a.ti_price_base,
        a.base_currency,
        a.geo_timezone,
        a.mkt_clickid,
        a.mkt_network,
        a.etl_tags,
        a.dvce_sent_tstamp,
        a.refr_domain_userid,
        a.refr_dvce_tstamp,
        {% if var('snowplow__enable_mobile_events', false) %}
            coalesce(
                ms.mob_session_session_id,
                a.domain_sessionid
            ) as domain_sessionid,
        {% else %}
            a.domain_sessionid,
        {% endif %}
        a.derived_tstamp,
        a.event_vendor,
        a.event_name,
        a.event_format,
        a.event_version,
        a.event_fingerprint,
        a.true_tstamp,
        {% if var('snowplow__enable_load_tstamp', true) %}
            a.load_tstamp,
        {% endif %}
        row_number() over (partition by a.event_id order by a.collector_tstamp) as event_id_dedupe_index,
        count(*) over (partition by a.event_id) as event_id_dedupe_count

    from {{ var('snowplow__events') }} as a
    {% if var('snowplow__enable_mobile_events', false) -%}
        left join {{ var('snowplow__context_mobile_session') }} ms on a.event_id = ms.mob_session__id and a.collector_tstamp = ms.mob_session__tstamp
    {%- endif %}
        inner join {{ ref('snowplow_ecommerce_base_sessions_this_run') }} as b
            on
            {% if var('snowplow__enable_mobile_events', false) %}
                coalesce(
                    ms.mob_session_session_id,
                    a.domain_sessionid
                )
            {% else %}
                a.domain_sessionid
            {% endif %} = b.session_id

    where a.collector_tstamp <= {{ snowplow_utils.timestamp_add('day', var("snowplow__max_session_days", 3), 'b.start_tstamp') }}
        and a.dvce_sent_tstamp <= {{ snowplow_utils.timestamp_add('day', var("snowplow__days_late_allowed", 3), 'a.dvce_created_tstamp') }}
        and a.collector_tstamp >= {{ lower_limit }}
        and a.collector_tstamp <= {{ upper_limit }}
        and {{ snowplow_utils.app_id_filter(var("snowplow__app_id",[])) }}
        and {{ snowplow_ecommerce.event_name_filter(var("snowplow__ecommerce_event_names", "['snowplow_ecommerce_action']")) }}

),


{% if not var('snowplow__disable_ecommerce_user_context', false) -%}
    {{ snowplow_utils.get_sde_or_context(var('snowplow__atomic_schema', 'atomic'), var('snowplow__context_ecommerce_user'), lower_limit, upper_limit, 'ecommerce_user') }},
{%- endif %}
{% if not var('snowplow__disable_ecommerce_checkouts', false) -%}
    {{ snowplow_utils.get_sde_or_context(var('snowplow__atomic_schema', 'atomic'), var('snowplow__context_ecommerce_checkout_step'), lower_limit, upper_limit, 'checkout') }},
{%- endif %}
{% if not var('snowplow__disable_ecommerce_page_context', false) -%}
    {{ snowplow_utils.get_sde_or_context(var('snowplow__atomic_schema', 'atomic'), var('snowplow__context_ecommerce_page'), lower_limit, upper_limit, 'ecommerce_page') }},
{%- endif %}
{% if not var('snowplow__disable_ecommerce_transactions', false) -%}
    {{ snowplow_utils.get_sde_or_context(var('snowplow__atomic_schema', 'atomic'), var('snowplow__context_ecommerce_transaction'), lower_limit, upper_limit, 'transaction') }},
{%- endif %}
{% if not var('snowplow__disable_ecommerce_carts', false) -%}
    {{ snowplow_utils.get_sde_or_context(var('snowplow__atomic_schema', 'atomic'), var('snowplow__context_ecommerce_cart'), lower_limit, upper_limit, 'cart') }},
{%- endif %}

{{ snowplow_utils.get_sde_or_context(var('snowplow__atomic_schema', 'atomic'), var('snowplow__sde_ecommerce_action'), lower_limit, upper_limit, 'ecommerce_action', single_entity = false) }},

{{ snowplow_utils.get_sde_or_context(var('snowplow__atomic_schema', 'atomic'), var('snowplow__context_web_page'), lower_limit, upper_limit, 'page_view') }}


select ev.*,
    {% if var('snowplow__enable_mobile_events', false) %}
        coalesce(
            sv.mob_sc_view_id,
            pv.page_view_id
        ) as page_view_id,
    {% else %}
        pv.page_view_id,
    {% endif %}

    {% if var('snowplow__disable_ecommerce_user_context', false) -%}
        cast(NULL as {{ type_string() }}) as ecommerce_user_id,
        cast(NULL as {{ type_string() }}) as ecommerce_user_email,
        cast(NULL as {{ type_boolean() }}) as ecommerce_user_is_guest,
    {%- else -%}
        usr.ecommerce_user_id,
        usr.ecommerce_user_email,
        usr.ecommerce_user_is_guest,
    {%- endif %}

    -- unpacking the ecommerce checkout step object
    {% if var('snowplow__disable_ecommerce_checkouts', false) -%}
        cast(NULL as {{ type_int() }}) as checkout_step_number,
        cast(NULL as {{ type_string() }}) as checkout_account_type,
        cast(NULL as {{ type_string() }}) as checkout_billing_full_address,
        cast(NULL as {{ type_string() }}) as checkout_billing_postcode,
        cast(NULL as {{ type_string() }}) as checkout_coupon_code,
        cast(NULL as {{ type_string() }}) as checkout_delivery_method,
        cast(NULL as {{ type_string() }}) as checkout_delivery_provider,
        cast(NULL as {{ type_boolean() }}) as checkout_marketing_opt_in,
        cast(NULL as {{ type_string() }}) as checkout_payment_method,
        cast(NULL as {{ type_string() }}) as checkout_proof_of_payment,
        cast(NULL as {{ type_string() }}) as checkout_shipping_full_address,
        cast(NULL as {{ type_string() }}) as checkout_shipping_postcode,
    {%- else -%}
        checkout.checkout_step as checkout_step_number,
        checkout.checkout_account_type,
        checkout.checkout_billing_full_address,
        checkout.checkout_billing_postcode,
        checkout.checkout_coupon_code,
        checkout.checkout_delivery_method,
        checkout.checkout_delivery_provider,
        checkout.checkout_marketing_opt_in,
        checkout.checkout_payment_method,
        checkout.checkout_proof_of_payment,
        checkout.checkout_shipping_full_address,
        checkout.checkout_shipping_postcode,
    {%- endif %}

    -- unpacking the ecommerce page object
    {% if var('snowplow__disable_ecommerce_page_context', false) -%}
        CAST(NULL as {{ type_string() }}) as ecommerce_page_type,
        CAST(NULL as {{ type_string() }}) as ecommerce_page_language,
        CAST(NULL as {{ type_string() }}) as ecommerce_page_locale,
    {%- else -%}
        ecom_page.ecommerce_page_type,
        ecom_page.ecommerce_page_language,
        ecom_page.ecommerce_page_locale,
    {%- endif %}

    -- unpacking the ecommerce transaction object
    {% if var('snowplow__disable_ecommerce_transactions', false) -%}
        CAST(NULL AS {{ type_string() }}) as transaction_id,
        CAST(NULL AS {{ type_string() }}) as transaction_currency,
        CAST(NULL AS {{ type_string() }}) as transaction_payment_method,
        CAST(NULL AS decimal(9,2)) as transaction_revenue,
        CAST(NULL AS {{ type_int() }}) as transaction_total_quantity,
        CAST(NULL AS {{ type_boolean() }}) as transaction_credit_order,
        CAST(NULL AS decimal(9,2)) as transaction_discount_amount,
        CAST(NULL AS {{ type_string() }}) as transaction_discount_code,
        CAST(NULL AS decimal(9,2)) as transaction_shipping,
        CAST(NULL AS decimal(9,2)) as transaction_tax,
    {%- else -%}
        trans.transaction_transaction_id as transaction_id,
        trans.transaction_currency,
        trans.transaction_payment_method,
        trans.transaction_revenue,
        trans.transaction_total_quantity,
        trans.transaction_credit_order,
        trans.transaction_discount_amount,
        trans.transaction_discount_code,
        trans.transaction_shipping,
        trans.transaction_tax,
    {%- endif %}

    -- unpacking the ecommerce cart object
    {% if var('snowplow__disable_ecommerce_carts', false) -%}
        CAST(NULL AS {{ type_string() }}) as cart_id,
        CAST(NULL AS {{ type_string() }}) as cart_currency,
        CAST(NULL AS decimal(9,2)) as cart_total_value,
    {%- else -%}
        carts.cart_cart_id as cart_id,
        carts.cart_currency,
        carts.cart_total_value,
    {%- endif%}

    -- unpacking the ecommerce action object
    action.ecommerce_action_type,
    action.ecommerce_action_name,

    dense_rank() over (partition by domain_sessionid order by derived_tstamp) AS event_in_session_index

from events_this_run ev

{% if not var('snowplow__disable_ecommerce_user_context', false) -%}
    left join {{ var('snowplow__context_ecommerce_user') }} usr on ev.event_id = usr.ecommerce_user__id and ev.collector_tstamp = usr.ecommerce_user__tstamp
{%- endif %}
{% if not var('snowplow__disable_ecommerce_checkouts', false) -%}
    left join {{ var('snowplow__context_ecommerce_checkout_step') }} checkout on ev.event_id = checkout.checkout__id and ev.collector_tstamp = checkout.checkout__tstamp
{%- endif %}
{% if not var('snowplow__disable_ecommerce_page_context', false) -%}
    left join {{ var('snowplow__context_ecommerce_page') }} ecom_page on ev.event_id = ecom_page.ecommerce_page__id and ev.collector_tstamp = ecom_page.ecommerce_page__tstamp
{%- endif %}
{% if not var('snowplow__disable_ecommerce_transactions', false) -%}
    left join {{ var('snowplow__context_ecommerce_transaction') }} trans on ev.event_id = trans.transaction__id and ev.collector_tstamp = trans.transaction__tstamp
{%- endif %}
{% if not var('snowplow__disable_ecommerce_carts', false) -%}
    left join {{ var('snowplow__context_ecommerce_cart') }} carts on ev.event_id = carts.cart__id and ev.collector_tstamp = carts.cart__tstamp
{%- endif %}
    left join {{ var('snowplow__sde_ecommerce_action') }} action on ev.event_id = action.ecommerce_action__id and ev.collector_tstamp = action.ecommerce_action__tstamp
    left join {{ var('snowplow__context_web_page') }} pv on ev.event_id = pv.page_view__id and ev.collector_tstamp = pv.page_view__tstamp
{% if var('snowplow__enable_mobile_events', false) -%}
    left join {{ var('snowplow__context_screen') }} sv on ev.event_id = sv.mob_sc_view__id and ev.collector_tstamp = sv.mob_sc_view__tstamp
{%- endif %}
where
    ev.event_id_dedupe_index = 1

{#
Copyright (c) 2022-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{{
    config(
        materialized="incremental",
        unique_key='session_identifier',
        upsert_date_key='start_tstamp',
        partition_by = snowplow_utils.get_value_by_target_type(bigquery_val={
            "field": "start_tstamp",
            "data_type": "timestamp"
        }, databricks_val='start_tstamp_date'),
        cluster_by=snowplow_utils.get_value_by_target_type(bigquery_val=["session_identifier"], snowflake_val=["to_date(start_tstamp)"]),
        full_refresh=snowplow_ecommerce.allow_refresh(),
        tags=["manifest"],
        sql_header=snowplow_utils.set_query_tag(var('snowplow__query_tag', 'snowplow_dbt')),
        tblproperties={
            'delta.autoOptimize.optimizeWrite' : 'true',
            'delta.autoOptimize.autoCompact' : 'true'
        },
        snowplow_optimize=true
    )
}}

{% set sessions_lifecycle_manifest_query = snowplow_utils.base_create_snowplow_sessions_lifecycle_manifest(
    session_identifiers=session_identifiers(),
    session_sql=var('snowplow__session_sql', none),
    session_timestamp=var('snowplow__session_timestamp', 'collector_tstamp'),
    user_identifiers=user_identifiers(),
    user_sql=var('snowplow__user_sql', none),
    derived_tstamp_partitioned=var('snowplow__derived_tstamp_partitioned', true),
    days_late_allowed=var('snowplow__days_late_allowed', 3),
    max_session_days=var('snowplow__max_session_days', 3),
    app_ids=var('snowplow__app_id', []),
    snowplow_events_database=var('snowplow__database', target.database) if target.type not in ['databricks', 'spark'] else var('snowplow__databricks_catalog', 'hive_metastore') if target.type in ['databricks'] else none,
    snowplow_events_schema=var('snowplow__atomic_schema', 'atomic'),
    snowplow_events_table=var('snowplow__events_table', 'events'),
    event_limits_table='snowplow_ecommerce_base_new_event_limits',
    incremental_manifest_table='snowplow_ecommerce_incremental_manifest'
) %}

{{ sessions_lifecycle_manifest_query }}

where session_identifier is not null

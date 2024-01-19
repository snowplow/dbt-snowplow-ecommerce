{#
Copyright (c) 2022-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}


{% macro coalesce_columns_by_prefix(model_ref, col_prefix) %}
    {% set all_column_objs = snowplow_utils.get_columns_in_relation_by_column_prefix(model_ref, col_prefix) %}
    {% set all_column_names = all_column_objs|map(attribute='name')|list %}
    {% set joined_paths = all_column_names|join(', ') %}
    {% set coalesced_field_paths = 'coalesce('~joined_paths~')' %}

    {{ return(coalesced_field_paths) }}
{% endmacro %}

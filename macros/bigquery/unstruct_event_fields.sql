{#
Copyright (c) 2022-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}


{% macro tracking_action_fields() %}

  {% set tracking_action_fields = [
      {'field': ('type', 'ecommerce_action_type'), 'dtype': 'string'},
      {'field': ('name', 'ecommerce_action_name'), 'dtype': 'string'},
    ] %}

  {{ return(tracking_action_fields) }}

{% endmacro %}

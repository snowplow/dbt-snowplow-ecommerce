
{% macro tracking_action_fields() %}

  {% set tracking_action_fields = [
      {'field': ('type', 'ecommerce_action_type'), 'dtype': 'string'},
      {'field': ('name', 'ecommerce_action_name'), 'dtype': 'string'},
    ] %}

  {{ return(tracking_action_fields) }}

{% endmacro %}

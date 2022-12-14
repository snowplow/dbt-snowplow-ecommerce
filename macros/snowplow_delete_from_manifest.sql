{% macro snowplow_ecommerce_delete_from_manifest(models) %}
    {{ snowplow_utils.snowplow_delete_from_manifest(models, ref('snowplow_ecommerce_incremental_manifest'))}}
{% endmacro %}

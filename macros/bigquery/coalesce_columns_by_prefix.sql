
{% macro coalesce_columns_by_prefix(model_ref, col_prefix) %}
    {% set all_column_objs = snowplow_utils.get_columns_in_relation_by_column_prefix(model_ref, col_prefix) %}
    {% set all_column_names = all_column_objs|map(attribute='name')|list %}
    {% set joined_paths = all_column_names|join(', ') %}
    {% set coalesced_field_paths = 'coalesce('~joined_paths~')' %}

    {{ return(coalesced_field_paths) }}
{% endmacro %}

{#
Copyright (c) 2022-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}


{% if target.type in ('databricks','spark') %}
SELECT {{ dbt_utils.star(from=ref('snowplow_ecommerce_product_interactions'), except=['derived_tstamp_date'] )}},
date(derived_tstamp_date) as derived_tstamp_date
{% else %}
SELECT {{ dbt_utils.star(from=ref('snowplow_ecommerce_product_interactions')) }}
{% endif %}
from {{ ref('snowplow_ecommerce_product_interactions') }}



select *

from {{ ref('snowplow_ecommerce_checkout_interactions_expected') }}


select *

from {{ ref('snowplow_ecommerce_product_interactions') }}


select *

from {{ ref('snowplow_ecommerce_cart_interactions') }}


select *

from {{ ref('snowplow_ecommerce_transaction_interactions') }}

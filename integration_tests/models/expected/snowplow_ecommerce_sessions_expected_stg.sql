
select *

from {{ ref('snowplow_ecommerce_sessions_expected') }}

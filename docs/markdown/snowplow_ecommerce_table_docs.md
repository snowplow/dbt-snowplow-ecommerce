{% docs table_cart_interactions_this_run %}

This staging table tracks and stores information about cart interactions that occurred within the current run, with interactions being when a user adds or removes an item from their cart. It possesses all of the same columns as `snowplow_ecommerce_cart_interactions`. If building a custom module that requires cart interactions, this is the table you should reference for that information.

{% enddocs %}


{% docs table_cart_interactions %}

This derived incremental table contains all historic cart interactions and should be the end point for any analysis or BI tools.

{% enddocs %}


{% docs table_ecommerce_sessions %}

This derived incremental table contains all historic sessions data specifically for ecommerce actions and should be the end point for any analysis or BI tools.

{% enddocs %}


{% docs table_ecommerce_sessions_this_run %}

This staging table tracks and stores aggregate information about sessions that occurred within the current run. It possesses all of the same columns as `snowplow_ecommerce_sessions`. If building a custom module that requires session level data, this is the table you should reference for that information.

{% enddocs %}


{% docs table_checkout_interactions_this_run %}

This staging table tracks and stores information about checkout interactions that occurred within the current run, with interactions being when a user progresses through the checkout flow or completes a transaction. It possesses all of the same columns as `snowplow_ecommerce_checkout_interactions`. If building a custom module that requires checkout interactions, this is the table you should reference for that information.

{% enddocs %}


{% docs table_checkout_interactions %}

This derived incremental table contains all historic checkout interactions and should be the end point for any analysis or BI tools.

{% enddocs %}


{% docs table_product_interactions_this_run %}

This staging table tracks and stores information about product interactions that occurred within the current run, such as a user viewing a product on a product page, or in a product list. It possesses all of the same columns as `snowplow_ecommerce_product_interactions`. If building a custom module that requires checkout interactions, this is the table you should reference for that information.

{% enddocs %}


{% docs table_product_interactions %}

This derived incremental table contains all historic product interactions and should be the end point for any analysis or BI tools.

{% enddocs %}


{% docs table_transaction_interactions_this_run %}

This staging table tracks and stores information about transaction interactions that occurred within the current run, with interactions being when a user completes a transaction. It possesses all of the same columns as `snowplow_ecommerce_transaction_interactions`. If building a custom module that requires checkout interactions, this is the table you should reference for that information.

{% enddocs %}


{% docs table_transaction_interactions %}

This derived incremental table contains all historic transaction interactions and should be the end point for any analysis or BI tools.

{% enddocs %}

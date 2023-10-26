{% macro user_fields() %}

  {% set user_fields = [
      {'field':('id', 'ecommerce_user_id'), 'dtype':'string'},
      {'field':('email', 'ecommerce_user_email'), 'dtype':'string'},
      {'field':('is_guest', 'ecommerce_user_is_guest'), 'dtype':'boolean'}
    ] %}

  {{ return(user_fields) }}

{% endmacro %}

{% macro checkout_step_fields() %}

  {% set checkout_step_fields = [
      {'field': ('step', 'checkout_step_number'), 'dtype': 'integer'},
      {'field': ('account_type', 'checkout_account_type'), 'dtype': 'string'},
      {'field': ('billing_full_address', 'checkout_billing_full_address'), 'dtype': 'string'},
      {'field': ('billing_postcode', 'checkout_billing_postcode'), 'dtype': 'string'},
      {'field': ('coupon_code', 'checkout_coupon_code'), 'dtype': 'string'},
      {'field': ('delivery_method', 'checkout_delivery_method'), 'dtype': 'string'},
      {'field': ('delivery_provider', 'checkout_delivery_provider'), 'dtype': 'string'},
      {'field': ('marketing_opt_in', 'checkout_marketing_opt_in'), 'dtype': 'boolean'},
      {'field': ('payment_method', 'checkout_payment_method'), 'dtype': 'string'},
      {'field': ('proof_of_payment', 'checkout_proof_of_payment'), 'dtype': 'string'},
      {'field': ('shipping_full_address', 'checkout_shipping_full_address'), 'dtype': 'string'},
      {'field': ('shipping_postcode', 'checkout_shipping_postcode'), 'dtype': 'string'}
    ] %}

  {{ return(checkout_step_fields) }}

{% endmacro %}

{% macro tracking_page_fields() %}

  {% set tracking_page_fields = [
      {'field': ('type', 'ecommerce_page_type'), 'dtype': 'string'},
      {'field': ('language', 'ecommerce_page_language'), 'dtype': 'string'},
      {'field': ('locale', 'ecommerce_page_locale'), 'dtype': 'string'},
    ] %}

  {{ return(tracking_page_fields) }}

{% endmacro %}

{% macro transaction_fields() %}

  {% set transaction_fields = [
      {'field': 'transaction_id', 'dtype': 'string'},
      {'field': ('currency', 'transaction_currency'), 'dtype': 'string'},
      {'field': ('payment_method', 'transaction_payment_method'), 'dtype': 'string'},
      {'field': ('revenue', 'transaction_revenue'), 'dtype': 'numeric'},
      {'field': ('total_quantity', 'transaction_total_quantity'), 'dtype': 'integer'},
      {'field': ('credit_order', 'transaction_credit_order'), 'dtype': 'boolean'},
      {'field': ('discount_amount', 'transaction_discount_amount'), 'dtype': 'numeric'},
      {'field': ('discount_code', 'transaction_discount_code'), 'dtype': 'string'},
      {'field': ('shipping', 'transaction_shipping'), 'dtype': 'numeric'},
      {'field': ('tax', 'transaction_tax'), 'dtype': 'numeric'},
    ] %}

  {{ return(transaction_fields) }}

{% endmacro %}

{% macro cart_fields() %}

  {% set cart_fields = [
      {'field': 'cart_id', 'dtype': 'string'},
      {'field': ('currency', 'cart_currency'), 'dtype': 'string'},
      {'field': ('total_value', 'cart_total_value'), 'dtype': 'numeric'},
    ] %}

  {{ return(cart_fields) }}

{% endmacro %}

{% macro page_view_fields() %}

  {% set page_view_fields = [
      {'field': ('id', 'page_view_id'), 'dtype': 'string'},
    ] %}

  {{ return(page_view_fields) }}

{% endmacro %}

{% macro mobile_session_context_fields()  %}

    {% set mobile_session_context_fields = [
      {'field': 'event_index', 'dtype': 'numeric'},
      {'field': 'first_event_id', 'dtype': 'string'},
      {'field': 'first_event_timestamp', 'dtype': 'timestamp'},
      {'field': 'previous_session_id', 'dtype': 'string'},
      {'field': 'session_id', 'dtype': 'string'},
      {'field': 'session_index', 'dtype': 'numeric'},
      {'field': 'storage_mechanism', 'dtype': 'string'},
      {'field': ('user_id', 'mobile_user_id'), 'dtype': 'string'},
    ] %}

  {{ return(mobile_session_context_fields) }}

{% endmacro %}

{% macro mobile_screen_view_context_fields()  %}

    {% set mobile_screen_view_context_fields = [
      {'field': 'id', 'dtype': 'string'},
      {'field': 'name', 'dtype': 'string'},
    ] %}

  {{ return(mobile_screen_view_context_fields) }}

{% endmacro %}

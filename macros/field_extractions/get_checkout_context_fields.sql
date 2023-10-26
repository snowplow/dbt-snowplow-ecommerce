{% macro get_checkout_context_fields() %}
    {{ return(adapter.dispatch('get_checkout_context_fields', 'snowplow_ecommerce')()) }}
{%- endmacro -%}

{% macro postgres__get_checkout_context_fields() %}
    {% if var('snowplow__disable_ecommerce_checkouts', false) %}
        , cast(NULL as {{ type_int() }}) as checkout_step_number
        , cast(NULL as {{ type_string() }}) as checkout_account_type
        , cast(NULL as {{ type_string() }}) as checkout_billing_full_address
        , cast(NULL as {{ type_string() }}) as checkout_billing_postcode
        , cast(NULL as {{ type_string() }}) as checkout_coupon_code
        , cast(NULL as {{ type_string() }}) as checkout_delivery_method
        , cast(NULL as {{ type_string() }}) as checkout_delivery_provider
        , cast(NULL as {{ type_boolean() }}) as checkout_marketing_opt_in
        , cast(NULL as {{ type_string() }}) as checkout_payment_method
        , cast(NULL as {{ type_string() }}) as checkout_proof_of_payment
        , cast(NULL as {{ type_string() }}) as checkout_shipping_full_address
        , cast(NULL as {{ type_string() }}) as checkout_shipping_postcode
    {% else %}
        , checkout__step as checkout_step_number
        , checkout__account_type as checkout_account_type
        , checkout__billing_full_address as checkout_billing_full_address
        , checkout__billing_postcode as checkout_billing_postcode
        , checkout__coupon_code as checkout_coupon_code
        , checkout__delivery_method as checkout_delivery_method
        , checkout__delivery_provider as checkout_delivery_provider
        , checkout__marketing_opt_in as checkout_marketing_opt_in
        , checkout__payment_method as checkout_payment_method
        , checkout__proof_of_payment as checkout_proof_of_payment
        , checkout__shipping_full_address as checkout_shipping_full_address
        , checkout__shipping_postcode as checkout_shipping_postcode
    {% endif %}
{% endmacro %}

{% macro bigquery__get_checkout_context_fields() %}

    {% if var('snowplow__disable_ecommerce_checkouts', false) %}
        , cast(NULL as {{ type_int() }}) as checkout_step_number
        , cast(NULL as {{ type_string() }}) as checkout_account_type
        , cast(NULL as {{ type_string() }}) as checkout_billing_full_address
        , cast(NULL as {{ type_string() }}) as checkout_billing_postcode
        , cast(NULL as {{ type_string() }}) as checkout_coupon_code
        , cast(NULL as {{ type_string() }}) as checkout_delivery_method
        , cast(NULL as {{ type_string() }}) as checkout_delivery_provider
        , cast(NULL as {{ type_boolean() }}) as checkout_marketing_opt_in
        , cast(NULL as {{ type_string() }}) as checkout_payment_method
        , cast(NULL as {{ type_string() }}) as checkout_proof_of_payment
        , cast(NULL as {{ type_string() }}) as checkout_shipping_full_address
        , cast(NULL as {{ type_string() }}) as checkout_shipping_postcode
    {% else %}
        ,{{ snowplow_utils.get_optional_fields(
            enabled=true,
            fields=checkout_step_fields(),
            col_prefix='contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1_',
            relation=source('atomic', 'events') if project_name != 'snowplow_ecommerce_integration_tests' else ref('snowplow_ecommerce_events_stg'),
            relation_alias=none) }}
    {% endif %}
{% endmacro %}

{% macro spark__get_checkout_context_fields() %}
    {% if var('snowplow__disable_ecommerce_checkouts', false) %}
        , cast(NULL as {{ type_int() }}) as checkout_step_number
        , cast(NULL as {{ type_string() }}) as checkout_account_type
        , cast(NULL as {{ type_string() }}) as checkout_billing_full_address
        , cast(NULL as {{ type_string() }}) as checkout_billing_postcode
        , cast(NULL as {{ type_string() }}) as checkout_coupon_code
        , cast(NULL as {{ type_string() }}) as checkout_delivery_method
        , cast(NULL as {{ type_string() }}) as checkout_delivery_provider
        , cast(NULL as {{ type_boolean() }}) as checkout_marketing_opt_in
        , cast(NULL as {{ type_string() }}) as checkout_payment_method
        , cast(NULL as {{ type_string() }}) as checkout_proof_of_payment
        , cast(NULL as {{ type_string() }}) as checkout_shipping_full_address
        , cast(NULL as {{ type_string() }}) as checkout_shipping_postcode
    {% else %}
        , contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1[0].step::int as checkout_step_number
        , contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1[0].account_type::string as checkout_account_type
        , contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1[0].billing_full_address::string as checkout_billing_full_address
        , contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1[0].billing_postcode::string as checkout_billing_postcode
        , contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1[0].coupon_code::string as checkout_coupon_code
        , contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1[0].delivery_method::string as checkout_delivery_method
        , contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1[0].delivery_provider::string as checkout_delivery_provider
        , contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1[0].marketing_opt_in::boolean as checkout_marketing_opt_in
        , contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1[0].payment_method::string as checkout_payment_method
        , contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1[0].proof_of_payment::string as checkout_proof_of_payment
        , contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1[0].shipping_full_address::string as checkout_shipping_full_address
        , contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1[0].shipping_postcode::string as checkout_shipping_postcode
    {% endif %}
{% endmacro %}

{% macro snowflake__get_checkout_context_fields() %}
    {% if var('snowplow__disable_ecommerce_checkouts', false) %}
        , cast(NULL as {{ type_int() }}) as checkout_step_number
        , cast(NULL as {{ type_string() }}) as checkout_account_type
        , cast(NULL as {{ type_string() }}) as checkout_billing_full_address
        , cast(NULL as {{ type_string() }}) as checkout_billing_postcode
        , cast(NULL as {{ type_string() }}) as checkout_coupon_code
        , cast(NULL as {{ type_string() }}) as checkout_delivery_method
        , cast(NULL as {{ type_string() }}) as checkout_delivery_provider
        , cast(NULL as {{ type_boolean() }}) as checkout_marketing_opt_in
        , cast(NULL as {{ type_string() }}) as checkout_payment_method
        , cast(NULL as {{ type_string() }}) as checkout_proof_of_payment
        , cast(NULL as {{ type_string() }}) as checkout_shipping_full_address
        , cast(NULL as {{ type_string() }}) as checkout_shipping_postcode
    {% else %}
        , contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1[0]:step::int as checkout_step_number
        , contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1[0]:accountType::varchar as checkout_account_type
        , contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1[0]:billingFullAddress::varchar as checkout_billing_full_address
        , contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1[0]:billingPostcode::varchar as checkout_billing_postcode
        , contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1[0]:couponCode::varchar as checkout_coupon_code
        , contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1[0]:deliveryMethod::varchar as checkout_delivery_method
        , contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1[0]:deliveryProvider::varchar as checkout_delivery_provider
        , contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1[0]:marketingOptIn::boolean as checkout_marketing_opt_in
        , contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1[0]:paymentMethod::varchar as checkout_payment_method
        , contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1[0]:proofOfPayment::varchar as checkout_proof_of_payment
        , contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1[0]:shippingFullAddress::varchar as checkout_shipping_full_address
        , contexts_com_snowplowanalytics_snowplow_ecommerce_checkout_step_1[0]:shippingPostcode::varchar as checkout_shipping_postcode
    {% endif %}
{% endmacro %}

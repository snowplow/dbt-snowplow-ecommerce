# snowplow-web-integration-tests

Integration test suite for the snowplow-ecommerce dbt package.

The `./scripts` directory contains one script:

- `integration_tests.sh`: This tests the standard modules of the snowplow-ecommerce package. It runs the Snowplow E-commerce package 4 times to replicate incremental loading of events, then performs an equality test between the actual vs expected output.

Run the scripts using:

```bash
bash integration_tests.sh -d {warehouse}
```

Supported warehouses:

- bigquery
- snowflake
- all (iterates through all supported warehouses)

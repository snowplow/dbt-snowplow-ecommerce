#!/bin/bash

# Expected input:
# -d (database) target database for dbt

while getopts 'd:' opt
do
  case $opt in
    d) DATABASE=$OPTARG
  esac
done

declare -a SUPPORTED_DATABASES=("bigquery" "postgres" "databricks" "snowflake", "spark_iceberg")

# set to lower case
DATABASE="$(echo $DATABASE | tr '[:upper:]' '[:lower:]')"

if [[ $DATABASE == "all" ]]; then
  DATABASES=( "${SUPPORTED_DATABASES[@]}" )
else
  DATABASES=$DATABASE
fi

for db in ${DATABASES[@]}; do

  echo "Snowplow e-commerce integration tests: Seeding data"

  eval "dbt seed --full-refresh --target $db" || exit 1;

  echo "Snowplow e-commerce integration tests: Execute models (no mobile) - run 0/4"

  eval "dbt run --full-refresh --vars '{snowplow__allow_refresh: true, snowplow__backfill_limit_days: 30, snowplow__enable_mobile_events: false}' --target $db" || exit 1;

  echo "Snowplow e-commerce integration tests: Execute models - run 1/4"

  eval "dbt run --full-refresh --vars '{snowplow__allow_refresh: true, snowplow__backfill_limit_days: 30}' --target $db" || exit 1;

  for i in {2..4}
  do
    echo "Snowplow e-commerce integration tests: Execute models - run $i/4"

    eval "dbt run --target $db" || exit 1;
  done

  echo "Snowplow e-commerce integration tests: Test models"

  eval "dbt test --store-failures --target $db" || exit 1;

  echo "Snowplow e-commerce integration tests: All tests passed"

done

[![early-release]][tracker-classification]
[![Release][release-image]][releases]
[![License][license-image]][license]
[![Discourse posts][discourse-image]][discourse]

![snowplow-logo](https://raw.githubusercontent.com/snowplow/dbt-snowplow-utils/main/assets/snowplow_logo.png)

# Snowplow E-Commerce

This dbt package:

- Transforms and aggregates raw web e-commerce event data collected from the [Snowplow JavaScript tracker][tracker-docs] into a set of derived tables based around the following e-commerce data objects: carts, checkouts, products and transactions.
- Processes **all e-commerce events incrementally**. It is not just constrained to out-of-the-box events - any custom events you are tracking will also be incrementally processed.
- Is designed in a modular manner, allowing you to easily integrate your own custom SQL into the incremental framework provided by the package.

Please refer to the [doc site][snowplow-ecommerce-docs] for a full breakdown of the package.

### Adapter Support

The snowplow-ecommerce v0.1.0 package currently supports BigQuery. Future support is expected for Databricks, Redshift, Snowflake & Postgres.

| Warehouse | dbt versions | snowplow-ecommerce version |
| :--------------------------------------------------: | :-----------------: | :------------------: |
| BigQuery | >=1.0.0 to <2.0.0 | 0.1.0 |

### Requirements

- A dataset of web events from the [Snowplow JavaScript tracker][tracker-docs] must be available in the database.
- Have the [`webPage` context][webpage-context] enabled.
- Have the following e-commerce contexts enabled: user, checkout_step, page, transaction, cart
- Track the e-commerce tracking action events on your website

### Installation

Check dbt Hub for the latest installation instructions, or read the [dbt docs][dbt-package-docs] for more information on installing packages.

### Configuration & Operation

Please refer to the [doc site][snowplow-ecommerce-docs] for details on how to configure and run the package.

### Models

The package contains multiple staging models however the mart models are as follows:

| Model                     | Description                                                                                |
| ------------------------- | ------------------------------------------------------------------------------------------ |
| snowplow_ecommerce_cart_interactions | A table that provides insights into actions that occurred with carts, such as adding and removing to cart. |
| snowplow_ecommerce_sessions | A table that provides insights into all of the e-commerce interactions that a occurred during a session as defined by the `domain_sessionid`. |
| snowplow_ecommerce_checkout_interactions | A table that provides insights into the checkout steps that were stepped through, including information that was filled out throughout the process  |
| snowplow_ecommerce_product_interactions | A table that provides information into the products that were viewed, either on product pages or in product lists, and how those products were later interacted with, e.g. through adding to cart. |
| snowplow_ecommerce_transaction_interactions | A table that provides insights into which transactions transpired, their value, how many products they contained, etc. |

# Join the Snowplow community

We welcome all ideas, questions and contributions!

For support requests, please use our community support [Discourse][discourse] forum.

If you find a bug, please report an issue on GitHub.

# Copyright and license

The snowplow-ecommerce package is Copyright 2022 Snowplow Analytics Ltd.

Licensed under the [Apache License, Version 2.0][license] (the "License");
you may not use this software except in compliance with the License.

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

[license]: http://www.apache.org/licenses/LICENSE-2.0
[license-image]: http://img.shields.io/badge/license-Apache--2-blue.svg?style=flat

[website]: https://snowplow.io/
[snowplow]: https://github.com/snowplow/snowplow
[docs]: https://docs.snowplow.io/

[release-image]: https://img.shields.io/github/v/release/snowplow/dbt-snowplow-ecommerce?sort=semver
[releases]: https://github.com/snowplow/dbt-snowplow-ecommerce/releases

[tracker-classification]: https://docs.snowplow.io/docs/collecting-data/collecting-from-own-applications/tracker-maintenance-classification/
[early-release]: https://img.shields.io/static/v1?style=flat&label=Snowplow&message=Early%20Release&color=014477&labelColor=9ba0aa&logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAAAeFBMVEVMaXGXANeYANeXANZbAJmXANeUANSQAM+XANeMAMpaAJhZAJeZANiXANaXANaOAM2WANVnAKWXANZ9ALtmAKVaAJmXANZaAJlXAJZdAJxaAJlZAJdbAJlbAJmQAM+UANKZANhhAJ+EAL+BAL9oAKZnAKVjAKF1ALNBd8J1AAAAKHRSTlMAa1hWXyteBTQJIEwRgUh2JjJon21wcBgNfmc+JlOBQjwezWF2l5dXzkW3/wAAAHpJREFUeNokhQOCA1EAxTL85hi7dXv/E5YPCYBq5DeN4pcqV1XbtW/xTVMIMAZE0cBHEaZhBmIQwCFofeprPUHqjmD/+7peztd62dWQRkvrQayXkn01f/gWp2CrxfjY7rcZ5V7DEMDQgmEozFpZqLUYDsNwOqbnMLwPAJEwCopZxKttAAAAAElFTkSuQmCC
[unsupported]: https://img.shields.io/static/v1?style=flat&label=Snowplow&message=Unsupported&color=24292e&labelColor=lightgrey&logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAAAeFBMVEVMaXGXANeYANeXANZbAJmXANeUANSQAM+XANeMAMpaAJhZAJeZANiXANaXANaOAM2WANVnAKWXANZ9ALtmAKVaAJmXANZaAJlXAJZdAJxaAJlZAJdbAJlbAJmQAM+UANKZANhhAJ+EAL+BAL9oAKZnAKVjAKF1ALNBd8J1AAAAKHRSTlMAa1hWXyteBTQJIEwRgUh2JjJon21wcBgNfmc+JlOBQjwezWF2l5dXzkW3/wAAAHpJREFUeNokhQOCA1EAxTL85hi7dXv/E5YPCYBq5DeN4pcqV1XbtW/xTVMIMAZE0cBHEaZhBmIQwCFofeprPUHqjmD/+7peztd62dWQRkvrQayXkn01f/gWp2CrxfjY7rcZ5V7DEMDQgmEozFpZqLUYDsNwOqbnMLwPAJEwCopZxKttAAAAAElFTkSuQmCC
[maintained]: https://img.shields.io/static/v1?style=flat&label=Snowplow&message=Maintained&color=9e62dd&labelColor=9ba0aa&logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAAAeFBMVEVMaXGXANeYANeXANZbAJmXANeUANSQAM+XANeMAMpaAJhZAJeZANiXANaXANaOAM2WANVnAKWXANZ9ALtmAKVaAJmXANZaAJlXAJZdAJxaAJlZAJdbAJlbAJmQAM+UANKZANhhAJ+EAL+BAL9oAKZnAKVjAKF1ALNBd8J1AAAAKHRSTlMAa1hWXyteBTQJIEwRgUh2JjJon21wcBgNfmc+JlOBQjwezWF2l5dXzkW3/wAAAHpJREFUeNokhQOCA1EAxTL85hi7dXv/E5YPCYBq5DeN4pcqV1XbtW/xTVMIMAZE0cBHEaZhBmIQwCFofeprPUHqjmD/+7peztd62dWQRkvrQayXkn01f/gWp2CrxfjY7rcZ5V7DEMDQgmEozFpZqLUYDsNwOqbnMLwPAJEwCopZxKttAAAAAElFTkSuQmCC
[actively-maintained]: https://img.shields.io/static/v1?style=flat&label=Snowplow&message=Actively%20Maintained&color=6638b8&labelColor=9ba0aa&logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAAAeFBMVEVMaXGXANeYANeXANZbAJmXANeUANSQAM+XANeMAMpaAJhZAJeZANiXANaXANaOAM2WANVnAKWXANZ9ALtmAKVaAJmXANZaAJlXAJZdAJxaAJlZAJdbAJlbAJmQAM+UANKZANhhAJ+EAL+BAL9oAKZnAKVjAKF1ALNBd8J1AAAAKHRSTlMAa1hWXyteBTQJIEwRgUh2JjJon21wcBgNfmc+JlOBQjwezWF2l5dXzkW3/wAAAHpJREFUeNokhQOCA1EAxTL85hi7dXv/E5YPCYBq5DeN4pcqV1XbtW/xTVMIMAZE0cBHEaZhBmIQwCFofeprPUHqjmD/+7peztd62dWQRkvrQayXkn01f/gWp2CrxfjY7rcZ5V7DEMDQgmEozFpZqLUYDsNwOqbnMLwPAJEwCopZxKttAAAAAElFTkSuQmCC

[tracker-docs]: https://docs.snowplow.io/docs/collecting-data/collecting-from-own-applications/
[webpage-context]: https://docs.snowplow.io/docs/collecting-data/collecting-from-own-applications/javascript-trackers/javascript-tracker/javascript-tracker-v3/tracker-setup/initialization-options/#Adding_predefined_contexts
[dbt-package-docs]: https://docs.getdbt.com/docs/building-a-dbt-project/package-management

[snowplow-ecommerce-docs-dbt]: https://snowplow.github.io/dbt-snowplow-ecommerce/#!/overview/snowplow_ecommerce
[snowplow-ecommerce-docs]: https://docs.snowplow.io/docs/modeling-your-data/modeling-your-data-with-dbt/
[discourse-image]: https://img.shields.io/discourse/posts?server=https%3A%2F%2Fdiscourse.snowplow.io%2F
[discourse]: http://discourse.snowplow.io/

WooCommerce API - Nim Client
===============================

A Nim wrapper for the WooCommerce REST API. Easily interact with the WooCommerce REST API using this library.

Installation
------------

.. code-block:: bash

    nimble install woocommerce

Getting started
---------------

Generate API credentials (Consumer Key & Consumer Secret) following this instructions http://woocommerce.github.io/woocommerce-rest-api-docs/#rest-api-keys.

Check out the WooCommerce API endpoints and data that can be manipulated in http://woocommerce.github.io/woocommerce-rest-api-docs/.

Setup
-----

.. code-block:: nim

    import woocommerce/AsyncAPI

    let wcapi = await API(
        url="http://example.com",
        consumer_key="ck_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
        consumer_secret="cs_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
    )

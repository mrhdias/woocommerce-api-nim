WooCommerce API - Nim Client
===============================

A [Nim](https://nim-lang.org/) wrapper for the [WooCommerce REST API](http://woocommerce.github.io/woocommerce-rest-api-docs/). Easily interact with the WooCommerce REST API using this library.

Installation
------------

```bash
git clone https://github.com/mrhdias/woocommerce-api-nim
cd woocommerce-api-nim
nimble install
```

Getting started
---------------

Generate API credentials (Consumer Key & Consumer Secret) following this instructions http://woocommerce.github.io/woocommerce-rest-api-docs/#rest-api-keys.

Check out the WooCommerce API endpoints and data that can be manipulated in http://woocommerce.github.io/woocommerce-rest-api-docs/.

Setup
-----

* Synchronous API
```nim
import woocommerce/API

let wcapi = API(
    url="http://example.com", # Your store URL
    consumer_key="ck_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", # Your consumer key
    consumer_secret="cs_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" # Your consumer secret
)
```

* Asynchronous API
```nim
import woocommerce/API

let wcapi = AsyncAPI(
    url="http://example.com",
    consumer_key="ck_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
    consumer_secret="cs_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
)
```
Methods
-------

Params       | Type         | Description
------------ | ------------ | ------------
``endpoint`` | ``string`` | WooCommerce API endpoint, example: ``products`` or ``order/12``
``data`` | ``string`` | JSON data stringified
``params`` | ``Table[string, string]`` | Accepts ``params`` to be passed as a query string


* GET
```nim
# Retrieve
wcapi.get(endpoint: string; params: Table) # params is optional
```
* POST
```nim
# Create
wcapi.post(endpoint: string, data: string)
```
* PUT
```nim
# Update
wcapi.put(endpoint: string, data: string)
```
* DELETE
```nim
# Delete
wcapi.delete(endpoint: string; params: Table) # params is optional
```
* OPTIONS
```nim
# JSON Schema
wcapi.options(endpoint: string)
```

Response
--------

All methods will return [Response](https://nim-lang.org/docs/httpclient.html#Response) / [AsyncResponse](https://nim-lang.org/docs/httpclient.html#AsyncResponse) object.

Example of returned data for asynchronous API:

```nim
import woocommerce/API
import asyncdispatch
import tables
import json

proc main() {.async.} =
    let wcapi = AsyncAPI(
        url="http://example.com",
        consumer_key="ck_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
        consumer_secret="cs_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
    )

    response = await wcapi.get("products?status=publish&per_page=10&page=1")
    echo response.status
    if response.status == "200 OK":
        let products = parseJson(response.body)
        for product in products:
            echo "SKU:", product["sku"], " NAME:", product["name"]

    wcapi.close()

waitFor main()
```

Request with `params` example
-----------------------------

```nim
import woocommerce/API
import asyncdispatch
import tables
import json

proc main() {.async.} =
    let wcapi = AsyncAPI(
        url="http://example.com",
        consumer_key="ck_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
        consumer_secret="cs_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
    )

    response = await wcapi.get(
        "products",
        params = {"status": "publish", "per_page": $(10), "page": $(2)}.toTable
    )
    echo response.status
    if response.status == "200 OK":
        let products = parseJson(response.body)
        for product in products:
            echo "SKU:", product["sku"], " NAME:", product["name"]

    wcapi.close()

waitFor main()
```

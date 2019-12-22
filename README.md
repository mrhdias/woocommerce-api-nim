WooCommerce API - Nim Client
===============================

A Nim wrapper for the WooCommerce REST API. Easily interact with the WooCommerce REST API using this library.

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
    url="http://example.com",
    consumer_key="ck_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
    consumer_secret="cs_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
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
        let products = parseJson(await response.body)
        for product in products:
            echo "SKU:", product["sku"], " NAME:", product["name"]

    wcapi.close()

waitFor main()
```

Request with `params` example
-----------------------------

```nim
import woocommerce/API
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
        let products = parseJson(await response.body)
        for product in products:
            echo "SKU:", product["sku"], " NAME:", product["name"]

    wcapi.close()

waitFor main()
```

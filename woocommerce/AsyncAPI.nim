#
# References:
# http://woocommerce.github.io/woocommerce-rest-api-docs/
# https://pypi.org/project/WooCommerce/
# https://github.com/woocommerce/wc-api-php/blob/master/src/WooCommerce/Client.php
#

import strutils
import base64
import asyncdispatch
import httpclient
import json
import tables
import strformat

export asyncdispatch
export httpclient

type
    WCAPI = ref object
        url: string
        client: AsyncHttpClient

proc API*(url, consumer_key, consumer_secret: string): Future[WCAPI] {.async.} =

    let basic = join(["Basic", encode(join([consumer_key, consumer_secret], ":"))], " ")
    let client = newAsyncHttpClient()
    client.headers = newHttpHeaders({
        "User-Agent": &"WooCommerce API - {defUserAgent}",
        "Authorization": basic
    })

    return WCAPI(url: url, client: client)

proc close*(wcapi: WCAPI) =
    wcapi.client.close()


proc params_to_query_string(params: Table): string =
    var parts = newSeq[string]()
    for key, value in params:
        parts.add(join([key, value], "="))

    return if parts.len > 0: join(parts, "&") else: ""

#
# Retrieve
#
proc get*(wcapi: WCAPI, endpoint: string, params: Table = initTable[string, string]()): Future[AsyncResponse] {.async.} =
    let query_string = params_to_query_string(params)
    let response = await wcapi.client.request(
        join([wcapi.url, "wp-json/wc/v3", if query_string.len > 0: join([endpoint, query_string], "?") else: endpoint], "/"),
        httpMethod = HttpGet
    )
    return response

#
# Create
#
proc post*(wcapi: WCAPI, endpoint: string, data: string): Future[AsyncResponse] {.async.} =
    wcapi.client.headers.add("Content-Type", "application/json; charset=UTF-8")
    let response = await wcapi.client.request(
        join([wcapi.url, "wp-json/wc/v3", endpoint], "/"),
        httpMethod = HttpPost,
        body = data
    )
    return response

#
# Update
#
proc put*(wcapi: WCAPI, endpoint: string, data: string): Future[AsyncResponse] {.async.} =
    wcapi.client.headers.add("Content-Type", "application/json; charset=UTF-8")
    let response = await wcapi.client.request(
        join([wcapi.url, "wp-json/wc/v3", endpoint], "/"),
        httpMethod = HttpPut,
        body = data
    )
    return response


#
# Delete
#
proc delete*(wcapi: WCAPI, endpoint: string, params: Table = initTable[string, string]()): Future[AsyncResponse] {.async.} =
    let query_string = params_to_query_string(params)
    let response = await wcapi.client.request(
        join([wcapi.url, "wp-json/wc/v3", if query_string.len > 0: join([endpoint, query_string], "?") else: endpoint], "/"),
        httpMethod = HttpDelete
    )
    return response

#
# JSON Schema
#
proc options*(wcapi: WCAPI, endpoint: string): Future[AsyncResponse] {.async.} =
    let response = await wcapi.client.request(
        join([wcapi.url, "wp-json/wc/v3", endpoint], "/"),
        httpMethod = HttpOptions
    )
    return response

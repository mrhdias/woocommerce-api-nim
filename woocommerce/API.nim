#
# References:
# http://woocommerce.github.io/woocommerce-rest-api-docs/
# https://pypi.org/project/WooCommerce/
# https://github.com/woocommerce/wc-api-php/blob/master/src/WooCommerce/Client.php
#

import strutils
import base64
import httpclient
import json
import tables
import strformat
import asyncdispatch

export httpclient

type
    WCAPI = ref object
        url: string
        version: string
        client: HttpClient

type
    AsyncWCAPI = ref object
        url: string
        version: string
        client: AsyncHttpClient

type
    APIVersionError = object of Exception

proc API*(url, consumer_key, consumer_secret: string, version: string = "wc/v3", timeout: int = -1): WCAPI =

    if version != "wc/v3":
        raise newException(APIVersionError, "Only wc/v3 API version is supported")

    let basic = join(["Basic", encode(join([consumer_key, consumer_secret], ":"))], " ")
    let client = newHttpClient(timeout=timeout)
    
    client.headers = newHttpHeaders({
        "User-Agent": &"WooCommerce API - {defUserAgent}",
        "Authorization": basic
    })
    
    var cleaned_url = url
    cleaned_url.removeSuffix("/")
    
    return WCAPI(
        url: cleaned_url,
        version: version,
        client: client
    )


proc AsyncAPI*(url, consumer_key, consumer_secret: string, version: string = "wc/v3"): AsyncWCAPI =

    if version != "wc/v3":
        raise newException(APIVersionError, "Only wc/v3 API version is supported")

    let basic = join(["Basic", encode(join([consumer_key, consumer_secret], ":"))], " ")
    let client = newAsyncHttpClient()
    
    client.headers = newHttpHeaders({
        "User-Agent": &"WooCommerce API - {defUserAgent}",
        "Authorization": basic
    })

    var cleaned_url = url
    cleaned_url.removeSuffix("/")

    return AsyncWCAPI(
        url: cleaned_url,
        version: version,
        client: client
    )


proc close*(wcapi: WCAPI | AsyncWCAPI) =
    wcapi.client.close()


proc params_to_query_string(params: Table): string =
    var parts = newSeq[string]()
    for key, value in params:
        parts.add(join([key, value], "="))

    return if parts.len > 0: join(parts, "&") else: ""

#
# Retrieve
#
proc get*(
    wcapi: WCAPI | AsyncWCAPI,
    endpoint: string,
    params: Table = initTable[string, string]()): Future[Response | AsyncResponse] {.multisync.} =

    let query_string = params_to_query_string(params)
    let url = join(
        [wcapi.url, "wp-json", wcapi.version, if query_string.len > 0: join([endpoint, query_string], "?") else: endpoint],
        "/"
    )

    when wcapi.client is AsyncHttpClient:
        return await wcapi.client.request(url, httpMethod=HttpGet)
    else:
        return wcapi.client.request(url, httpMethod=HttpGet)


#
# Create
#
proc post*(
    wcapi: WCAPI | AsyncWCAPI,
    endpoint: string,
    data: string): Future[Response | AsyncResponse] {.multisync.} =

    wcapi.client.headers.add("Content-Type", "application/json; charset=UTF-8")
    let url = join([wcapi.url, "wp-json", wcapi.version, endpoint], "/")

    when wcapi.client is AsyncHttpClient:
        return await wcapi.client.request(url, httpMethod=HttpPost, body=data)
    else:
        return wcapi.client.request(url, httpMethod=HttpPost, body=data)

#
# Update
#
proc put*(
    wcapi: WCAPI | AsyncWCAPI,
    endpoint: string,
    data: string): Future[Response | AsyncResponse] {.multisync.} =

    wcapi.client.headers.add("Content-Type", "application/json; charset=UTF-8")
    let url = join([wcapi.url, "wp-json", wcapi.version, endpoint], "/")

    when wcapi.client is AsyncHttpClient:
        return await wcapi.client.request(url, httpMethod=HttpPut, body=data)
    else:
        return wcapi.client.request(url, httpMethod=HttpPut, body=data)

#
# Delete
#
proc delete*(
    wcapi: WCAPI | AsyncWCAPI,
    endpoint: string,
    params: Table = initTable[string, string]()): Future[Response | AsyncResponse] {.multisync.} =

    let query_string = params_to_query_string(params)
    let url = join(
        [wcapi.url, "wp-json", wcapi.version, if query_string.len > 0: join([endpoint, query_string], "?") else: endpoint],
        "/"
    )

    when wcapi.client is AsyncHttpClient:
        return await wcapi.client.request(url, httpMethod=HttpDelete)
    else:
        return wcapi.client.request(url, httpMethod=HttpDelete)

#
# JSON Schema
#
proc options*(
    wcapi: WCAPI | AsyncWCAPI,
    endpoint: string): Future[Response | AsyncResponse] {.multisync.} =

    let url = join([wcapi.url, "wp-json", wcapi.version, endpoint], "/")

    when wcapi.client is AsyncHttpClient:
        return await wcapi.client.request(url, httpMethod=HttpOptions)
    else:
        return wcapi.client.request(url, httpMethod=HttpOptions)
 

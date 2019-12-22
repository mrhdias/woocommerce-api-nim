#
# nim c -d:ssl -p=./ -r tests/post.nim 
#
import os
import woocommerce/API
import tables
import json

proc main() =

    if not (existsEnv("WCAPI_URL") and existsEnv("WCAPI_CONSUMER_KEY") and existsEnv("WCAPI_CONSUMER_SECRET")):
        echo """
Set manually the following environment variables to run the tests:
export WCAPI_URL=http://example.com
export WCAPI_CONSUMER_KEY=ck_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
export WCAPI_CONSUMER_SECRET=cs_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
"""
        quit()

    let url = getEnv("WCAPI_URL")
    let consumer_key = getEnv("WCAPI_CONSUMER_KEY")
    let consumer_secret = getEnv("WCAPI_CONSUMER_SECRET")

    let wcapi = API(
        url=url,
        consumer_key=consumer_key,
        consumer_secret=consumer_secret
    )

    let data = %* {
        "name": "TestAttribute",
        "slug": "pa_testattribute",
        "type": "select",
        "order_by": "menu_order",
        "has_archives": false
    }

    var response = wcapi.post("products/attributes", $data)
    echo response.status
    if response.status == "201 Created":
        echo parseJson(response.body)

    response = wcapi.get("products/attributes")
    echo response.status
    if response.status == "200 OK":
        echo parseJson(response.body)

    wcapi.close()

main()

#
# nim c -d:ssl -p=./ -r tests/options.nim 
#
import os
import woocommerce/API

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

    let response = wcapi.options("products")
    echo response.status
    echo response.version
    echo response.headers["content-type"]
    if response.status == "200 OK":
        echo response.body

    wcapi.close()

main()

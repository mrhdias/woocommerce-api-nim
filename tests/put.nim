#
# nim c -d:ssl -p=./ -r tests/put.nim 
#
import os
import woocommerce/API
import json
import rdstdin
import strformat
import strutils

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

    var input_response = readLineFromStdin "Enter the id number of the product to update the regular price (0 to cancel): "
    if input_response == "0":
        echo "Test canceled!"
        quit()

    var id = 0
    try:
        id = input_response.parseInt
    except ValueError:
        echo "The characters you entered are not a number..."
        quit()

    input_response = readLineFromStdin "Enter the new regular price (0 to cancel): "
    if input_response == "0":
        echo "Test canceled!"
        quit()

    if id <= 0:
        echo "The characters you entered are not positive integer number..."
        quit()

    var regular_price = 0.00
    try:
        regular_price = input_response.parseFloat
    except ValueError:
        echo "The characters you entered are not a float number..."
        quit()

    if regular_price <= 0:
        echo "The characters you entered are not positive float number..."
        quit()

    var data = %* {"regular_price": $(regular_price.formatFloat(ffDecimal, 2))}
    echo $data

    let response = wcapi.put(&"products/{id}", $data)
    echo response.status
    if response.status == "200 OK":
        let product = parseJson(response.body)
        echo "SKU:", product["sku"], " REGULAR PRICE:", product["regular_price"]

    wcapi.close()

main()

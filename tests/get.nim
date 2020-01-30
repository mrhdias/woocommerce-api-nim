#
# nim c -d:ssl -p=./ -r tests/get.nim 
#
import os
import woocommerce/API
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
  
  let response = wcapi.get("products", params = {"status": "publish", "per_page": $(10), "page": $(1)})
  echo response.status
  echo response.version
  echo response.headers["content-type"]
  if response.status == "200 OK":
    let products = parseJson(response.body)
    for product in products:
      echo "SKU:", product["sku"], " NAME:", product["name"]

  wcapi.close()

main()

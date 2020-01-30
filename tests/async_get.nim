#
# nim c -d:ssl -p=./ -r tests/async_get.nim 
#
import os
import woocommerce/API
import asyncdispatch
import json

proc main() {.async.} =

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

  let wcapi = AsyncAPI(
    url=url,
    consumer_key=consumer_key,
    consumer_secret=consumer_secret
  )
  
  let response = await wcapi.get("products", params = @{"status": "publish", "per_page": $(10), "page": $(1)})
  echo response.status
  echo response.version
  echo response.headers["content-type"]
  if response.status == "200 OK":
    let products = parseJson(await response.body)
    for product in products:
      echo "SKU:", product["sku"], " NAME:", product["name"]

  wcapi.close()

waitFor main()

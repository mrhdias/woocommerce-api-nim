#
# nim c -d:ssl -p=./ -r tests/get.nim 
#
import woocommerce/AsyncAPI
import tables
import json

proc main() {.async.} =
  let wcapi = await API(
    url="http://example.com",
    consumer_key="ck_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
    consumer_secret="cs_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
  )
  
  let response = await wcapi.get("products", params = {"status": "publish", "per_page": $(10), "page": $(1)}.toTable)
  echo response.status
  echo response.version
  echo response.headers["content-type"]
  if response.status == "200 OK":
    let products = parseJson(await response.body)
    for product in products:
      echo "SKU:", product["sku"], " NAME:", product["name"]

  wcapi.close()

waitFor main()

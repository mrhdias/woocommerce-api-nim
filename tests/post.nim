#
# nim c -d:ssl -p=./ -r tests/post.nim 
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

  let data = %* {
    "name": "TestAttribute",
    "slug": "pa_testattribute",
    "type": "select",
    "order_by": "menu_order",
    "has_archives": false
  }

  var response = await wcapi.post("products/attributes", $data)
  echo response.status
  if response.status == "201 Created":
    echo parseJson(await response.body)

  response = await wcapi.get("products/attributes")
  echo response.status
  if response.status == "200 OK":
    echo parseJson(await response.body)

  wcapi.close()

waitFor main()

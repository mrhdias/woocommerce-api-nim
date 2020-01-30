#
# nim c -d:ssl -p=./ -r tests/delete.nim 
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

  echo "ATTENTION: This also will delete all terms from the selected attribute!"
  let input_response = readLineFromStdin "Enter the id number of the attribute to delete (0 to cancel): "

  if input_response == "0":
    echo "Test canceled!"
    quit()

  var id = 0
  try:
    id = input_response.parseInt
  except ValueError:
    echo "The characters you entered are not a number..."
    quit()

  if id <= 0:
    echo "The characters you entered are not integer number..."
    quit()

  let response = wcapi.delete(&"products/attributes/{id}", params = @{"force": $(true)})
  echo response.status
  if response.status == "200 OK":
    echo parseJson(response.body)

  wcapi.close()

main()

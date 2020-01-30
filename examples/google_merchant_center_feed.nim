#
#  nim c -d:ssl -p=./ -r examples/google_merchant_center_feed.nim -c=examples/google_merchant_center_feed.ini -d
#
import os
import woocommerce/API
import json
import strutils
import strformat
import re
import parseopt
import parsecfg
import std/wordwrap

var DEBUG = false

proc clean_text(text: string): string =
  return text.replace(re"<[^>]*>").replace(re"\s+", " ").strip(chars = {' ', '\t', '\n', '\r', '\c'}).escape.wrapWords(5000)

proc add_product_to_feed(conf: Config, fp: File, shipping_methods: JsonNode, product: JsonNode): string =

  # echo product

  var brand = "unknown"
  for attributes in product["attributes"]:
    if attributes.hasKey("name") and getStr(attributes["name"]) == "Marca":
      # echo attributes["options"].kind
      brand = attributes["options"].getElems.join(", ").replace("\"", "").escape
      if brand == "":
        brand = "not selected"
      break

  if brand == "unknown" or brand == "not selected":
    return &"""The product "{getStr(product["sku"])}" was excluded because it has no brand ({brand})!"""

  var ean = ""
  var mpn = ""
  for data in product["meta_data"]:
    if getStr(data["key"]) == "_gtin":
      ean = getStr(data["value"])
    elif getStr(data["key"]) == "_mpn":
      mpn = getStr(data["value"])
    if ean.len > 0 and mpn.len > 0:
      break

  if ean.len == 0:
    return &"""The product "{getStr(product["sku"])}" was excluded because it has no "EAN/GTIN" code!"""

  if mpn.len == 0:
    return &"""The product "{getStr(product["sku"])}" was excluded because it has no "MPN" code!"""

  var delivery_cost = -1.00
  for shipping_method in shipping_methods:
    let shipping_value = getStr(shipping_method["settings"][&"""class_cost_{getInt(product["shipping_class_id"])}"""]["value"])
    if shipping_value.len > 0:
      let parts = shipping_value.split(' ', 1)
      delivery_cost = parseFloat(parts[0])

  if delivery_cost <= 0.00:
    return &"""The product "{getStr(product["sku"])}" was excluded because it has a shipping costs error!"""

  fp.writeLine(&"""
    <item>
      <g:id>{getStr(product["sku"])}</g:id>
      <g:title>{escape(getStr(product["name"]))}</g:title>
      <g:description>{clean_text(getStr(product["description"]))}</g:description>
      <g:link>{getStr(product["permalink"])}</g:link>
      <g:image_link>{getStr(product["images"][0]["src"])}</g:image_link>
      <g:condition>new</g:condition>
      <g:availability>in stock</g:availability>
      <g:price>{getStr(product["regular_price"]):2} {conf.getSectionValue("ISO-Codes", "currency_code")}</g:price>""")

  if product.hasKey("price") and parseFloat(getStr(product["price"])) < parseFloat(getStr(product["regular_price"])):
    fp.writeLine(&"""{"\t\t\t"}<g:sale_price>{getStr(product["price"]):2} {conf.getSectionValue("ISO-Codes", "currency_code")}</g:sale_price>""")

  fp.writeLine(&"""
      <g:shipping>
        <g:country>{conf.getSectionValue("ISO-Codes", "country_code")}</g:country>
        <g:service>{conf.getSectionValue("Shipping-Service", "carrier")}</g:service>
        <g:price>{delivery_cost:2}</g:price>
      </g:shipping>
      <g:brand>{escape(brand)}</g:brand>
      <g:gtin>{ean}</g:gtin>
      <g:mpn>{mpn}</g:mpn>
    </item>""")

  return ""

proc main() =

  proc show_help() =
    echo """
--config(-c)=path_to_ini_file
  path to ini file configuration 
--debug (-d)
  for detailed debugging"""
    quit()

  var ini_file = ""
  var p = initOptParser(commandLineParams())
  for kind, key, val in p.getopt():
    case kind:
      of cmdArgument:
        discard
      of cmdLongOption, cmdShortOption:
        case key:
          of "config", "c":
            ini_file = val
          of "degug", "d":
            DEBUG = true
          of "help", "h": show_help()
      of cmdEnd:
        break

  if not (ini_file != "" and existsFile(ini_file)):
    echo "no ini file!"
    show_help()
    quit()

  let conf = loadConfig(ini_file)

  let wcapi = API(
    url=conf.getSectionValue("REST-API-Credentials", "url"),
    consumer_key=conf.getSectionValue("REST-API-Credentials", "consumer_key"),
    consumer_secret=conf.getSectionValue("REST-API-Credentials", "consumer_secret")
  )

  let feed_filepath = conf.getSectionValue("Feed", "save")
  if not (feed_filepath.len >= 4 and feed_filepath.endsWith(".xml")):
    echo "The feed file does not exist in the ini configuration file."
    quit()

  let pathSplit = splitPath(feed_filepath)
  if not existsDir(pathSplit.head):
    echo &"Unable to create feed file: {feed_filepath}."
    quit()

  let fp = open(feed_filepath, fmWrite)
  defer: fp.close()

  var id = 0
  let shipping_zones_response = wcapi.get("shipping/zones")
  if shipping_zones_response.status == "200 OK":
    for shipping_zone in parseJson(shipping_zones_response.body):
      if shipping_zone.hasKey("name") and getStr(shipping_zone["name"]) == conf.getSectionValue("Shipping-Service", "zone"):
        id = getInt(shipping_zone["id"])
        break

  let shipping_methods_response = wcapi.get(&"shipping/zones/{id}/methods")
  if shipping_methods_response.status != "200 OK":
    if DEBUG:
      echo &"HTTP Server Error: {shipping_methods_response.status}"
    quit()

  let shipping_methods = parseJson(shipping_methods_response.body)
  if shipping_methods.len == 0:
    echo "No shipping methods returned!"
    quit()

  fp.writeLine(&"""
<?xml version="1.0" encoding="utf-8"?>
<rss xmlns:g="http://base.google.com/ns/1.0" version="2.0">
  <channel>
    <title>{conf.getSectionValue("Feed", "title")}</title>
    <link>{conf.getSectionValue("Feed", "link")}</link>
    <description>{conf.getSectionValue("Feed", "description")}</description>""")

  let per_page = conf.getSectionValue("Get-Params", "per_page")
  var page = 0
  while true:
    page.inc
    let response = wcapi.get("products", params = @{"status": "publish", "per_page": per_page, "page": $(page)})

    # echo response.status
    # echo response.version
    # echo response.headers["content-type"]
    if response.status != "200 OK":
      if DEBUG:
        echo &"HTTP Server Error: {response.status}"
      break

    let products = parseJson(response.body)
    if products.len == 0:
      if DEBUG:
        echo "End..."
      break

    # echo products

    if DEBUG:
      echo &"Loading page {page}"

    for product in products:
      let error = add_product_to_feed(conf, fp, shipping_methods, product)
      if DEBUG and error.len > 0:
        echo error

  fp.writeLine("""
  </channel>
</rss>""")

  wcapi.close()

main()

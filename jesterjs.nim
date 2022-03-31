import jester/[patterns], tables, jsffi, uri
type 
  Params = Table[string, string]
  Response = object
    headers: JsAssoc[cstring, cstring]
    body: cstring

template `@`*(field: string): untyped =
  params[field]

proc fillParams*(url: string, urlParams: Table[string, string], headers: JsAssoc[cstring, cstring], body: cstring): Table[string, string] =
#   ## Parameters from the pattern and the query string.
  result = urlParams
  for (key, val) in url.parseUri.query.decodeQuery:
    result[key] = val
  for (key, val) in ($body).decodeQuery:
    result[key] = val

template router(codeBody: untyped): untyped {.dirty.} =
  var response = ""
  var params: Params
  proc run*(jspath: cstring, headers: JsAssoc[cstring, cstring], reqBody: cstring): Response {.exportc.} =
    var path = $jspath
    codeBody
    result.body = response

template get(pathRule: string, codeBody2: untyped): untyped =
  let pattern = pathRule.parsePattern()
  var (matched, tmpParams) = pattern.match(path.parseUri.path)
  if matched:
    params = path.fillParams(tmpParams, headers, reqBody)
    codeBody2

template resp(s: string) =
  response = s

when isMainModule:
  router:
    get "/here/@val":
      resp @"val"
    get "/name":
      resp @"name"

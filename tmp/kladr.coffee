(($) ->
  $.kladr = {}

  # Service URL
  $.kladr.url = "http://kladr-api.ru/api.php"

  # Enum KLADR object types
  $.kladr.type =
    region: "region"
    district: "district"
    city: "city"
    street: "street"
    building: "building"


  # Send query to service
  $.kladr.api = (query, callback) ->
    params = {}
    params.token = query.token  if query.token
    params.key = query.key  if query.key
    params.contentType = query.type  if query.type
    params.query = query.name  if query.name
    params[query.parentType + "Id"] = query.parentId  if query.parentType and query.parentId
    params.withParent = 1  if query.withParents
    params.limit = (if query.limit then query.limit else 2000)
    completed = false
    $.getJSON $.kladr.url + "?callback=?", params, (data) ->
      return  if completed
      completed = true
      callback and callback(data.result)
      return

    setTimeout (->
      return  if completed
      completed = true
      console.error "Request error"
      callback and callback([])
      return
    ), 5000
    return


  # Check existence object
  $.kladr.check = (query, callback) ->
    query.withParents = false
    query.limit = 1
    $.kladr.api query, (objs) ->
      if objs and objs.length
        callback and callback(objs[0])
      else
        callback and callback(false)
      return

    return

  return
) jQuery
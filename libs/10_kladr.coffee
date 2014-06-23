# Класс работы с API
class Kladr
  url: "http://kladr-api.ru/api.php"
  type:
    region: "region"
    district: "district"
    city: "city"
    street: "street"
    building: "building"

  # конструктор
  # @param P[object] parrent
  constructor: (@P)->
    @opt = @P.opt if @P.opt
    @

  ###
  Api
  @param query[string] строка адреса
  @param callback[function] (result)
  ###
  api: (query, callback) ->
    self = @
    params = {}
    params.token = @opt.token  if @opt.token
    params.key = @opt.key  if @opt.key
    params.contentType = @opt.type  if @opt.type
    params.query = query  if query
    params.cityId = @opt.cityId  if @opt.cityId
    params.limit = (if @opt.limit then @opt.limit else 2000)
    params[@opt.Type + "Id"] = @opt.parentId  if @opt.Type and @opt.parentId
    params.withParent = 1 if @opt.withParents
    params._ = Math.round new Date().getTime() / 1000
    console.log params

    $.getJSON @url + "?callback=?", params, (data)->
      self.data = data if data
      callback(data.result) if callback

    @

  # Check existence object
  check: (query, callback) ->
    query.withParents = false
    query.limit = 1
    @api query, (objs) ->
      if objs and objs.length
        callback and callback(objs[0])
      else
        callback and callback(false)
    @


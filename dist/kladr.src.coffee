# Класс работы с API
class Kladr
  constructor: (@P)->
    @opt = @P.opt if @P.opt

  url: "http://kladr-api.ru/api.php"

  type:
    region: "region"
    district: "district"
    city: "city"
    street: "street"
    building: "building"


  ###
  Api
  @param query[string] строка адреса
  @param callback[function] (result)
  ###
  api: (query, callback) ->
    params = {}
    params.token = @opt.token  if @opt.token
    params.key = @opt.key  if @opt.key
    params.contentType = @opt.type  if @opt.type
    params.query = query  if query
    params.cityId = @opt.cityId  if @opt.cityId
    params.limit = (if @opt.limit then @opt.limit else 2000)
    params[@opt.Type + "Id"] = @opt.parentId  if @opt.Type and @opt.parentId
    params._ = Math.round new Date().getTime() / 1000

    $.getJSON $.kladr.url + "?callback=?", params, (data, textStatus)->
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

class Option
  token: null
  key: null
  type: null
  parentType: null
  parentId: null
  limit: 10
  withParents: false
  verify: false
  showSpinner: true
  arrowSelect: true
  current: null
  open: null
  close: null
  send: null
  received: null
  select: null
  check: null

  ###
  Получения списка объектов отображаемых при автодополнении.
  По-умолчанию запрашивает данные у сервиса [kladr-api.ru] [1].
  Может быть переопределена для получения объектов из другого источника.
  @param query[]
  @param calback[function]
  ###
  source: (query, callback) ->
    params =
      token: options.token
      key: options.token
      type: options.type
      name: query
      parentType: options.parentType
      parentId: options.parentId
      withParents: options.withParents
      limit: options.limit
    # @todo поменять прямой вызов api $.kladr.api
    $.kladr.api params, callback if callback
    @


  ###
  Форматирования значений в списке.
  @param obj[Object] – объект КЛАДР,
  @param query[String]– текущее значение поля ввода.
  ###
  labelFormat: (obj, query) ->
    label = ""
    name = obj.name.toLowerCase()
    query = query.toLowerCase()
    start = name.indexOf(query)
    start = (if start > 0 then start else 0)
    label += obj.typeShort + ". "  if obj.typeShort
    if query.length < obj.name.length
      label += obj.name.substr(0, start)
      label += "<strong>" + obj.name.substr(start, query.length) + "</strong>"
      label += obj.name.substr(start + query.length, obj.name.length - query.length - start)
    else
      label += "<strong>" + obj.name + "</strong>"
    label


  ###
  Форматирования подставляемых в поле ввода значений.
  @param obj[Object] – объект КЛАДР,
  @param query[String]– текущее значение поля ввода.
  ###
  valueFormat: (obj, query) ->
    obj.name

# Ввод запроса
class Input
  ###
  Конструктор
  @param P[Object] parrent object
  ###
  constructor:(@P)->
    console.log 'load input'
    @$el = $ @P.el if @P.el
    @opt = @P.opt if @P?.opt
    @kladr = @P.kladr
    @events()

  # События ввода
  events:->
    self = @
    @$el.on 'keyup',(e)->
      # debugger
      return if 8 < event.which < 46
      # @todo
      # return unless self.validate()
      # value
      e.target.value = $.trim self.key e.target.value
      query = e.target.value

      unless query
        self.P.close()
        return
      # spinnerShow
      self.P.query query


  # проверка
  validate: ->
    # @todo Эту проверку нужно перенести в др. объект
    # switch @opt.type
    #   when ['region', 'district', 'city']
    #     if @opt.Type and not opt.opt.parentId
    #       console.error "parentType is defined and parentId in not"
    #       return false
    #   when 'street'
    #     unless opt.opt.parentType is @kladr.type.city
    #       console.error "For street parentType must equal \"city\""
    #       return false
    #     unless opt.opt.parentId
    #       console.error "For street parentId must defined"
    #       return false
    #   when 'building'
    #     unless opt.opt.parentType is @kladr.type.street
    #       console.error "For building parentType must equal \"street\""
    #       return false
    #     unless opt.opt.parentId
    #       console.error "For building parentId must defined"
    #       return false
    #   else
    #     console.error "type must defined and equal \"region\",
    #       \"district\", \"city\", \"street\" or \"building\""
    #     return false
    # /@todo
    # if opt.opt.limit < 1
    #   console.error "limit must greater than 0"
    #   return false
    true

  ###
  Обработка данных
  ###
  key:(val)->
    key =
      en: "1234567890qazwsxedcrfvtgbyhnujmik,ol.p;[']- " + "QAZWSXEDCRFVTGBYHNUJMIK<OL>P:{\"} "
      ru: "1234567890йфяцычувскамепинртгоьшлбщдюзжхэъ- " + "ЙФЯЦЫЧУВСКАМЕПИНРТГОЬШЛБЩДЮЗЖХЭЪ "
      enRU: (char)->
        idx = @en.indexOf char
        return @ru[ idx ] if idx isnt -1
        char

    str = val.split ''
    newStr = ''

    for char in str
      newStr += key.enRU char
    newStr






class Display
  constructor:->
# jQuery plugin
class Plugin
  # Конструктор
  constructor: (@opt, @el)->
    console.log 'plugin load'
    @$el = $ @el
    # kladr
    @kladr = new Kladr @
    # create input
    if @$el
      console.log 'create input'
      @input =  new Input @
      # @el.html @input.render().$el
  ###
  #
  ###
  # options:->
    # @opt.cityId = @opt.parentId if @opt.Type is 'city'

  ###
  Обработка полученных
  @param query[String] запрос
  ###
  query:(query)->
    @kladr.api query, (result)->
      console.log result

  # Закрыть список
  # @todo
  close:()->

$ ->
  # создаю плагин
  $.fn.jqKladr = (options)->
    new Plugin options, @

# Кодинг Тест
$ ->
  # Подключение автодополнения улиц
  $('[name="mskstreet"]').jqKladr
    token: '51dfe5d42fb2b43e3300006e'
    key: '86a2c2a06f1b2451a87d05512cc2c3edfdf41969'
    # type: $.kladr.type.street
    type: 'street'
    # parentType: $.kladr.type.city
    Type:'city'
    parentId: '7700000000000'
    limit: 10
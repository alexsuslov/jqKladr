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

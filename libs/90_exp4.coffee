$ ->
  token = "51dfe5d42fb2b43e3300006e"
  key = "86a2c2a06f1b2451a87d05512cc2c3edfdf41969"
  city = $("[name=\"city\"]")
  street = $("[name=\"street\"]")
  building = $("[name=\"building\"]")
  buildingAdd = $("[name=\"building-add\"]")
  map = null
  placemark = null
  map_created = false

  Address =
    zoom:12

    set:(name, value)->
      return unless name
      @[name] = value
      @[name].zoom = 12 if name is 'city'
      @[name].zoom = 14 if name is 'street'
      @[name].zoom = 16 if name is 'building'

      @[name].address = @renderAddress value

      MapUpdate @address()

    renderAddress:(obj)->
      "#{obj.typeShort}. #{obj.name}"

    address:->
      comma = ''
      addr =
        address: ''
        zoom: 0

      for item in ['city','street','building' ]
        if @[item]
          addr.address += comma + @[item].address
          addr.zoom = @[item].zoom if addr.zoom < @[item].zoom
          addr.zip = @[item].zip if @[item].zip
          addr.type = @[item].type
          addr.sType = @[item].typeShort
          comma = ', '
      addr

    addressText:->
      obj = @address()
      "#{obj.zip}, #{obj.address}"


  # Формирует подписи в autocomplete
  LabelFormat = (obj, query) ->
    label = ""
    name = obj.name.toLowerCase()
    query = query.toLowerCase()
    start = name.indexOf(query)
    start = (if start > 0 then start else 0)
    label += "<span class=\"ac-s2\">" + obj.typeShort + ". " + "</span>"  if obj.typeShort
    if query.length < obj.name.length
      label += "<span class=\"ac-s2\">" + obj.name.substr(0, start) + "</span>"
      label += "<span class=\"ac-s\">" + obj.name.substr(start, query.length) + "</span>"
      label += "<span class=\"ac-s2\">" + obj.name.substr(start + query.length, obj.name.length - query.length - start) + "</span>"
    else
      label += "<span class=\"ac-s\">" + obj.name + "</span>"
    if obj.parents
      k = obj.parents.length - 1

      while k > -1
        parent = obj.parents[k]
        if parent.name
          label += "<span class=\"ac-st\">, </span>"  if label
          label += "<span class=\"ac-st\">" + parent.name + " " + parent.typeShort + ".</span>"
        k--
    label

  # Options
  # building
  optionsBuilding =
    prefix:'BuildingKl'
    token: token
    key: key
    type: 'building'
    # Type: 'street'
    # labelFormat: LabelFormat
    verify: true
    limit: 10
    onSelect:(obj) ->
      Log obj
      Address.set 'building', obj
      $("#address").text Address.addressText()

  # Street
  optionsStreet =
    prefix:'streetKl'
    token: token
    key: key
    type: 'street'
    Type: 'city'
    # labelFormat: LabelFormat
    verify: true
    limit: 10
    onSelect:(obj) ->
      Log obj
      Address.set 'street', obj
      $("#address").text Address.addressText()
      optionsBuilding.parentId = obj.id
      optionsBuilding.Type = obj.contentType

  ## City
  optionsCity =
    prefix:'cityKl'
    token: token
    key: key
    type: 'city'
    withParents: true
    # labelFormat: LabelFormat
    verify: true
    limit: 10
    onSelect: (obj) ->
      # console.log obj
      Log obj
      Address.set 'city', obj
      $("#address").text Address.addressText()
      optionsStreet.parentId = obj.id
      optionsStreet.Type = obj.contentType

  # Подключение плагина для поля ввода города
  city.jqKladr optionsCity
    # check: (obj) ->
    #   if obj
    #     city.parent().find("label").text obj.type
    #     street.kladr "parentType", $.kladr.type.city
    #     street.kladr "parentId", obj.id
    #     building.kladr "parentType", $.kladr.type.city
    #     building.kladr "parentId", obj.id
    #   Log obj
    #   AddressUpdate()
    #   MapUpdate()
    #   return


  # Подключение плагина для поля ввода улицы
  street.jqKladr optionsStreet
    # check: (obj) ->
    #   if obj
    #     street.parent().find("label").text obj.type
    #     building.kladr "parentType", $.kladr.type.street
    #     building.kladr "parentId", obj.id
    #   Log obj
    #   AddressUpdate()
    #   MapUpdate()
    #   return


  # Подключение плагина для поля ввода номера дома
  building.jqKladr optionsBuilding
    # check: (obj) ->
    #   Log obj
    #   AddressUpdate()
    #   MapUpdate()
    #   return


  # Проверка названия корпуса
  buildingAdd.change ->
    Log null
    AddressUpdate()
    MapUpdate()
    return


  # Обновляет карту
  MapUpdate = (opt)->
    if map_created and opt.address
      geocode = ymaps.geocode(opt.address)
      geocode.then (res) ->
        map.geoObjects.each (geoObject) ->
          map.geoObjects.remove geoObject
          return

        position = res.geoObjects.get(0).geometry.getCoordinates()
        placemark = new ymaps.Placemark(position, {}, {})
        map.geoObjects.add placemark
        map.setCenter position, opt.zoom
        return
    return

  # Обновляет лог текущего выбранного объекта
  Log = (obj) ->
    logId = $("#id")
    if obj and obj.id
      logId.find(".value").text obj.id
      logId.show()
    else
      logId.hide()
    logName = $("#name")
    if obj and obj.name
      logName.find(".value").text obj.name
      logName.show()
    else
      logName.hide()
    logZip = $("#zip")
    if obj and obj.zip
      logZip.find(".value").text obj.zip
      logZip.show()
    else
      logZip.hide()
    logType = $("#type")
    if obj and obj.type
      logType.find(".value").text obj.type
      logType.show()
    else
      logType.hide()
    logTypeShort = $("#type_short")
    if obj and obj.typeShort
      logTypeShort.find(".value").text obj.typeShort
      logTypeShort.show()
    else
      logTypeShort.hide()
    return

  ymaps.ready ->
    return  if map_created
    map_created = true
    map = new ymaps.Map("map",
      center: [
        55.76
        37.64
      ]
      zoom: 12
    )
    map.controls.add "smallZoomControl",
      top: 5
      left: 5

    return

  return

  # # Элементы
  # $location = $("[name=\"location1\"]")
  # $street = $("[name=\"street1\"]")

  # # опции
  # token = "51dfe5d42fb2b43e3300006e"
  # key = "86a2c2a06f1b2451a87d05512cc2c3edfdf41969"
  # streetOptions =
  #   prefix: 'streetKL'
  #   token: token
  #   key: key
  #   type: 'street'
  #   Type: 'city'
  #   limit: 10

  # locationOptions =
  #   prefix:'locationKL'
  #   token: token
  #   key: key
  #   type: 'city'
  #   limit: 10
  #   onSelect: (obj)->
  #     # Изменения родительского объекта для автодополнения улиц
  #     streetOptions.parentId = obj.id

  # # Запуск объектов
  # $location.jqKladr locationOptions
  # $street.jqKladr streetOptions
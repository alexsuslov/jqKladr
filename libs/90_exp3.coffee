$ ->
  # Элементы
  $location = $("[name=\"location1\"]")
  $street = $("[name=\"street1\"]")

  # опции
  token = "51dfe5d42fb2b43e3300006e"
  key = "86a2c2a06f1b2451a87d05512cc2c3edfdf41969"
  streetOptions =
    prefix: 'streetKL'
    token: token
    key: key
    type: 'street'
    Type: 'city'
    limit: 10

  locationOptions =
    prefix:'locationKL'
    token: token
    key: key
    type: 'city'
    limit: 10
    onSelect: (obj)->
      # Изменения родительского объекта для автодополнения улиц
      streetOptions.parentId = obj.id

  # Запуск объектов
  $location.jqKladr locationOptions
  $street.jqKladr streetOptions
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

    #display
    @display = new Display @
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
    self = @
    # для работы выделения набранного текста
    @display.highlight = query
    @kladr.api query, (result)->
      self.open result

  # открыть список
  # @todo
  open:(result)->
    @display.collection = result
    @display.render()

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
    prefix:'jqKladr'
    token: '51dfe5d42fb2b43e3300006e'
    key: '86a2c2a06f1b2451a87d05512cc2c3edfdf41969'
    # type: $.kladr.type.street
    type: 'street'
    # parentType: $.kladr.type.city
    Type:'city'
    parentId: '7700000000000'
    limit: 10
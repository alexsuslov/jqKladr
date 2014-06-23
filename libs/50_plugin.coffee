# jQuery plugin
class Plugin
  # Конструктор
  constructor: (@opt, @el)->
    console.log 'plugin load'
    @$el = $ @el
    @$el.attr 'autocomplete', "off"
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

  # выбор объекта
  select:(name)->
    # нахожу выбранный объект
    if @kladr.data?.result?.length
      for item in @kladr.data.result
        if item.name is name
          @selected = item
          break
    @opt.onSelect @selected if @selected and @opt.onSelect


$ ->
  # создаю плагин
  $.fn.jqKladr = (options)->
    new Plugin options, @



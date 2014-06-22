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



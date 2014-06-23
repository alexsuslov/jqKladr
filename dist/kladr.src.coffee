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


# Класс обработки input
class Input
  ###
  Конструктор
  @param P[Object] parrent object
  ###
  constructor:(@P)->
    console.log 'load input' if @debug
    @$el = $ @P.el if @P.el
    @opt = @P.opt if @P?.opt
    @kladr = @P.kladr
    @events()
    @

  # Setter установщик значение
  val:(value)->
    if typeof(value) is 'undefined'
      return @$el.val()
    else
      @P.select value
      @$el.val value
    @

  # События ввода
  # KEYUP
  # KEYDOWN
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


    @$el.on 'keydown', (e)->
      self.P.display.keyselect e

    @


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
  Обработка ввода текста
  @param val[string] строка набранная латиницей или кирилицей
  @return [string] строка в кирилице
  ###
  key:(val)->
    # объект преобразования
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


# Класс для показа списка
class Display
  # убирает лишние символы
  mini:(str)->
    str.replace(/\r|\n|\t/g,' ').replace(/\s+/g,' ')
  #кнопки
  keys:
    up: 38, down: 40, esc: 27, enter: 13

  # шаблон основного объекта
  template:->
    @mini  """
<div id="#{@P.opt.prefix}_autocomplete"><ul></ul></div>

    """
  # шаблон строки
  row:(item)->
    console.log item if @debug
    name = item.name
    if @highlight
      name = name.replace new RegExp( '(' + @highlight + ')', 'gi') , (highlight)->
        "<strong>#{highlight}</strong>"
    @mini "<li data-val=\"#{item.name}\" > #{item.typeShort}. #{name} </li>"

  # шаблон стилей
  # @todo поменять background-image на встроенный
  style:->
    @mini """
<style>
##{@P.opt.prefix}_autocomplete ul{
    position: absolute;
    display: block;
    margin: 0;
    padding: 0;
    border: 1px solid rgb(138, 138, 138);
    border-radius: 3px;
    background-color: white;
    z-index: 9999;
}

##{@P.opt.prefix}_autocomplete li{
    display: list-item;
    list-style-type: none;
    margin: 0;
    padding: 3px 5px;
    overflow: hidden;
    border: 1px solid white;
    border-bottom: 1px solid rgb(189, 189, 189);
}

##{@P.opt.prefix}_autocomplete li.active{
    background-color: rgb(224, 224, 224);
    border-radius: 3px;
    border: 1px solid rgb(151, 151, 151);
}

##{@P.opt.prefix}_autocomplete a{
    display: block;
    cursor: default;
    width: 10000px;
}

##{@P.opt.prefix}_autocomplete .spinner{
    position: absolute;
    display: block;
    margin: 0;
    padding: 0;
    width: 20px;
    height: 20px;
    background-color: transparent;
    background-image: url("images/spinner.png");
    background-position: center center;
    background-repeat: no-repeat;
    z-index: 9999;
}
</style>
"""

  # конструктор
  constructor:(@P)->
    @opt = @P.opt if @P.opt
    $('body').append @template()
    $('head').append @style()
    @$el = $("##{@P.opt.prefix}_autocomplete")
    @$el.hide()
    @$list = $("##{@P.opt.prefix}_autocomplete ul")
    @position()

  # позиция списка
  position: ->
    input = @P.input.$el
    inputOffset = input.offset()
    inputWidth = input.outerWidth()
    inputHeight = input.outerHeight()
    @$list.css
      top: inputOffset.top + inputHeight + "px"
      left: inputOffset.left

    differ = @$list.outerWidth() - @$list.width()
    @$list.width inputWidth - differ

  # собрать список
  render:->
    self = @
    @$list.empty()
    for model in @collection
      self.$list.append @row model
    @events()
    @$el.show()

  # активировать строку в списке
  activate:(active)->
    active.addClass "active"

  # Обработка up/down enter/ esc
  keyselect:(e)->
    active = @$list.find("li.active")

    switch e.which
      # нажата кнопка вверх
      when @keys.up
        if active.length
          active.removeClass "active"
          @activate active.prev()
        else
          @activate @$list.find("li").last()
      # нажата кнопка вниз
      when @keys.down
        if active.length
          active.removeClass "active"
          @activate active.next()
        else
          @activate @$list.find("li").first()
      # нажата кнопка esc
      when @keys.esc
        active.removeClass "active"
        @close()

      # нажата кнопка enter
      when @keys.enter
        # вставляю выбранное значение в input
        unless @opt.arrowSelect
          @P.input.val $(active).data('val')
        active.removeClass "active"
        @close()

  # закрыть список
  close:->
    @$el.hide()

  # события
  events:->
    self = @
    $li = @$list.find('li')

    # мышь на списке
    $li.on 'mouseenter',(e)->
      self.$list.find('li').removeClass "active"
      self.activate $(e.target)

    # клик мыши на списке
    $li.on 'click',(e)->
      $(e.target).removeClass "active"
      # вставляю выбранное значение в input
      self.P.input.val $(e.target).data('val')
      self.close()

    # мышь покинула список
    $li.on 'mouseleave',(e)->
      $(e.target).removeClass "active"




# jQuery plugin
class Plugin
  # Конструктор
  constructor: (@opt, @el)->
    console.log 'plugin load' if @debug
    @$el = $ @el
    @$el.attr 'autocomplete', "off"
    # kladr
    @kladr = new Kladr @
    # create input
    if @$el
      console.log 'create input' if @debug
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



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
  val:(value)->
    if typeof(value) is 'undefined'
      return @$el.val()
    else
      @$el.val value
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


    @$el.on 'keydown', (e)->
      self.P.display.keyselect e


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
  keys:
    up: 38
    down: 40
    esc: 27
    enter: 13

  # объект
  template:->
    """
<div id="#{@P.opt.prefix}_autocomplete"><ul></ul></div>

    """
  # строка
  row:(item)->
    name = item.name
    if @highlight
      name = name.replace new RegExp( '(' + @highlight + ')', 'gi') , (highlight)->
        "<strong>#{highlight}</strong>"
    "<li data-val=\"#{item.name}\" > #{name} </li>"

  # стили
  style:->
    """
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

    # spinnerWidth = spinner.width()
    # spinnerHeight = spinner.height()
    # spinner.css
    #   top: inputOffset.top + (inputHeight - spinnerHeight) / 2 - 1
    #   left: inputOffset.left + inputWidth - spinnerWidth - 2

  # собрать список
  render:->
    self = @
    @$list.empty()
    for model in @collection
      self.$list.append @row model
    @events()
    @$el.show()

  activate:(active)->
    active.addClass "active"

  # Обработка up/down enter/ esc
  keyselect:(e)->
    active = @$list.find("li.active")

    switch e.which
      when @keys.up
        if active.length
          active.removeClass "active"
          @activate active.prev()
        else
          @activate @$list.find("li").last()
      when @keys.down
        if active.length
          active.removeClass "active"
          @activate active.next()
        else
          @activate @$list.find("li").first()
      when @keys.esc
        active.removeClass "active"
        @close()
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

    $li.on 'mouseenter',(e)->
      self.$list.find('li').removeClass "active"
      self.activate $(e.target)

    $li.on 'click',(e)->
      $(e.target).removeClass "active"
      self.P.input.val $(e.target).data('val')
      self.close()

    $li.on 'mouseleave',(e)->
      $(e.target).removeClass "active"




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
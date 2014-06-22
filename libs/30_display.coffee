# Класс для показа списка
class Display
  #кнопки
  keys:
    up: 38
    down: 40
    esc: 27
    enter: 13

  # шаблон основного объекта
  template:->
    """
<div id="#{@P.opt.prefix}_autocomplete"><ul></ul></div>

    """
  # шаблон строки
  row:(item)->
    name = item.name
    if @highlight
      name = name.replace new RegExp( '(' + @highlight + ')', 'gi') , (highlight)->
        "<strong>#{highlight}</strong>"
    "<li data-val=\"#{item.name}\" > #{name} </li>"

  # шаблон стилей
  # @todo поменять background-image на встроенный
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




class Display
  # объект
  template:->
    """
<div id="#{@P.opt.prefix}_autocomplete"><ul></ul></div>

    """
  # строка
  row:(item)->
    "<li><a data-val=\"#{item.name}\"> #{item.name} </a></li>"
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
    $('body').append @template()
    $('head').append @style()
    @$el = $("##{@P.opt.prefix}_autocomplete")
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

  # события
  events:->
    # @$list

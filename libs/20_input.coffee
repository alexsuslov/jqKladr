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


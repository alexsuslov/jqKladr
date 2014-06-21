(($) ->
  $.kladr = {}

  # Service URL
  $.kladr.url = "http://kladr-api.ru/api.php"

  # Enum KLADR object types
  $.kladr.type =
    region: "region"
    district: "district"
    city: "city"
    street: "street"
    building: "building"


  # Send query to service
  $.kladr.api = (query, callback) ->
    params = {}
    params.token = query.token  if query.token
    params.key = query.key  if query.key
    params.contentType = query.type  if query.type
    params.query = query.name  if query.name
    params[query.parentType + "Id"] = query.parentId  if query.parentType and query.parentId
    params.withParent = 1  if query.withParents
    params.limit = (if query.limit then query.limit else 2000)
    completed = false
    $.getJSON $.kladr.url + "?callback=?", params, (data) ->
      return  if completed
      completed = true
      callback and callback(data.result)
      return

    setTimeout (->
      return  if completed
      completed = true
      console.error "Request error"
      callback and callback([])
      return
    ), 5000
    return


  # Check existence object
  $.kladr.check = (query, callback) ->
    query.withParents = false
    query.limit = 1
    $.kladr.api query, (objs) ->
      if objs and objs.length
        callback and callback(objs[0])
      else
        callback and callback(false)
      return

    return

  return
) jQuery
(($, undefined_) ->
  $.fn.kladr = (param1, param2) ->
    debugger
    kladr = (input, param1, param2) ->
      ac = {}
      spinner = {}
      options = {}
      init = (param1, param2, callback) ->
        options = input.data("kladr-options")
        if param2 isnt `undefined`
          options[param1] = param2
          input.data "kladr-options", options
          return input
        if $.type(param1) is "string"
          return null  unless options
          return options[param1]
        return input  if options
        options = defaultOptions
        if $.type(param1) is "object"
          for i of param1
            options[i] = param1[i]
        input.data "kladr-options", options
        callback and callback()
        input
      create = ->
        container = $(document.getElementById("kladr_autocomplete"))
        inputName = input.attr("name")
        container = $("<div id=\"kladr_autocomplete\"></div>").appendTo("body")  unless container.length
        input.attr "autocomplete", "off"
        ac = $("<ul class=\"kladr_autocomplete_" + inputName + "\" style=\"display: none;\"></ul>")
        ac.appendTo container
        spinner = $("<div class=\"spinner kladr_autocomplete_" + inputName + "_spinner\" class=\"spinner\" style=\"display: none;\"></div>")
        spinner.appendTo container
        return
      render = (objs, query) ->
        ac.empty()
        for i of objs
          obj = objs[i]
          value = options.valueFormat(obj, query)
          label = options.labelFormat(obj, query)
          a = $("<a data-val=\"" + value + "\">" + label + "</a>")
          a.data "kladr-object", obj
          li = $("<li></li>").append(a)
          li.appendTo ac
        return
      position = ->
        inputOffset = input.offset()
        inputWidth = input.outerWidth()
        inputHeight = input.outerHeight()
        ac.css
          top: inputOffset.top + inputHeight + "px"
          left: inputOffset.left

        differ = ac.outerWidth() - ac.width()
        ac.width inputWidth - differ
        spinnerWidth = spinner.width()
        spinnerHeight = spinner.height()
        spinner.css
          top: inputOffset.top + (inputHeight - spinnerHeight) / 2 - 1
          left: inputOffset.left + inputWidth - spinnerWidth - 2

        return
      open = (event) ->

        # return on keyup control keys
        return  if (event.which > 8) and (event.which < 46)
        return  unless validate()
        query = key(input.val())
        unless $.trim(query)
          close()
          return
        spinnerShow()
        trigger "send"
        options.source query, (objs) ->
          spinnerHide()
          trigger "received"
          unless input.is(":focus")
            close()
            return
          if not $.trim(input.val()) or not objs.length
            close()
            return
          render objs, query
          position()
          ac.slideDown 50
          trigger "open"
          return

        return
      close = ->
        select()
        ac.hide()
        trigger "close"
        return
      validate = ->
        switch options.type
          when $.kladr.type.region, $.kladr.type.district, $.kladr.type.city
            if options.parentType and not options.parentId
              console.error "parentType is defined and parentId in not"
              return false
          when $.kladr.type.street
            unless options.parentType is $.kladr.type.city
              console.error "For street parentType must equal \"city\""
              return false
            unless options.parentId
              console.error "For street parentId must defined"
              return false
          when $.kladr.type.building
            unless options.parentType is $.kladr.type.street
              console.error "For building parentType must equal \"street\""
              return false
            unless options.parentId
              console.error "For building parentId must defined"
              return false
          else
            console.error "type must defined and equal \"region\", \"district\", \"city\", \"street\" or \"building\""
            return false
        if options.limit < 1
          console.error "limit must greater than 0"
          return false
        true
      select = ->
        a = ac.find(".active a")
        return  unless a.length
        input.val a.attr("data-val")
        options.current = a.data("kladr-object")
        input.data "kladr-options", options
        trigger "select", options.current
        return
      keyselect = (event) ->
        active = ac.find("li.active")
        switch event.which
          when keys.up
            if active.length
              active.removeClass "active"
              active = active.prev()
            else
              active = ac.find("li").last()
            active.addClass "active"
            obj = active.find("a").data("kladr-object")
            trigger "preselect", obj
            select()  if options.arrowSelect
          when keys.down
            if active.length
              active.removeClass "active"
              active = active.next()
            else
              active = ac.find("li").first()
            active.addClass "active"
            obj = active.find("a").data("kladr-object")
            trigger "preselect", obj
            select()  if options.arrowSelect
          when keys.esc
            active.removeClass "active"
            close()
          when keys.enter
            select()  unless options.arrowSelect
            active.removeClass "active"
            close()
            false
      mouseselect = ->
        close()
        input.focus()
        false
      change = ->
        return  unless options.verify
        return  unless validate()
        query = key(input.val())
        return  unless $.trim(query)
        spinnerShow()
        trigger "send"
        options.source query, (objs) ->
          spinnerHide()
          trigger "received"
          obj = null
          i = 0

          while i < objs.length
            queryLowerCase = query.toLowerCase()
            nameLowerCase = objs[i].name.toLowerCase()
            if queryLowerCase is nameLowerCase
              obj = objs[i]
              break
            i++
          input.val options.valueFormat(obj, query)  if obj
          options.current = obj
          input.data "kladr-options", options
          trigger "check", options.current
          return

        return
      key = (val) ->
        en = "1234567890qazwsxedcrfvtgbyhnujmik,ol.p;[']- " + "QAZWSXEDCRFVTGBYHNUJMIK<OL>P:{\"} "
        ru = "1234567890йфяцычувскамепинртгоьшлбщдюзжхэъ- " + "ЙФЯЦЫЧУВСКАМЕПИНРТГОЬШЛБЩДЮЗЖХЭЪ "
        strNew = ""
        ch = undefined
        index = undefined
        i = 0

        while i < val.length
          ch = val[i]
          index = en.indexOf(ch)
          if index > -1
            strNew += ru[index]
            continue
          strNew += ch
          i++
        strNew
      trigger = (event, obj) ->
        return  unless event
        input.trigger "kladr_" + event, obj
        options[event].call input.get(0), obj  if options[event]
        return
      spinnerStart = ->
        return  if spinnerInterval
        top = -0.2
        spinnerInterval = setInterval(->
          unless spinner.is(":visible")
            clearInterval spinnerInterval
            spinnerInterval = null
            return
          spinner.css "background-position", "0% " + top + "%"
          top += 5.555556
          top = -0.2  if top > 95
          return
        , 30)
        return
      spinnerShow = ->
        if options.showSpinner
          spinner.show()
          spinnerStart()
        return
      spinnerHide = ->
        spinner.hide()
        return
      ac = null
      spinner = null
      options = null
      defaultOptions =
        token: null
        key: null
        type: null
        parentType: null
        parentId: null
        limit: 10
        withParents: false
        verify: false
        showSpinner: true
        arrowSelect: true
        current: null
        open: null
        close: null
        send: null
        received: null
        select: null
        check: null
        source: (query, callback) ->
          params =
            token: options.token
            key: options.token
            type: options.type
            name: query
            parentType: options.parentType
            parentId: options.parentId
            withParents: options.withParents
            limit: options.limit

          $.kladr.api params, callback
          return

        labelFormat: (obj, query) ->
          label = ""
          name = obj.name.toLowerCase()
          query = query.toLowerCase()
          start = name.indexOf(query)
          start = (if start > 0 then start else 0)
          label += obj.typeShort + ". "  if obj.typeShort
          if query.length < obj.name.length
            label += obj.name.substr(0, start)
            label += "<strong>" + obj.name.substr(start, query.length) + "</strong>"
            label += obj.name.substr(start + query.length, obj.name.length - query.length - start)
          else
            label += "<strong>" + obj.name + "</strong>"
          label

        valueFormat: (obj, query) ->
          obj.name

      keys =
        up: 38
        down: 40
        esc: 27
        enter: 13

      spinnerInterval = null
      return init(param1, param2, ->
        isActive = false
        create()
        position()
        input.keyup open
        input.keydown keyselect
        input.change ->
          change()  unless isActive
          return

        input.blur ->
          close()  unless isActive
          return

        ac.on "click", "li, a", mouseselect
        ac.on "mouseenter", "li", ->
          $this = $(this)
          ac.find("li.active").removeClass "active"
          $this.addClass "active"
          obj = $this.find("a").data("kladr-object")
          trigger "preselect", obj
          isActive = true
          return

        ac.on "mouseleave", "li", ->
          $(this).removeClass "active"
          isActive = false
          return

        $(window).resize position
        return
      )
      return
    result = `undefined`
    @each ->
      res = kladr($(this), param1, param2)
      result = res  if result is `undefined`
      return

    return result
    return

  return
) jQuery

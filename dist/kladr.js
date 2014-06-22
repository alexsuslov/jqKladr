(function() {
  var Display, Input, Kladr, Plugin;

  Kladr = (function() {
    function Kladr(P) {
      this.P = P;
      if (this.P.opt) {
        this.opt = this.P.opt;
      }
    }

    Kladr.prototype.url = "http://kladr-api.ru/api.php";

    Kladr.prototype.type = {
      region: "region",
      district: "district",
      city: "city",
      street: "street",
      building: "building"
    };


    /*
    Api
    @param query[string] строка адреса
    @param callback[function] (result)
     */

    Kladr.prototype.api = function(query, callback) {
      var params;
      params = {};
      if (this.opt.token) {
        params.token = this.opt.token;
      }
      if (this.opt.key) {
        params.key = this.opt.key;
      }
      if (this.opt.type) {
        params.contentType = this.opt.type;
      }
      if (query) {
        params.query = query;
      }
      if (this.opt.cityId) {
        params.cityId = this.opt.cityId;
      }
      params.limit = (this.opt.limit ? this.opt.limit : 2000);
      if (this.opt.Type && this.opt.parentId) {
        params[this.opt.Type + "Id"] = this.opt.parentId;
      }
      params._ = Math.round(new Date().getTime() / 1000);
      $.getJSON($.kladr.url + "?callback=?", params, function(data, textStatus) {
        if (callback) {
          return callback(data.result);
        }
      });
      return this;
    };

    Kladr.prototype.check = function(query, callback) {
      query.withParents = false;
      query.limit = 1;
      return this.api(query, function(objs) {
        if (objs && objs.length) {
          return callback && callback(objs[0]);
        } else {
          return callback && callback(false);
        }
      });
    };

    return Kladr;

  })();

  Input = (function() {

    /*
    Конструктор
    @param P[Object] parrent object
     */
    function Input(P) {
      var _ref;
      this.P = P;
      console.log('load input');
      if (this.P.el) {
        this.$el = $(this.P.el);
      }
      if ((_ref = this.P) != null ? _ref.opt : void 0) {
        this.opt = this.P.opt;
      }
      this.kladr = this.P.kladr;
      this.events();
    }

    Input.prototype.val = function(value) {
      if (typeof value === 'undefined') {
        return this.$el.val();
      } else {
        return this.$el.val(value);
      }
    };

    Input.prototype.events = function() {
      var self;
      self = this;
      this.$el.on('keyup', function(e) {
        var query, _ref;
        if ((8 < (_ref = event.which) && _ref < 46)) {
          return;
        }
        e.target.value = $.trim(self.key(e.target.value));
        query = e.target.value;
        if (!query) {
          self.P.close();
          return;
        }
        return self.P.query(query);
      });
      return this.$el.on('keydown', function(e) {
        return self.P.display.keyselect(e);
      });
    };

    Input.prototype.validate = function() {
      return true;
    };


    /*
    Обработка данных
     */

    Input.prototype.key = function(val) {
      var char, key, newStr, str, _i, _len;
      key = {
        en: "1234567890qazwsxedcrfvtgbyhnujmik,ol.p;[']- " + "QAZWSXEDCRFVTGBYHNUJMIK<OL>P:{\"} ",
        ru: "1234567890йфяцычувскамепинртгоьшлбщдюзжхэъ- " + "ЙФЯЦЫЧУВСКАМЕПИНРТГОЬШЛБЩДЮЗЖХЭЪ ",
        enRU: function(char) {
          var idx;
          idx = this.en.indexOf(char);
          if (idx !== -1) {
            return this.ru[idx];
          }
          return char;
        }
      };
      str = val.split('');
      newStr = '';
      for (_i = 0, _len = str.length; _i < _len; _i++) {
        char = str[_i];
        newStr += key.enRU(char);
      }
      return newStr;
    };

    return Input;

  })();

  Display = (function() {
    Display.prototype.keys = {
      up: 38,
      down: 40,
      esc: 27,
      enter: 13
    };

    Display.prototype.template = function() {
      return "<div id=\"" + this.P.opt.prefix + "_autocomplete\"><ul></ul></div>\n";
    };

    Display.prototype.row = function(item) {
      var name;
      name = item.name;
      if (this.highlight) {
        name = name.replace(new RegExp('(' + this.highlight + ')', 'gi'), function(highlight) {
          return "<strong>" + highlight + "</strong>";
        });
      }
      return "<li data-val=\"" + item.name + "\" > " + name + " </li>";
    };

    Display.prototype.style = function() {
      return "<style>\n#" + this.P.opt.prefix + "_autocomplete ul{\n    position: absolute;\n    display: block;\n    margin: 0;\n    padding: 0;\n    border: 1px solid rgb(138, 138, 138);\n    border-radius: 3px;\n    background-color: white;\n    z-index: 9999;\n}\n\n#" + this.P.opt.prefix + "_autocomplete li{\n    display: list-item;\n    list-style-type: none;\n    margin: 0;\n    padding: 3px 5px;\n    overflow: hidden;\n    border: 1px solid white;\n    border-bottom: 1px solid rgb(189, 189, 189);\n}\n\n#" + this.P.opt.prefix + "_autocomplete li.active{\n    background-color: rgb(224, 224, 224);\n    border-radius: 3px;\n    border: 1px solid rgb(151, 151, 151);\n}\n\n#" + this.P.opt.prefix + "_autocomplete a{\n    display: block;\n    cursor: default;\n    width: 10000px;\n}\n\n#" + this.P.opt.prefix + "_autocomplete .spinner{\n    position: absolute;\n    display: block;\n    margin: 0;\n    padding: 0;\n    width: 20px;\n    height: 20px;\n    background-color: transparent;\n    background-image: url(\"images/spinner.png\");\n    background-position: center center;\n    background-repeat: no-repeat;\n    z-index: 9999;\n}\n</style>";
    };

    function Display(P) {
      this.P = P;
      if (this.P.opt) {
        this.opt = this.P.opt;
      }
      $('body').append(this.template());
      $('head').append(this.style());
      this.$el = $("#" + this.P.opt.prefix + "_autocomplete");
      this.$el.hide();
      this.$list = $("#" + this.P.opt.prefix + "_autocomplete ul");
      this.position();
    }

    Display.prototype.position = function() {
      var differ, input, inputHeight, inputOffset, inputWidth;
      input = this.P.input.$el;
      inputOffset = input.offset();
      inputWidth = input.outerWidth();
      inputHeight = input.outerHeight();
      this.$list.css({
        top: inputOffset.top + inputHeight + "px",
        left: inputOffset.left
      });
      differ = this.$list.outerWidth() - this.$list.width();
      return this.$list.width(inputWidth - differ);
    };

    Display.prototype.render = function() {
      var model, self, _i, _len, _ref;
      self = this;
      this.$list.empty();
      _ref = this.collection;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        model = _ref[_i];
        self.$list.append(this.row(model));
      }
      this.events();
      return this.$el.show();
    };

    Display.prototype.activate = function(active) {
      return active.addClass("active");
    };

    Display.prototype.keyselect = function(e) {
      var active;
      active = this.$list.find("li.active");
      switch (e.which) {
        case this.keys.up:
          if (active.length) {
            active.removeClass("active");
            return this.activate(active.prev());
          } else {
            return this.activate(this.$list.find("li").last());
          }
          break;
        case this.keys.down:
          if (active.length) {
            active.removeClass("active");
            return this.activate(active.next());
          } else {
            return this.activate(this.$list.find("li").first());
          }
          break;
        case this.keys.esc:
          active.removeClass("active");
          return this.close();
        case this.keys.enter:
          if (!this.opt.arrowSelect) {
            this.P.input.val($(active).data('val'));
          }
          active.removeClass("active");
          return this.close();
      }
    };

    Display.prototype.close = function() {
      return this.$el.hide();
    };

    Display.prototype.events = function() {};

    return Display;

  })();

  Plugin = (function() {
    function Plugin(opt, el) {
      this.opt = opt;
      this.el = el;
      console.log('plugin load');
      this.$el = $(this.el);
      this.kladr = new Kladr(this);
      if (this.$el) {
        console.log('create input');
        this.input = new Input(this);
      }
      this.display = new Display(this);
    }


    /*
     *
     */


    /*
    Обработка полученных
    @param query[String] запрос
     */

    Plugin.prototype.query = function(query) {
      var self;
      self = this;
      this.display.highlight = query;
      return this.kladr.api(query, function(result) {
        return self.open(result);
      });
    };

    Plugin.prototype.open = function(result) {
      this.display.collection = result;
      return this.display.render();
    };

    Plugin.prototype.close = function() {};

    return Plugin;

  })();

  $(function() {
    return $.fn.jqKladr = function(options) {
      return new Plugin(options, this);
    };
  });

  $(function() {
    return $('[name="mskstreet"]').jqKladr({
      prefix: 'jqKladr',
      token: '51dfe5d42fb2b43e3300006e',
      key: '86a2c2a06f1b2451a87d05512cc2c3edfdf41969',
      type: 'street',
      Type: 'city',
      parentId: '7700000000000',
      limit: 10
    });
  });

}).call(this);

//# sourceMappingURL=../dist/kladr.js.map

(function() {
  var Display, Input, Kladr, Option, Plugin;

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

  Option = (function() {
    function Option() {}

    Option.prototype.token = null;

    Option.prototype.key = null;

    Option.prototype.type = null;

    Option.prototype.parentType = null;

    Option.prototype.parentId = null;

    Option.prototype.limit = 10;

    Option.prototype.withParents = false;

    Option.prototype.verify = false;

    Option.prototype.showSpinner = true;

    Option.prototype.arrowSelect = true;

    Option.prototype.current = null;

    Option.prototype.open = null;

    Option.prototype.close = null;

    Option.prototype.send = null;

    Option.prototype.received = null;

    Option.prototype.select = null;

    Option.prototype.check = null;


    /*
    Получения списка объектов отображаемых при автодополнении.
    По-умолчанию запрашивает данные у сервиса [kladr-api.ru] [1].
    Может быть переопределена для получения объектов из другого источника.
    @param query[]
    @param calback[function]
     */

    Option.prototype.source = function(query, callback) {
      var params;
      params = {
        token: options.token,
        key: options.token,
        type: options.type,
        name: query,
        parentType: options.parentType,
        parentId: options.parentId,
        withParents: options.withParents,
        limit: options.limit
      };
      if (callback) {
        $.kladr.api(params, callback);
      }
      return this;
    };


    /*
    Форматирования значений в списке.
    @param obj[Object] – объект КЛАДР,
    @param query[String]– текущее значение поля ввода.
     */

    Option.prototype.labelFormat = function(obj, query) {
      var label, name, start;
      label = "";
      name = obj.name.toLowerCase();
      query = query.toLowerCase();
      start = name.indexOf(query);
      start = (start > 0 ? start : 0);
      if (obj.typeShort) {
        label += obj.typeShort + ". ";
      }
      if (query.length < obj.name.length) {
        label += obj.name.substr(0, start);
        label += "<strong>" + obj.name.substr(start, query.length) + "</strong>";
        label += obj.name.substr(start + query.length, obj.name.length - query.length - start);
      } else {
        label += "<strong>" + obj.name + "</strong>";
      }
      return label;
    };


    /*
    Форматирования подставляемых в поле ввода значений.
    @param obj[Object] – объект КЛАДР,
    @param query[String]– текущее значение поля ввода.
     */

    Option.prototype.valueFormat = function(obj, query) {
      return obj.name;
    };

    return Option;

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

    Input.prototype.events = function() {
      var self;
      self = this;
      return this.$el.on('keyup', function(e) {
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
    function Display() {}

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
    }


    /*
     *
     */


    /*
    Обработка полученных
    @param query[String] запрос
     */

    Plugin.prototype.query = function(query) {
      return this.kladr.api(query, function(result) {
        return console.log(result);
      });
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

(function() {
  $(function() {
    var Address, Log, MapUpdate, building, buildingAdd, city, key, map, map_created, optionsBuilding, optionsCity, optionsStreet, placemark, street, token;
    token = "51dfe5d42fb2b43e3300006e";
    key = "86a2c2a06f1b2451a87d05512cc2c3edfdf41969";
    city = $("[name=\"city\"]");
    street = $("[name=\"street\"]");
    building = $("[name=\"building\"]");
    buildingAdd = $("[name=\"building-add\"]");
    map = null;
    placemark = null;
    map_created = false;
    Address = {
      zoom: 12,
      set: function(name, value) {
        if (!name) {
          return;
        }
        this[name] = value;
        if (name === 'city') {
          this[name].zoom = 12;
        }
        if (name === 'street') {
          this[name].zoom = 14;
        }
        if (name === 'building') {
          this[name].zoom = 16;
        }
        this[name].address = this.renderAddress(value);
        return MapUpdate(this.address());
      },
      renderAddress: function(obj) {
        return "" + obj.typeShort + ". " + obj.name;
      },
      address: function() {
        var addr, comma, item, _i, _len, _ref;
        comma = '';
        addr = {
          address: '',
          zoom: 0
        };
        _ref = ['city', 'street', 'building'];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          item = _ref[_i];
          if (this[item]) {
            addr.address += comma + this[item].address;
            if (addr.zoom < this[item].zoom) {
              addr.zoom = this[item].zoom;
            }
            if (this[item].zip) {
              addr.zip = this[item].zip;
            }
            addr.type = this[item].type;
            addr.sType = this[item].typeShort;
            comma = ', ';
          }
        }
        return addr;
      },
      addressText: function() {
        var obj;
        obj = this.address();
        return "" + obj.zip + ", " + obj.address;
      }
    };
    optionsBuilding = {
      prefix: 'BuildingKl',
      token: token,
      key: key,
      type: 'building',
      verify: true,
      onSelect: function(obj) {
        Log(obj);
        Address.set('building', obj);
        return $("#address").text(Address.addressText());
      }
    };
    optionsStreet = {
      prefix: 'streetKl',
      token: token,
      key: key,
      type: 'street',
      Type: 'city',
      verify: true,
      limit: 10,
      onSelect: function(obj) {
        Log(obj);
        Address.set('street', obj);
        $("#address").text(Address.addressText());
        optionsBuilding.parentId = obj.id;
        return optionsBuilding.Type = obj.contentType;
      }
    };
    optionsCity = {
      prefix: 'cityKl',
      token: token,
      key: key,
      type: 'city',
      withParents: true,
      verify: true,
      limit: 10,
      onSelect: function(obj) {
        Log(obj);
        Address.set('city', obj);
        $("#address").text(Address.addressText());
        optionsStreet.parentId = obj.id;
        return optionsStreet.Type = obj.contentType;
      }
    };
    city.jqKladr(optionsCity);
    street.jqKladr(optionsStreet);
    building.jqKladr(optionsBuilding);
    buildingAdd.change(function() {
      Log(null);
      AddressUpdate();
      MapUpdate();
    });
    MapUpdate = function(opt) {
      var geocode;
      if (map_created && opt.address) {
        geocode = ymaps.geocode(opt.address);
        geocode.then(function(res) {
          var position;
          map.geoObjects.each(function(geoObject) {
            map.geoObjects.remove(geoObject);
          });
          position = res.geoObjects.get(0).geometry.getCoordinates();
          placemark = new ymaps.Placemark(position, {}, {});
          map.geoObjects.add(placemark);
          map.setCenter(position, opt.zoom);
        });
      }
    };
    Log = function(obj) {
      var logId, logName, logType, logTypeShort, logZip;
      logId = $("#id");
      if (obj && obj.id) {
        logId.find(".value").text(obj.id);
        logId.show();
      } else {
        logId.hide();
      }
      logName = $("#name");
      if (obj && obj.name) {
        logName.find(".value").text(obj.name);
        logName.show();
      } else {
        logName.hide();
      }
      logZip = $("#zip");
      if (obj && obj.zip) {
        logZip.find(".value").text(obj.zip);
        logZip.show();
      } else {
        logZip.hide();
      }
      logType = $("#type");
      if (obj && obj.type) {
        logType.find(".value").text(obj.type);
        logType.show();
      } else {
        logType.hide();
      }
      logTypeShort = $("#type_short");
      if (obj && obj.typeShort) {
        logTypeShort.find(".value").text(obj.typeShort);
        logTypeShort.show();
      } else {
        logTypeShort.hide();
      }
    };
    ymaps.ready(function() {
      if (map_created) {
        return;
      }
      map_created = true;
      map = new ymaps.Map("map", {
        center: [55.76, 37.64],
        zoom: 12
      });
      map.controls.add("smallZoomControl", {
        top: 5,
        left: 5
      });
    });
  });

}).call(this);

//# sourceMappingURL=../../examples/js/exp4.js.map

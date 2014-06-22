(function() {
  $(function() {
    var $location, $street, key, locationOptions, streetOptions, token;
    $location = $("[name=\"location1\"]");
    $street = $("[name=\"street1\"]");
    token = "51dfe5d42fb2b43e3300006e";
    key = "86a2c2a06f1b2451a87d05512cc2c3edfdf41969";
    streetOptions = {
      prefix: 'streetKL',
      token: token,
      key: key,
      type: 'street',
      Type: 'city'
    };
    locationOptions = {
      prefix: 'locationKL',
      token: token,
      key: key,
      type: 'city',
      onSelect: function(obj) {
        return streetOptions.parentId = obj.id;
      }
    };
    $location.jqKladr(locationOptions);
    return $street.jqKladr(streetOptions);
  });

}).call(this);

//# sourceMappingURL=../../examples/js/exp3.js.map

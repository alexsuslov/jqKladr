(function() {
  $(function() {
    var city, options, street;
    city = $("[name=\"city1\"]");
    options = {
      prefix: 'jqKladr',
      token: "51dfe5d42fb2b43e3300006e",
      key: "86a2c2a06f1b2451a87d05512cc2c3edfdf41969",
      type: 'street',
      Type: 'city',
      parentId: city.val()
    };
    street = $("[name=\"street1\"]");
    street.jqKladr(options);
    return city.change(function() {
      return options.parentId = city.val();
    });
  });

}).call(this);

//# sourceMappingURL=../../examples/js/exp2.js.map

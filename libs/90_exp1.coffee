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
$ ->
  $('#dev-location-on').click ->
    NetMap.Pil.locationOn()
  $('#dev-location-off').click ->
    NetMap.Pil.locationOff()
  $('#dev-location-button').click ->
    jsonString = NetMap.Pil.locationJson()
    $('#dev-location-data').text jsonString
  $('#dev-store-light-button').click ->
    jsonString = NetMap.Pil.startReading '',
        NetMap.PilEvents.wrapCallback (digest) ->
          $('#dev-location-data').text digest
  $('#dev-store-ndt-button').click ->
    jsonString = NetMap.Pil.startReading 'ndt',
        NetMap.PilEvents.wrapCallback (digest) ->
          $('#dev-location-data').text digest
  $('#dev-store-wifi-button').click ->
    jsonString = NetMap.Pil.startReading 'wifi-ap',
        NetMap.PilEvents.wrapCallback (digest) ->
          $('#dev-location-data').text digest
  $('#dev-upload-button').click ->
    NetMap.Pil.uploadReadingPack NetMap.PilEvents.wrapCallback (done) ->
      $('#dev-location-data').text done
  NetMap.PilEvents.addListener 'location', ->
    $('#dev-location-data').text '- ' + NetMap.Pil.locationJson()

  NetMap.Pil.saveCookies location.origin

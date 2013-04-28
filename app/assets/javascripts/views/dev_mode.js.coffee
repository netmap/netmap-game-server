$ ->
  $('#dev-location-on').click ->
    NetMap.Pil.locationOn()
  $('#dev-location-off').click ->
    NetMap.Pil.locationOff()
  $('#dev-location-button').click ->
    jsonString = NetMap.Pil.locationJson()
    $('#dev-location-data').text jsonString
  $('#dev-store-button').click ->
    jsonString = NetMap.Pil.startReading 'gps',
        NetMap.PilEvents.wrapCallback (digest) ->
          $('#dev-location-data').text digest
  $('#dev-upload-button').click ->
    NetMap.Pil.uploadReadingPack NetMap.PilEvents.wrapCallback (done) ->
      $('#dev-location-data').text done

  NetMap.Pil.saveCookies location.origin

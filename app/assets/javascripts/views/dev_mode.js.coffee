$ ->
  $('#dev-location-on').click ->
    NetMap.Pil.trackLocation true
  $('#dev-location-off').click ->
    NetMap.Pil.trackLocation false
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
    $('#dev-location-data').text 'loc: ' + NetMap.Pil.locationJson()
  NetMap.PilEvents.addListener 'power', ->
    $('#dev-location-data').text 'pow: ' + NetMap.Pil.powerStateJson()
  NetMap.PilEvents.addListener 'network', ->
    $('#dev-location-data').text 'net: ' + NetMap.Pil.networkStateJson()

  NetMap.Pil.saveCookies location.origin

$ ->
  $('#dev-gps-start').click ->
    NetMap.Pil.gpsStart()
  $('#dev-gps-stop').click ->
    NetMap.Pil.gpsStop()
  $('#dev-gps-button').click ->
    jsonString = NetMap.Pil.gpsInfoJson()
    $('#dev-gps-data').text jsonString
  $('#dev-store-button').click ->
    jsonString = NetMap.Pil.readSensor()
  $('#dev-upload-button').click ->
    NetMap.Pil.uploadReadingPack()


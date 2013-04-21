initRecorder = ->
  url = window.location.origin + '/net_readings'

  if cookieMatch = /(^|;)\s?_netmap_session=([^;+])/.exec(document.cookie)
    cookie = unescape(cookieMatch[2])
  else
    cookie = ''

  csrfToken = document.querySelector('meta[name="csrf-token"]').
      getAttribute('content')

  NetMap.Pil.setReadingsUploadBackend url, cookie, csrfToken

$ ->
  initRecorder()

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
    jsonString = NetMap.Pil.uploadReadingPack()


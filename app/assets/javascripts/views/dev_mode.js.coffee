$ ->
  $('#dev-gps-start').click ->
    NetMap.gpsStart()
  $('#dev-gps-stop').click ->
    NetMap.gpsStop()
  $('#dev-gps-button').click ->
    if typeof NetMap is 'undefined'
      traceText = 'NetMap undefined'
    else if not NetMap.getGpsTrace
      traceText = 'NetMap.getGpsTrace missing'
    else
      traceText = NetMap.getGpsTrace()

    $('#dev-gps-data').text traceText

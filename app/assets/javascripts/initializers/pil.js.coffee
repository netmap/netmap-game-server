# Emulates the client app's platform interface layer on browsers.

window.NetMap or= {}

# NetMap.Pil will be an instance of this class.
#
# This is the low-level interface to the mobile client application. Game code
# should not call methods here directly.
class PilClass
  constructor: ->
    @_initGeo()
    @_initRecorder()

  # Starts querying the GPS for a position.
  #
  # This is called when the application becomes active.
  gpsStart: ->
    return unless @_geoWatch is null
    @_geoStatus.enabled = true
    @_geoStatus.started = true
    @_geoFixStart = Date.now()
    @_geoWatch = navigator.geolocation.watchPosition(
        @_boundOnGeoLocation, @_boundOnGeoError,
        enableHighAccuracy: true, maximumAge:1000)
    null

  # Stops querying the GPS.
  gpsStop: ->
    return if @_geoWatch is null
    navigator.geolocation.clearWatch @_geoWatch
    null

  # Reads the current GPS status.
  #
  # @return {String} a JSON-encoded string representing GPS
  gpsInfoJson: ->
    JSON.stringify @_geoStatus

  # Sketch: read sensor information and store it in the database.
  readSensor: ->
    reading = JSON.stringify
      gps: JSON.parse(@gpsInfoJson()),
      timestamp: Date.now()
    @_storeReading reading, ->
      console.log 'done storing'

  # Upload queued sensor readings to the server.
  uploadReadingPack: ->
    @_readPack 128 * 1024, (packData, lastReadingId) =>
      if lastReadingId is 0
        console.log 'no readings to send'
        return
      @_uploadPackData packData, @_dbUploadUrl, (success) =>
        if success
          @_deletePack lastReadingId, =>
            console.log 'done sending'

  # Sets the URL of the server that receives the sensor readings.
  #
  # The server URL will be persisted until a new URL is set by calling this
  # method.
  #
  # @param {String} url fully-qualified URL to the HTTP backend that will
  #     recieve readings as POST data
  # @param {String} cookie value of the Cookie HTTP header sent when uploading
  #     sensor reading data
  # @param {String} csrfToken value of the X-CSRF-Token HTTP header sent when
  #     uploading sensor reading data
  setReadingsUploadBackend: (url, cookie, csrfToken) ->
    if url isnt @_dbUploadUrl or cookie isnt @_dbUploadCookie or
        csrfToken isnt @_dbUploadToken
      @_dbUploadUrl = url
      @_dbUploadCookie = cookie
      @_dbUploadToken = csrfToken
      localStorage.setItem '_dbUploadBackend', JSON.stringify(
          url: url, cookie: cookie, token: csrfToken)
    null

  # Sets up the sensor readings storage.
  _initRecorder: ->
    @_dbCallbacks = []
    @_db = null
    try
      dbUploadBackend = JSON.parse localStorage.getItem('_dbUploadBackend')
    catch jsonError
      dbUploadBackend = null
    dbUploadBackend or=  url: 'http://netmap.pwnb.us', cookie: '', token: ''
    @_dbUploadUrl = dbUploadBackend.url
    @_dbUploadCookie = dbUploadBackend.cookie
    @_dbUploadToken = dbUploadBackend.token

    request = indexedDB.open 'recorder', 1
    request.onsuccess = (event) =>
      db = event.target.result
      @_db = db
      for callback in @_dbCallbacks
        callback @_db
      @_dbCallbacks = null
    request.onupgradeneeded = (event) =>
      db = event.target.result
      transaction = event.target.transaction
      db.createObjectStore 'metrics', keyPath: 'id', autoIncrement: true
      transaction.error = (event) =>
        console.warn 'IndexedDB error', event.target.error
    request.onblocked = (event) =>
      console.warn 'IndexedDB blocked', event.target.error
    request.onerror = (event) =>
      console.warn 'IndexedDB open error', event.target.error
    null

  # Obtains the actively open database connection.
  #
  # @param {function(IDBDatabase)} callback called with the IndexedDB database
  # @return null
  _recorderDb: (callback) ->
    if @_db
      callback @_db
    else
      @_dbCallbacks.push callback
    return null

  # Queues a sensor reading for later transmission.
  #
  # @param {String} jsonData the reading's information, encoded as a JSON
  #   string
  # @param {function()} callback called when the reading is stored
  #   successsfully
  _storeReading: (jsonData, callback) ->
    @_recorderDb (db) ->
      transaction = db.transaction 'metrics', 'readwrite'
      metricsStore = transaction.objectStore 'metrics'
      request = metricsStore.put json: jsonData
      transaction.oncomplete = ->
        callback()
      transaction.onerror = (event) =>
        console.warn 'IndexedDB write error', event.target.error
    null

  # Fetches queued sensor readings from the database, so they can be uploaded.
  #
  # @param {Number} packSize a guideline for the size of JSON data to be read
  # @param {function(String, Number)}
  _readPack: (packSize, callback) ->
    packBits = []
    readSize = 0
    lastReadingId = null

    @_recorderDb (db) ->
      transaction = db.transaction 'metrics', 'readonly'
      metricsStore = transaction.objectStore 'metrics'
      cursor = metricsStore.openCursor null, 'next'
      cursor.onsuccess = (event) =>
        cursor = event.target.result
        if cursor and cursor.key
          lastReadingId = cursor.key
          jsonData = cursor.value.json
          packBits.push jsonData
          packBits.push "\n"
          readSize += jsonData.length + 1
        if !cursor or readSize >= packSize
          # Done reading.
          callback packBits.join(''), lastReadingId
          return
        if cursor
          cursor.continue()
      cursor.onerror = (event) =>
        console.warn 'IndexedDB read error', event.target.error
    null

  # Uploads an already-assembled pack of sensor readings data to the server.
  #
  # @param {String} packData the sensor readings data to be uploaded; this
  #     should be obtained by calling _readPack
  # @param {String} url the absolue URL of the server receiving the upload
  # @param {String} csrfToken value of the X-CSRF-Token HTTP header
  # @param {function(Boolean)} callback called when the upload is complete; the
  #     argument will be false if something went wrong during the upload
  _uploadPackData: (packData, url, csrfToken, callback) ->
    xhr = new XMLHttpRequest
    xhr.onload = (event) ->
      if xhr.status < 200 or xhr.status >= 300
        console.warn 'XHR upload backend error', xhr.responseText
        callback false
      else
        callback true
    xhr.error = (event) ->
      console.warn 'XHR upload error', event
      callback false
    xhr.open 'POST', url, true
    xhr.setRequestHeader 'Content-Type', 'text/plain'
    xhr.setRequestHeader 'X-CSRF-Token', csrfToken
    xhr.responseType = 'text'
    xhr.send packData

  # Removes successfully uploaded sensor readings from the database.
  #
  # @param {Number} lastRecordId the ID of the last reading; this should be
  #     obtained by calling _readPack
  _deletePack: (lastRecordId, callback) ->
    @_recorderDb (db) ->
      transaction = db.transaction 'metrics', 'readwrite'
      metricsStore = transaction.objectStore 'metrics'
      metricsStore.delete IDBKeyRange.upperBound(lastRecordId)
      transaction.oncomplete = ->
        callback()
      transaction.onerror = (event) =>
        console.warn 'IndexedDB delete error', event.target.error

  # Sets up the HTML5 geolocation services.
  _initGeo: ->
    @_geoWatch = null
    @_geoFixStart = 0
    @_geoStatus =
      enabled: false, unavailable: false, browser: true, started: false,
      timeToFix: 0, satellites: []
    unless navigator.geolocation and navigator.geolocation.watchPosition
      console.error "Browser missing GPS support!"

    @_boundOnGeoLocation = (location) => @_onGeoLocation location
    @_boundOnGeoError = (error) => @_onGeoError error
    null

  # Called by the HTML5 geolocation API to report a location update.
  #
  # @private
  # This method is not in the client PIL.
  _onGeoLocation: (location) ->
    console.log location

    if @_geoStatus.timeToFix is 0
      @_geoStatus.timeToFix = (Date.now() - @_geoFixStart) / 1000.0
    @_geoStatus.unavailable = false

    time = location.timestamp
    coords = location.coords
    coords.latitude
    coords.longitude
    coords.altitude
    coords.accuracy  # meters
    coords.altitudeAccuracy
    coords.heading
    coords.speed

  # Called by the HTML5 geolocation API to report an error.
  #
  # @private
  # This method is not in the client PIL.
  _onGeoError: (error) ->
    console.log error

    switch error.code
      when 1  # PERMISSION_DENIED
        @_geoStatus.enabled = false
        @_geoStatus.unavailable = false

      when 2  # POSITION_UNAVAILABLE
        @_geoStatus.enabled = true
        @_geoStatus.unavailable = true

      when 3  # TIMEOUT
        @_geoStatus.enabled = true
        @_geoStatus.unavailable = true

if typeof _NetMapPil is 'undefined'
  NetMap.Pil = new PilClass
else
  NetMap.Pil = _NetMapPil

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

  # Starts querying the platform for a location.
  #
  # This is called when the application becomes active.
  locationOn: ->
    return unless @_geoWatch is null
    @_geoStatus.enabled = true
    @_geoStatus.started = true
    @_geoFixStart = Date.now()
    @_geoWatch = navigator.geolocation.watchPosition(
        @_boundOnGeoLocation, @_boundOnGeoError,
        enableHighAccuracy: true, maximumAge:1000)
    null

  # Stops querying the platform for a location.
  locationOff: ->
    return if @_geoWatch is null
    navigator.geolocation.clearWatch @_geoWatch
    null

  # Reads the current GPS status.
  #
  # @return {String} a JSON-encoded string representing GPS
  locationJson: ->
    JSON.stringify @_geoLocation

  # Starts reading the device's sensors.
  #
  # @param {String} measurements comma-separated list of measurements to be
  #   performed and included in the reading
  # @param {String} callbackName the name of a function to be called after all
  #   the required data was stored in the database; the function will receive
  #   the reading's digest
  startReading: (measurements, callbackName) ->
    reading = JSON.stringify
      gps: @_geoStatus,
      location: @_geoLocation,
      timestamp: Date.now()
      uid: @_dbUploadUid
    @_storeReading reading, (digest) ->
      _pil_cb[callbackName](digest)

  # Upload queued sensor readings to the server.
  #
  # @param {String} callbackName the name of a function to be called after the
  #   readings are uploaded; the function will receive true if there are more
  #   readings left to be uploaded, and false
  uploadReadingPack: (callbackName) ->
    @_readPack 128 * 1024, (packData, lastReadingId) =>
      if lastReadingId is 0
        _pil_cb[callbackName](false)
        return
      @_uploadPackData packData, @_dbUploadUrl, (success) =>
        if success
          @_deletePack lastReadingId, =>
            _pil_cb[callbackName](true)
        else
          _pil_cb[callbackName](true)

  # Sets the URL of the server that receives the sensor readings.
  #
  # The server URL will be persisted until a new URL is set by calling this
  # method.
  #
  # @param {String} url fully-qualified URL to the HTTP backend that will
  #   recieve readings as POST data
  # @param {String} uid user token to be used as the 'uid' property in all the
  #   sensor reading data
  setReadingsUploadBackend: (url, uid) ->
    if url isnt @_dbUploadUrl or uid isnt @_dbUploadUid
      @_dbUploadUrl = url
      @_dbUploadUid = uid
      localStorage.setItem '_dbUploadBackend', JSON.stringify(
          url: url, uid: uid)
    null

  # Saves the site's cookies.
  #
  # The saved cookies will be injected into WebView during the next visit.
  saveCookies: (origin) ->
    # This is a noop in the browser, because it saves cookies automatically.
    if origin isnt window.location.origin
      console.warn 'Wrong origin passed to Pil.saveCookies'

  # Sets up the sensor readings storage.
  #
  # @private
  # This method is not in the client PIL.
  _initRecorder: ->
    @_dbCallbacks = []
    @_db = null
    try
      dbUploadBackend = JSON.parse localStorage.getItem('_dbUploadBackend')
    catch jsonError
      dbUploadBackend = null
    dbUploadBackend or=  url: 'http://netmap-data.pwnb.us', uid: ''
    @_dbUploadUrl = dbUploadBackend.url
    @_dbUploadUid = dbUploadBackend.uid

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
  # @private
  # This method is not in the client PIL.
  #
  # @param {String} jsonData the reading's information, encoded as a JSON
  #   string
  # @param {function(String)} callback called when the reading is stored
  #   successsfully; the callback receives the reading's digest as an argument
  _storeReading: (jsonData, callback) ->
    digest = sjcl.codec.hex.fromBits sjcl.hash.sha256.hash(jsonData)
    @_recorderDb (db) ->
      transaction = db.transaction 'metrics', 'readwrite'
      metricsStore = transaction.objectStore 'metrics'
      request = metricsStore.put json: jsonData
      transaction.oncomplete = ->
        callback digest
      transaction.onerror = (event) =>
        console.warn 'IndexedDB write error', event.target.error
        callback null
    null

  # Fetches queued sensor readings from the database, so they can be uploaded.
  #
  # @private
  # This method is not in the client PIL.
  #
  # @param {Number} packSize a guideline for the size of JSON data to be read
  # @param {function(String, Number)}
  _readPack: (packSize, callback) ->
    packBits = []
    readSize = 0
    lastReadingId = 0

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
  # @private
  # This method is not in the client PIL.
  #
  # @param {String} packData the sensor readings data to be uploaded; this
  #     should be obtained by calling _readPack
  # @param {String} url the absolue URL of the server receiving the upload
  # @param {function(Boolean)} callback called when the upload is complete; the
  #     argument will be false if something went wrong during the upload
  _uploadPackData: (packData, url, callback) ->
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
    xhr.responseType = 'text'
    xhr.send packData

  # Removes successfully uploaded sensor readings from the database.
  #
  # @private
  # This method is not in the client PIL.
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
  #
  # @private
  # This method is not in the client PIL.
  _initGeo: ->
    @_geoWatch = null
    @_geoFixStart = 0
    @_geoLocation = {}
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
    if @_geoStatus.timeToFix is 0
      @_geoStatus.timeToFix = (Date.now() - @_geoFixStart) / 1000.0
    @_geoStatus.unavailable = false

    coords = location.coords
    geoLocation =
      latitude: coords.latitude
      longitude: coords.longitude
      accuracy: coords.accuracy
      timestamp: location.timestamp
    if coords.altitude isnt null
      geoLocation.altitude = coords.altitude
    if coords.speed isnt null
      geoLocation.speed = coords.speed
    if coords.heading or coords.heading is 0
      geoLocation.heading = coords.heading

    # TODO(pwnall): fire event
    @_geoLocation = geoLocation

  # Called by the HTML5 geolocation API to report an error.
  #
  # @private
  # This method is not in the client PIL.
  _onGeoError: (error) ->
    console.error error

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

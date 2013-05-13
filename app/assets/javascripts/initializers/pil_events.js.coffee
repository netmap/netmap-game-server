# Receives callbacks from the client app's platform interface.

window.NetMap or= {}

# Callbacks will come here.
window._pil_cb = {}

# Events will be issued here.
window._pil_ev =
  # Fired when the location reported by the platform updates.
  location: null
  # Fired when the power source reported by the platform updates.
  power: null
  # Fired when the network connection reported by the platform updates.
  network: null

# NetMap.PilEvents will be an instance of this class.
class PilEventsClass
  constructor: ->
    @id = 1
    @listeners = {}

  # Wraps a callback so the client app's platform code can call it.
  #
  # @param {function(...)} callback the function to be wrapped
  # @return {String} the callback name to be passed to the platform interface
  #   layer
  wrapCallback: (callback) ->
    callbackName = "f" + @id
    @id += 1
    _pil_cb[callbackName] = (args...) ->
      callback.apply window, args
      delete _pil_cb[callbackName]
    callbackName

  # Registers a listener for a platform interface event.
  #
  # This method is idempotent, so a function will not be added to the list of
  # listeners if was previously added.
  #
  # @param {String} eventName the event to listen for, e.g. 'location'
  # @param {function()} listener called when the event triggers
  # @return this, for easy call chaining
  addListener: (eventName, listener) ->
    unless typeof listener is 'function'
      throw new TypeError 'Invalid listener type; expected function'

    # If this is a new event, set up its dispatch function.
    unless _pil_ev[eventName]
      listeners = @listeners[eventName] = []
      _pil_ev[eventName] = (args...) =>
        for listener in listeners
          listener.apply window, args

    listeners = @listeners[eventName]
    unless listener in listeners
      listeners.push listener
    @

  # De-registers a previously registered platform event listener.
  #
  # This method is idempotent, so it will fail silently if the given listener
  # is not registered as a subscriber.
  #
  # @param {String} eventName the event name passed to a previous addListener
  #     call
  # @param {function()} listener the event handler passed to a previous
  #     addListener call
  # @return this, for easy call chaining
  removeListener: (eventName, listener) ->
    return @ unless listeners = _pil_ev[eventName]
    index = listeners.indexOf handler
    listeners.splice index, 1 if index isnt -1
    @

NetMap.PilEvents = new PilEventsClass

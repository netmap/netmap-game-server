# Receives callbacks from the client app's platform interface.

window.NetMap or= {}

# Callbacks will come here.
window._pil_cb = {}

# NetMap.PilEvents will be an instance of this class.
class PilEventsClass
  constructor: ->
    @id = 1

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


NetMap.PilEvents = new PilEventsClass

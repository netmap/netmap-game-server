# Responsible for rendering the game map.
class MapView
  # @param {DOMNode} root the DOM node that contains this view
  constructor: (root) ->
    @_root = root
    @_map = @buildMap()

  # @return {OpenLayers.Map} newly created map holding the game view
  buildMap: ->
    map = new OpenLayers.Map @_root, projection: @projection(), controls: []

    base = new OpenLayers.Layer.OSM 'base', @tileUrl()
    map.addLayer base
    map.setBaseLayer base

    map.addControls [
      new OpenLayers.Control.Geolocate(
          bind: true, geolocationOptions: { enableHighAccuracy: true }),
      new OpenLayers.Control.KeyboardDefaults(
          bind: true, geolocationOptions: { enableHighAccuracy: true }),
      new OpenLayers.Control.TouchNavigation(
          dragPanOptions: { documentDrag: true, enableKinetic: true },
          pinchZoomOptions: { preserveCenter: true }, documentDrag: true)
    ]

    position = @defaultCenter().transform(
        new OpenLayers.Projection('EPSG:4326'), @projection())
    map.setCenter position, @defaultZoom()

    map

  # @return {OpenLayers.Projection} the projection used by the game map
  projection: ->
    @_projection ||= new OpenLayers.Projection 'EPSG:900913'

  # @return {String, Array<String} the URL(s) for the map tile server(s)
  tileUrl: ->
    window.location.origin + '/map_tile/${z}/${x}/${y}.png'

  # @return {OpenLayers.LonLat}
  defaultCenter: ->
    new OpenLayers.LonLat -71.0903861, 42.3618384

  # @return {Number} the zoom level before the user interacts with the map
  defaultZoom: ->
    17

  # @return {OpenLayers.Map} the OpenLayers map object rendered in this view
  # @private
  _map: null

  # @return {DOMNode} the DOM node that contains this view
  # @private
  _root: null


$ ->
  if mapRoot = document.querySelector '#map-container'
    window.mapView = new MapView mapRoot

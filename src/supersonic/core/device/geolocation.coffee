Promise = require 'bluebird'
Bacon = require 'baconjs'

{deviceready} = require '../../util/document-events'

superify = require '../superify'

module.exports = (steroids, log) ->
  s = superify 'supersonic.device.geolocation', log

  ###
   # @namespace supersonic.device
   # @name geolocation
   # @overview
   # @description
   # Provides access to location data based on the device's GPS sensor or inferred from network signals.
  ###

  ###
   # @namespace supersonic.device.geolocation
   # @name watchPosition
   # @function
   # @apiCall supersonic.device.geolocation.watchPosition
   # @description
   # Returns a stream of position updates.
   # @type
   # supersonic.device.geolocation.watchPosition : (
   #   options?: {
   #     enableHighAccuracy?: Boolean
   #   }
   # ) => Stream {
   #   coord: Object,
   #   timestamp: Date
   # }
   # @define {Object} options={} Optional options object.
   # @define {Boolean} options.enableHighAccuracy=true Provides a hint that the application needs the best possible results. By default, the device attempts to retrieve a position using network-based methods. Setting this property to true tells the framework to use more accurate methods, such as satellite positioning.
   # @returnsDescription A [`Stream`](/supersonic/guides/technical-concepts/streams/) of position objects with the following properties:
   # @define {=>Object} position Position object.
   # @define {=>Object} position.coord  A set of geographic coordinates. The `coord` object has the following properties:
   # <ul>
   #   <li>`longitude`: Longitude in decimal degrees (Number).</li>
   #   <li>`latitude`: Latitude in decimal degrees (Number).</li>
   #   <li>`altitude`: Height of the position in meters above the ellipsoid (Number).</li>
   #   <li>`accuracy`: Accuracy level of the latitude and longitude coordinates in meters (Number).</li>
   #   <li>`altitudeAccuracy`: Accuracy level of the altitude coordinate in meters (Number). Not supported by Android devices, returning null.</li>
   #   <li>`heading`: Direction of travel, specified in degrees counting clockwise relative to the true north (Number).</li>
   #   <li>`speed`: Current ground speed of the device, specified in meters per second (Number).</li>
   # </ul>
   # @define {=>Date} position.timestamp Creation timestamp for coords.
   # @supportsCallbacks
   # @exampleCoffeeScript
   # supersonic.device.geolocation.watchPosition().onValue (position) ->
   #   supersonic.logger.log(
   #     """
   #     Latitude: #{position.coords.latitude}
   #     Longitude: #{position.coords.longitude}
   #     Timestamp: #{position.timestamp}
   #     """
   #   )
   # @exampleJavaScript
   # supersonic.device.geolocation.watchPosition().onValue( function(position) {
   #   supersonic.logger.log(
   #     "Latitude: " + position.coords.latitude + "\n" +
   #     "Longitude: " + position.coords.longitude + "\n" +
   #     "Timestamp: " + position.timestamp
   #   );
   # });
  ###
  watchPosition = s.streamF "watchPosition", (options = {}) ->

    options.enableHighAccuracy ?= true

    Bacon.fromPromise(deviceready).flatMap ->
      Bacon.fromBinder (sink) ->
        watchId = window.navigator.geolocation.watchPosition(
          (position) -> sink new Bacon.Next position
          (error) -> sink new Bacon.Error error
          options
        )
        ->
          window.navigator.geolocation.clearWatch watchId

  ###
   # @namespace supersonic.device.geolocation
   # @name getPosition
   # @function
   # @apiCall supersonic.device.geolocation.getPosition
   # @description
   # Returns device's current position.
   # @type
   # supersonic.device.compass.geolocation.getPosition : () =>
   #   Promise: {
   #     coord: Object,
   #     timestamp: Date
   #   }
   # @returnsDescription A [`Promise`](/supersonic/guides/technical-concepts/promises/) is resolved to the next available position data. Will wait for data for an indeterminate time; use a timeout if required.
   # @define {=>Object} position Position object.
   # @define {=>Object} position.coord  A set of geographic coordinates.
   # @define {=>Number} coord.longitude  Longitude in decimal degrees.
   # @define {=>Number} coord.latitude  Latitude in decimal degrees.
   # @define {=>Number} coord.altitude  Height of the position in meters above the ellipsoid.
   # @define {=>Number} coord.accuracy  Accuracy level of the latitude and longitude coordinates in meters.
   # @define {=>Number} coord.altitudeAccuracy  Accuracy level of the altitude coordinate in meters. Not supported by Android devices, returning null.
   # @define {=>Number} coord.heading  Direction of travel, specified in degrees counting clockwise relative to the true north.
   # @define {=>Number} coord.speed  Current ground speed of the device, specified in meters per second.
   # @define {=>Date} position.timestamp Creation timestamp for coords.
   # @supportsCallbacks
   # @exampleCoffeeScript
   # supersonic.device.geolocation.getPosition().then (position) ->
   #   supersonic.logger.log(
   #     """
   #     Latitude: #{position.coords.latitude}
   #     Longitude: #{position.coords.longitude}
   #     Timestamp: #{position.timestamp}
   #     """
   #   )
   # @exampleJavaScript
   # supersonic.device.geolocation.getPosition().then( function(position) {
   #   supersonic.logger.log(
   #     "Latitude: " + position.coords.latitude + "\n" +
   #     "Longitude: " + position.coords.longitude + "\n" +
   #     "Timestamp: " + position.timestamp
   #   );
   # });
  ###
  getPosition = s.promiseF "getPosition", (options = {}) ->
    new Promise (resolve) ->
      watchPosition(options).take(1).onValue resolve

  return {watchPosition, getPosition}

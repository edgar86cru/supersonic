Promise = require 'bluebird'

{deviceready} = require '../../util/document-events'

module.exports = (steroids, log) ->
  bug = log.debuggable "supersonic.device.platform"

  ###
   # @namespace supersonic.device
   # @name platform
   # @function
   # @apiCall supersonic.device.platform
   # @description
   # Get the device's operating system name and version.
   # @type
   # supersonic.device.platform : () =>
   #   Promise {
   #     name: String,
   #     version: String,
   #     model: String
   #   }
   # @returnsDescription A [`Promise`](/supersonic/guides/technical-concepts/promises/) is resolved to the name and version of the operating system and the model of the device.
   # @define {=>Object} platform Platform object.
   # @define {=>String} platform.name  The device's operating system name.
   # @define {=>String} platform.version  The device's operating system version.
   # @define {=>String} platform.model The name of the device's model or product. The value is set by the device manufacturer and may be different across versions of the same product.
   # @exampleCoffeeScript
   # supersonic.device.platform().then (platform) ->
   #   supersonic.logger.log(
   #     """
   #     Name: #{platform.name}
   #     Version: #{platform.version}
   #     Model: #{platform.model}
   #     """
   #   )
   # @exampleJavaScript
   # supersonic.device.platform().then( function(platform) {
   #   supersonic.logger.log(
   #     "Name: " + platform.name + "\n" +
   #     "Version: " + platform.version + "\n" +
   #     "Model: " + platform.model
   #   );
   # });
  ###
  platform = ->
    deviceready.then ->
      name: window.device.platform
      version: window.device.version
      model: window.device.model

  return platform

Promise = require 'bluebird'
superify = require '../superify'

module.exports = (logger, router, getDriver, global) ->
  s = superify 'supersonic.module.modal', logger

  ###
   # @namespace supersonic.module.modal
   # @name show
   # @function
   # @type
   # supersonic.module.modal.show: (
   #   route: String
   #   attributes: Object
   # ) => Promise
   # @define {String} route The navigation target
   # @define {Object} attributes What attributes to pass to the target
  ###
  show: s.promiseF 'show', (route, attributes = {}) ->
    # FIXME: What is this about?
    attributes["disable_header"] = true unless attributes["disable_header"]?

    # KLUDGE: Prevent attributes from outside modal leaking into the modal in web
    # See: ./attributes.coffee
    attributes["ag-isolate-scope"] = true

    { path, uid, attributes } = router.getMapping route, attributes
    Promise.resolve(getDriver().modal.show(path, {
      route: uid
      attributes
      origin: global
    }))

  ###
   # @namespace supersonic.module.modal
   # @name hide
   # @function
   # @type
   # supersonic.module.modal.hide: () => Promise
  ###
  hide: s.promiseF 'hide', ->
    Promise.resolve getDriver().modal.hide {
      origin: global
    }

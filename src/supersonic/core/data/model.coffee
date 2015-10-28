data = require 'ag-data'
Bacon = require 'baconjs'

defaultPollBehavior = require './model/default-poll-behavior'

DEFAULT_BACKEND_POLL_INTERVAL_MILLISECONDS = 10000
DEFAULT_CACHE_POLL_INTERVAL_MILLISECONDS = 1000

module.exports = (logger, superglobal, getDefaultCacheStorage, session, env) ->
  ###
   # @namespace supersonic.data
   # @name model
   # @function
   # @apiCall supersonic.data.model
   # @description
   # Provides access to Supersonic Data cloud resources. The factory function returns a new Model class that represents the resource given as a parameter.
   # @type
   # model: (
   #   name: String
   #   options?: {
   #     headers?: Object
   #     cache?:
   #       enabled: Boolean
   #       timeToLive?: Integer
   #       storage?: Object
   #   }
   # ) => Model
   # @define {String} name The name of a configured cloud resource
   # @define {Object} options May have headers to set for all requests performed through this model. May configure caching.
   # @define {Integer} timeToLive Duration of time for cached objects to stay valid, specified in milliseconds.
   # @define {Object} storage Storage adapter to use for caching. Defaults to localforage.
   # @returnsDescription
   # Returns a Model class that represents the given resource, e.g. `supersonic.data.model("car")` returns a new Car Model class, representing the `Car` resource in the cloud backend.
   # @exampleCoffeeScript
   # # Create the Task Model class
   # Task = supersonic.data.model "Task"
   #
   # # Create a new Task instance
   # takeOutTheTrash = new Task {
   #   description: "Take out the trash"
   # }
   #
   # # Persist our new Task instance to the cloud
   # takeOutTheTrash.save()
   # @exampleJavaScript
   # // Create the Task Model class
   # var Task = supersonic.data.model("Task");
   #
   # // Create a new Task instance
   # var takeOutTheTrash = new Task({
   #   description: "Take out the trash"
   # });
   #
   # // Persist our new Task instance to the cloud
   # takeOutTheTrash.save();
  ###
  withDefaults = (name, options) ->
    if options.cache?.enabled != false
      options.cache ?= {}
      options.cache.enabled = true

    if options.cache.enabled
      unless options.cache.storage?
        options.cache.storage = getDefaultCacheStorage()

    if not options.headers?.Authorization?
      options.headers ?= {}
      options.headers.Authorization = session.getAccessToken()

    options.followable ?= {
      poll: defaultPollBehavior name
      interval: switch options.cache.enabled
        when true then DEFAULT_CACHE_POLL_INTERVAL_MILLISECONDS
        else DEFAULT_BACKEND_POLL_INTERVAL_MILLISECONDS
    }

    options

  createModel = do ->
    bundleDefinition = switch
      when env?.data?.bundle? then env.data.bundle
      when superglobal?.ag?.data? then superglobal.ag.data

    if not bundleDefinition?
      return (name) ->
        logger.error "Tried to access a cloud resource, but no resources have been configured"
        throw new Error "No cloud resources available"

    # Connect ag-data to a resource bundle from window.ag.data such that errors
    # are correctly wrapped and logged. Notably, if window.ag.data exists but
    # does not define a valid bundle, an error will be logged without interaction.
    try
      bundle = data.loadResourceBundle bundleDefinition

      return (name, options = {}) ->
        options = withDefaults(name, options)

        try
          bundle.createModel name, options
        catch err
          logger.error "Tried to access cloud resource '#{name}', but it is not a configured resource"
          throw new Error "Could not load model #{name}: #{err}"

    catch err
      logger.error "Tried to access a cloud resource, but the configured cloud resource bundle could not be loaded"
      ->
        throw new Error "Could not load configured cloud resource bundle: #{err}"

###
# @namespace supersonic.data
# @name Model
# @class
# @description
# A Supersonic Data Model class. Provides methods to query the cloud backend for records and a constructor for creating new Model instances.
#
# The base Model class can never be used directly. Instead, the `supersonic.data.model()` factory function must be used. The function creates a new class that inherits the base Model class and references a specific resource, as defined in the Supersonic Data cloud backend.
#
# Thus, to interact with the `Car` resource in your Supersonic Data cloud backend, you must create a Car Model class by calling `var Car = supersonic.data.model("Car")`.
# @type
# supersonic.data.Model: {
#   all: (queryParams, options) => Object
#   findAll: (queryParams) => Promise Collection
#   find: (id) => Promise Model
#   fromJson: (json) => Model
#   one: (options) => Object
# }
# @methods all find findAll
# @define {Function} all Access a stream of Collections, triggered when new data is available. A Collection contains Model instances, representing records in the backend. The stream is updated with fresh data at periodic intervals.
# @define {Function} findAll Returns a [`Promise`](/supersonic/guides/technical-concepts/promises/) that resolves to a Collection of Model instances, representing all the records in the backend for the resource represented by this Model class.
# @define {Function} find Returns a [`Promise`](/supersonic/guides/technical-concepts/promises/) that resolves to a Model instance representing the record with the given id.
# @define {Function} fromJson Create a persisted Model instance from serialized data.
# @define {Function} one Access a stream of updates to a single Model instance, triggered when new data is available.
###

###
# @namespace supersonic.data
# @name Model.all
# @function
# @type
# all: (
#   queryParams?: Object
#   options?:
#      interval?: Integer
# ) =>
#   whenChanged: (Collection) =>
#     unsubscribe: Function
# @description
# Find and fetch a Collection of Model instances representing records that match the query parameters given to the function. The results of the query are made available as a stream that gets updated with the latest data every `interval` ms.
# @define {Object} queryParams An object containing parameters for the database query, e.g. `limit: 10`.
# @define {Object} options An optional options object.
# @define {Integer} options.interval=1000 An integer defining how often the backend is polled for new data, in ms.
# @returnsDescription
# An object with the `whenChanged` property, which accepts a recurring callback function that gets triggered when new data is available.
# @define {=>Function} whenChanged Called with a Collection matching the original query. Called every `options.interval` ms, but only when new data is available. Returns a function that can be used to unsubscribe from the update stream.
# @define {=>Function} whenChanged.unsubscribe Call this function to stop listening for data changes.
# @exampleCoffeeScript
# Task = supersonic.data.model 'task'
# unsubscribe = Task.all(queryParameters, options).whenChanged (updatedTasks) ->
#   supersonic.logger.log "First element of updated Task collection: ", updatedTasks[0]
#
# # Later on, we can stop listening to updates
# unsubscribe()
# @exampleJavaScript
# var Task = supersonic.data.model('task');
# var unsubscribe = Task.all(queryParameters, options).whenChanged( function(updatedTasks) {
#   supersonic.logger.log("First element of updated Task collection: ", updatedTasks[0]);
# });
#
# // Later on, we can stop listening to updates
# unsubscribe();
###

###
# @namespace supersonic.data
# @name Model.one
# @function
# @type
# one: (
#   id: String
#   options?:
#     interval?: Integer
# ) =>
#   whenChanged: (Model) =>
#     unsubscribe: Function
# @description
# Find a single record from the cloud by an id. The results are made available as a stream that gets updated with the latest data every `interval` ms.
# @define {String} id An id string matching a record in the cloud resource represented by this Model class.
# @define {Object} options An optional options object.
# @define {Integer} options.interval=1000 An integer defining how often the backend is polled for new data, in ms.
# @returnsDescription
# An object with the `whenChanged` property, which accepts a recurring callback function that gets triggered when new data is available.
# @define {=>Function} whenChanged Called with a Model matching the `id`. Called every `options.interval` ms, but only when new data is available. Returns a function that can be used to unsubscribe from the update stream.
# @define {=>Function} whenChanged.unsubscribe Call this function to stop listening for data changes.
# @exampleCoffeeScript
# unsubscribe = supersonic.data.model('task').one('123', options).whenChanged (updatedTask) ->
#   supersonic.logger.log "Most recent data on task 123: ", updatedTask
#
# # Later on, we can stop listening for updates
# unsubscribe()
# @exampleJavaScript
# var unsubscribe = supersonic.data.model('task').one('123', options).whenChanged( function(updatedTask) {
#   supersonic.logger.log("Most recent data on task 123: ", updatedTask);
# });
#
# // Later on, we can stop listening for updates
# unsubscribe();
###

###
 # @namespace supersonic.data
 # @name Model.findAll
 # @function
 # @type
 # findAll: () => Promise collection: Collection<Model>
 # @description
 # Fetch and access all the records in the cloud resource represented by this Model class.
 # @returnsDescription
 # A [`Promise`](/supersonic/guides/technical-concepts/promises/) that resolves with a Collection of Model instances, each of whom represents a single record.
 # @define {=>Collection<Model>} collection A Collection that contains Model instances for all the records in the cloud resource represented by this Model class.
 # @exampleCoffeeScript
 # supersonic.data.model('task').findAll().then (tasks) ->
 #   for task in tasks
 #      console.log task.description
 # @exampleJavaScript
 # supersonic.data.model('task').findAll().then( function(tasks) {
 #   for (var i = 0; i < tasks.length; i++) {
 #     console.log(tasks[i].description);
 #   }
 # });
###
###
 # @namespace supersonic.data
 # @name Model.find
 # @function
 # @type
 # find: (id: String) => Promise Model
 # @description
 # Find a single record from the cloud by an id. Returns a Model instance matching that record.
 # @define {String} id An id string matching a record in the cloud resource represented by this Model class.
 # @returnsDescription
 # A [`Promise`](/supersonic/guides/technical-concepts/promises/) that gets resolved with a Model instance representing the record matching the id.
 # @exampleCoffeeScript
 # supersonic.data.model('task').find(123).then (task) ->
 #   console.log task.description
 # @exampleJavaScript
 # supersonic.data.model('task').find(123).then( function(task) {
 #   console.log(task.description);
 # });
###
###
 # @namespace supersonic.data
 # @name Model.fromJson
 # @function
 # @type
 # fromJson: (json: Object) => Model
 # @description
 # Restore a persisted Model instance from serialized data.
 # @define {Object} json A JSON object used to create the Model instance.
 # @exampleCoffeeScript
 # Task = supersonic.data.model('task')
 # Task.find(123).then (task) ->
 #   serialized = task.toJson()
 #   # At this point the task can be e.g. stored to localStorage
 #   # Retrieve it from the storage-compatible format using fromJson
 #   task = Task.fromJson(serialized)
 #   task.description = 'updated!'
 #   # Unlike the serialized JSON object, the restored model instance
 #   # has all the behavior intact.
 #   task.save()
 # @exampleJavaScript
 # var Task = supersonic.data.model('task');
 # Task.find(123).then( function(task) {
 #   var serialized = task.toJson();
 #   // At this point the task can be e.g. stored to localStorage
 #   // Retrieve it from the storage-compatible format using fromJson
 #   var task = Task.fromJson(serialized);
 #   task.description = 'Updated!';
 #   // Unlike the serialized JSON object, the restored model instance
 #   // has all the behavior intact.
 #   task.save();
 #  });
###
###
 # @namespace supersonic.data
 # @name Collection
 # @class
 # @description
 # A Supersonic Data Collection class. Represents a collection of records (represented as instances of `supersonic.data.Model`) fetched from the Supersonic Data cloud backend. A Collection always has records from a single cloud resource only, i.e. there can be a Car Collection and a Bus Collection, but never a Collection containing both Cars and Buses.
 # @type
 # Collection: {
 #   save: () => Promise
 # }
 # @methods save
 # @define {Function} save Persist all the Model instances in this collection.
###
###
 # @namespace supersonic.data
 # @name Collection.save
 # @function
 # @type
 # Collection.save: () => Promise
 # @description
 # Persist all Model instances in this Collection to the cloud, updating the matching records.
 # @returnsDescription
 # A [`Promise`](/supersonic/guides/technical-concepts/promises/) that resolves once all the Model instances in the Collection have been perisisted to the cloud backend.
 # @exampleCoffeeScript
 # supersonic.data.model('task').findAll().then (tasks) ->
 #   for task in tasks
 #     task.completed = true
 #   tasks.save().then ->
 #     supersonic.logger.log "All tasks saved!"
 # @exampleJavaScript
 # supersonic.data.model('task').findAll().then( function(tasks) {
 #   for (var i = 0; i < tasks.length; i++) {
 #     tasks[i].completed = true;
 #   }
 #   tasks.save().then( function() {
 #     supersonic.logger.log("All tasks saved!");
 #   });
 # });
###
###
 # @namespace supersonic.data
 # @name Model-instance
 # @instance
 # @description
 # An instance of a specific Model class. Represents a single record fetched from (or not yet persisted to) the cloud backend, e.g. a single `Car`.
 #
 # The Model class reperesenting a specific resource is created by calling the `supersonic.data.model()` factory function. New instances of that Model class can then be created either via the constructor or via the various query functions available to the Model class object itself (e.g. `Car.find()`).
 #
 # ##Constructor
 # ```coffeescript
 # Model(
 #   data: Object
 # )
 # ```
 # The constructor accepts a data object containing arbitrary data that can then be persisted to the backend as a new record with `Model.save()`. There is no validation, so it's up to the developer to only input data that matches the backend's data schema. Nested properties are not supported.
 # @type
 # Model: {
 #   save: () => Promise
 #   delete: () => Promise
 # }
 # @exampleCoffeeScript
 # # Create the Task Model class
 # Task = supersonic.data.model "Task"
 #
 # # Create a new Task instance
 # takeOutTheTrash = new Task {
 #   description: "Take out the trash"
 # }
 #
 # # Persist our new Task instance to the cloud
 # takeOutTheTrash.save()
 # @exampleJavaScript
 # // Create the Task Model class
 # var Task = supersonic.data.model("Task");
 #
 # // Create a new Task instance
 # var takeOutTheTrash = new Task({
 #   description: "Take out the trash"
 # });
 #
 # // Persist our new Task instance to the cloud
 # takeOutTheTrash.save();
 # @methods save delete
 # @define {Function} save Persist the data in this Model instance to the cloud backend.
 # @define {Function} delete Remove this Model instance from the cloud backend.
###
###
 # @namespace supersonic.data
 # @name Model.save
 # @function
 # @type
 # Model.save: () => Promise
 # @description
 # Persist the data in this Model instance to the cloud. If the instance is new, create it in the cloud; otherwise update the existing record.
 # @exampleCoffeeScript
 # supersonic.data.model('task').find(123).then (task) ->
 #   task.done = true
 #   task.save()
 # @exampleJavaScript
 # supersonic.data.model('task').find(123).then( function(task) {
 #   task.done = true;
 #   task.save();
 # });
 # @returnsDescription
 # A [`Promise`](/supersonic/guides/technical-concepts/promises/) that gets resolved once the Model instance has been persisted to the cloud backend.
###
###
 # @namespace supersonic.data
 # @name Model.delete
 # @function
 # @type
 # Model.delete: () => Promise
 # @description
 # Remove the record matching this Model instance from the cloud backend.
 # @exampleCoffeeScript
 # supersonic.data.model('task').find(123).then (task) ->
 #   if task.done
 #     task.delete()
 # @exampleJavaScript
 # supersonic.data.model('task').find(123).then( function(task) {
 #   if (task.done) {
 #     task.delete();
 #   }
 # });
 # @returnsDescription
 # A [`Promise`](/supersonic/guides/technical-concepts/promises/) that gets resolved once the record matching this Model instance has been deleted from the cloud backend.
###

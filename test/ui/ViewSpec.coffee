chai = require('chai')
chai.should()
chai.use require 'chai-as-promised'

steroids = require '../../src/supersonic/mock/steroids'
Window = require '../../src/supersonic/mock/window'
logger = require('../../src/supersonic/core/logger')(steroids, new Window())
view = require('../../src/supersonic/core/ui/View')(steroids, logger)

describe "supersonic.ui.View", ->
  it "should exist", ->
    view.should.exist

chai = require('chai')
chai.should()
chai.use require 'chai-as-promised'

steroids = require '../../src/supersonic/mock/steroids'
Window = require '../../src/supersonic/mock/window'
logger = require('../../src/supersonic/core/logger')(steroids, new Window())
platform = require('../../src/supersonic/core/device/platform')(steroids, logger)

describe "supersonic.device.platform", ->
  it "should exist", ->
    platform.should.exist

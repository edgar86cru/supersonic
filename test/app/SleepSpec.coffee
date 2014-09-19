chai = require('chai')
chai.should()
chai.use require 'chai-as-promised'

steroids = require '../../src/supersonic/steroids.mock'
sleep = require('../../src/supersonic/app/sleep')(steroids)

describe "supersonic.app.sleep.disable", ->
  it "should exist", ->
    sleep.disable.should.exist

describe "supersonic.app.sleep.enable", ->
  it "should exist", ->
    sleep.enable.should.exist
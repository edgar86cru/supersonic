
describe "supersonic.data.channel", ->

  channelName = null
  beforeEach ->
    channelName = "channel-#{Math.random()}"

  it "is a function", ->
    supersonic.data.channel.should.be.a 'function'

  it "accepts a channel name and returns a channel", ->
    supersonic.data.channel(channelName).should.be.an 'object'

  describe "identity", ->
    it "is a string", ->
      supersonic.data.channel(channelName).identity.should.be.a 'string'

  describe "subscribe()", ->
    it "is a function", ->
      supersonic.data.channel(channelName).subscribe.should.be.a 'function'

    it "should attach a listener to messages from channel.inbound", (done) ->
      channel = supersonic.data.channel channelName
      channel.inbound = new Bacon.Bus
      new Promise((resolve) ->
        channel.subscribe resolve
      ).should.eventually.equal('message').and.notify(done)
      channel.inbound.push 'message'

    it "should provide the listener with reply()", (done) ->
      channel = supersonic.data.channel channelName
      channel.inbound = new Bacon.Bus
      channel.subscribe (ignored, reply) ->
        done asserting =>
          reply.should.be.a 'function'
      channel.inbound.push 'message'

    describe "reply()", ->
      it "pipes to publish", (done) ->
        channel = supersonic.data.channel channelName
        channel.inbound = new Bacon.Bus

        # Hack for expecting a function to be called at a later time
        new Promise((resolve) ->
          channel.publish = resolve
        ).should.eventually.equal('bar').and.notify done

        channel.subscribe (ignored, reply) ->
          reply 'bar'
        channel.inbound.push 'message'

  describe "publish()", ->
    it "is a function", ->
      supersonic.data.channel('foo').publish.should.be.a 'function'

    describe "intra-view message passing", (done) ->
      it "allows other channel instances with the same name to subscribe to messages", ->
        producer = supersonic.data.channel channelName
        consumer = supersonic.data.channel channelName

        new Promise((resolve) ->
          consumer.subscribe resolve
        ).should.eventually.equal('message').and.notify done

        producer.publish 'message'

      it "will not feedback a published message to the same channel instance", (done) ->
        channel = supersonic.data.channel channelName
        new Promise((resolve) ->
          channel.subscribe resolve
        ).timeout(100).should.be.rejected.and.notify done
        channel.publish 'message'

    describe "cross-view message passing", ->
      startedView = null

      beforeEach (done) ->
        supersonic.ui.views.find("data#channel/pingback?channel=#{channelName}").then (view) ->
          view.start()
          .then ->
            startedView = view
            done()

      afterEach (done) ->
        startedView.stop().then ->
          startedView = null
          done()

      it "can subscribe to messages published by another view", (done) ->
        channel = supersonic.data.channel(channelName)
        new Promise((resolve) ->
          channel.subscribe resolve
        ).should.eventually.equal('Ping!').and.notify done


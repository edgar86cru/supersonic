before ->
  window.importsLoaded

fireAfterModalDidShow = (done) ->
  showListener = steroids.modal.on "didshow", ->
    steroids.modal.off "didshow", showListener
    done()

fireAfterModalDidHide = (done) ->
  hideListener = steroids.modal.on "didclose", ->
    steroids.modal.off "didclose", hideListener
    done()

fireAfterModalDidHideAndShow = (done) ->
  fireAfterModalDidShow ->
    fireAfterModalDidHide ->
      done()

clickElement = (id) ->
  element = document.getElementById id
  element.click()

fireTouchEvent = (obj, evt) ->
  evObj = document.createEvent "TouchEvent"
  evObj.initUIEvent evt, true, false
  obj.dispatchEvent evObj

describe "<super-modal-show> and <super-modal-hide>", ->
  @timeout 10000

  it "should show modal by clicking on element with route", (done) ->
    fireAfterModalDidHideAndShow done
    clickElement "super-modal-show-route"

  it "should show modal with an URL", (done) ->
    fireAfterModalDidHideAndShow done
    clickElement "super-modal-show-url"

  it "should show modal after changing element's location attribute", (done) ->
    fireAfterModalDidHideAndShow done
    elem = document.getElementById "super-modal-show-change-location"
    elem.setAttribute "location", "web-components#super-modal-hide"
    elem.click()

  it "should show modal with a custom touchstart action", (done) ->
    fireAfterModalDidHideAndShow done
    elem = document.getElementById "super-modal-show-touchstart"
    fireTouchEvent elem, "touchstart"

  it "should show modal with a view-id", (done) ->
    view = new supersonic.ui.View "web-components#super-modal-hide-preloaded"

    fireAfterModalDidHideAndShow ->
      view.stop().then ->
        done()

    view.start("super-modal-hide").then ->
      clickElement "super-modal-show-id"

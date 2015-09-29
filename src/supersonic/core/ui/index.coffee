
module.exports = (steroids, log, global) ->
  View: require("./View")(steroids, log)

  MediaGallery: require("./MediaGallery")(steroids, log)
  PDFView: require("./PDFView")(steroids, log)

  screen: require("./screen")(steroids, log)
  views: require("./views")(steroids, log, global)
  layers: require("./layers")(steroids, log)
  drawers: require("./drawers")(steroids, log)
  tabs: require("./tabs")(steroids, log)

  modal: require("./modal")(steroids, log)
  dialog: require("./dialog")(steroids, log)
  initialView: require("./initialView")(steroids, log)

  navigationBar: require("./navigationBar")(steroids, log)
  NavigationBarButton: require("./NavigationBarButton")(steroids, log)

  animate: require("./animate")(steroids, log)

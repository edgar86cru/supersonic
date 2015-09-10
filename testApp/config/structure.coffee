module.exports =

  rootView:
    location: "common#index"

  tabs: [
    {
      title: "Index"
      icon: "icons/pill@2x.png"
      location: "common#index"
    }
    {
      title: "Internet"
      icon: "icons/telescope@2x.png"
      location: "http://www.google.com"
    }
  ]

  initialView:
    id: "initialView"
    location: "initial#start"

  # drawers:
  #   left:
  #     id: "leftDrawer"
  #     location: "ui#drawers"
  #     showOnAppLoad: true
  #     widthOfDrawerInPixels: 200
  #   right:
  #     id: "rightDrawer"
  #     location: "ui#drawers"
  #     showOnAppLoad: false
  #     widthOfDrawerInPixels: 200
  #   options:
  #     centerViewInteractionMode: "Full"
  #     closeGestures: ["PanNavBar", "PanCenterView", "TapCenterView"]
  #     openGestures: ["PanNavBar", "PanCenterView"]
  #     showShadow: true
  #     stretchDrawer: true
  #     widthOfLayerInPixels: 0

  preloads: [
    {
      id: "app-index"
      location: "app#index"
    },
    {
      id: "navigate-result"
      location: "webComponents#navigate_result"
    },
    {
      id: "super-data"
      location: "webComponents#data"
    }
  ]

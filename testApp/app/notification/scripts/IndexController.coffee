angular
  .module('notification')
  .controller 'IndexController', ($scope, supersonic) ->
    $scope.dismissedAlerts = 0

    $scope.alertTests = [
      {
        title: "Alert with message as param"
        message: "Just a string value."
      }
      {
        title: "Alert with message and options params"
        message: "I'm an alert!"
        options:
          title: "Custom Title"
          buttonLabel: "Close"
      }
      {
        title: "Alert with null message"
        message: null
      }
      {
        title: "Alert without params"
      }
    ]

    $scope.testAlert = (message, options) ->
      supersonic.notification.alert(message, options).then ->
        $scope.dismissedAlerts++

    $scope.confirms = [
      0
      0
      0
    ]

    $scope.confirmTests = [
      {
        title: "Confirm with message as param"
        message: "Just a string value."
      }
      {
        title: "Alert with message string and options object params"
        message: "I'm a Confirm!"
        options:
          title: "Custom Title"
          buttonLabels: ["Yay","NO!","third"]
      }
      {
        title: "Confirm with null message"
        message: null
      }
      {
        title: "Confirm without options"
      }
    ]

    $scope.testConfirm = (message, options) ->
      supersonic.notification.confirm(message, options).then (index) ->
        $scope.confirms[index]++

    $scope.vibrations = 0

    $scope.vibrateTests = [
      {
        title: "Vibrate for 2500 ms"
        options: 2500
      }
      {
        title: "Vibrate"
        options: null
      }
    ]

    $scope.testVibrate = (options) ->
      supersonic.notification.vibrate(options).then ->
        $scope.vibrations++

    $scope.buttonIndex = undefined
    $scope.input = undefined

    $scope.promptTests = [
      {
        title: "Prompt with message as param"
        message: "Just a string value."
      }
      {
        title: "Prompt with message string and options object params"
        message: "I am a prompt"
        options:
          title: "Custom Title" 
          buttonLabels: ["Yay","NO!","Maybe"]
          defaultText: "Type something"
      }
      {
        title: "Prompt with null message"
        message: null
      }
      {
        title: "Prompt without options"
      }
    ]

    $scope.testPrompt = (message, options) ->
      supersonic.notification.prompt(message, options).then (result) ->
        $scope.buttonIndex = result.buttonIndex
        $scope.input = result.input

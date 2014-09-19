angular
  .module('steroids')
  .controller 'IndexController', ($scope, $timeout, supersonic) ->
    $scope.successfulOpens = 0

    $scope.openURLTests = [
      {
        title: "Apple Maps maps://"
        options: "maps://?daddr=San+Francisco,+CA&saddr=cupertino"
      }
      {
        title: "Dolanz dolanz:// (should fail)"
        options: "dolanz://"
      }
    ]

    $scope.testOpenURL = (options) ->
      supersonic.steroids.openURL(options).then(
        () ->
          $scope.successfulOpens++
        (message) ->
          alert "Could not open URL! \n\n #{JSON.stringify(message)}"
      )

    $scope.launchURL = undefined

    $scope.getLaunchURLTests = [
      {
        title: "Get Launch URL"
      }
    ]

    $scope.testGetLaunchURL = (options) ->
      supersonic.steroids.app.getLaunchURL().then( 
        (launchURL) ->
          $scope.launchURL = launchURL
        (message) ->
          alert "No launch URL available! \n\n #{JSON.stringify(message)}"
    )

    $scope.sleepDisabled = 0
    $scope.sleepEnabled = 0

    $scope.disableAndEnableSleepTests = [
      {
        title: "Disable and Enable Sleep"
      }
    ]

    $scope.testDisableAndEnableSleep = (options) ->
      supersonic.steroids.app.sleep.disable().then ->
        $scope.sleepDisabled++
        supersonic.steroids.app.sleep.enable().then ->
         $scope.sleepEnabled++

    $scope.splashscreenShown = 0
    $scope.splashscreenHidden = 0

    $scope.showAndHideSplashscreenTests = [
      {
        title: "Show Splashscreen and Hide in 5000 ms"
      }
    ]

    $scope.testShowAndHideSplashscreen = (options) ->
      supersonic.steroids.app.splashscreen.show().then( 
        () ->
          $scope.splashscreenShown++
          $timeout ->
            supersonic.steroids.app.splashscreen.hide().then( 
              () ->
                $scope.splashscreenHidden++
              (message) ->
                alert "Could not hide splashscreen! \n\n #{JSON.stringify(message)}"
            )
          , 5000
        (message) ->
          alert "Could not show splashscreen! \n\n #{JSON.stringify(message)}"
      )

    
using Toybox.Application as App;
using Toybox.WatchUi as Ui;

class HexWatchFaceApp extends App.AppBase {
	
	function initialize() {
        AppBase.initialize();
    }

    //! onStart() is called on application start up
    function onStart(state) {
    }

    //! onStop() is called when your application is exiting
    function onStop(state) {
    }

    //! Return the initial view of your application here
    function getInitialView() {
        return [ new HexWatchFaceView() ];
    }
       
    // For this app all that needs to be done is trigger a Ui refresh
    // since the settings are only used in onUpdate().
    function onSettingsChanged()
    {
        Ui.requestUpdate();
    }
    
    function getGoalView(goal){
        return [new HexWatchFaceView(goal)];
    }

}
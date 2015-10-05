using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
//using Toybox.Lang as Lang;


var wakeMode = true;  // check if user looks at his fenix3 is set in onhide() at the end of source code
var width, height;

class HexWatchFaceView extends Ui.WatchFace {

    //! Load your resources here
    function onLayout(dc) {
    	width = dc.getWidth();
     	height = dc.getHeight();
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    //! Called when this View is brought to the foreground. Restore
    //! the state of this View and prepare it to be shown. This includes
    //! loading resources into memory.
    function onShow() {
    }
    
    
	function toHexDigit(digit) {
		var hex_digits = ["0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F"];
		return hex_digits[digit];
    }
    
    function decToHex(num) {	
		var hi = (num/16).toNumber();
		var lo = toHexDigit(num%16); 
		return hi+lo;
	}
    
    function drawDate(dc) {	
		var dateStrings = Time.Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var date = dateStrings.day_of_week.toString() + " " + dateStrings.day.toString() + " " + dateStrings.month.toString(); 
        dc.setColor( Gfx.COLOR_GREEN,  Gfx.COLOR_TRANSPARENT);
        dc.drawText(width/2, height/2+height/3.5, Gfx.FONT_SMALL, date, Gfx.TEXT_JUSTIFY_CENTER);
	}
	
	function drawTime(dc) {	
		// Get and show the current time
        var clockTime = Sys.getClockTime();
        var hours = clockTime.hour.toNumber();
        var hoursStr;
        var timeLabelName;
        
        if( Sys.getDeviceSettings().is24Hour ) { 
        	timeLabelName = "TimeLabel_100";
        	hoursStr = decToHex(hours);
 		}
 		else {// if watch is in 12hour Mode 
       		timeLabelName = "TimeLabel_105";
        	if (hours > 12) {
        		hours = hours - 12;
        	}
        	hoursStr = toHexDigit(hours);       	
		}     

        var timeString = "0x" + hoursStr + ":" + decToHex(clockTime.min);
        var view = View.findDrawableById(timeLabelName);
        view.setText(timeString);      
              // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);             
	}
	
	function drawBT(dc) {
 		if ( Sys.getDeviceSettings().phoneConnected) {
        	var BtIcon = Ui.loadResource(Rez.Drawables.id_icon_BT);  // load pictur from resources.xml
        	dc.drawBitmap(width/2 - BtIcon.getWidth()/2 , height/8, BtIcon);
        	} 
	}
	
	function drawActivity(dc) {
		var MILES_PER_KM = 0.62137;
		var CM_PER_KM = 100 * 1000;
    	var activity = ActivityMonitor.getInfo();
      	var moveBarLevel = activity.moveBarLevel;
        var distance = activity.distance.toFloat() / CM_PER_KM; // distance is saved as cm --> / 100 / 1000 --> km
        var units;            
        if (Sys.getDeviceSettings().distanceUnits){//is watch set to IMPERIAL-Units?  km--> miles
            distance = distance.toFloat() * MILES_PER_KM;
            units = "mi";
         }
         else {
         	units = "km";      
        	}
        distance = distance.format("%2.1f");     // formatting km/mi to 2numbers + 1 digit

		var text = activity.steps + "/" + activity.stepGoal + " " + distance + units;
		dc.setColor( Gfx.COLOR_GREEN,  Gfx.COLOR_TRANSPARENT);
        dc.drawText(width/2, height/2+height/5, Gfx.FONT_TINY, text , Gfx.TEXT_JUSTIFY_CENTER);

	}
	
    function drawFullInfo(dc) {	
    	drawBT(dc);
    	//
        drawDate(dc);
         // Battery
		drawBatt(dc, width/2 - 20, height/2 + (height/2.4) ); // function, source below

		drawActivity(dc);

     //   var dateStrings1 = Time.Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
      //  var time = dateStrings1.hour.toString();
      //  dc.drawText(width/2, height/2+height/4, Gfx.FONT_SMALL, time, Gfx.TEXT_JUSTIFY_CENTER);
	}
	
    //! Update the view
    function onUpdate(dc) {
    
        drawTime(dc);
           
        //USER is watching the watch -> show all information
        if (wakeMode){
			drawFullInfo(dc);
        }       
     
    }

    //! Called when this View is removed from the screen. Save the
    //! state of this View here. This includes freeing resources from
    //! memory.
    function onHide() {
    	wakeMode = false;
    	Ui.requestUpdate();
    }

    //! The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
    	wakeMode = true;
    	Ui.requestUpdate();
    }

    //! Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
    	wakeMode = false;
    	Ui.requestUpdate();
    }
    
     // draw the battery
//                 dc, positionx , position y)  
 	function drawBatt(dc,batx,baty){
              // Batterie neu
		var batWidth = 40;
		var batHeight = 15;
        var batt = Sys.getSystemStats().battery; // get battery status
        batt = batt.toNumber(); // safety first --> set it to integer
        dc.setPenWidth(1);
        batx = batx.toNumber();
        baty = baty.toNumber();
        var batFill = (batWidth-4)*batt/100;
             
              // draw boarder 
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_WHITE); 
        dc.fillRectangle(batx, baty, batWidth, batHeight); // white area BODY
        dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_DK_GRAY); 
        dc.fillRectangle(batx + batWidth, baty +batHeight/4+1, batHeight/4, batHeight/2); //  BOBBL
        dc.drawRectangle(batx, baty, batWidth, batHeight); // frame
           //draw green / colored fill-level
               
		var color;
		if (batt >= 40){
				color = Gfx.COLOR_GREEN;}
			else if(batt >= 30){
					color = Gfx.COLOR_YELLOW;}
				else if(batt >= 20){
					color = Gfx.COLOR_ORANGE;}
					else {
						color = Gfx.COLOR_RED;}
			
     	dc.setColor(color, Gfx.COLOR_TRANSPARENT);
        dc.fillRectangle(batx+2, baty+2, batFill, batHeight-4);
        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
        dc.drawText(batx+batWidth/2,  baty+batHeight/2-1 , Gfx.FONT_XTINY, batt.toString() + "%", Gfx.TEXT_JUSTIFY_CENTER|Gfx.TEXT_JUSTIFY_VCENTER);
               
	} // End drawbattfunction    

}

using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;


class HexWatchFaceView extends Ui.WatchFace {

	var wakeMode = true;  // check if user looks at his fenix3 is set in onhide() at the end of source code
	var width, height;
	var timeColor, backColor, infoColor, screenShape;
	
	function initialize() {
        WatchFace.initialize();
        screenShape = Sys.getDeviceSettings().screenShape;
    }
	
    //! Load your resources here
    function onLayout(dc) {
    	width = dc.getWidth();
     	height = dc.getHeight();
        setLayout(Rez.Layouts.WatchFace(dc));
        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_WHITE);
    }

    //! Called when this View is brought to the foreground. Restore
    //! the state of this View and prepare it to be shown. This includes
    //! loading resources into memory.
   // function onShow() {
    
  //  }
    
    function drawDate(dc) {	
		var dateStrings = Time.Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var date = dateStrings.day_of_week.toString() + " " + dateStrings.day.toString() + " " + dateStrings.month.toString(); 
        dc.setColor(infoColor,Gfx.COLOR_TRANSPARENT);//,  Gfx.COLOR_TRANSPARENT);
        dc.drawText(width/2, height/2+height/3.5, Gfx.FONT_SMALL, date, Gfx.TEXT_JUSTIFY_CENTER);
	}
	
	function drawTime(dc) {	
		// Get and show the current time
        var clockTime = Sys.getClockTime();
        var hours = clockTime.hour.toNumber();
        var hoursStr;
        var ampm = "";
		        
        if( Sys.getDeviceSettings().is24Hour ) { 
        	
        	hoursStr = hours.format("%02X"); 
 		}
 		else {// if watch is in 12hour Mode 
        	if (hours > 12) {
        		ampm = "p";
        		hours = hours - 12;
        	}
        	else {
        		ampm = "a";
        	}
        	hoursStr = hours.format("%1X");       	
		}     

        var timeString = "0x" + hoursStr + ":" +  clockTime.min.format("%02X") + ampm; // decToHex(clockTime.min);
        var timeFont; 
		//System.println(timeString);
		//dc.setColor(timeColor,Gfx.COLOR_TRANSPARENT);
		var timeFontProperty = Application.getApp().getProperty("timeFont_prop");
		if (timeFontProperty == 0) {
			timeFont = Ui.loadResource(Rez.Fonts.id_font_terminal_100);  // load font from resources.xml
		}
		else {
			timeFont = Ui.loadResource(Rez.Fonts.id_font_open_sans_90);
			//timeString = timeString.toLower();
		}      
		dc.drawText(width/2,  height/2 ,timeFont, timeString, Gfx.TEXT_JUSTIFY_CENTER|Gfx.TEXT_JUSTIFY_VCENTER);   
	}
	
	function drawBT(dc) {
 		if ( Sys.getDeviceSettings().phoneConnected) {
        	var BtIcon = Ui.loadResource(Rez.Drawables.id_icon_BT);  // load picture from resources.xml
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
        if(distance < 100) {
        	distance = distance.format("%2.1f");     // formatting km/mi to 2numbers + 1 digit
		}
		else {
			distance = distance.format("%3u");
		}
		
		
		var text = "";
		if(activity.steps){
			text = activity.steps + "/" + activity.stepGoal;
		}
		
		if(activity.distance.toFloat()) {
			text = text + " " + distance + units;
		}
			 
		dc.setColor(infoColor,Gfx.COLOR_TRANSPARENT);//,  Gfx.COLOR_TRANSPARENT);
        dc.drawText(width/2, height/2+height/5, Gfx.FONT_SMALL, text , Gfx.TEXT_JUSTIFY_CENTER);

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
    	
    	
    	timeColor = Application.getApp().getProperty("timeColor_prop");
    	backColor = Application.getApp().getProperty("backColor_prop");
    	infoColor = Application.getApp().getProperty("infoColor_prop");
    	dc.setColor(timeColor,backColor);
 		dc.clear();     
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

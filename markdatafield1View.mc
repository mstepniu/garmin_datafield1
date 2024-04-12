import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class markdatafield1View extends WatchUi.DataField {

    var heartrate, total_distance, total_duration, speed, pace;
    var activity_type;

    function initialize() {
        DataField.initialize();
        heartrate = 0;
        total_distance = 0.0;
        total_duration = 0.0;
        speed = 0.0;
        pace = 0.0;
    }

    // Set your layout here. Anytime the size of obscurity of
    // the draw context is changed this will be called.
    function onLayout(dc as Dc) as Void {
        var obscurityFlags = DataField.getObscurityFlags();

        // Top left quadrant so we'll use the top left layout
        if (obscurityFlags == (OBSCURE_TOP | OBSCURE_LEFT)) {
            View.setLayout(Rez.Layouts.TopLeftLayout(dc));

        // Top right quadrant so we'll use the top right layout
        } else if (obscurityFlags == (OBSCURE_TOP | OBSCURE_RIGHT)) {
            View.setLayout(Rez.Layouts.TopRightLayout(dc));

        // Bottom left quadrant so we'll use the bottom left layout
        } else if (obscurityFlags == (OBSCURE_BOTTOM | OBSCURE_LEFT)) {
            View.setLayout(Rez.Layouts.BottomLeftLayout(dc));

        // Bottom right quadrant so we'll use the bottom right layout
        } else if (obscurityFlags == (OBSCURE_BOTTOM | OBSCURE_RIGHT)) {
            View.setLayout(Rez.Layouts.BottomRightLayout(dc));

        // Use the generic, centered layout
        } else {
            View.setLayout(Rez.Layouts.MainLayout(dc));
            // var labelView = View.findDrawableById("label") as Text;
            // labelView.locY = labelView.locY - 16;
            // var valueView = View.findDrawableById("value") as Text;
            // valueView.locY = valueView.locY + 7;
        }

        // (View.findDrawableById("label") as Text).setText(Rez.Strings.label);
    }

    // The given info object contains all the current workout information.
    // Calculate a value and save it locally in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info as Activity.Info) as Void {
        var temp = Activity.getProfileInfo();
        activity_type = temp.sport;
        // See Activity.Info in the documentation for available information.
        if(info has :currentHeartRate){
            if(info.currentHeartRate != null){
                heartrate = info.currentHeartRate as Number;
            } else {
                heartrate = 0;
            }
        }
        if (info has :elapsedDistance){
            if (info.elapsedDistance != null){
                total_distance = info.elapsedDistance as Number;
            }
            else {
                total_distance = 0.0;
            }
        }
        if (info has :timerTime) {
            if (info.timerTime != null) {
                total_duration = info.timerTime as Number;
            }
            else {
                total_duration = 0.0;
            }
        }
        // get current speed and convert to MPH
        // also calculate pace (how long to run a mile)
        if (info has :currentSpeed) {
            if (info.currentSpeed != null) {
                speed = info.currentSpeed as Number;
                speed = speed * 0.44704;
                if (speed > 0) {
                    pace = 60.0 / speed;
                }
                else {
                    pace = 0.0;
                }
                
            }
            else {
                speed = 0.0;
                pace = 0.0;
            }
        }
    }

    // Display the value you computed here. This will be called
    // once a second when the data field is visible.
    function onUpdate(dc as Dc) as Void {
        setHeartRate();
        setTotalDistance();
        setTotalDuration();
        setSpeed();
        setPace();
        setCurrentTime(dc);
        // Call parent's onUpdate(dc) to redraw the layout
        View.onUpdate(dc);
        
        
    }

    private function setCurrentTime(dc as Dc) {
        var clockTime = System.getClockTime();
        var view_time = View.findDrawableById("time") as Text;
        view_time.setColor(Graphics.COLOR_WHITE as Number);

        if (clockTime == null) {
            view_time.setText("N\\A");
            return;
        }
        var hours = clockTime.hour;
        var minutes = clockTime.min;
        if (!System.getDeviceSettings().is24Hour) {
            if (hours > 12) {
                hours = hours - 12;
            }
            else if (hours == 0) {
                hours = 12;
            }
        }
        view_time.setText(hours + ":" + minutes);
        System.println(view_time.height.toString());
        System.println(view_time.width.toString());
        System.println(view_time.locX.toString());
        System.println(view_time.locY.toString());
        

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
        dc.setPenWidth(2);
        dc.drawRectangle(view_time.locX - (view_time.width / 2) - 5, 200, view_time.width + 10, view_time.height);

    }

    private function setHeartRate() {
        var view_heartrate = View.findDrawableById("heartrate") as Text;
        view_heartrate.setColor(Graphics.COLOR_RED);
        view_heartrate.setText(heartrate.toString());
        
    }

    private function setTotalDistance() {
        var view_total_distance = View.findDrawableById("total_distance") as Text;
        view_total_distance.setColor(Graphics.COLOR_BLUE);
        var temp;
        temp = total_distance * 0.000621;
        view_total_distance.setText(temp.format("%02.1f").toString() + "mi");

    }

    // convert to seconds by multiplying milliseconds by 1000
    // check if over 1 hour
    private function setTotalDuration() {
        var view_total_duration = View.findDrawableById("total_duration") as Text;
        view_total_duration.setColor(Graphics.COLOR_GREEN);
        var temp;
        var duration_minutes;
        var duration_seconds;
        var duration_hours;        
        temp = total_duration / 1000;
        if (temp >= 3600) {

        }
        view_total_duration.setText(temp.format("%02d").toString());
    }

    private function setSpeed() {
        var view_speed = View.findDrawableById("speed") as Text;
        view_speed.setColor(Graphics.COLOR_PURPLE);
        view_speed.setText(speed.format("%02.1f").toString());
    }

    private function setPace() {
        var view_pace = View.findDrawableById("pace") as Text;
        view_pace.setColor(Graphics.COLOR_PURPLE);
        view_pace.setText(pace.format("%02.2f").toString());
    }

}

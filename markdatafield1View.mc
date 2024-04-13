import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class markdatafield1View extends WatchUi.DataField {

    var heartrate, total_distance, total_duration, speed, pace, additional_steps;
    var activity_type;
    var base_steps;

    function initialize() {
        DataField.initialize();
        heartrate = 0;
        total_distance = 0.0;
        total_duration = 0.0;
        speed = 0.0;
        pace = 0.0;
        additional_steps = 0;
        base_steps = ActivityMonitor.getInfo().steps;

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
            var speed_label = View.findDrawableById("speed_label") as Text;
            speed_label.setColor(Graphics.COLOR_BLACK);
            speed_label.setText("mph");
            var pace_label = View.findDrawableById("pace_label") as Text;
            pace_label.setColor(Graphics.COLOR_BLACK);
            pace_label.setText("min/mi");
            var heartrate_label = View.findDrawableById("heartrate_label") as Text;
            heartrate_label.setColor(Graphics.COLOR_BLACK);
            heartrate_label.setText("hr");
            var total_distance_label = View.findDrawableById("total_distance_label") as Text;
            total_distance_label.setColor(Graphics.COLOR_BLACK);
            total_distance_label.setText("Distance");
            var total_duration_label = View.findDrawableById("total_duration_label") as Text;
            total_duration_label.setColor(Graphics.COLOR_BLACK);
            total_duration_label.setText("Duration");
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
        // ????????? info.getCurrentWorkoutStep().sport ????????
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
        setSteps();
        // Call parent's onUpdate(dc) to redraw the layout
        View.onUpdate(dc);
        setCurrentTime(dc);
        
    }

    private function setCurrentTime(dc as Dc) {
        var clockTime = System.getClockTime();
        var view_time = View.findDrawableById("time") as Text;
        view_time.setColor(Graphics.COLOR_BLACK as Number);

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

        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_DK_GRAY);
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
        view_total_duration.setColor(Graphics.COLOR_DK_GREEN);
        var timeformat = "$1$:$2$";
        var duration_minutes = 0;
        var duration_seconds = total_duration / 1000;
        var duration_hours = 0;

        if (duration_seconds >= 3600) {
            duration_hours = duration_seconds / 3600;
            duration_seconds = duration_seconds - (duration_hours * 3600);
            duration_hours = duration_hours.format("%0d");
        }
        if (duration_seconds >= 60) {
            duration_minutes = duration_seconds / 60;
            duration_seconds = duration_seconds - (duration_minutes * 60);
            duration_minutes = duration_minutes.format("%0d");
        }
        var timestring = Lang.format(timeformat, [duration_minutes, duration_seconds.format("%02d")]);
        if (duration_hours > 0) {
            timestring = duration_hours.toString() + ":" + timestring;
        }
        view_total_duration.setText(timestring);
    }

    private function setSpeed() {
        var view_speed = View.findDrawableById("speed") as Text;
        view_speed.setColor(Graphics.COLOR_PURPLE);
        view_speed.setText(speed.format("%02.1f").toString());
    }

    private function setPace() {
        var view_pace = View.findDrawableById("pace") as Text;
        view_pace.setColor(Graphics.COLOR_DK_RED);
        view_pace.setText(pace.format("%02.2f").toString());
    }

    private function setSteps() {
        if (base_steps > ActivityMonitor.getInfo().steps) {
            base_steps = ActivityMonitor.getInfo().steps;
            additional_steps = additional_steps + base_steps;
        }
        else {
            additional_steps = ActivityMonitor.getInfo().steps - base_steps;
        }
        
        var view_steps = View.findDrawableById("steps") as Text;
        view_steps.setColor(Graphics.COLOR_ORANGE);
        view_steps.setText("+" + additional_steps.toString());
    }

}

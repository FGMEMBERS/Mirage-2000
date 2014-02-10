#### Typhonn systems  
#### crazy dj nasal from many sources...
#### and also, almursi work
#### and 5H1N0B1

var deltaT = 1.0;
var SAS_Loop_running = 0;

setlistener("/controls/engines/engine[0]/throttle", func(n) {
    setprop("/controls/engines/engine[0]/reheat", 105 -( n.getValue() >= 0.75)/(105-95));
},1);

setlistener("/instrumentation/tacan/frequencies/selected-channel[4]", func(n) {
    if(n.getValue() =="X"){
        setprop("instrumentation/tacan/frequencies/XPos",1);
    }else{
        setprop("instrumentation/tacan/frequencies/XPos",-1);
    }
},1);

setlistener("/gear/gear[2]/wow", func(n) {
    if(getprop("/gear/gear[2]/wow")==1){
        gui.menuEnable("fuel-and-payload", 1);
    }else{
        gui.menuEnable("fuel-and-payload", 0);
    }
},1);

setlistener("/controls/gear/gear-down", func(n) {setprop("/controls/flight/flaps", 0);},1);

# turn off hud in external views
setlistener("/sim/current-view/view-number", func(n) { setprop("/sim/hud/visibility[1]", n.getValue() == 0) },1);

var InitListener = setlistener("/sim/signals/fdm-initialized", func {
        settimer(main_Init_Loop, 5.0);
        removelistener(InitListener);
});

################################################ Main init loop################################################
#####         Perhaps in the future, make an object for each subsystems, in the same way of "engine"   ########
###############################################################################################################
var main_Init_Loop = func(){    

    var SAS_rudder   = nil;
    var SAS_elevator = nil; 
    var SAS_aileron  = nil;

    print("Radar ...Check");
    settimer(radar.init, 5.0);

    print("Flight Director ...Check");
    settimer(mirage2000.init_set, 5.0);

    print("MFD ...Check");
    settimer(mirage2000.update_main, 5.0);

    print("Intrumentation ...Chsck");
    settimer(instrumentation.initIns, 5.0);

    print("Transponder ...Check");
    settimer(init_Transpondeur, 5.0);

    print("system loop ...Check");
    settimer(updatefunction, 5.0);

    if(SAS_rudder == nil){
        var SAS_rudder = setlistener("/controls/flight/rudder", func {
                #mirage2000.computeSAS();
                Update_SAS();
        });
    }
    if(SAS_aileron == nil){
         var SAS_aileron = setlistener("controls/flight/aileron", func {
                #mirage2000.computeSAS();
                Update_SAS();
          });
    }
    if(SAS_elevator == nil){
         var SAS_elevator = setlistener("controls/flight/elevator", func {
                #mirage2000.computeSAS();
                Update_SAS();
          });
    }

}

######################################SAS double running avoidance #######################################
var Update_SAS = func (){

    if(SAS_Loop_running == 0){
        SAS_Loop_running = 1;
        mirage2000.computeSAS();
        SAS_Loop_running = 0;
    } 
}


##################################################################################################################
var UpdateMain = func {settimer (updatefunction, 0.25);}


var updatefunction = func(){
     #deltaT = getprop ("sim/time/delta-sec");
   
     Update_SAS();
     #mirage2000.computeSAS();     
     mirage2000.UpdateMain();
}


 #################################################################################################################
 var init_Transpondeur = func() {
    #Init Transponder
    var poweroften = [1, 10, 100, 1000];
    var idcode = getprop('/instrumentation/transponder/id-code');
        
    if (idcode != nil)
    {
          for (var i = 0; i < 4 ; i = i+1)
            {
            setprop("/instrumentation/transponder/inputs/digit[" ~ i ~ "]", math.mod(idcode/poweroften[i], 10) );
            }
     }
} 
 

# ================================== Chute ==================================================

controls.deployChute = func(v){

  # Deploy
  if (v > 0){
    setprop("sim/model/lightning/controls/flight/chute_deployed",1);
    setprop("sim/model/lightning/controls/flight/chute_open",1);
    chuteAngle();
  }
  # Jettison
  if (v < 0){ 
    var voltage = getprop("systems/electrical/outputs/chute_jett");
    if (voltage > 20) {
      setprop("sim/model/lightning/controls/flight/chute_jettisoned",1);
      setprop("sim/model/lightning/controls/flight/chute_open",0);
    }
  }
}

var chuteAngle = func {
  var chute_open = getprop('sim/model/lightning/controls/flight/chute_open');

  if (chute_open != '1') {return();}

  var speed = getprop('velocities/airspeed-kt');
  var aircraftpitch = getprop('orientation/pitch-deg[0]');
  var aircraftyaw = getprop('orientation/side-slip-deg');
  var chuteyaw = getprop("sim/model/lightning/orientation/chute_yaw");
  var aircraftroll = getprop('orientation/roll-deg');

  if (speed > 210) {
    setprop("sim/model/lightning/controls/flight/chute_jettisoned", 1); # Model Shear Pin
    return();
  }

  # Chute Pitch
  var chutepitch = aircraftpitch * -1;
  setprop("sim/model/lightning/orientation/chute_pitch", chutepitch);

  # Damped yaw from Vivian's A4 work
  var n = 0.01;
  if (aircraftyaw == nil) {aircraftyaw = 0;}
  if (chuteyaw == nil) {chuteyaw = 0;}
  var chuteyaw = ( aircraftyaw * n) + ( chuteyaw * (1 - n));  
  setprop("sim/model/lightning/orientation/chute_yaw", chuteyaw);

  # Chute Roll - no twisting for now
  var chuteroll = aircraftroll;
  setprop("sim/model/lightning/orientation/chute_roll", chuteroll*rand()*-1 );

  return registerTimerControlsNil(chuteAngle);  # Keep watching

} # end function

var chuteRepack = func{

  setprop('sim/model/lightning/controls/flight/chute_open', 0);
  setprop('sim/model/lightning/controls/flight/chute_deployed', 0);
  setprop('sim/model/lightning/controls/flight/chute_jettisoned', 0);

} # end func  

##
# AirBrake handling.
#
var fullAirBrakeTime = 1;
var applyAirBrakes = func(v) {
  interpolate("/controls/flight/spoilers", v, fullAirBrakeTime);
}

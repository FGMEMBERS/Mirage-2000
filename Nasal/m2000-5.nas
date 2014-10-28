#### Typhonn systems  
#### crazy dj nasal from many sources...
#### and also, almursi work
#### and 5H1N0B1

var deltaT = 1.0;
var SAS_Loop_running = 0;
var Elapsed_time_actual = 0;
var Elapsed_time_previous = 0;
var LastTime = 0;



var InitListener = setlistener("/sim/signals/fdm-initialized", func {  
        
        settimer(main_Init_Loop, 5.0);
        removelistener(InitListener);
});



################################################ Main init loop################################################
#####         Perhaps in the future, make an object for each subsystems, in the same way of "engine"   ########
################################################################################################################
var main_Init_Loop = func(){   

    # --------- Loop Updated inside
    #print("Electrical ...Check");
    settimer(electrics.Electrical_init, 1.0);
    
    # --------- Loop Updated inside
    #print("Hydraulical ...Check");
    settimer(hydraulics.Hydraulical_init, 1.0);
    
    # --------- Loop Updated inside
    #print("Hydraulical ...Check");
    settimer(fuel.Fuel_init, 1.0);
    
    # --------- Loop Updated bellow
    print("Stability Augmentation System ...Check");
    settimer(mirage2000.init_SAS, 4.0);
    
    # -------------
    print("Intrumentation ...Chsck");
    settimer(instrumentation.initIns, 5.0);
 
    # --------- Loop Updated bellow
    print("Radar ...Check");
    settimer(radar.init, 8.0);
    
    # --------- Loop Updated bellow
    print("Flight Director ...Check");
    settimer(mirage2000.init_set, 8.0);
    
    # --------- Loop Updated bellow
    print("MFD ...Check");
    settimer(mirage2000.update_main, 8.0);
    
    # -------------Transponder
    print("Transponder ...Check");
    settimer(init_Transpondeur, 8.0);
    
    # -------------Canvas    <- Old way. Now object is created when selected
    #Init Canvas for central Mfd
    #settimer(mirage2000.CANVAS_init,8);
    
    # ---------link to bellow
    print("system loop ...Check");
    settimer(updatefunction, 15.0);
    

    

}




##################################################################################################################
var UpdateMain = func {settimer (mirage2000.updatefunction, 0);}
#var UpdateMain = func {mirage2000.updatefunction();}

var updatefunction = func(){
     #deltaT = getprop ("sim/time/delta-sec");
     #print(deltaT);
     
     Elapsed_time_actual = int(getprop ("sim/time/elapsed-sec"));
     FirstTime = getprop ("sim/time/elapsed-sec");
     #print(FirstTime);
     
     #print("Elapsed_time_actual:",Elapsed_time_actual, " Elapsed_time_previous:",Elapsed_time_previous);
     #print("################ FPS:",1/(FirstTime-LastTime));


     #---------------UPDATE SAS---------------------
     mirage2000.Update_SAS();
     ##mirage2000.computeSAS();
     
     #SASTime = getprop ("sim/time/elapsed-sec");
     #print(FirstTime-SASTime);
     
     
     #---------------UPDATE RADAR : Radar loop  -----------
     radar.rdr_loop();
     
     #RadarTime = getprop ("sim/time/elapsed-sec");
     #print(SASTime-RadarTime);
     
     
     #---------------UPDATE Electric : Electrical loop  -----------
     #electrics.update_electrical();
     
     #---------------UPDATE Guns : Electrical loop  -----------
     #guns.update_guns();
     
     
     #--------------UPDATE MFD : mfd loop-------------------
     mirage2000.update_main();
     
     MfdTime = getprop ("sim/time/elapsed-sec");
     #print(RadarTime-MfdTime);
     
     
     #-------------UPDATE FLIGHT DIRECTOR : Flight Director (autopilot)--------
     if(getprop("autopilot/locks/AP-status")=="AP1"){
        mirage2000.update_fd();
     }else{
        #this is a way to reduce autopilot refreshing time when not activated  <-? what
        if(Elapsed_time_actual != Elapsed_time_previous){
            mirage2000.update_fd();  
        }
        
     }
     
     #FlightDirectorTime = getprop ("sim/time/elapsed-sec");
     #print(MfdTime-FlightDirectorTime);
     
     if(Elapsed_time_actual != Elapsed_time_previous){
        mirage2000.fuel_managment();
        #print("Im here");
     }
     
     
     Elapsed_time_previous = Elapsed_time_actual;
     LastTime = FirstTime;
        
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


var fuel_managment = func(){
  var Externaltank = getprop("/consumables/fuel/tank[2]/empty");
  Externaltank *= getprop("/consumables/fuel/tank[3]/empty");
  Externaltank *=getprop("/consumables/fuel/tank[4]/empty");
  #If only one external Tank is still not empty, then...
  
  #print("Is my ext fuel tanks empty ",Externaltank);
  
  #systems/refuel/contact = false si pas refuel en cours

  if(getprop("systems/refuel/contact")){
        setprop("/consumables/fuel/tank[0]/selected",1);
        setprop("/consumables/fuel/tank[1]/selected",1);
        
        setprop("/consumables/fuel/tank[2]/selected",1);
        setprop("/consumables/fuel/tank[3]/selected",1);
        setprop("/consumables/fuel/tank[4]/selected",1);   
        
  }elsif(Externaltank){
    setprop("/consumables/fuel/tank[0]/selected",1);
    setprop("/consumables/fuel/tank[1]/selected",1);
  }else{
    setprop("/consumables/fuel/tank[0]/selected",0);
    setprop("/consumables/fuel/tank[1]/selected",0);
    if(!getprop("/consumables/fuel/tank[2]/empty")){setprop("/consumables/fuel/tank[2]/selected",1);}
    if(!getprop("/consumables/fuel/tank[3]/empty")){setprop("/consumables/fuel/tank[3]/selected",1);}
    if(!getprop("/consumables/fuel/tank[4]/empty")){setprop("/consumables/fuel/tank[4]/selected",1);} 
  }

}


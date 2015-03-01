var dt = 0 ;
var isFiring = 0;


fire_MG = func (b) {
  var time = getprop("sim/time/elapsed-sec");

  #Here is the gun things : the firing should last 0,5 sec or 1 sec, and in the future should be selectionable 
  if(getprop("controls/armament/stick-selector")==1 and getprop("ai/submodels/submodel/count")>0 and isFiring ==0){
    isFiring = 1;
    setprop("/controls/armament/Gun_trigger", 1);
    settimer(stopFiring,0.5);
  }

  if(getprop("controls/armament/stick-selector")==2){
    if(b == 1){
      #To limit: one missile/second
      #var time = getprop("sim/time/elapsed-sec");
      if(time - dt > 1){
        dt=time;
        var pylon = getprop("controls/armament/missile/current-pylon");
        m2000_load.dropLoad(pylon);
        print("Should fire Missile");
      }
    }
  }
}

var stopFiring = func {
    setprop("/controls/armament/Gun_trigger", 0);
    isFiring = 0;
}

reload_Cannon = func {
  setprop("ai/submodels/submodel/count",120);
  setprop("ai/submodels/submodel[1]/count",120);
  setprop("ai/submodels/submodel[2]/count",120);
  setprop("ai/submodels/submodel[3]/count",120);
}

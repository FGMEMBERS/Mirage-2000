var dt = 0 ;

fire_MG = func (b) {
  #print("Mode selected",getprop("controls/armament/stick-selector"));     
  if(getprop("controls/armament/stick-selector")==1 and getprop("ai/submodels/submodel/count")>0){
    setprop("/controls/armament/Gun_trigger", b);
  }
  if(getprop("controls/armament/stick-selector")==2){
    if(b == 1){
      #To limit: one missile/second
      var time = getprop("sim/time/elapsed-sec");
      if(time - dt > 1){
        dt=time;
        var pylon = getprop("controls/armament/missile/current-pylon");
        load.dropLoad(pylon);
        print("Should fire Missile");
      }
    }
  }
}

reload_Cannon = func {
  setprop("ai/submodels/submodel/count",120);
  setprop("ai/submodels/submodel[1]/count",120);
  setprop("ai/submodels/submodel[2]/count",120);
  setprop("ai/submodels/submodel[3]/count",120);
}

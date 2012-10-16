# Radar2 and RWR routines.

# Alexis Bory (xiii)

# Every 0.05 seconde:
# [1] Scans /AI/models for (aircrafts), (carriers), multiplayers. Creates a list of
#     these targets, whenever they are in radar overall range and are valid.
# [2] RWR (Radar Warning Receiver) signals are then computed. RWR signal values
#     are writen under /instrumentation/radar2/targets for interoperabilty purposes.
# [3] At each loop the targets list is scanned and each target bearing is checked
#     against the radar beam heading. If the target is within the radar beam, its
#     display properties are updated. Two different displays are possible:
#     B-scan like and PPI like.
#     The target distance is then scored so the radar system can autotrack the
#     nearest target.
# Every 0.1 seconde:
# [4] Computes HUD marker position for the nearest target.

var OurAlt            = props.globals.getNode("position/altitude-ft");
var OurHdg            = props.globals.getNode("orientation/heading-deg");


var our_alt           = 0;
var Mp = props.globals.getNode("ai/models");
var tgts_list         = [];

var StandByTgtMarker  = 0;



var switch_distance = func() {

         var range = getprop("instrumentation/radar/range");
         if(range == 5){
            range = 10;
            if(getprop("/sim/aim/tachy") != "true"){setprop("instrumentation/radar[0]/selected",3);}
         }elsif(range == 10){
            range = 20;
            if(getprop("/sim/aim/tachy") != "true"){setprop("instrumentation/radar[0]/selected",2);}
         }elsif(range == 20){
            range = 50;
            if(getprop("/sim/aim/tachy") != "true"){setprop("instrumentation/radar[0]/selected",2);}
         }elsif(range == 50){
            range = 100;
            if(getprop("/sim/aim/tachy") != "true"){setprop("instrumentation/radar[0]/selected",2);}
         }elsif(range == 100){
            range = 150;
            if(getprop("/sim/aim/tachy") != "true"){setprop("instrumentation/radar[0]/selected",2);}
         }elsif(range==150){
            range = 5;
            if(getprop("/sim/aim/tachy") != "true"){setprop("instrumentation/radar[0]/selected",3);}
         }
         
       setprop("instrumentation/radar/range",range);
       if(range<101){setprop("instrumentation/nd/range",range);}
       setprop("instrumentation/radar/range-selected",range);
       #remove_target();
      
         
         
}


var remove_target = func(){
        var targets = props.globals.getNode("instrumentation/radar2/targets");
        var raw_list = Mp.getChildren();
        foreach( var c; raw_list ) {
                c.remove();
        }

}




#Toggle circle for the HUD. This have to move to the future hud.nas
var activate_borsight = func() {
        if(getprop("/sim/aim/active") != "true" )
         {
           setprop("/sim/aim/active","true");
         }else{

           if(getprop("/sim/aim/tachy") != "true"){
             setprop("/sim/aim/tachy","true");
             setprop("/sim/aim/align","true");
             setprop("/sim/aim/speed-fps",3363); #speed of bullets ?
             setprop("/sim/aim/range-yds",6075); #(3nm = 6075 yard)
             setprop("instrumentation/radar[0]/selected",4);
           }else{
             setprop("/sim/aim/tachy","false");
             setprop("/sim/aim/align","false"); 
             setprop("/sim/aim/active","false");
            }
          }
}
var activate_ECM = func() {
        if(getprop("instrumentation/ecm/on-off") != "true" )
         {
           setprop("instrumentation/ecm/on-off","true");
         }else{
           setprop("instrumentation/ecm/on-off","false");
         }
}


var activate_Telemeter= func(){
       if(getprop("/ai/closest/range") == -2){
          setprop("/ai/closest/range",-1);}
       else{setprop("/ai/closest/range",-2);}

       closest_target();
       radar.radar_mode_toggle();
       StandByTgtMarker = 0;

}


#This have to move to another .nas
var closest_target = func() {
        if(getprop("/ai/closest/range") >= -1){


              tgts_list = [];
              var raw_list = Mp.getChildren();
              var closeRange =200;
              var bearing = 0;
              var heading = 0 ;
              var speed = 0;
              var altitude = 0;
              var callsign = "-";
              var longitude = 0;
              var latitude = 0;
              var current_target=0;


              foreach( var c; raw_list ) {
                     var type = c.getName();
                     

                     if (!c.getNode("valid", 1).getValue()) {
                          continue;
                     }
                    
                     if (type == "multiplayer" or type == "tanker" or type =="carrier" or type =="aircraft") {
                         var maTarget = Threat.new(c);
                         var u_rng = maTarget.get_range();
                         #var u_rng = c.getChildren("distance-to-nm").getValue();

                         if(math.abs(maTarget.get_bearing()-getprop("orientation/heading-deg"))<=5){
                                
                                 if(math.abs( (math.atan2((maTarget.get_altitude() - getprop("position/altitude-ft"))*FT2M,u_rng *1852)*R2D) - getprop("orientation/pitch-deg")) <= 5 ){
                                         if(closeRange >= u_rng and u_rng!=0){
                                             closeRange = u_rng;
                                             #print(u_rng);
                                             current_target = maTarget;

                                             heading = maTarget.get_heading();
                                             altitude = maTarget.get_altitude();
                                             speed = maTarget.get_Speed();
                                             callsign = maTarget.get_Callsign();
                                             longitude = maTarget.get_Longitude();
                                             latitude = maTarget.get_Latitude();
                                             bearing = maTarget.get_bearing();

                                         }
                                 }
                        }
                        
                     }
              }
              if(closeRange == 200){closeRange = -1;}
              setprop("/ai/closest/range",closeRange);
              setprop("/ai/closest/bearing",bearing);
              setprop("/ai/closest/heading",heading);
              setprop("/ai/closest/altitude",altitude);
              setprop("/ai/closest/speed",speed);
              setprop("/ai/closest/callsign",callsign);
              setprop("/ai/closest/longitude",longitude);
              setprop("/ai/closest/latitude",latitude);
              if(StandByTgtMarker < 1000) {
                        settimer(closest_target, 0.5);
                        StandByTgtMarker = StandByTgtMarker +1 ;
              }else{
                    setprop("/ai/closest/range",-2 );
                    StandByTgtMarker = 0;
                    radar.radar_mode_toggle();
              }

              return current_target;

       }
}


# Target class
var Threat = {
        new : func (c) {
                var obj = { parents : [Threat]};
                obj.RdrProp = c.getNode("radar");
                obj.Heading = c.getNode("orientation/true-heading-deg");
                obj.Pitch = c.getNode("orientation/pitch-deg");
                obj.Alt = c.getNode("position/altitude-ft");
                obj.longitude = c.getNode("position/longitude-deg");
                obj.latitude = c.getNode("position/latitude-deg");

                obj.AcType = c.getNode("sim/model/ac-type");
                obj.type = c.getName();
                obj.index = c.getIndex();
                obj.string = "ai/models/" ~ obj.type ~ "[" ~ obj.index ~ "]";
                obj.shortstring = obj.type ~ "[" ~ obj.index ~ "]";
                obj.InstrTgts = props.globals.getNode("instrumentation/radar2/targets", 1);
                obj.TgtsFiles = obj.InstrTgts.getNode(obj.shortstring, 1);

                obj.Callsign       = c.getNode("callsign");
                obj.Speed          = c.getNode("velocities/true-airspeed-kt");

                obj.Range          = obj.RdrProp.getNode("range-nm");
                obj.Bearing        = obj.RdrProp.getNode("bearing-deg");
                obj.Elevation      = obj.RdrProp.getNode("elevation-deg");
                obj.TotalElevation = obj.RdrProp.getNode("total-elevation-deg", 1);
                obj.BBearing       = obj.TgtsFiles.getNode("bearing-deg", 1);
                obj.BHeading       = obj.TgtsFiles.getNode("true-heading-deg", 1);
                obj.RangeScore     = obj.TgtsFiles.getNode("range-score", 1);
                obj.RelBearing     = obj.TgtsFiles.getNode("ddd-relative-bearing", 1);
                obj.Carrier        = obj.TgtsFiles.getNode("carrier", 1);
                obj.EcmSignal      = obj.TgtsFiles.getNode("ecm-signal", 1);
                obj.EcmSignalNorm  = obj.TgtsFiles.getNode("ecm-signal-norm", 1);
                obj.EcmTypeNum     = obj.TgtsFiles.getNode("ecm_type_num", 1);

                obj.RadarStandby = c.getNode("sim/multiplay/generic/int[6]");
                obj.deviation = nil;

                return obj;
        },
        get_Speed : func {
                var n = me.Speed.getValue();
                #vat alt = me.Alt.getValue();
                #n = n/(0.632^(-(alt/25066))); #Calcul of Air Speed based on ground speed. the function ^ don't work !!
                return n;
        },
        get_Callsign : func {
                var n = me.Callsign.getValue();
                return n;
        },
        get_Longitude : func {
                var n = me.longitude.getValue();
                return n;
        },
        get_Latitude : func {
                var n = me.latitude.getValue();
                return n;
        },
        get_Pitch : func {
                var n = me.Pitch.getValue();
                return n;
        },
        get_heading : func {
                var n = me.Heading.getValue();
                me.BHeading.setValue(n);
                return n;
        },
        get_bearing : func {
                var n = me.Bearing.getValue();
                me.BBearing.setValue(n);
                return n;
        },
        set_relative_bearing : func(n) {
                me.RelBearing.setValue(n);
        },
        get_reciprocal_bearing : func {
                return geo.normdeg(me.get_bearing() + 180);
        },
        get_deviation : func(true_heading_ref) {
                me.deviation =  - deviation_normdeg(true_heading_ref, me.get_bearing());
                return me.deviation;
        },
        get_altitude : func {
                return me.Alt.getValue();
        },
        get_range : func {
                       return me.Range.getValue();
        },
        get_total_elevation : func(own_pitch) {
                me.deviation =  - deviation_normdeg(own_pitch, me.Elevation.getValue());
                me.TotalElevation.setValue(me.deviation);
                return me.deviation;
        },
        get_horizon : func(own_alt) {
                var tgt_alt = me.get_altitude();
                if ( tgt_alt != nil ) {
                        if ( own_alt < 0 ) { own_alt = 0.001 }
                        if ( debug.isnan(tgt_alt)) {
                                return(0);
                        }
                        if ( tgt_alt < 0 ) { tgt_alt = 0.001 }
                        return radardist.radar_horizon( own_alt, tgt_alt );
                } else {
                        return(0);
                }
        },
        check_carrier_type : func {
                var type = "none";
                var carrier = 0;
                if ( me.AcType != nil ) { type = me.AcType.getValue() }
                if ( type == "MP-Nimitz" or type == "MP-Eisenhower"  or type == "MP-Vinson") { carrier = 1 }
                # This works only after the mp-carrier model has been loaded. Before that it is seen like a common aircraft.
                me.Carrier.setBoolValue(carrier);
                return carrier;
        },
        get_rdr_standby : func {
                var s = 0;
                if ( me.RadarStandby != nil ) {
                        s = me.RadarStandby.getValue();
                        if (s == nil) { s = 0 } elsif (s != 1) { s = 0 }
                }
                return s;
        },
        list : [],
};

# Utilities.
var deviation_normdeg = func(our_heading, target_bearing) {
        var dev_norm = our_heading - target_bearing;
        while (dev_norm < -180) dev_norm += 360;
        while (dev_norm > 180) dev_norm -= 360;
        return(dev_norm);
}

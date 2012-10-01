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
var EcmOn             = props.globals.getNode("instrumentation/ecm/on-off", 1);
var EcmAlert1         = props.globals.getNode("instrumentation/ecm/alert-type1", 1);
var EcmAlert2         = props.globals.getNode("instrumentation/ecm/alert-type2", 1);

var our_alt           = 0;
var Mp = props.globals.getNode("ai/models");
var tgts_list         = [];
var ecm_alert1        = 0;
var ecm_alert2        = 0;
var ecm_alert1_last   = 0;
var ecm_alert2_last   = 0;
var u_ecm_signal      = 0;
var u_ecm_signal_norm = 0;
var u_radar_standby   = 0;
var u_ecm_type_num    = 0;
var StandByTgtMarker  = 0;


init = func() {
        radardist.init();
        closest_target();
        settimer(rwr_loop, 0.5);
}

var switch_distance = func() {
         if(getprop("instrumentation/radar/range")==10){
            setprop("instrumentation/radar/range",20);
            if(getprop("/sim/aim/tachy") != "true"){setprop("instrumentation/radar[0]/selected",3);}
         }elsif(getprop("instrumentation/radar/range")==20){
            setprop("instrumentation/radar/range",40);
            if(getprop("/sim/aim/tachy") != "true"){setprop("instrumentation/radar[0]/selected",2);}
         }elsif(getprop("instrumentation/radar/range")==40){
            setprop("instrumentation/radar/range",100);
            if(getprop("/sim/aim/tachy") != "true"){setprop("instrumentation/radar[0]/selected",2);}
         }elsif(getprop("instrumentation/radar/range")==100){
            setprop("instrumentation/radar/range",10);
            if(getprop("/sim/aim/tachy") != "true"){setprop("instrumentation/radar[0]/selected",3);}
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
       if(getprop("/ai/closest/range") == 101){
          setprop("/ai/closest/range",100);}
       else{setprop("/ai/closest/range",101);}

       closest_target();

}


#This have to move to another .nas
var closest_target = func() {
        if(getprop("/ai/closest/range") < 101){


              tgts_list = [];
              var raw_list = Mp.getChildren();
              var closeRange =100;
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
              setprop("/ai/closest/range",closeRange);
              setprop("/ai/closest/bearing",bearing);
              setprop("/ai/closest/heading",heading);
              setprop("/ai/closest/altitude",altitude);
              setprop("/ai/closest/speed",speed);
              setprop("/ai/closest/callsign",callsign);
              setprop("/ai/closest/longitude",longitude);
              setprop("/ai/closest/latitude",latitude);
              if(StandByTgtMarker < 600) {
                        settimer(closest_target, 0.5);
                        StandByTgtMarker = StandByTgtMarker +1 ;
              }else{
                    setprop("/ai/closest/range",101);
                    StandByTgtMarker = 0;
              }

              return current_target;

       }
}



# Main loop ###############
var rwr_loop = func() {

        ecm_on = EcmOn.getBoolValue();
        if ( ecm_on) {
                our_alt = OurAlt.getValue();
                tgts_list = [];
                var raw_list = Mp.getChildren();
                foreach( var c; raw_list ) {
                        var type = c.getName();
                        if (!c.getNode("valid", 1).getValue()) {
                                continue;
                        }
                        var HaveRadarNode = c.getNode("radar");
                        if (type == "multiplayer" or type == "tanker" and HaveRadarNode != nil) {
                                var u = Threat.new(c);
                                u_ecm_signal      = 0;
                                u_ecm_signal_norm = 0;
                                u_radar_standby   = 0;
                                u_ecm_type_num    = 0;
                                if ( u.Range != nil) {
                                        # Test if target has a radar. Compute if we are illuminated. This propery used by ECM
                                        # over MP, should be standardized, like "ai/models/multiplayer[0]/radar/radar-standby".
                                        var u_name = radardist.get_aircraft_name(u.string);
                                        var u_maxrange = radardist.my_maxrange(u_name); # in kilometer, 0 is unknown or no radar.
                                        var horizon = u.get_horizon( our_alt );
                                        var u_rng = u.get_range();
                                        var u_carrier = u.check_carrier_type();
                                        if ( u.get_rdr_standby() == 0 and u_maxrange > 0  and u_rng < horizon ) {
                                                # Test if we are in its radar field (hard coded 74°) or if we have a MPcarrier.
                                                # Compute the signal strength.
                                                var our_deviation_deg = deviation_normdeg(u.get_heading(), u.get_reciprocal_bearing());
                                                if ( our_deviation_deg < 0 ) { our_deviation_deg *= -1 }
                                                if ( our_deviation_deg < 37 or u_carrier == 1 ) {
                                                        u_ecm_signal = (((-our_deviation_deg/20)+2.5)*(!u_carrier )) + (-u_rng/20) + 2.6 + (u_carrier*1.8);
                                                        u_ecm_type_num = radardist.get_ecm_type_num(u_name);
                                                }
                                        } else {
                                                u_ecm_signal = 0;
                                        }        
                                        # Compute global threat situation for undiscriminant warning lights
                                        # and discrete (normalized) definition of threat strength.
                                        if ( u_ecm_signal > 1 and u_ecm_signal < 3 ) {
                                                EcmAlert1.setBoolValue(1);
                                                ecm_alert1 = 1;
                                                u_ecm_signal_norm = 2;
                                        } elsif ( u_ecm_signal >= 3 ) {
                                                EcmAlert2.setBoolValue(1);
                                                ecm_alert2 = 1;
                                                u_ecm_signal_norm = 1;
                                        }
                                        u.EcmSignal.setValue(u_ecm_signal);
                                        u.EcmSignalNorm.setIntValue(u_ecm_signal_norm);
                                        u.EcmTypeNum.setIntValue(u_ecm_type_num);
                                }
                        }
                }

                # Summarize ECM alerts.
                if ( ecm_alert1 == 0 and ecm_alert1_last == 0 ) { EcmAlert1.setBoolValue(0) }
                if ( ecm_alert2 == 0 and ecm_alert1_last == 0 ) { EcmAlert2.setBoolValue(0) }
                ecm_alert1_last = ecm_alert1; # And avoid alert blinking at each loop.
                ecm_alert2_last = ecm_alert2;
                ecm_alert1 = 0;
                ecm_alert2 = 0;
        } elsif ( size(tgts_list) > 0 ) {
                foreach( u; tgts_list ) {
                        u.EcmSignal.setValue(0);
                        u.EcmSignalNorm.setIntValue(0);
                        u.EcmTypeNum.setIntValue(0);
                }
        }
        settimer(rwr_loop, 0.05);
}



# Utilities.
var deviation_normdeg = func(our_heading, target_bearing) {
        var dev_norm = our_heading - target_bearing;
        while (dev_norm < -180) dev_norm += 360;
        while (dev_norm > 180) dev_norm -= 360;
        return(dev_norm);
}


setlistener("sim/signals/fdm-initialized", init);

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



##########################################################
####### Single Starter/Generator electrical system #######
####################    Syd Adams    #####################
###### Based on Curtis Olson's nasal electrical code #####
##########################################################
##########################################################
######## Modified by Clement DE L'HAMAIDE for DC-3 #######
########       Modified by PAF team for DC-3       #######
##########################################################

var last_time = 0.0;
var OutPuts = props.globals.getNode("/systems/electrical/outputs",1);
var Volts = props.globals.getNode("/systems/electrical/volts",1);
var Amps = props.globals.getNode("/systems/electrical/amps",1);
var PWR = props.globals.getNode("systems/electrical/serviceable",1).getBoolValue();
var BATT_CHARGE_PERCENT = props.globals.getNode("/systems/electrical/battery_charge_percent",1);
var BATT = props.globals.getNode("/controls/switches/battery-switch",1);
var ALT_1 = props.globals.getNode("/controls/switches/ALT1-switch",1);
var ALT_2 = props.globals.getNode("/controls/switches/ALT2-switch",1);
var DIMMER = props.globals.getNode("/controls/lighting/instruments-norm",1);
var ALT1_Amp = props.globals.getNode("/systems/electrical/suppliers/ALT_1",1);
var ALT2_Amp = props.globals.getNode("/systems/electrical/suppliers/ALT_2",1);
var BATT_Amp = props.globals.getNode("/systems/electrical/suppliers/BATT",1);
var APU_Amp = props.globals.getNode("/systems/electrical/suppliers/APU",1);
var NORM = 0.0357;
var Battery={};
var Alternator={};
var load = 0.0;

############################################################################
##################### Définition de la batterie ############################
############################################################################
#var battery = Battery.new(volts,amps,amp_hours,charge_percent,charge_amps);

Battery = {
    new : func {
        m = { parents : [Battery] };
        m.ideal_volts = arg[0];
        m.ideal_amps = arg[1];
        m.amp_hours = arg[2];
        m.charge_percent = arg[3];
        m.charge_amps = arg[4];
        return m;
    },

    apply_load : func {
        var amphrs_used = arg[0] * arg[1] / 3600.0;
        var percent_used = amphrs_used / me.amp_hours;
        me.charge_percent -= percent_used;
        if ( me.charge_percent < 0.0 ) {
            me.charge_percent = 0.0;
        } elsif ( me.charge_percent > 1.0 ) {
            me.charge_percent = 1.0;
        }
        BATT_CHARGE_PERCENT.setValue(me.charge_percent);
        return me.amp_hours * me.charge_percent;
    },

    get_output_volts : func {
        var x = 1.0 - me.charge_percent;
        var tmp = -(3.0 * x - 1.0);
        var factor = (tmp*tmp*tmp*tmp*tmp + 32) / 32;
        return me.ideal_volts * factor;
    },

    get_output_amps : func {
        var x = 1.0 - me.charge_percent;
        var tmp = -(3.0 * x - 1.0);
        var factor = (tmp*tmp*tmp*tmp*tmp + 32) / 32;
        return me.ideal_amps * factor;
    }
};

############################################################################
##################### Définition de l'aternateur ###########################
############################################################################
# var alternator = Alternator.new("rpm-source",rpm_threshold,volts,amps);

Alternator = {
    new : func {
        m = { parents : [Alternator] };
        m.rpm_source =  props.globals.getNode(arg[0],1);
        m.rpm_threshold = arg[1];
        m.ideal_volts = arg[2];
        m.ideal_amps = arg[3];
        return m;
    },

    apply_load : func( amps, dt) {
        var factor = me.rpm_source.getValue() / me.rpm_threshold;
        if ( factor > 1.0 ){
            factor = 1.0;
        }
        var available_amps = me.ideal_amps * factor;
        return available_amps - amps;
    },

    get_output_volts : func {
        var factor = me.rpm_source.getValue() / me.rpm_threshold;
        if ( factor > 1.0 ) {
            factor = 1.0;
            }
        return me.ideal_volts * factor;
    },

    get_output_amps : func {
        var factor = me.rpm_source.getValue() / me.rpm_threshold;
        #print(factor);
        if ( factor > 1.0 ) {
            factor = 1.0;
        }
        return me.ideal_amps * factor;
    }
};

#var battery = Battery.new(volts,amps,amp_hours,charge_percent,charge_amps);
var battery = Battery.new(24.0, 40, 40, 1.0, 40);           # Définition des caractéristiques de la batterie
var alternator_1 = Alternator.new("/engines/engine[0]/rpm", 4400.0, 28.0, 120.0);   # Définition des caractéristiques de l'alternateur
var alternator_2 = Alternator.new("/engines/engine[0]/rpm", 4400.0, 28.0, 119.0);   # Définition des caractéristiques de l'alternateur

############################################################################
############# Définition des proppriétés à l'initialisation ################
############################################################################



Electrical_init = func () {
    foreach(var a; props.globals.getNode("/systems/electrical/outputs").getChildren()){
       a.setValue(0);
    }
    foreach(var a; props.globals.getNode("/controls/circuit-breakers").getChildren()){
       a.setBoolValue(1);
    }
    foreach(var a; props.globals.getNode("/controls/lighting").getChildren()){
       a.setValue(1);
    }
    props.globals.getNode("/controls/lighting/instrument-lights",1).setBoolValue(1);
    props.globals.getNode("/controls/anti-ice/prop-heat",1).setBoolValue(0);
    props.globals.getNode("/controls/anti-ice/pitot-heat",1).setBoolValue(0);
    props.globals.getNode("/controls/cabin/fan",1).setBoolValue(0);
    props.globals.getNode("/controls/cabin/heat",1).setBoolValue(0);
    props.globals.getNode("/controls/electric/external-power",1).setBoolValue(0);
    props.globals.getNode("/controls/switches/battery-switch",1).setBoolValue(0);
    props.globals.getNode("/sim/failure-manager/instrumentation/comm/serviceable",1).setBoolValue(1);
    props.globals.getNode("/instrumentation/kt76a/mode",1).setValue("0");
    props.globals.getNode("/systems/electrical/volts",1).setValue(0);
      #### ENGINE[0] ####
    props.globals.getNode("/controls/electric/engine[0]/generator",1).setBoolValue(1);
    props.globals.getNode("/engines/engine[0]/amp-v",1).setDoubleValue(0);
    props.globals.getNode("/controls/engines/engine[0]/master-alt",1).setBoolValue(0);
    props.globals.getNode("/controls/engines/engine[0]/master-bat",1).setBoolValue(0);
      #### engine[0] ####
    #props.globals.getNode("/controls/electric/engine[0]/generator",1).setBoolValue(1);
    #props.globals.getNode("/engines/engine[0]/amp-v",1).setDoubleValue(0);
    #props.globals.getNode("/controls/engines/engine[0]/master-alt",1).setBoolValue(0);
    #props.globals.getNode("/controls/engines/engine[0]/master-bat",1).setBoolValue(0);

    settimer(update_electrical,1);
    print("Electrical System ... OK");
}

#setlistener("/controls/electric/key", func(key){
#    if(key.getValue() == 1){
#      setprop("/controls/electric/battery-switch",1);
#    }else{
#      setprop("/controls/electric/battery-switch",0);
#    }
#});

############################################################################
#################### Simulation du bus électrique virtuel ##################
############################################################################
var bus_volts = 0.0;

var update_virtual_bus = func(dt) {
    var AltVolts_1 = alternator_1.get_output_volts();
    var AltAmps_1 = alternator_1.get_output_amps();
    var AltVolts_2 = alternator_2.get_output_volts();
    var AltAmps_2 = alternator_2.get_output_amps();
    var BatVolts = battery.get_output_volts();
    var BatAmps = battery.get_output_amps();
    
    #in order to return what is working or not
    if(AltAmps_1 != "" and AltAmps_1!=nil){ ALT1_Amp.setValue(AltAmps_1);}
    if(AltAmps_2 != "" and AltAmps_2!=nil){ ALT2_Amp.setValue(AltAmps_2);}
    if(BatAmps != ""   and BatAmps  !=nil){ BATT_Amp.setValue(BatAmps);}
    
    
    var power_source = nil;
    load = 0.0;
    load += electrical_bus(bus_volts);              # On récupère l'ampérage utilisé par le Bus électrique
    load += avionics_bus(bus_volts);              # On récupère l'ampérage utilisé par le Bus Avionics
    
    #print("BatAmps:",BatAmps," AltAmps_1:",AltAmps_1," AltAmps_2:",AltAmps_1);
    #print("ALT_1:",ALT_1.getBoolValue()," ALT_2:",ALT_2.getBoolValue());

    #####################################################################
    ################# Définition de la tension au moteur ################
    #####################################################################

    if(PWR){                    # Si le système électrique n'est pas endommagé
      if (ALT_1.getBoolValue() and (AltAmps_1 > BatAmps)        # Si le switch Alt Left ou Alt Right est à ON et que le courant d'un alternateur est supérieur ou égal à celui de la batterie
      or ALT_2.getBoolValue() and (AltAmps_2 > BatAmps)){       
          if(AltVolts_1 > AltVolts_2){              
            bus_volts = AltVolts_1;             # L'alternateur fournit la tension au Bus
          }else{                  
            bus_volts = AltVolts_2;             # L'alternateur fournit la tension au Bus
          }                   
          power_source = "alternator";              # L'alternateur est donc la source d'alimentation
          battery.apply_load(-battery.charge_amps, dt);         # Et on recharge la batterie
          #print("Pouet0");
      }                     
      elsif (ALT_1.getBoolValue() and (AltAmps_1 < BatAmps)
      or ALT_2.getBoolValue() and (AltAmps_2 < BatAmps)){       # Sinon si le switch Alt Left ou Alt Right est à ON mais que le courant de l'alternateur est inférieur à ce lui de la batterie
        if (BATT.getBoolValue()){             # Si le switch Batt est à ON 
          bus_volts = BatVolts;               # C'est la batterie qui fournie la tension au Bus
          power_source = "battery";             # La batterie est donc la source d'alimentation
          battery.apply_load(load, dt);             # Et on décharge la batterie
          #print("Pouet1");
        }                   
        else {                    # Sinon
          bus_volts = 0.0;                # La tension du Bus est 0V
          #print("Pouet2");
        }                   
      }                   
      elsif (BATT.getBoolValue()){              # Sinon si le switch de la batterie est à ON
          bus_volts = BatVolts;               # C'est la batterie qui fournie la tension au Bus
          power_source = "battery";             # La batterie est donc la source d'alimentation
          battery.apply_load(load, dt);             # Et on décharge la batterie
          #print("Pouet3");
      }                     
      else {                    # Sinon
        bus_volts = 0.0;                # La tension du Bus est 0V
      }                     
    } else {                    # Sinon c'est le système électrique est endommagé
        bus_volts = 0.0;                # La tension du Bus est 0V
    }

    props.globals.getNode("/engines/engine[0]/amp-v",1).setValue(bus_volts);    # La tension au moteur est égale à celle du Bus
    props.globals.getNode("/engines/engine[0]/amp-v",1).setValue(bus_volts);    # La tension au moteur est égale à celle du Bus

    #####################################################################
    ################### Définition de l'ampérage du Bus #################
    #####################################################################

    var bus_amps = 0.0;

    if (bus_volts > 1.0){               # Si la tension du Bus est supérieur à 1V
        if (power_source == "battery"){             # Si la source est la batterie
            bus_amps = BatAmps-load;              # L'intensité du Bus est l'intensité de la batterie moins l'intensité de tous les Bus
        } else {                  # Sinon
            bus_amps = battery.charge_amps;           # Sinon l'intensité du Bus est l'intensité fourni par l'alternateur (limité par les caractéristiques de la batterie)
        }
    }

    #####################################################################
    ###################### Affectation des valeurs ######################
    #####################################################################

    Amps.setValue(bus_amps);
    Volts.setValue(bus_volts);
    return load;
}

############################################################################
#################### Mesure des charge du bus électrique ###################
############################################################################

var electrical_bus = func(bus_volts){
    var load = 0.0;
    var starter_voltsL = 0.0;
    var starter_voltsR = 0.0;

    if(props.globals.getNode("/controls/lighting/landing-lights").getBoolValue()){
        OutPuts.getNode("landing-lights",1).setValue(bus_volts);
        load += 0.0004;
    } else {
        OutPuts.getNode("landing-lights",1).setValue(0.0);
    }
    if(props.globals.getNode("/controls/lighting/landing-lights[1]").getBoolValue()){
        OutPuts.getNode("landing-lights[1]",1).setValue(bus_volts);
        load += 0.0004;
    } else {
        OutPuts.getNode("landing-lights[1]",1).setValue(0.0);
    }

    if(props.globals.getNode("/controls/lighting/running-lights").getBoolValue()){
        OutPuts.getNode("running-lights",1).setValue(bus_volts);
        load += 0.000002;
    } else {
        OutPuts.getNode("running-lights",1).setValue(0.0);
    }

    if(props.globals.getNode("/controls/lighting/passing-lights").getBoolValue()){
        OutPuts.getNode("passing-lights",1).setValue(bus_volts);
        load += 0.000006;
    } else {
        OutPuts.getNode("passing-lights",1).setValue(0.0);
    }

    if(props.globals.getNode("/controls/lighting/recognition-lights").getBoolValue()){
        OutPuts.getNode("recognition-lights",1).setValue(bus_volts);
        load += 0.000006;
    } else {
        OutPuts.getNode("recognition-lights",1).setValue(0.0);
    }

    if(props.globals.getNode("/controls/lighting/recognition-lights[1]").getBoolValue()){
        OutPuts.getNode("recognition-lights[1]",1).setValue(bus_volts);
        load += 0.000006;
    } else {
        OutPuts.getNode("recognition-lights[1]",1).setValue(0.0);
    }

    if(props.globals.getNode("/controls/lighting/recognition-lights[2]").getBoolValue()){
        OutPuts.getNode("recognition-lights[2]",1).setValue(bus_volts);
        load += 0.000006;
    } else {
        OutPuts.getNode("recognition-lights[2]",1).setValue(0.0);
    }

    if(props.globals.getNode("/controls/lighting/formation-lights").getBoolValue()){
        OutPuts.getNode("formation-lights",1).setValue(bus_volts);
        load += 0.000006;
    } else {
        OutPuts.getNode("formation-lights",1).setValue(0.0);
    }

    if(props.globals.getNode("/controls/lighting/tail-lights").getBoolValue()){
        OutPuts.getNode("tail-lights",1).setValue(bus_volts);
        load += 0.000002;
    } else {
        OutPuts.getNode("tail-lights",1).setValue(0.0);
    }

    if(props.globals.getNode("/controls/lighting/cabin-lights").getBoolValue()){
        OutPuts.getNode("cabin-lights",1).setValue(bus_volts);
        load += 0.00002;
    } else {
        OutPuts.getNode("cabin-lights",1).setValue(0.0);
    }

    if(props.globals.getNode("/controls/anti-ice/engine/carb-heat").getBoolValue()){
        OutPuts.getNode("carb-heat",1).setValue(bus_volts);
        load += 0.00002;
    } else {
        OutPuts.getNode("carb-heat",1).setValue(0.0);
    }

    if(props.globals.getNode("/controls/fuel/tank/boost-pump").getBoolValue()){
        OutPuts.getNode("boost-pump",1).setValue(bus_volts);
        load += 0.000006;
    } else {
        OutPuts.getNode("boost-pump",1).setValue(0.0);
    }

    if(props.globals.getNode("/controls/fuel/tank[1]/boost-pump").getBoolValue()){
        OutPuts.getNode("boost-pump[1]",1).setValue(bus_volts);
        load += 0.000006;
    } else {
        OutPuts.getNode("boost-pump[1]",1).setValue(0.0);
    }

    if(props.globals.getNode("/controls/engines/engine/fuel-pump").getBoolValue()){
        OutPuts.getNode("fuel-pump",1).setValue(bus_volts);
        load += 0.000006;
    } else {
        OutPuts.getNode("fuel-pump",1).setValue(0.0);
    }

    if(props.globals.getNode("/controls/engines/engine[0]/fuel-pump").getBoolValue()){
        OutPuts.getNode("fuel-pump[1]",1).setValue(bus_volts);
        load += 0.000006;
    } else {
        OutPuts.getNode("fuel-pump[1]",1).setValue(0.0);
    }


    if (props.globals.getNode("/controls/engines/engine[0]/starter").getBoolValue()){
        starter_voltsL = bus_volts;
        load += 0.01;
    }

    if (props.globals.getNode("/controls/engines/engine[0]/starter").getBoolValue()){
        starter_voltsR = bus_volts;
        load += 0.01;
    }
    OutPuts.getNode("starter",1).setValue(starter_voltsL);
    OutPuts.getNode("starter[1]",1).setValue(starter_voltsR);

    return load;
}

############################################################################
############# Mesure des charges du bus avionique (Instruments) ############
############################################################################

var avionics_bus = func(bus_volts) {
    #load = 0.0;

    if (props.globals.getNode("/controls/lighting/instrument-lights").getBoolValue() and props.globals.getNode("/controls/circuit-breakers/instrument-lights").getBoolValue()){
        var instr_norm = props.globals.getNode("/controls/lighting/instruments-norm").getValue();
        var v = instr_norm * bus_volts;
        OutPuts.getNode("instrument-lights",1).setValue(v);
        load += 0.000025;
    } else {
        OutPuts.getNode("instrument-lights",1).setValue(0.0);
    }

    if (props.globals.getNode("/instrumentation/comm/serviceable").getBoolValue() and props.globals.getNode("/sim/failure-manager/instrumentation/comm/serviceable").getBoolValue()){
        OutPuts.getNode("comm",1).setValue(bus_volts);
        load += 0.00015;
    } else {
        OutPuts.getNode("comm",1).setValue(0.0);
    }

    if (props.globals.getNode("/controls/switches/transponder").getBoolValue()){
        OutPuts.getNode("transponder",1).setValue(bus_volts);
        load += 0.00015;
    } else {
        OutPuts.getNode("transponder",1).setValue(0.0);
    }

    if (props.globals.getNode("/instrumentation/nav[0]/serviceable").getBoolValue() ){
        OutPuts.getNode("nav",1).setValue(bus_volts);
        load += 0.00015;
    } else {
        OutPuts.getNode("nav",1).setValue(0.0);
    }
   
   if (props.globals.getNode("/instrumentation/nav[1]/serviceable").getBoolValue() ){
        OutPuts.getNode("nav[1]",1).setValue(bus_volts);
        load += 0.000015;
    } else {
        OutPuts.getNode("nav[1]",1).setValue(0.0);
    }   
   
   if (props.globals.getNode("/instrumentation/adf/serviceable").getBoolValue() ){
        OutPuts.getNode("adf",1).setValue(bus_volts);
        load += 0.000015;
    } else {
        OutPuts.getNode("adf",1).setValue(0.0);
    }
   
   if (props.globals.getNode("/instrumentation/turn-indicator/serviceable").getBoolValue() ){
        OutPuts.getNode("turn-coordinator",1).setValue(bus_volts);
        load += 0.000015;
    } else {
        OutPuts.getNode("turn-coordinator",1).setValue(0.0);
    }
    
    if (props.globals.getNode("/instrumentation/tacan/serviceable").getBoolValue() ){
        OutPuts.getNode("tacan",1).setValue(bus_volts);
        load += 0.000015;
    } else {
        OutPuts.getNode("tacan",1).setValue(0.0);
    }
    
    if (props.globals.getNode("/instrumentation/dme/serviceable").getBoolValue() ){
        OutPuts.getNode("dme",1).setValue(bus_volts);
        load += 0.000015;
    } else {
        OutPuts.getNode("dme",1).setValue(0.0);
    }
    

    
    if (props.globals.getNode("/instrumentation/gps/serviceable").getBoolValue() ){
        OutPuts.getNode("gps",1).setValue(bus_volts);
        load += 0.000015;
    } else {
        OutPuts.getNode("gps",1).setValue(0.0);
    }
       
    if (props.globals.getNode("/instrumentation/mk-viii/serviceable").getBoolValue() ){
        OutPuts.getNode("mk-viii",1).setValue(bus_volts);
        load += 0.000015;
    } else {
        OutPuts.getNode("mk-viii",1).setValue(0.0);
    }   

    return load;
}

var update_electrical = func {
    var time = getprop("/sim/time/elapsed-sec");
    var dt = time - last_time;
    var last_time = time;
    update_virtual_bus(dt);
    settimer(update_electrical, 1);
}

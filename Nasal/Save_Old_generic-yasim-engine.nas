# generic-yasim-engine.nas -- a generic Nasal-based engine control system for YASim
# Version 1.0.0
#
# Copyright (C) 2011  Ryan Miller
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#


var UPDATE_PERIOD = 0.05; # update interval for engine init() functions

# jet engine class
var Jet =
{
  # creates a new engine object
  new: func(n, running = 0, idle_throttle = 0.01, max_start_n1 = 5.21, start_threshold = 3, spool_time = 4, start_time = 30, shutdown_time = 4)
  {
    # copy the Jet object
    var m = { parents: [Jet] };
    # declare object variables
    m.number = n;
    m.autostart_status = 0;
    m.autostart_id = -1;
    m.loop_running = 0;
    m.started = 0;
    m.starting = 0;
    m.idle_throttle = idle_throttle;
    m.max_start_n1 = max_start_n1;
    m.start_threshold = start_threshold;
    m.spool_time = spool_time;
    m.start_time = start_time;
    m.shutdown_time = shutdown_time;
    # create references to properties and set default values
    m.cutoff = props.globals.getNode("controls/engines/engine[" ~ n ~ "]/cutoff", 1);
    m.cutoff.setBoolValue(!running);
    m.n1 = props.globals.getNode("engines/engine[" ~ n ~ "]/n1", 1);
    m.n1.setDoubleValue(0);
    m.n2 = props.globals.getNode("engines/engine[" ~ n ~ "]/n2", 1);
    m.out_of_fuel = props.globals.getNode("engines/engine[" ~ n ~ "]/out-of-fuel", 1);
    m.out_of_fuel.setBoolValue(0);
    m.reverser = props.globals.getNode("controls/engines/engine[" ~ n ~ "]/reverser", 1);
    m.reverser.setBoolValue(0);
    m.rpm = props.globals.getNode("engines/engine[" ~ n ~ "]/rpm", 1);
    m.rpm.setDoubleValue(running ? 100 : 0);
    m.running = props.globals.getNode("engines/engine[" ~ n ~ "]/running", 1);
    m.running.setBoolValue(running);
    m.serviceable = props.globals.getNode("engines/engine[" ~ n ~ "]/serviceable", 1);
    m.serviceable.setBoolValue(1);
    #m.starter = props.globals.getNode("controls/engines/engine[" ~ n ~ "]/starter", 1);
    #m.starter.setBoolValue(0);
    m.throttle = props.globals.getNode("controls/engines/engine[" ~ n ~ "]/throttle", 1);
    m.throttle.setDoubleValue(0);
    m.throttle_lever = props.globals.getNode("controls/engines/engine[" ~ n ~ "]/throttle-lever", 1);
    m.throttle_lever.setDoubleValue(0);
    
    #Fuel pressure ! if bp off, don't start, if bpg & bpd off ... on sarting but not runing
    m.bpg = props.globals.getNode("/systems/fuel/suppliers/FUEL1_press",1);
    m.bpd = props.globals.getNode("/systems/fuel/suppliers/FUEL2_press",1);
    m.bp  = props.globals.getNode("/systems/fuel/suppliers/BP_press",1);
    
    # Oil Pressure !! if off, engine not running
    m.oil1 = props.globals.getNode("/systems/hydraulical/suppliers/HYD1_press",1);
    m.oil2 = props.globals.getNode("/systems/hydraulical/suppliers/HYD2_press",1);
    
    # Alt. When Amp 115 : Engine is running
    m.ALT1_Amp = props.globals.getNode("/systems/electrical/suppliers/ALT_1",1);
    m.ALT2_Amp = props.globals.getNode("/systems/electrical/suppliers/ALT_2",1);
    
    # Switches
    #Allumage = for starting Not running
    #Starter/demarrage = for starting Not running
    m.allumage = props.globals.getNode("/controls/switches/vent-allumage",1);
    m.starter = props.globals.getNode("controls/engines/engine[" ~ n ~ "]/starter", 1);
    
    m.starting = false;
    
    
    
    # return our new object
    return m;
  },
  # engine-specific autostart
  autostart: func
  {
    if (me.autostart_status)
    {
      me.autostart_status = 0;
      me.cutoff.setBoolValue(1);
    }
    else
    {
      me.autostart_status = 1;
      me.starter.setBoolValue(1);
      settimer(func
      {
        me.cutoff.setBoolValue(0);
      }, me.max_start_n1 / me.start_time);
    }
  },
  # creates an engine update loop (optional)
  init: func
  {
    if (me.loop_running) return;
    me.loop_running = 1;
    var loop = func
    {
      me.update();
      settimer(loop, UPDATE_PERIOD);
    };
    settimer(loop, 0);
  },
  # updates the engine
  update: func
  {
  
          #TESTED variable, in order to use a set listener
          #me.running.getBoolValue() -> props.globals.getNode("engines/engine[" ~ n ~ "]/running", 1);
          #me.cutoff.getBoolValue() 
          #me.serviceable.getBoolValue()
          #me.out_of_fuel.getBoolValue()
          #me.starter.getBoolValue()
      
          
    #if (me.running.getBoolValue() and !me.started)
    #{
    # me.running.setBoolValue(0);
    #}
    
    #We need time and will set rpm
    var rpm = me.rpm.getValue();
    var time_delta = getprop("sim/time/delta-realtime-sec");
      
    ### What we need to start ###
    #bp        =  true
    #cutoff    =  false
    #allumage  =  true (<-if false mean 'ventilation' to blow out fuel of the jet, without burning it (shut off process))
    #starter   =  true
    #starter launch the fan
    
    if(!me.cutoff.getBoolValue() and me.bp.getBoolValue() and me.allumage.getBoolValue() {
        #Detect the start button
        if(me.starter.getgetBoolValue()){
            me.starting = true;
        }
        #if start button have been pressed, then start fan
        if(me.starting){
            me.rpm.setValue(4700);
            me.n1.setValue(4700)
        }
    
    
    
    }
    
    
    
    
    
    
    ####################################   Starting or Shutting down process #####################
    if (me.cutoff.getBoolValue() or !me.serviceable.getBoolValue() or me.out_of_fuel.getBoolValue())
    {
      var rpm = me.rpm.getValue();
      var time_delta = getprop("sim/time/delta-realtime-sec");
      
      #################    Start Process   #############
      if (me.starter.getBoolValue())
      {
        rpm += time_delta * me.spool_time *100;
        me.rpm.setValue(rpm >= me.max_start_n1 *100  ? me.max_start_n1 *100 : rpm);
      }
      
       #################   Shut Down process ###########
      else
      {
        rpm -= time_delta * me.shutdown_time * 100;
        me.rpm.setValue(rpm <= 0 ? 0 : rpm);
        me.running.setBoolValue(0);
        me.throttle.setDoubleValue(0);
        me.throttle_lever.setDoubleValue(0);
        me.started = 0;
      }
      UPDATE_PERIOD = 0.05;
    }




    ##########################################################################################
    
    
    #################      Another Starting Process ? ###########################
    elsif (me.starter.getBoolValue())
    {
      var rpm = me.rpm.getValue();
      if (rpm >= me.start_threshold)
      {
        var time_delta = getprop("sim/time/delta-realtime-sec");
        rpm += time_delta * me.spool_time*100;
        me.rpm.setValue(rpm);
        if (rpm >= me.n1.getValue())
        {
          me.running.setBoolValue(1);
          me.starter.setBoolValue(0);
          me.started = 1;
        }
        else
        {
          me.running.setBoolValue(0);
        }
      }
    }
    elsif (me.running.getBoolValue())
    {
      ###############  Normal runing process ###################################
      UPDATE_PERIOD = 0.2;
      me.throttle_lever.setValue(me.idle_throttle + (1 - me.idle_throttle) * me.throttle.getValue());
      me.rpm.setValue(me.n1.getValue()*100);
      
      
      #print("Pouet");
      #var beta_n2 = (9.8-1)*(me.n2.getValue()-73)/(110-73);
      #var beta_n1 = (9.8-1)*(me.n1.getValue()-47)/(105-47);
      #var beta = 0.8*beta_n2+0.2*beta_n1;
      #var beta0 = 1/(9.8-1);
      #var tempsExtKelv = getprop("/environment/temperature-degc") + 273.15;
      #var EGT = tempsExtKelv + beta *beta0*(1123 -tempsExtKelv);#Kelvin 273,15
      #print(EGT-273.15);
    }
  }
};

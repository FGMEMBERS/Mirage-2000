var blinking = 0;


var initIns = func {
        convertTemp();
        average_fuel();

        settimer(initIns, 0.5);
}


var convertTemp = func{	    
	        var degF = getprop("engines/engine[0]/egt-degf");
	        if(degF != nil){
	                #print(degF);
	                var degC = (degF - 32) * 5/9;
	                #print(degC);
	                setprop("engines/engine[0]/egt-degC", degC);
	        }
	        #settimer(convertTemp, 0.2);
}

var average_fuel = func {
        #in kg...
        var consumption = getprop("engines/engine[0]/fuel-flow-gph");
        
        #1 litter of fuel = 0.87 kg and 1 gallon = 3.7854118
        
        
        var time = getprop("sim/time/elapsed-sec");
        
        #print("MY MODULO IS :" ~ math.mod(60, time) ~ " TIME IS " ~ time);
        #print ("MY TIME " ~ (int(int(time) / 60) == int(time) / 60) ~ " TIME IS " ~ time);
        
        
        #refreshing time in sec
        if(int(int(time) / 1) == int(time) / 1 ){
            if (consumption != nil){
        
                #in kg fuel per hour
                consumption = consumption * 3.7854118 *0.87;
                
                #Per min
                consumption = consumption / 60;
                
                #Old name, need to be changed
                setprop("instrumentation/consumables/average_consuption_per_min",consumption);
                
                #Average Consumption 36 kg/min
                bingo(50);
                
            }
        }
        

        var remain_fuel = getprop("/consumables/fuel/total-fuel-kg");
        
        #print(remain_fuel);
        
        if(remain_fuel != nil){
                remain_fuel = remain_fuel - 100;
                if(remain_fuel<0) { remain_fuel = 0;}
                setprop("/instrumentation/consumables/remain_fuel",remain_fuel);
        }


}

var bingo = func(moy){

#var lastWPtime = getprop("/autopilot/route-manager/ete");
var lastWPtime = getprop("instrumentation/gps/wp/wp[1]/TTW-sec");

print("/autopilot/route-manager/ete : " ~ getprop("/autopilot/route-manager/ete") ~ " instrumentation/gps/wp/wp[1]/TTW-sec : " ~ getprop("instrumentation/gps/wp/wp[1]/TTW-sec"));
        
        
        #Consommations moyennes: 4kg / Nm en HA. 7kg / Nm en BA (LA) or Average Consumption 36 kg/min
        #Fisrt -> Calculation of the last airport (route manager)
        var remaining = getprop("/autopilot/route-manager/distance-remaining-nm");
        
        #That means at Low Alt : 
        
        var bingo = remaining * 7;
        
        #Adde 45 min to the process
        
        bingo = bingo + 36 * 45;
        
        
        setprop("/instrumentation/consumables/bingo_fuel",bingo);    
        if(blinking ==0){ clignote(); }
        
        
        #This is a simplified calculation of bingo fuel : We have to add a an alternate airport in the calculation, but here it seeems to be a bit complicated
        #Bingo : 
        #Today Federal Aviation Regulations determine the amount of fuel an aircraft must carry. Using Instrument Flight Rules (IFR), an aircraft must carry enough fuel to:
        #  *Complete the flight to the landing destination.
        #  *Fly from that airport to an alternate airport.
        #  *Fly after that for 45 minutes at normal cruising speed for that aircraft.

        
        #if(lastWPtime != nil and lastWPtime != "NaN"){       
        #        lastWPtime = lastWPtime/60;
        #        var bingo = moy * (lastWPtime + 45);
        #        setprop("/instrumentation/consumables/bingo_fuel",bingo);    
        #        if(blinking ==0){ clignote(); }

        #}



}

#This is for blinking light
var clignote = func(){

        if(getprop("/consumables/fuel/total-fuel-kg")<getprop("/instrumentation/consumables/bingo_fuel")){
        
                 if(getprop("/instrumentation/consumables/bingo_low") == 1)
                 {
                        setprop("/instrumentation/consumables/bingo_low",0); 
                 }else{
                        setprop("/instrumentation/consumables/bingo_low",1); 
                 }
                blinking = 1;
                settimer(clignote, 0.25);
        }else{
                setprop("/instrumentation/consumables/bingo_low",0); 
                blinking = 0;
        }


}

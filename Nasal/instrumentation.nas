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
        var average = getprop("engines/engine[0]/fuel-consumed-lbs");
        
        var time = getprop("sim/time/elapsed-sec");
        
        #Conversion to min and to kg
        if(time = int(time)){
                if(average != nil){
                        average = (average * 60) * 0.45359237;
                        var my_average = (getprop("instrumentation/consumables/average_consuption_per_min")*(time-1)+average)/time;                
                        setprop("instrumentation/consumables/average_consuption_per_min",my_average);
                        bingo(my_average);
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

var lastWPtime = getprop("instrumentation/gps/wp/wp[1]/TTW-sec");

        
        #This is a simplified calculation of bingo fuel : We have to add a an alternate airport in the calculation, but here it seeems to be a bit complicated
        #Bingo : 
        #Today Federal Aviation Regulations determine the amount of fuel an aircraft must carry. Using Instrument Flight Rules (IFR), an aircraft must carry enough fuel to:
        #  *Complete the flight to the landing destination.
        #  *Fly from that airport to an alternate airport.
        #  *Fly after that for 45 minutes at normal cruising speed for that aircraft.

        
        if(lastWPtime != nil and lastWPtime != "NaN"){       
                lastWPtime = lastWPtime/60;
                var bingo = moy * (lastWPtime + 45);
                setprop("/instrumentation/consumables/bingo_fuel",bingo);    
                if(blinking ==0){ clignote(); }

        }



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

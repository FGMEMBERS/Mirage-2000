


var convertTemp = func{	    
	        var degF = getprop("engines/engine[0]/egt-degf");
	        if(degF != nil){
	                #print(degF);
	                var degC = (degF - 32) * 5/9;
	                #print(degC);
	                setprop("engines/engine[0]/egt-degC", degC);
	        }
	        settimer(convertTemp, 0.2);
}
 



#On verifie et on largue
var dropTanks = func(){
        for(var i = 2 ;i < 5 ; i = i + 1 ){
           var select = getprop("sim/weight["~ i ~"]/selected");
           if(select == "1300 l Droptank" or select == "1700 l Droptank"){ load.dropLoad(i);}

        }
}


#Begining of the dropable function.
#It has to be simplified and generic made
#Need to know how to make a table
dropLoad = func (number) {
          var select = getprop("sim/weight["~ number ~"]/selected");
          if(select != "none"){
                if(select == "1300 l Droptank" or select == "1700 l Droptank"){
                     tank_submodel(number,select);
                     setprop("consumables/fuel/tank["~ number ~"]/selected", 0);
                     settimer(func load.dropLoad_stop(number),2);
                }else{
                     load.dropMissile(number);
                     settimer(func load.dropLoad_stop(number),0.5);
                }
                setprop("controls/armament/station["~ number ~"]/release", 1);
                setprop("sim/weight["~ number ~"]/selected", "none");
                setprop("sim/weight["~ number ~"]/weight-lb", 0);


           }

           
}


#Need to be changed
dropLoad_stop = func(n) {     
         setprop("controls/armament/station["~ n ~"]/release", 0);
}





dropMissile = func (number) { 

  var typeMissile = getprop("sim/weight["~ number ~"]/selected");

#print(typeMissile);
  missile.Loading_missile(typeMissile);

  Current_missile = missile.MISSILE.new(number);
  Current_missile.status = 0;
  var target  = rwr.closest_target();        
  Current_missile.search(target);             
  Current_missile.release();      

}

var tank_submodel = func (pylone, select){

        #1300 Tanks
        if(pylone == 2 and select == "1300 l Droptank"){ setprop("controls/armament/station[2]/release-L1300", 1);}
        if(pylone == 3 and select == "1300 l Droptank"){ setprop("controls/armament/station[3]/release-C1300", 1);}
        if(pylone == 4 and select == "1300 l Droptank"){ setprop("controls/armament/station[4]/release-R1300", 1);}

        #1700 Tanks
        if(pylone == 2 and select == "1700 l Droptank"){ setprop("controls/armament/station[2]/release-L1700", 1);}
        if(pylone == 4 and select == "1700 l Droptank"){ setprop("controls/armament/station[4]/release-R1700", 1);}


}





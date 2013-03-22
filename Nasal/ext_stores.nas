

#On verifie et on largue
var dropTanks = func(){
        for(var i = 2 ;i < 5 ; i = i + 1 ){
           var select = getprop("sim/weight["~ i ~"]/selected");
           if(select == "1300 l Droptank" or select == "1700 l Droptank"){ load.dropLoad(i);}

        }
}

#Here is where quick load management is managed...
#These 4 function can't be active whn flying : This mean a little preparation for the mission
#It's an anti kiddo script
var AirToAirMiddle = func(){
    if(getprop("/gear/gear[2]/wow")==1){
        setprop("consumables/fuel/tank[2]/selected", 0);
        setprop("consumables/fuel/tank[2]/capacity-gal_us", 0);
        setprop("consumables/fuel/tank[2]/level-gal_us", 0);
        setprop("consumables/fuel/tank[3]/selected", 0);
        setprop("consumables/fuel/tank[3]/capacity-gal_us", 0);
        setprop("consumables/fuel/tank[3]/level-gal_us", 0);
        setprop("consumables/fuel/tank[4]/selected", 0);
        setprop("consumables/fuel/tank[4]/capacity-gal_us", 0);
        setprop("consumables/fuel/tank[4]/level-gal_us", 0);



        setprop("sim/weight[0]/selected", "Matra MICA");
        setprop("sim/weight[1]/selected", "Matra MICA");
        setprop("sim/weight[2]/selected", "Matra MICA");
        setprop("sim/weight[3]/selected", "1300 l Droptank");
        setprop("consumables/fuel/tank[3]/selected", 1);
        setprop("consumables/fuel/tank[3]/capacity-gal_us", 343);
        setprop("consumables/fuel/tank[3]/level-gal_us", 342);
        
        setprop("sim/weight[4]/selected", "Matra MICA");
        setprop("sim/weight[5]/selected", "Matra MICA");
        setprop("sim/weight[6]/selected", "Matra MICA");
        setprop("sim/weight[7]/selected", "Matra MICA");
        setprop("sim/weight[8]/selected", "Matra MICA");
     }

}

var AirToAirshort = func(){
    if(getprop("/gear/gear[2]/wow")==1){
        setprop("consumables/fuel/tank[2]/selected", 0);
        setprop("consumables/fuel/tank[2]/capacity-gal_us", 0);
        setprop("consumables/fuel/tank[2]/level-gal_us", 0);
        setprop("consumables/fuel/tank[3]/selected", 0);
        setprop("consumables/fuel/tank[3]/capacity-gal_us", 0);
        setprop("consumables/fuel/tank[3]/level-gal_us", 0);
        setprop("consumables/fuel/tank[4]/selected", 0);
        setprop("consumables/fuel/tank[4]/capacity-gal_us", 0);
        setprop("consumables/fuel/tank[4]/level-gal_us", 0);



        setprop("sim/weight[0]/selected", "Matra MICA");
        setprop("sim/weight[1]/selected", "Matra R550 Magic 2");
        setprop("sim/weight[2]/selected", "Matra MICA");
        setprop("sim/weight[3]/selected", "1300 l Droptank");
        setprop("consumables/fuel/tank[3]/selected", 1);
        setprop("consumables/fuel/tank[3]/capacity-gal_us", 343);
        setprop("consumables/fuel/tank[3]/level-gal_us", 342);
        
        setprop("sim/weight[4]/selected", "Matra MICA");
        setprop("sim/weight[5]/selected", "Matra R550 Magic 2");
        setprop("sim/weight[6]/selected", "Matra MICA");
        setprop("sim/weight[7]/selected", "Matra MICA");
        setprop("sim/weight[8]/selected", "Matra MICA");
    }
}

var AirToAirLong = func() {
    if(getprop("/gear/gear[2]/wow")==1){
        setprop("consumables/fuel/tank[2]/selected", 0);
        setprop("consumables/fuel/tank[2]/capacity-gal_us", 0);
        setprop("consumables/fuel/tank[2]/level-gal_us", 0);
        setprop("consumables/fuel/tank[3]/selected", 0);
        setprop("consumables/fuel/tank[3]/capacity-gal_us", 0);
        setprop("consumables/fuel/tank[3]/level-gal_us", 0);
        setprop("consumables/fuel/tank[4]/selected", 0);
        setprop("consumables/fuel/tank[4]/capacity-gal_us", 0);
        setprop("consumables/fuel/tank[4]/level-gal_us", 0);

        setprop("sim/weight[0]/selected", "Matra MICA");
        setprop("sim/weight[1]/selected", "Matra MICA");
        
        setprop("sim/weight[2]/selected", "1700 l Droptank");
        setprop("consumables/fuel/tank[2]/selected", 1);
        setprop("consumables/fuel/tank[2]/capacity-gal_us", 448.50);
        setprop("consumables/fuel/tank[2]/level-gal_us", 447);        
                
        setprop("sim/weight[3]/selected", "1300 l Droptank");
        setprop("consumables/fuel/tank[3]/selected", 1);
        setprop("consumables/fuel/tank[3]/capacity-gal_us", 343);
        setprop("consumables/fuel/tank[3]/level-gal_us", 342);

        setprop("sim/weight[4]/selected", "1700 l Droptank");
        setprop("consumables/fuel/tank[4]/selected", 1);
        setprop("consumables/fuel/tank[4]/capacity-gal_us", 448.50);
        setprop("consumables/fuel/tank[4]/level-gal_us", 447);  
                
                
        setprop("sim/weight[5]/selected", "Matra MICA");
        setprop("sim/weight[6]/selected", "Matra MICA");
        setprop("sim/weight[7]/selected", "Matra MICA");
        setprop("sim/weight[8]/selected", "Matra MICA");
    }


}

var NoLoad = func() {
    if(getprop("/gear/gear[2]/wow")==1){
        setprop("consumables/fuel/tank[2]/selected", 0);
        setprop("consumables/fuel/tank[2]/capacity-gal_us", 0);
        setprop("consumables/fuel/tank[2]/level-gal_us", 0);
        setprop("consumables/fuel/tank[3]/selected", 0);
        setprop("consumables/fuel/tank[3]/capacity-gal_us", 0);
        setprop("consumables/fuel/tank[3]/level-gal_us", 0);
        setprop("consumables/fuel/tank[4]/selected", 0);
        setprop("consumables/fuel/tank[4]/capacity-gal_us", 0);
        setprop("consumables/fuel/tank[4]/level-gal_us", 0);

        setprop("sim/weight[0]/selected", "none");
        setprop("sim/weight[1]/selected", "none");
        setprop("sim/weight[2]/selected", "none");
        setprop("sim/weight[3]/selected", "none");
        setprop("sim/weight[4]/selected", "none");                         
        setprop("sim/weight[5]/selected", "none");
        setprop("sim/weight[6]/selected", "none");        
        setprop("sim/weight[7]/selected", "none");
        setprop("sim/weight[8]/selected", "none");
     }


}

var AirToGround = func() {
    if(getprop("/gear/gear[2]/wow")==1){
        setprop("consumables/fuel/tank[2]/selected", 0);
        setprop("consumables/fuel/tank[2]/capacity-gal_us", 0);
        setprop("consumables/fuel/tank[2]/level-gal_us", 0);
        setprop("consumables/fuel/tank[3]/selected", 0);
        setprop("consumables/fuel/tank[3]/capacity-gal_us", 0);
        setprop("consumables/fuel/tank[3]/level-gal_us", 0);
        setprop("consumables/fuel/tank[4]/selected", 0);
        setprop("consumables/fuel/tank[4]/capacity-gal_us", 0);
        setprop("consumables/fuel/tank[4]/level-gal_us", 0);

        setprop("sim/weight[0]/selected", "GBU16");
        setprop("sim/weight[1]/selected", "Matra MICA");
        
        setprop("sim/weight[2]/selected", "1700 l Droptank");
        setprop("consumables/fuel/tank[2]/selected", 1);
        setprop("consumables/fuel/tank[2]/capacity-gal_us", 448.50);
        setprop("consumables/fuel/tank[2]/level-gal_us", 447);        
                
        setprop("sim/weight[3]/selected", "SCALP");


        setprop("sim/weight[4]/selected", "1700 l Droptank");
        setprop("consumables/fuel/tank[4]/selected", 1);
        setprop("consumables/fuel/tank[4]/capacity-gal_us", 448.50);
        setprop("consumables/fuel/tank[4]/level-gal_us", 447);  
                
                
        setprop("sim/weight[5]/selected", "Matra MICA");
        setprop("sim/weight[6]/selected", "GBU16");
        setprop("sim/weight[7]/selected", "GBU16");
        setprop("sim/weight[8]/selected", "GBU16");
    }        

}




#La boite de dialogue
var ext_loads_dlg = gui.Dialog.new("dialog","Aircraft/Mirage-2000/Dialogs/external-loads.xml");

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
                     setprop("controls/armament/station["~ number ~"]/release", 1);
                     #setprop("sim/weight["~ number ~"]/selected", "none");
                     setprop("sim/weight["~ number ~"]/weight-lb", 0);
                }else{
                     load.dropMissile(number);
                     settimer(func load.dropLoad_stop(number),0.5);
                }


           }

           
}


#Need to be changed
dropLoad_stop = func(n) {     
         #setprop("controls/armament/station["~ n ~"]/release", 0);
}





dropMissile = func (number) { 

  var target  = hud.closest_target();
  if(target == nil){ return;}

  
        #print(typeMissile);


          var typeMissile = getprop("sim/weight["~ number ~"]/selected");
          missile.Loading_missile(typeMissile);
          Current_missile = missile.MISSILE.new(number);
          Current_missile.status = 0;
          Current_missile.search(target);             
          Current_missile.release();
          setprop("controls/armament/station["~ number ~"]/release", 1);
          #print(getprop("controls/armament/station["~ number ~"]/release"));
          #setprop("sim/weight["~ number ~"]/selected", "none");
          setprop("sim/weight["~ number ~"]/weight-lb", 0);
     

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







#On verifie et on largue
var dropTanks = func(){
        for(var i = 2 ;i < 5 ; i = i + 1 ){
           var select = getprop("sim/weight["~ i ~"]/selected");
           if(select == "1300 l Droptank" or select == "1700 l Droptank"){ m2000_load.dropLoad(i);}

        }
}


##### This function compile all load in a multiplay variable
var Encode_Load = func(){

        var list = ["none","1300 l Droptank","1700 l Droptank","AGM65","AIM-54","aim-9","AIM120","GBU12","GBU16","Matra MICA","MATRA-R530","Matra R550 Magic 2","Meteor","R74","R77","SCALP","Sea Eagle"];

        var compiled = "";
        for(var i = 0 ;i < 9 ; i = i + 1 ){
           #Load name
           var select = getprop("sim/weight["~ i ~"]/selected");
           
           #fireable or not : may displays the pylons if there a weight but fire = 0
           var released = getprop("controls/armament/station["~ i ~"]/release");
           
           #Selection of the index load for each pylon
           #We get the children of the tree sim weight[actual]
           for(var y = 0; y < size(list);y = y+1){
              if(list[y] == select){
                  var select_Index = y;
                  #print(select);
              }
           } 
           #Now we select the index
           compiled = compiled ~"#"~ i ~ released ~ select_Index;    
        }
        
        #We put it in a multiplay string
        setprop("sim/multiplay/generic/string[1]",compiled);
        #print(compiled);
        #print(substr(compiled,5,13));
        #Decode_Load(compiled);
}

#var Decode_Load = func(myString){
#var Decode_Load = func(mySelf, myString, updateTime){


####
#   To use Decode_Load, we have to provide a string (from multiplay) and the "Self"  : var self = cmdarg();
#   This function has to be called when using the <load> balise It's only load in Multiplay
#
#   myself : tree of the current MP aircraft
#   myString : string node
#   updateTime
#
#
####
#substr (StringToSplit, begining number, length)
#size of the string
#can play string like an array (like in C) myString[i]

############################################################################################################################
################################################Object decode###########################################################
############################################################################################################################
var Decode_Load = {
  new: func(mySelf, myString, updateTime){
    var m = { parents: [Decode_Load] };
    m.mySelf = mySelf;
    m.myString = myString;
    m.updateTime = updateTime;
    m.running = 1;
    m.loadList = ["none","1300 l Droptank","1700 l Droptank","AGM65","AIM-54","aim-9","AIM120","GBU12","GBU16","Matra MICA","MATRA-R530","Matra R550 Magic 2","Meteor","R74","R77","SCALP","Sea Eagle"];
    return m;
  },
  decode: func{
    #print("Upload On going");
    var myString = me.myString.getValue();
    var myIndexArray = [];
    
    
    
    if(myString != nil){
        #print("the string :"~ myString);
        #print("test" ~ me.loadList[3]);

        #Here to detect each substring index
        for(i = 0; i<size(myString); i = i+1){
          #print(chr(myString[i]));
          if(chr(myString[i]) == '#'){
            #print("We got one : " ~ i );
            append(myIndexArray,i);
          }
          #print(size(myIndexArray));
        }
      
      #Now we can splitt the substring
        for(i=0;i<size(myIndexArray);i=i+1){
          if(i<size(myIndexArray) -1){
            #print(substr(myString,myIndexArray[i],myIndexArray[i+1]-myIndexArray[i]));
            
            #Index of weight :
            var myWeightIndex = substr(myString,myIndexArray[i]+1,1);
            #print("myWeightIndex:"~ myWeightIndex);
            
            #Has been fired (display pylons or not)
            var myFired = substr(myString,myIndexArray[i]+2,1)==1;
            #print(myFired);
            
            #what to put in weight[]/selected index
            var myWeightOptIndex = substr(myString,myIndexArray[i]+3,(myIndexArray[i+1]-1)-(myIndexArray[i]+2));
            var myWeight = me.loadList[myWeightOptIndex];
            #var myWeight = getprop("sim/weight["~ myWeightIndex ~"]/opt[" ~ myWeightOptIndex ~ "]/name");
            #print("myWeight: " ~ myWeight);
            
            # Rebuilt the property Tree
            me.mySelf.getNode("sim/weight["~ myWeightIndex ~"]/selected", 1).setValue(myWeight);
            me.mySelf.getNode("controls/armament/station["~ myWeightIndex ~"]/release", 1).setValue(myFired);
            
          }else{
            #print(substr(myString,myIndexArray[i],size(myString)-myIndexArray[i]));
            
            #Index of weight :
            var myWeightIndex = substr(myString,myIndexArray[i]+1,1);
            #print(myWeightIndex);
            
            #Has been fired (display pylons or not)
            var myFired = substr(myString,myIndexArray[i]+2,1)==1;
            #print(myFired);
            
            #what to put in weight[]/selected
            var myWeightOptIndex = substr(myString,myIndexArray[i]+3,size(myString)-(myIndexArray[i]+2));
            var myWeight = me.loadList[myWeightOptIndex];
            #var myWeight = getprop("sim/weight["~ myWeightIndex ~"]/opt[" ~ myWeightOptIndex ~ "]/name");
            #print(myWeight);
            
            # Rebuilt the property Tree
            me.mySelf.getNode("sim/weight["~ myWeightIndex ~"]/selected", 1).setValue(myWeight);
            me.mySelf.getNode("controls/armament/station["~ myWeightIndex ~"]/release", 1).setValue(myFired);
            
            
            if(me.running == 1){settimer(func me.decode(), me.updateTime);}
          }
        }
      }
      #print(me.mySelf.getName() ~ "["~ me.mySelf.getIndex() ~"]");
    },
    stop: func{
      me.running = 0;
    },
};

############################################################################################################################
############################################################################################################################






#Here is where quick load management is managed...
#These 4 function can't be active when flying : This mean a little preparation for the mission
#It's an anti kiddo script

var Po = func(){
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


        setprop("sim/weight[1]/selected", "Matra R550 Magic 2");
        
        setprop("sim/weight[3]/selected", "1300 l Droptank");
        setprop("consumables/fuel/tank[3]/selected", 1);
        setprop("consumables/fuel/tank[3]/capacity-gal_us", 343);
        setprop("consumables/fuel/tank[3]/level-gal_us", 342);
        
        setprop("sim/weight[5]/selected", "Matra R550 Magic 2");
        
        setprop("sim/weight[0]/selected", "none");
        setprop("sim/weight[6]/selected", "none");        
        setprop("sim/weight[7]/selected", "none");
        setprop("sim/weight[8]/selected", "none");
        
        
        FireableAgain();
     }

}



var Fox = func(){
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
        #setprop("sim/weight[2]/selected", "Matra MICA");
        setprop("sim/weight[3]/selected", "1300 l Droptank");
        setprop("consumables/fuel/tank[3]/selected", 1);
        setprop("consumables/fuel/tank[3]/capacity-gal_us", 343);
        setprop("consumables/fuel/tank[3]/level-gal_us", 342);
        
        #setprop("sim/weight[4]/selected", "Matra MICA");
        setprop("sim/weight[5]/selected", "Matra R550 Magic 2");
        setprop("sim/weight[6]/selected", "Matra MICA");
        setprop("sim/weight[7]/selected", "Matra MICA");
        setprop("sim/weight[8]/selected", "Matra MICA");
        FireableAgain();
     }

}

var Bravo = func(){
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
        
        setprop("sim/weight[2]/selected", "1700 l Droptank");
        setprop("consumables/fuel/tank[2]/selected", 1);
        setprop("consumables/fuel/tank[2]/capacity-gal_us", 448.50);
        setprop("consumables/fuel/tank[2]/level-gal_us", 447); 
        
        
        setprop("sim/weight[4]/selected", "1700 l Droptank");
        setprop("consumables/fuel/tank[4]/selected", 1);
        setprop("consumables/fuel/tank[4]/capacity-gal_us", 448.50);
        setprop("consumables/fuel/tank[4]/level-gal_us", 447); 
        
        setprop("sim/weight[5]/selected", "Matra R550 Magic 2");
        setprop("sim/weight[6]/selected", "Matra MICA");
        setprop("sim/weight[7]/selected", "Matra MICA");
        setprop("sim/weight[8]/selected", "Matra MICA");
        FireableAgain();
    }
}

var Kilo = func() {
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
        FireableAgain();
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
        FireableAgain();
        
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
        FireableAgain();
    }        

}

var FireableAgain = func() {
       for(var i = 0 ;i < 9 ; i = i + 1 ){
          #to make it fireable again
          setprop("controls/armament/station["~ i ~"]/release", 0);
          
          #To add weight to pylons
          var select = getprop("sim/weight["~ i ~"]/selected");
          
          if(select=="Matra MICA"){
                setprop("sim/weight["~ i ~"]/weight-lb",246.91)          
          }
          if(select=="Matra R550 Magic 2"){
                setprop("sim/weight["~ i ~"]/weight-lb",196.21)          
          }
          if(select=="GBU16"){
                setprop("sim/weight["~ i ~"]/weight-lb",1000)          
          }
          if(select=="SCALP"){
                setprop("sim/weight["~ i ~"]/weight-lb",2866)          
          }
          if(select=="1700 l Droptank"){
                setprop("sim/weight["~ i ~"]/weight-lb",280)          
          }
          if(select=="1300 l Droptank"){
                setprop("sim/weight["~ i ~"]/weight-lb",220)          
          }
       }
       setprop("controls/armament/name",getprop("sim/weight[0]/selected"));
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
                     setprop("controls/armament/station["~ number ~"]/release", 1);
                     setprop("sim/weight["~ number ~"]/weight-lb", 0);
                }else{
                     if(getprop("controls/armament/station["~ number ~"]/release")==0){;
                        m2000_load.dropMissile(number);
                     }
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
          after_fire_next();

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

var inscreased_selected_pylon = func(){
     var SelectedPylon = getprop("controls/armament/missile/current-pylon");
     
     var out = 0;
     var mini = loadsmini();
     var max = loadsmaxi();
     if(SelectedPylon==max){SelectedPylon=-1;}
     
     for(var i = SelectedPylon+1 ;i < 9 ; i = i + 1 ){
            if(getprop("sim/weight["~ i ~"]/selected")){
                if(getprop("sim/weight["~ i ~"]/weight-lb")>1){
                   if(mini==-1){mini = i;}
                   max = i;
                   if(out == 0){
                        #print(i);
                        SelectedPylon = i;
                        out = 1;
                   }
                }            
            }
      }
      if(SelectedPylon == getprop("controls/armament/missile/current-pylon")){SelectedPylon = mini;}
      setprop("controls/armament/name",getprop("sim/weight["~ SelectedPylon ~"]/selected"));
      setprop("controls/armament/missile/current-pylon",SelectedPylon);
}

var decreased_selected_pylon = func(){

}

#smallest index of load
var loadsmini = func(){
        var out = 0;        
        for(var i = 0 ;i < 9 ; i = i + 1 ){
                if(getprop("sim/weight["~ i ~"]/weight-lb")>1){
                   if(out == 0){
                        #print("i:",i);
                        var mini = i;
                        out = 1;
                   }
                   var maxi = i;
                }
         }
         return mini;
}

#Biggt index of load
var loadsmaxi = func(){
        var out = 0;
        for(var i = 0 ;i < 9 ; i = i + 1 ){
                if(getprop("sim/weight["~ i ~"]/weight-lb")>1){
                   if(out == 0){
                        #print("i:",i);
                        var mini = i;
                        out = 1;
                   }
                   var maxi = i;
                }
         }
         return maxi;
}
        

#next missile after fire
var after_fire_next = func(){
       var SelectedPylon = getprop("controls/armament/missile/current-pylon");
       if(SelectedPylon == "nil"){SelectedPylon = 0;}
       var out = 0;
    
        if(SelectedPylon == 4){SelectedPylon =2;}elsif(SelectedPylon == 2){SelectedPylon =4;}
        if(SelectedPylon == 5){SelectedPylon =1;}elsif(SelectedPylon == 1){SelectedPylon =5;}
        if(SelectedPylon == 6){SelectedPylon =0;}elsif(SelectedPylon == 0){SelectedPylon =6;}
        if(SelectedPylon == 8){SelectedPylon =7;}elsif(SelectedPylon == 7){SelectedPylon =8;}
        
        
        if(getprop("sim/weight["~ SelectedPylon ~"]/weight-lb")<1){
            for(var i = 0 ;i < 9 ; i = i + 1 ){
                if(getprop("sim/weight["~ i ~"]/weight-lb")>1){
                   if(out == 0){
                        #print("i:",i);
                        SelectedPylon = i;
                        out = 1;
                   }
                }
            }
            setprop("controls/armament/name",getprop("sim/weight["~ SelectedPylon ~"]/selected"));
            setprop("controls/armament/missile/current-pylon",SelectedPylon);
            
        }else{
            setprop("controls/armament/name",getprop("sim/weight["~ SelectedPylon ~"]/selected"));
            setprop("controls/armament/missile/current-pylon",SelectedPylon);
            #print("Test1:",SelectedPylon);
        }
}
   
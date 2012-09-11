var load_adress = func(s) {
  var type = self.getNode("sim/weight[6]/selected",1);
  if( type == "aim9" ){return "Aircraft/Mirage-2000/Models/External-objects/aim-9/aim-9-0.xml";}
  elsif( type == "Matra R550 Magic 2" ) {return "Aircraft/Mirage-2000/Models/External-objects/MatraR550Magic2/MatraR550Magic2.xml";}
  elsif( type == "AIM120" ) {return "Aircraft/Mirage-2000/Models/External-objects/AIM-120/AIM-120.xml";}
  else{return "Aircraft/Mirage-2000/Models/External-objects/aim-9/aim-9-0.xml";}
}

#On verifie et on largue
var dropTanks = func(){
          load.dropLoad(2);
          load.dropLoad(3);
          load.dropLoad(4);
}


#Begining of the dropable function.
#It has to be simplified and generic made
#Need to know how to make a table
dropLoad = func (number) {
          var select = getprop("sim/weight["~ number ~"]/selected");
	  if(select == "none"){}else{
           var index_ofload = type_load(number,select);   
           setprop("controls/armament/station["~ number ~"]/type["~ index_ofload ~"]/release", 1);
           setprop("sim/weight["~ number ~"]/selected", "none");
           setprop("sim/weight["~ number ~"]/weight-lb", 0);
           if(select == "1300 l Droptank" or select == "1700 l Droptank"){
                setprop("consumables/fuel/tank["~ number ~"]/selected", 0);
           }
          }


}
#Need to be changed
dropLoad_stop = func() {
          
          #setprop("controls/armament/station[3]/type[0]/release", "false");


}

#For the moment, a fucntion is used. But the ideal, with a generic code is to use a table.
var type_load = func (station,selected) {



   if(station == 3) {
     if(selected == "1300 l Droptank"){
       return 0;
     }elsif (selected == "GBU16"){
       return 1;
     }
   }
   elsif(station == 2) {
     if(selected == "1300 l Droptank"){
       return 1;
     }elsif (selected == "1700 l Droptank"){
       return 0;
     }elsif (selected == "Matra R550 Magic 2"){
       return 2;
     }
   }
   elsif(station == 4) {
    if(selected == "1300 l Droptank"){
       return 1;
     }elsif (selected == "1700 l Droptank"){
       return 0;
     }elsif (selected == "Matra R550 Magic 2"){
       return 2;
     }
   }
}

var Weapon_Selection = func (number) {
   if(number == 0){return getprop("sim/weight[0]/selected");}
   elsif(number == 1){return getprop("sim/weight[1]/selected");}
   elsif(number == 2){return getprop("sim/weight[2]/selected");}
   elsif(number == 3){return getprop("sim/weight[3]/selected");}
   elsif(number == 4){return getprop("sim/weight[4]/selected");}
   elsif(number == 5){return getprop("sim/weight[5]/selected");}
	
}
# Load engine class
var Load =
{
	# creates a new Load object
	new: func(n, ,p,q,r)
	{

#What we need :
#Name, Index (form load_list), Index (of pylone), 3D model adress, Offsets x,y,z
#Update the multiplayer string variable (to update MP loads), kind of load (missile, bomb, tank, drone, detector, or even Radar
#


		# copy the Load object
		var m = { parents: [Load] };
		# declare object variables

		# create references to properties and set default values

	
		# return our new object
		return m;
	},
	# get3Dmodel
	get3Dmodel: func
	{

	},
	# init the load
	init: func
	{

	},
	# other
	other: func
	{

	}
};


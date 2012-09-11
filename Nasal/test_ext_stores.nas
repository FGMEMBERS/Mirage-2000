test = func {
#Dynamic XML code test
    var location = "Aircraft/Mirage-2000/Models/External-objects/";
    var filename="Test_load.xml";

    setprop(location~"model[0]/name", "load");
    setprop(location~"model[0]/path", "Aircraft/Mirage-2000/Models/External-objects/AIM-120/AIM-120.xml");
    setprop(location~"model[0]/offsets/x-m", "-1.265");
    setprop(location~"model[0]/offsets/y-m", "-0.824");
    setprop(location~"model[0]/offsets/z-m", "-1.404");


    setprop(location~"animation[0]/type", "select");
    setprop(location~"animation[0]/object-name", "load");
    setprop(location~"animation[0]/condition/and/equals[0]/property", "sim/weight[0]/selected");
    setprop(location~"animation[0]/condition/and/equals[0]/value", "AIM120");
    setprop(location~"animation[0]/condition/and/equals[1]/property", "controls/armament/station[0]/release");


    io.write_properties(filename, location);
}

String[] gcode_drill = new String[0];


void createDrillGcode(){
  ArrayList a = new ArrayList();
  println("drills.size() = "+drills.size());
  Iterator it = drills.iterator();
  
  a.add("M106 S0");
  a.add("G1 F"+feedrate_drill);
  gcode_home_z(a);
  gcode_home_xy(a);

  
  int drillCalibCount = 0;
  while(it.hasNext()){
    Drill d = (Drill)(it.next());
    a.add("G0 X"+(d.x + x_drillOffset_mm)+" Y"+(d.y + y_drillOffset_mm));
    
    // lower and drill
    a.add("G0 Z"+drillJustAboveSurface_mm);
    a.add("G4 P0");
    a.add("M106 S255");
    a.add("G1 Z"+drillHeight_mm);
    
    // lift to clear above surface.
    a.add("G1 Z"+drillJustAboveSurface_mm);
    a.add("G4 P0");
    a.add("M106 S0");
    a.add("G0 Z"+drillClearAboveSurface_mm);
  
    if(drillCalibCount >= drillCalibEvery){   
      // lift, home
      //a.add("G1 Z"+drillJustAboveSurface_mm);
      a.add("G4 P0");
      a.add("M106 S0");
      gcode_home_z(a);
      gcode_home_xy(a);

      drillCalibCount = 0;
    }
    
    drillCalibCount++;
  }
  
  // lift, home
  a.add("G4 P0");
  a.add("M106 S0");
  gcode_home_z(a);
  gcode_home_xy(a);


  
  gcode_drill = new String[a.size()];
  it = a.iterator();
  int i = 0;
  while(it.hasNext()){
    String s = (String)(it.next());
    gcode_drill[i] = s;
    i++;
  }
}
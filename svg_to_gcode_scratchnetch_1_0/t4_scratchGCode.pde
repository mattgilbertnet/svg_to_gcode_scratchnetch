void gcode_home_z(ArrayList a){
  a.add("G28 Z0");
}
void gcode_home_xy(ArrayList a){
  a.add("G28 X0 Y0");
}

void gcode_pressure_off(ArrayList a){
  a.add("G0 Z"+(1000.0 - z_liftScriber));
  a.add("G4 P0");
  a.add("G92 Z"+scratchJustAboveSurface_mm);
  a.add("G4 P0");
}

void gcode_pressure_on(ArrayList a, float f){
  a.add("G4 P0");
  a.add("G162 Z");
  a.add("G1 F"+feedrate_scratch);
}

String[] createScratchGcode(ArrayList copperShapes_AL){
  println("copperShapes.size() = "+copperShapes_AL.size());
  ArrayList a = new ArrayList();
  a.add("M106 S0");
  //gcode_pressure_off(a);
  a.add("G1 F"+feedrate_scratch);
  //a.add("G1 N"+scriberPressure);
  gcode_home_z(a);
  gcode_home_xy(a);
  
  int numCalibrations = 0;
  int sinceXYScratchCalib = 0;
  int sinceZScratchCalib = 0;
  
  Iterator it = copperShapes_AL.iterator();
  while(it.hasNext()){
    CopperShape t = (CopperShape)(it.next()); 
    RPolygon poly = t.polygon;
    float distanceSinceCalibration_mm = 0;
    for(int i=0; i < poly.contours.length; i++){
      RContour c = poly.contours[i];
      RPoint p = c.points[0];
      RPoint p_prev = p;
      float x = round((p.x + x_scratchOffset_mm)*1000.0) / 1000.0;
      float y = round((p.y + y_scratchOffset_mm)*1000.0) / 1000.0;
      float x_prev = round((p_prev.x + x_scratchOffset_mm)*1000.0) / 1000.0;
      float y_prev = round((p_prev.y + y_scratchOffset_mm)*1000.0) / 1000.0;

      // move to point
      a.add("G0 X"+x+" Y"+y);

      // lower
      a.add("G0 Z"+scratchJustAboveSurface_mm);
      gcode_pressure_on(a, feedrate_scratch_adjustZ);
      
      for(int j=0; j < c.points.length; j++){
        p = c.points[j];
        x = round((p.x + x_scratchOffset_mm)*1000.0) / 1000.0;
        y = round((p.y + y_scratchOffset_mm)*1000.0) / 1000.0;

        // scratch to the next point
        a.add("G1 X"+x+" Y"+y);
        
        distanceSinceCalibration_mm += abs(x - x_prev) + abs(y - y_prev); // summing x and y, as if they were stair steps. [shrug]
        boolean needCalibrate = (distanceSinceCalibration_mm > calibrateEvery_mm);
        if(needCalibrate){
          numCalibrations++;
          // reset
          distanceSinceCalibration_mm = 0;
          // lift, home
          gcode_pressure_off(a);
          gcode_home_z(a);
          gcode_home_xy(a);
          // return to X Y
          a.add("G0 X"+x+" Y"+y);
          // lower
          a.add("G0 Z"+scratchJustAboveSurface_mm);      
          gcode_pressure_on(a, feedrate_scratch_adjustZ);
        }
        
        p_prev = p;
      }
      
      // then do the first bit again, to make sure the scriber doesn't leave a tiny gap.
      
      if(c.points.length > 2){
        p = c.points[0];
        x = round((p.x + x_scratchOffset_mm)*1000.0) / 1000.0;
        y = round((p.y + y_scratchOffset_mm)*1000.0) / 1000.0;
        a.add("G1 X"+x+" Y"+y);
        p = c.points[1];
        x = round((p.x + x_scratchOffset_mm)*1000.0) / 1000.0;
        y = round((p.y + y_scratchOffset_mm)*1000.0) / 1000.0;
        a.add("G1 X"+x+" Y"+y);
      }
      
            
      // then lift
      gcode_pressure_off(a);
      sinceZScratchCalib++;
      if(sinceZScratchCalib > scratchZCalibEvery){
        
        gcode_home_z(a);
        sinceZScratchCalib = 0;
      } else {
      }
    } // end for loop through contours
    
    
    // calibrate between TraceSegments
    sinceXYScratchCalib++;
    if(sinceXYScratchCalib > scratchXYCalibEvery){
      gcode_home_xy(a);
      sinceXYScratchCalib = 0;
    } else {
      //a.add("G0 Z"+scratchJustAboveSurface_mm);
    }
    
  } // end while through traceSegments
  
  
  String[] out = new String[a.size()];
  it = a.iterator();
  int i = 0;
  while(it.hasNext()){
    String s = (String)(it.next());
    out[i] = s;
    i++;
  }
  return out;
}
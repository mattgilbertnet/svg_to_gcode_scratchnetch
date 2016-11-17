
public void saveGCode(int theValue){
  
  if(svgLoaded){
    
    createDrillGcode();
    
    String[] gc_sr = createScratchGcode(copperShapes_repeats);
    
    gcode_scratchRepeats = createScratchGcode(copperShapes_repeats);
    gcode_scratchRepeats = skipDuplicateGCode(gcode_scratchRepeats);
    
    //println("length: "+gcode_scratchRepeats.length);
    
    saveStrings("out/"+filename_in+"_drill.gcode", gcode_drill);
    saveStrings("out/"+filename_in+"_scratch.gcode", gcode_scratchRepeats);
  
  }
}

String[] skipDuplicateGCode(String[] gcode_in){
  ArrayList strings_al = new ArrayList();
  String prev = gcode_in[0];
  strings_al.add(prev);
  for(int i = 1; i < gcode_in.length; i++){
    String s = gcode_in[i];
    if(s.equals(prev)){
        println("==, "+prev+", "+s);
    } else {
        //println("!=, "+prev+", "+s);
      strings_al.add(s);
      prev = s;
    }
  }
  
  String[] gcode_out = new String[strings_al.size()];
  for(int i = 0; i < strings_al.size(); i++){
    gcode_out[i] = (String)(strings_al.get(i));
  }
  //println("lengths: "+gcode_in.length + ", "+gcode_out.length);
  return gcode_out;
}


public void saveSVG(int theValue){
  if(svgLoaded){
    
    println("saveSVG");
    RGroup g = new RGroup();
  
    g = new RGroup();
    Iterator it = copperShapes_repeats.iterator();
    while(it.hasNext()){
      CopperShape t = (CopperShape)(it.next());    
      RPolygon p = t.polygon;
      g.addElement(p);
    }
    RSVG rsvg = new RSVG();
    
    rsvg.saveGroup("out/debug.svg", g);
  }
}

void keyPressed(){
  if(keyCode == LEFT){
    i0_test--;
    if(i0_test < 0){
      //i0_test = copperShapes.size() - 1;
    }
  } else if(keyCode == RIGHT){
    i0_test++;
    //i0_test %= copperShapes.size();
  }
}
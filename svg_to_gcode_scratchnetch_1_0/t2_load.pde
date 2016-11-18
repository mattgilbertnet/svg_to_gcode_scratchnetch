ArrayList drills = new ArrayList();
//ArrayList copperShapes = new ArrayList();
ArrayList copperShapeArrays = new ArrayList();

void initSVG(){
  svg = loadXML(filename_in);
  println("svg.getName() = "+svg.getName());
  String[] atts = svg.listAttributes();
  
  // GET THE VIEWBOX PARAMETERS, TO ESTABLISH SCALE (set mm_per_px)
  String h_svg = svg.getString("height");
  String w_svg = svg.getString("width");
  String vb_svg = svg.getString("viewBox");
  boolean metric_svg = false; //Fritzing uses inches
  if(h_svg.indexOf("cm") != -1){
    metric_svg = true;
  }
  float h = Float.parseFloat(h_svg.substring(0,h_svg.length()-2));
  float w = Float.parseFloat(w_svg.substring(0,w_svg.length()-2));
  String[] vbs = vb_svg.split(" ");
  if(metric_svg){
    mm_per_px = (w*10.0)/(Float.parseFloat(vbs[2]));
  } else {
    mm_per_px = (w*25.4)/(Float.parseFloat(vbs[2])); // assuming units are inches
  }
  println("mm_per_px = "+mm_per_px);
  
  // I need to do this loading procedure several times, with greater strokeweight and larger pads each time.
  // * + So, the loadfunctions need additional arguments:
  //   * + The arraylist to load shapes into (since there will now be many instead of one)
  //   * + The "lap" that they are on. This will be used to incrementally add to the strokeweight and pad size
 // * + Unionize will also need to apply to all arraylists in copperShapeArrays, instead of copperShapes.
 // * createScratchRepeats will also need to change
  
  // GO THROUGH THE CHILDREN, LOAD EVERYTHING (recursive functions)
  for(int lap=0; lap < scratchRepeats; lap++){
    ArrayList cs = new ArrayList();
    XML[] children = svg.getChildren();
    for(int i=0; i < children.length; i++){
      XML c = children[i];
      String name = c.getName();
      if(name.equals("line")){
        loadLine(c, cs, lap);
      } else if(name.equals("path")){
        loadPath(c, cs, lap);
      } else if(name.equals("polyline")){
        loadPolyline(c, cs, lap);
      } else if(name.equals("circle")){
        loadCircle(c, cs, lap);
      } else if(name.equals("g")){
        loadG(c, cs, lap);
      }
    }
    copperShapeArrays.add(cs);
  }
  println("drills.size() = "+drills.size());
  
  //REMOVE DUPLICATE DRILLS
  for(int i = 0; i < drills.size()-1; i++){
    Drill di = (Drill)(drills.get(i));
    ArrayList toRemove = new ArrayList();

    for(int j = i+1; j < drills.size(); j++){
      Drill dj = (Drill)(drills.get(j));
      if(di.x == dj.x && di.y == dj.y){
        
        toRemove.add(new Integer(j));
      }
    }
    
    if(toRemove.size() > 0){
      //println("duplicate drills: "+toRemove.size());
      for(int j = toRemove.size()-1; j >=0; j--){
        int j_r = ((Integer)(toRemove.get(j))).intValue();
        drills.remove(j_r);
      }
    }
  }
  println("unique drills: "+drills.size());
  
  // OPTIMIZE DRILL ORDER
  // really should learn some travelling salesman tricks to optimize this more.
  optimizeDrillOrder();
  optimizeDrillOrder();
  optimizeDrillOrder();
  optimizeDrillOrder();
  optimizeDrillOrder();
  
  // UNIONIZE COPPERSHAPES
  Iterator it_a = copperShapeArrays.iterator();
  while(it_a.hasNext()){
    ArrayList cs_this = (ArrayList)(it_a.next());
    println("copperShapes.size() = "+cs_this.size());
    println("unionizing");
    unionize(cs_this); 
    println("copperShapes.size() = "+cs_this.size());
  }
  
  //MERGE CLOSE POINTS
  
  println("merge close points on contour");
  for(int i = 0; i < copperShapeArrays.size(); i++){
    ArrayList cs_this = (ArrayList)(copperShapeArrays.get(i));
    ArrayList replacement = mergeClosePoints(cs_this);
    copperShapeArrays.set(i, replacement);
  }
  
  
  //CREATE SCRATCH REPEATS
  println("create scratch repeats");  
  createScratchRepeats();
  
  
  svgLoaded = true;
}

void loadLine(XML l, ArrayList cs, int lap){
  println("loadLine (no RMatrix)");  
  RMatrix rm = new RMatrix();  // create an identity matrix
  float sw = getStrokewidth(l);
  loadLine(l, rm, sw, cs, lap);
}

void loadPath(XML l, ArrayList cs, int lap){
  println("loadPath (no RMatrix)");  
  RMatrix rm = new RMatrix();  // create an identity matrix
  float sw = getStrokewidth(l);
  loadPath(l, rm, sw, cs, lap);
}

void loadPolyline(XML l, ArrayList cs, int lap){
  println("loadPolyLine (no RMatrix)");  
  RMatrix rm = new RMatrix();  // create an identity matrix
  float sw = getStrokewidth(l);
  loadPolyline(l, rm, sw, cs, lap);
}

void loadCircle(XML l, ArrayList cs, int lap){ // prolly never called
  println("loadCircle (no RMatrix)");  
  RMatrix rm = new RMatrix();  // create an identity matrix
  float sw = getStrokewidth(l);
  loadCircle(l, rm, sw, cs, lap);
}

void loadG(XML g, ArrayList cs, int lap){
  println("loadG");
  
  // print some info
  if(g.hasAttribute("id")){
    println("g.id="+g.getString("id"));  }
  if(g.hasAttribute("partID")){
    println("partID = "+g.getString("partID"));  }
  
  // If this group has a transform matrix, create a new 
  // matrix. Start with an identity matrix, and apply this matrix to that.
  // The result will apply to all children of this element.
  RMatrix rm = new RMatrix();
  if(g.hasAttribute("transform")){
    String transform = g.getString("transform");
    rm = applySvgTransform(rm, transform);
  }
  float sw = getStrokewidth(g);
  loadChildren(g.getChildren(), rm, sw, cs, lap);
}

void loadCircle(XML c, RMatrix rm, float strokewidth, ArrayList cs, int lap){
  // GET VALUES
  float sw = getStrokewidth(c, strokewidth);
  float x = Float.parseFloat(c.getString("cx"));
  float y = Float.parseFloat(c.getString("cy"));
  float r = Float.parseFloat(c.getString("r"));
  
  // CONVERT TO MM
  float sw_mm = sw * mm_per_px;
  float x_mm = x * mm_per_px;
  float y_mm = y * mm_per_px;
  
  int r_start = scratchRepeats_startAt;
  float r_mm = r * mm_per_px + ((float)(r_start + lap))*scratchWidth_mm;
      
  cs.add(new CopperShape(x_mm, y_mm, r_mm));
  drills.add(new Drill(x_mm, y_mm));
}

void loadLine(XML l, RMatrix rm, float strokewidth, ArrayList cs, int lap){
  // GET VALUES IN PX
  float sw = getStrokewidth(l, strokewidth);
  float x1 = matrixParseFloat(l.getString("x1"));
  float y1 = matrixParseFloat(l.getString("y1"));
  float x2 = matrixParseFloat(l.getString("x2"));
  float y2 = matrixParseFloat(l.getString("y2"));
  RPoint pt_1 = new RPoint(x1, y1);
  pt_1.transform(rm);
  RPoint pt_2 = new RPoint(x2, y2);
  pt_2.transform(rm);

  // CONVERT TO MM
  int r_start = scratchRepeats_startAt;
  float sw_mm = sw * mm_per_px + ((float)(r_start + lap*2))*scratchWidth_mm;  
  float x1_mm = mm_per_px * pt_1.x;
  float y1_mm = mm_per_px * pt_1.y;
  float x2_mm = mm_per_px * pt_2.x;
  float y2_mm = mm_per_px * pt_2.y;

  // ADD TRACESEGMENT
  
  cs.add(new CopperShape(x1_mm, y1_mm, x2_mm, y2_mm, sw_mm));
}

void loadPath(XML p, RMatrix rm, float strokewidth, ArrayList cs, int lap){
  // GET VALUES IN PX
  float sw = getStrokewidth(p, strokewidth);
  String[] ds = p.getString("d").split(" |\n");
  float x1 = Float.parseFloat(ds[0].substring(1));
  float y1 = Float.parseFloat(ds[1]);
  float x2 = Float.parseFloat(ds[2].substring(1));
  float y2 = Float.parseFloat(ds[3]);
  RPoint pt_1 = new RPoint(x1, y1);
  pt_1.transform(rm);
  RPoint pt_2 = new RPoint(x2, y2);
  pt_2.transform(rm);
  
  // CONVERT TO MM
  int r_start = scratchRepeats_startAt;
  float sw_mm = sw * mm_per_px + ((float)(r_start + lap*2))*scratchWidth_mm; 
  float x1_mm = mm_per_px * pt_1.x;
  float y1_mm = mm_per_px * pt_1.y;
  float x2_mm = mm_per_px * pt_2.x;
  float y2_mm = mm_per_px * pt_2.y;
  
  // ADD TRACESEGMENT
  cs.add(new CopperShape(x1_mm, y1_mm, x2_mm, y2_mm, sw_mm));
}
void loadPolyline(XML p, RMatrix rm, float sw, ArrayList cs, int lap){
  // GET THE POINTS
  String[] points = p.getString("points").split(" ");
  float[] x = new float[points.length];
  float[] y = new float[points.length];
  for(int i = 0; i < points.length; i++){
    String[] xy = points[i].split(",");
    x[i] = Float.parseFloat(xy[0]);
    y[i] = Float.parseFloat(xy[1]);
  }
  
  //CONVERT TO MM, adding the lap offset too.
  int r_start = scratchRepeats_startAt;
  //find center
  float x_min = x[0];  float x_max = x[0];
  float y_min = y[0];  float y_max = y[0];
  for(int i = 0; i < points.length; i++){
    float x_i = x[i];    float y_i = y[i];
    if(x_i < x_min){ x_min = x_i; }
    if(x_i > x_max){ x_max = x_i; }
    if(y_i < y_min){ y_min = y_i; }
    if(y_i > y_max){ y_max = y_i; }
  }
  float cx = (x_min + x_max) / 2.0;
  float cy = (y_min + y_max) / 2.0;
  for(int i = 0; i < points.length; i++){
    if(x[i] > cx){
      x[i] = x[i] * mm_per_px + (float)(lap + r_start)*scratchWidth_mm;
    } else {
      x[i] = x[i] * mm_per_px - (float)(lap + r_start)*scratchWidth_mm;
    }
    if(y[i] > cy){
      y[i] = y[i] * mm_per_px + (float)(lap + r_start)*scratchWidth_mm;
    } else {
      y[i] = y[i] * mm_per_px - (float)(lap + r_start)*scratchWidth_mm;
    }
  }
  
  cs.add(new CopperShape(x, y));
}
float sqrt2 = sqrt(2.0);

void loadG(XML g, RMatrix rm_parent, float strokewidth, ArrayList cs, int lap){
  float sw = getStrokewidth(g, strokewidth);
  
  // If this group has a transform matrix, create a new 
  // matrix. Start with an identity matrix, and apply this matrix to that.
  // The result will apply to all children of this element.
  RMatrix rm = new RMatrix(rm_parent);
  //println("  has transform: "+g.hasAttribute("transform"));
  if(g.hasAttribute("transform")){
    String transform = g.getString("transform");
    rm = applySvgTransform(rm, transform);
  }

  loadChildren(g.getChildren(), rm, sw, cs, lap);
}


void loadChildren(XML[] children, RMatrix rm, float strokewidth, ArrayList cs, int lap){
  for(int i=0; i < children.length; i++){
    XML c = children[i];
    String name = c.getName();
    if(name.equals("line")){
      loadLine(c, rm, strokewidth, cs, lap);
    } else if(name.equals("path")){
      loadPath(c, rm, strokewidth, cs, lap);
    } else if(name.equals("polyline")){
      loadPolyline(c, rm, strokewidth, cs, lap);
    } else if(name.equals("circle")){
      loadCircle(c, rm, strokewidth, cs, lap);
    } else if(name.equals("g")){
      loadG(c, rm, strokewidth, cs, lap);
    }
  }
}

float getStrokewidth(XML e){
  return getStrokewidth(e, 0.0);
}
float getStrokewidth(XML e, float default_sw){
  float strokewidth = default_sw;
  if(e.hasAttribute("stroke-width")){
    strokewidth = e.getFloat("stroke-width");
  } else if(e.hasAttribute("style")){
    String[] styles = e.getString("style").split(" ");
    for(int i=0; i<styles.length; i++){
      String s = styles[i];
      if(s.indexOf("stroke-width") != -1){
        println("strokewidth = "+s.substring(13, s.length()-1));
        strokewidth = Float.parseFloat(s.substring(13, s.length()-1));
      }
    }
  }
  return strokewidth;
}

float matrixParseFloat(String s){
  if(s.indexOf(",") != -1){
    s = s.substring(0, s.length()-1);
  }
  //println("matrixParseFloat: "+s);
  if(s.indexOf("e") == -1){
     return Float.parseFloat(s);
  } else {
    int i = s.indexOf("e");
    int i_end = s.indexOf("0");
    //String s1 = "";
    //if(i_end == -1){
      
    String s1 = s.substring(0, i);    
    float f1 = Float.parseFloat(s1);
    
    String e_sign = s.substring(i+1,i+2);
    if(e_sign.equals("-")){
      String s2 = s.substring(i+2);
      float f2 = -Float.parseFloat(s2+".0");
      println(f1);
      println(f2);
      println(f1 * pow(10.0, f2));
      return f1 * pow(10.0, f2);
    } else if(e_sign.equals("+")){
      String s2 = s.substring(i+2);
      float f2 = Float.parseFloat(s2);
      println(f1);
      println(f2);
      println(f1 * pow(10.0, f2));
      return f1 * pow(10.0, f2);
    } else {
      String s2 = s.substring(i+1);
      float f2 = Float.parseFloat(s2);
      println(f1);
      println(f2);
      println(f1 * pow(10.0, f2));
      return f1 * pow(10.0, f2);
    }
  }
}

RMatrix applySvgTransform(RMatrix rm, String transform){
  if(transform.indexOf("translate(0 0) scale(1 1)") != -1){
    // do nothing, I think.
  } else if(transform.indexOf("translate") != -1){
    String[] xy_ss = (transform.substring(10, transform.length()-1)).split(",");
    float x_t = matrixParseFloat(xy_ss[0]);
    float y_t = matrixParseFloat(xy_ss[1]);
    rm.translate(x_t, y_t);
  } else if(transform.indexOf("matrix") != -1){
    String[] xy_ss = (transform.substring(7, transform.length()-1)).split(",");
    float[] matrix = new float[6];
    // Geomerative RMatrixes order them like this:
    //       { 00, 01, 02, 
    //         10, 11, 12  }
    //  which makes perfect sense to me. However, svg matrices are ordered like this:
    //       {  a,  c,  e
    //          b,  d,  f  }
    //  which makes perfect sense to crazy people. Lowly, wretched, bad people.
    
    matrix[0] = matrixParseFloat(xy_ss[0]);
    matrix[1] = matrixParseFloat(xy_ss[2]);
    matrix[2] = matrixParseFloat(xy_ss[4]);
    matrix[3] = matrixParseFloat(xy_ss[1]);
    matrix[4] = matrixParseFloat(xy_ss[3]);
    matrix[5] = matrixParseFloat(xy_ss[5]);
    //println(xy_ss[0]+", "+xy_ss[2]+", "+xy_ss[4]+", "+xy_ss[1]+", "+xy_ss[3]+", "+xy_ss[5]);
    //println(matrix[0]+", "+matrix[1]+", "+matrix[2]+", "+matrix[3]+", "+matrix[4]+", "+matrix[5]);
    rm.apply(matrix[0], matrix[1], matrix[2], matrix[3], matrix[4], matrix[5]);
  }
  //println(transform);
  return rm;
}
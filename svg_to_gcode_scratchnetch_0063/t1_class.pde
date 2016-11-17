
class CopperShape{
  //float x1, y1, x2, y2;
  RPolygon polygon;
  CopperShape(RPolygon polygon){    
    this.polygon = polygon;
  }
  CopperShape(float x1, float y1, float x2, float y2, float sw){
    // values in mm. (convert from pixels before creating a traceSegment.)
    
    
    // CREATE THE MAIN BODY OF THE TRACE
    float dx = x2 - x1;
    float dy = y2 - y1;
    float d = sqrt(sq(dx) + sq(dy));
    float t = atan2(dy, dx);
    float w_half = sw/2.0;
    float x_corner = x1 + w_half*cos(t+HALF_PI);
    float y_corner = y1 + w_half*sin(t+HALF_PI);
    float x_b = x_corner + d*cos(t);
    float y_b = y_corner + d*sin(t);
    float x_c = x_b + sw * cos(t-HALF_PI);
    float y_c = y_b + sw * sin(t-HALF_PI);
    float x_d = x_corner + sw * cos(t-HALF_PI);
    float y_d = y_corner + sw * sin(t-HALF_PI);
    RContour c = new RContour();
    c.addPoint(x_corner, y_corner);
    c.addPoint(x_b, y_b);
    c.addPoint(x_c, y_c);
    c.addPoint(x_d, y_d);
    RPolygon p = new RPolygon(c);
    
    
    // CREATE OCTAGONS AT THE ENDS OF THE TRACE
    float corner90 = sw/2.0;
    float corner45 = (sw/2.0) * sin(PI/4.0);
    float c_Oct = HALF_PI/4.0;
    float cornerOct = (corner90 / cos(c_Oct)) * sin(c_Oct);
    
    RContour c_tip1 = new RContour();
    c_tip1.addPoint(x1 - corner90 , y1 - cornerOct);
    c_tip1.addPoint(x1 - cornerOct, y1 - corner90);
    c_tip1.addPoint(x1 + cornerOct, y1 - corner90);
    c_tip1.addPoint(x1 + corner90 , y1 - cornerOct);
    c_tip1.addPoint(x1 + corner90 , y1 + cornerOct);
    c_tip1.addPoint(x1 + cornerOct, y1 + corner90);
    c_tip1.addPoint(x1 - cornerOct, y1 + corner90);
    c_tip1.addPoint(x1 - corner90 , y1 + cornerOct);
    RPolygon p_tip1 = new RPolygon(c_tip1);
    
    RContour c_tip2 = new RContour();
    c_tip2.addPoint(x2 - corner90 , y2 - cornerOct);
    c_tip2.addPoint(x2 - cornerOct, y2 - corner90);
    c_tip2.addPoint(x2 + cornerOct, y2 - corner90);
    c_tip2.addPoint(x2 + corner90 , y2 - cornerOct);
    c_tip2.addPoint(x2 + corner90 , y2 + cornerOct);
    c_tip2.addPoint(x2 + cornerOct, y2 + corner90);
    c_tip2.addPoint(x2 - cornerOct, y2 + corner90);
    c_tip2.addPoint(x2 - corner90 , y2 + cornerOct);
    RPolygon p_tip2 = new RPolygon(c_tip2);
    
    // UNIONIZE THE MAIN PART OF THE TRACE WITH THE ENDCAPS
    this.polygon = p.union(p_tip1).union(p_tip2);
  }
  CopperShape(float[] x_points, float[] y_points){
    // values in mm. (convert from pixels before creating a Pad.)
    // This constructor is tuned to work with square pads, typically described with polylines in an svg from KiCad.
    RContour c = new RContour();
    for(int i = 0; i < x_points.length; i++){
      c.addPoint(x_points[i], y_points[i]);
    }
    this.polygon = new RPolygon(c);
  }
  CopperShape(float x, float y, float r){    
    // values in mm. (convert from pixels before creating a CopperShape.)
    // This copper shape constructor is for a pad, or other circular area (approximated with an octogon).
    
    // CREATE OCTOGON
    float pad90 = r;
    float pad45 = r * sin(PI/4.0);
    float t_Oct = HALF_PI/4.0;
    float padOct = (pad90 / cos(t_Oct)) * sin(t_Oct);
    RContour c = new RContour();
    c.addPoint(x - pad90 , y - padOct);
    c.addPoint(x - padOct, y - pad90);
    c.addPoint(x + padOct, y - pad90);
    c.addPoint(x + pad90 , y - padOct);
    c.addPoint(x + pad90 , y + padOct);
    c.addPoint(x + padOct, y + pad90);
    c.addPoint(x - padOct, y + pad90);
    c.addPoint(x - pad90 , y + padOct);
    this.polygon = new RPolygon(c);
  }
  CopperShape union(CopperShape t){
    return new CopperShape(polygon.union(t.polygon));
  }
  boolean hasIntersection(CopperShape t){
    try{
      RPolygon p = this.polygon.intersection(t.polygon);
      if(p.countContours() > 0){
        return true;
      } else {
        return false;
      }
    } catch(NullPointerException e) {
      return false;
    }
  }
  
  boolean compare(CopperShape t){
    try{
      RPolygon p = this.polygon.diff(t.polygon);
      if(p.countContours() == 0){
        return true;
      } else{
        return false;
      }
    } catch(NullPointerException e){
      println("null difference");
      return false;
    }
  }
}

class Drill{
  float x;
  float y;
  Drill(float x, float y){    
    // values in mm. (convert from pixels before creating a Pad.)
    this.x = x;
    this.y = y;
  }
}
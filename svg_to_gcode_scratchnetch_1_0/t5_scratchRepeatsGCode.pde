String[] gcode_scratchRepeats = new String[0];
String[] gcode_scratchAreas = new String[0];
ArrayList copperShapes_repeats = new ArrayList();

float scratchWidth_mm = .08; //how far apart is each round of scrathing
int scratchRepeats = 6; //how many times around should we scratch
int scratchRepeats_startAt = 4; //makes evey copper area a little bigger



ArrayList mergeClosePoints(ArrayList copperShapes){  
  
  float tooClose = 0.02;
  
  ArrayList copperShapes_new = new ArrayList();
  Iterator it = copperShapes.iterator();
  while(it.hasNext()){
    RPolygon poly_new = new RPolygon();
    
    CopperShape ts = (CopperShape)(it.next()); 
    RPolygon poly = ts.polygon;
    
    
    for(int i=0; i < poly.contours.length; i++){
      RContour c = poly.contours[i];
      RContour c_new = new RContour();
      RPoint p_prev = c.points[0];
      RPoint p = c.points[0];
      c_new.addPoint(p);

      for(int j=1; j < c.points.length; j++){
        p = c.points[j];
        float dx = p.x - p_prev.x;
        float dy = p.y - p_prev.y;
        float d = sqrt(sq(dx) + sq(dy));
        if(d > tooClose){
          c_new.addPoint(p);
          p_prev = p;
          println("including a point");
        } else {
          println("skipping a point");
        }
      }
      poly_new.addContour(c_new);
    }
    
    copperShapes_new.add(new CopperShape(poly_new));
  }
  return copperShapes_new;
}
void createScratchRepeats(){  
  copperShapes_repeats = new ArrayList();

  int lap_count = copperShapeArrays.size();
  for(int l = 0 ; l < lap_count; l++){
    ArrayList al = ((ArrayList)(copperShapeArrays.get(l))); 
    int shape_count = al.size();
    for(int k = 0; k < shape_count; k++){
      CopperShape t = (CopperShape)(al.get(k)); 
      RPolygon poly = t.polygon;
      RPolygon poly_new = new RPolygon();
      for(int i=0; i < poly.contours.length; i++){
        RContour c_new = new RContour();
        RContour c = poly.contours[i];
        if(c.points.length >1){
          RPoint p_prev = c.points[0];
          RPoint p = c.points[1];
      
          for(int j=0; j < c.points.length; j++){
        
            int j_prev = j % c.points.length;
            int j_curr = (j+1) % c.points.length;
            p_prev = c.points[j_prev];
            p = c.points[j_curr];

            c_new.addPoint(p_prev);
        
            //break up long contours into short segments, so that the scratchHeight is updated more often, keeping it more accurate along long traces
            float dx = p.x - p_prev.x;
            float dy = p.y - p_prev.y;
            float d = sqrt(sq(dx) + sq(dy));
            if(d > pressureUpdateEvery_mm){
              float segments = ceil(d / pressureUpdateEvery_mm);
              float inc = 1.0 / segments;
              for(float s = 0; s <1.0; s += inc){
                float dx_s = dx*s;
                float dy_s = dy*s;
                RPoint p_s = new RPoint(p_prev.x + dx_s, p_prev.y + dy_s);
                c_new.addPoint(p_s);
              }
            }
            c_new.addPoint(p);
          }
          poly_new.addContour(c_new);
        }
      }
      copperShapes_repeats.add(new CopperShape(poly_new));
    }
  }
}
/*
void createScratchRepeats(){  
  copperShapes_repeats = new ArrayList();
  Iterator it = copperShapes.iterator();
       
  while(it.hasNext()){
    CopperShape ts = (CopperShape)(it.next()); 
    RPolygon poly = ts.polygon;
    RPolygon poly_new = new RPolygon();
    
    int r_start = scratchRepeats_startAt;
    float offset = scratchWidth_mm * r_start ; //start some rings out, to make all traces wider
      
          
    for(int i=0; i < poly.contours.length; i++){
      RContour c = poly.contours[i];
      RContour c_new = new RContour();
      RPoint p_prev = c.points[0];
      RPoint p = c.points[0];
      
      p_prev = c.points[0];
      p = c.points[1];
      RPoint p_next = c.points[2];
        
      float t = d_angle(p_prev, p, p_next);
      float t_h = t/2.0;
      float t_l1 = angle(p_prev, p);
      float t_l2 = angle(p_next, p);
      float t1 = t_l1 + (-HALF_PI) + t_h;
            
      //float h = offset / cos(t_h);
      float h = offset;
      if(t_h >= .01){
        h = offset / (cos(t_h));
      }
           
      float x = p.x + h*cos(t1);
      float y = p.y + h*sin(t1);
      RPoint p2_prev = new RPoint(x, y);
      
      RPoint p2 = p;
      
      
      float[] h_news = new float[c.points.length+2];
      int[] h_news_found = new int[c.points.length+2];
      
      for(int j=0; j < c.points.length+2; j++){
        
        int j_prev = j % c.points.length;
        int j_curr = (j+1) % c.points.length;
        int j_next = (j+2) % c.points.length;
        p_prev = c.points[j_prev];
        p = c.points[j_curr];
        p_next = c.points[j_next];
        
        t = d_angle(p_prev, p, p_next);
        t_h = t/2.0;
        t_l1 = angle(p_prev, p);
        t_l2 = angle(p_next, p);
        t1 = t_l1 + (-HALF_PI) + t_h;
            
        //float h = offset / cos(t_h);
        
        h = offset;
        if(h_news_found[j]==1){
          h = offset / h_news[j];
        } else {
          if(t_h >= .01){
            h_news[j] = (cos(t_h));
            h = offset / h_news[j];
            h_news_found[j] = 1;
          }
        }
        //h = offset / sin(t_h);
           
        x = p.x + h*cos(t1);
        y = p.y + h*sin(t1);
        //x = p.x - h*cos(t_l1) + h*cos(t_l2);
        //y = p.y - h*sin(t_l1) + h*sin(t_l2);
        p2 = new RPoint(x, y);
        
        //break up long contours into short segments, so that the scratchHeight is updated more often, keeping it more accurate along long traces
        float x_prev = p2_prev.x;
        float y_prev = p2_prev.y;
        float dx = p2.x - p2_prev.x;
        float dy = p2.y - p2_prev.y;
        float d = sqrt(sq(dx) + sq(dy));
        if(d > pressureUpdateEvery_mm){
          float segments = ceil(d / pressureUpdateEvery_mm);
          float inc = 1.0 / segments;
          for(float s = 0; s <1.0; s += inc){
            float dx_s = dx*s;
            float dy_s = dy*s;
            RPoint p_s = new RPoint(x_prev + dx_s, y_prev + dy_s);
            c_new.addPoint(p_s);
          }
        }
        c_new.addPoint(p2);
            
        p2_prev = p2;
      }
      //c_new.addPoint(c.points[0]); // make sure it closes
      
      for(float r = r_start+1; r < scratchRepeats + r_start; r++){
        // then go around several times more, slightly further away each time
        offset = scratchWidth_mm * r;
        if(c.points.length > 2){
          for(int j=c.points.length+1; j >= 0; j--){
            int j_prev = (j+2) % c.points.length;
            int j_curr = (j+1) % c.points.length;
            int j_next = j % c.points.length;
            p_prev = c.points[j_prev];
            p = c.points[j_curr];
            p_next = c.points[j_next];
            
            t = d_angle(p_prev, p, p_next);
            t_h = t/2.0;
            t_l1 = angle(p_prev, p);
            t_l2 = angle(p_next, p);
            t1 = t_l1 + (-HALF_PI) + t_h;
            
            //float h = offset / cos(t_h);
            h = offset;
            if(h_news_found[j]==1){
              h = offset / h_news[j];
            } else {
              if(t_h >= .01){
                h_news[j] = (cos(t_h));
                h = offset / h_news[j];
                h_news_found[j] = 1;
              }
            }
            
            
            
            x = p.x - h*cos(t1);
            y = p.y - h*sin(t1);
            //x = p.x - h*cos(t_l1) + h*cos(t_l2);
            //y = p.y - h*sin(t_l1) + h*sin(t_l2);
            p2 = new RPoint(x, y);
                        
            //break up long contours into short segments, so that the scratch height is updated more often, keeping it more accurate along long traces
            if(j > 0){
              float x_prev = p2_prev.x;
              float y_prev = p2_prev.y;
              float dx = p2.x - p2_prev.x;
              float dy = p2.y - p2_prev.y;
              float d = sqrt(sq(dx) + sq(dy));
                          
              if(d > pressureUpdateEvery_mm){
                float segments = ceil(d / pressureUpdateEvery_mm);
                float inc = 1.0 / segments;
                for(float s = 0; s <1.0; s += inc){
                  float dx_s = dx*s;
                  float dy_s = dy*s;
                  RPoint p_s = new RPoint(x_prev + dx_s, y_prev + dy_s);
                  c_new.addPoint(p_s);
                }
              }
            } else {
              float nudge = .05;
              float x_nudge = nudge * cos(t_l1);
              float y_nudge = nudge * sin(t_l1);
              p2.x = p2.x + x_nudge;
              p2.y = p2.y + y_nudge;
            }
            if(j == 1) {
              float nudge = .05;
              float x_nudge = nudge * cos(t_l1);
              float y_nudge = nudge * sin(t_l1);
              p2.x = p2.x + x_nudge;
              p2.y = p2.y + y_nudge;
            }
            
            c_new.addPoint(p2);
            
            p2_prev = p2;
          }
          
        
          // do the next repeat backwards, in case it matters
          //println(r);
          r++;
          //println(r);
          // then go around several times more, slightly further away each time
          offset = scratchWidth_mm * r;
          
          for(int j=0; j < c.points.length+2; j++){
            int j_prev = j % c.points.length;
            int j_curr = (j+1) % c.points.length;
            int j_next = (j+2) % c.points.length;
            p_prev = c.points[j_prev];
            p = c.points[j_curr];
            p_next = c.points[j_next];
            
            t = d_angle(p_prev, p, p_next);
            t_h = t/2.0;
            t_l1 = angle(p_prev, p);
            t_l2 = angle(p_next, p);
            t1 = t_l1 + (-HALF_PI) + t_h;
            
            //float h = offset / cos(t_h);
            
            h = offset;
            if(h_news_found[j]==1){
              h = offset / h_news[j];
            } else {
              if(t_h >= .1){
                h_news[j] = (cos(t_h));
                h = offset / h_news[j];
                h_news_found[j] = 1;
              }
            }
            x = p.x + h*cos(t1);
            y = p.y + h*sin(t1);
            //x = p.x + h*cos(t_l1) + h*cos(t_l2);
            //y = p.y + h*sin(t_l1) + h*sin(t_l2);
            p2 = new RPoint(x, y);
            
            //break up long contours into short segments, so that the scratch height is updated more often, keeping it more accurate along long traces
            if(j > 0){
              float x_prev = p2_prev.x;
              float y_prev = p2_prev.y;
              float dx = p2.x - p2_prev.x;
              float dy = p2.y - p2_prev.y;
              float d = sqrt(sq(dx) + sq(dy));

              if(d > pressureUpdateEvery_mm){
                float segments = ceil(d / pressureUpdateEvery_mm);
                float inc = 1.0 / segments;
                for(float s = 0; s <1.0; s += inc){
                        //println("s = "+s);
                  float dx_s = dx*s;
                  float dy_s = dy*s;
                  RPoint p_s = new RPoint(x_prev + dx_s, y_prev + dy_s);
                  c_new.addPoint(p_s);
                }
              }
            } else {
              float nudge = .05;
              float x_nudge = nudge * cos(t_l1);
              float y_nudge = nudge * sin(t_l1);
              p2.x = p2.x + x_nudge;
              p2.y = p2.y + y_nudge;
            }
            if(j == 1) {
              float nudge = .05;
              float x_nudge = nudge * cos(t_l1);
              float y_nudge = nudge * sin(t_l1);
              p2.x = p2.x + x_nudge;
              p2.y = p2.y + y_nudge;
            }

            c_new.addPoint(p2);
            
            p2_prev = p2;
          }
        }
      }
      
      poly_new.addContour(c_new);
    } // end for loop through contours
    copperShapes_repeats.add(new CopperShape(poly_new));
  } // end while through traceSegments
  
}
*/

float d_angle(RPoint a, RPoint b, RPoint c){
  float t_ab = angle(a, b);
  float t_bc = angle(b, c);
  
  float dt = t_bc - t_ab;
  if(dt > PI){
    dt -= TWO_PI;
  } else if(dt < -PI){
    dt += TWO_PI;
  }
  return dt;
}

float angle(RPoint a, RPoint b){
  float dx = b.x - a.x;
  float dy = b.y - a.y;
  if(dx==0 && dy==0){
    println("coincident points");
  }
  return atan2(dy,dx);
}
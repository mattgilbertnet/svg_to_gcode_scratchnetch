int i0_test = 0;

void drawParts(processing.core.PApplet g){
  fill(200, 200, 100);
  stroke(255);
  //strokeWeight(drillWidth_px);
  strokeWeight(.1);
  ArrayList cs = (ArrayList)(copperShapeArrays.get(0));
  Iterator it = cs.iterator();
  while(it.hasNext()){
    CopperShape c = (CopperShape)(it.next());
    drawRPolygon(c.polygon);
  }
/*
  Iterator it = copperShapes.iterator();
  while(it.hasNext()){
    CopperShape c = (CopperShape)(it.next());
    c.polygon.draw(g);
  }
  
  fill(255, 0, 0);
  stroke(255);
  strokeWeight(.5);
  if(copperShapes.size() > i0_test){
    CopperShape c_a = (CopperShape)(copperShapes.get(i0_test));
    c_a.polygon.draw(g);
  }
  */
  noStroke();
  fill(0);
  /*
  it = Drills.iterator();
  while(it.hasNext()){
    Drills p = (Pad)(it.next());
    p.drawDrillHole();
  }
  */
  noFill();
  stroke(0, 0, 255);
  strokeWeight(.1);
  if(drills.size() > 0){
    it = drills.iterator();
    Drill d_prev = (Drill)(drills.get(0));
    beginShape();
    vertex(d_prev.x, d_prev.y);
    while(it.hasNext()){
      Drill d = (Drill)(it.next());
      vertex(d.x, d.y);
      d_prev = d;
    }
    endShape();
  }
  
}

void drawRPolygon(RPolygon p){
  beginShape();
  for(int i = 0; i < p.contours.length; i++){
    RContour rc = p.contours[i];
    for(int j= 0; j < rc.points.length; j++){
      RPoint pt = rc.points[j];
      vertex(pt.x, pt.y);
    }
  }
  endShape(CLOSE);
}
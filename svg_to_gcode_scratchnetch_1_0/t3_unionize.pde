void unionize(ArrayList cs){
  // for each shape
  for(int i = 0; i < cs.size()-1; i++){
    //println("i = "+i);
    CopperShape t1 = (CopperShape)(cs.get(i));
    
    //look for a shape that it intersect
    boolean foundAnIntersect = true;
    while(foundAnIntersect){
      foundAnIntersect = false;
      for(int j = i+1; j < cs.size() && !foundAnIntersect; j++){
        //println("  j = "+j);
        CopperShape t2 = (CopperShape)(cs.get(j));
        if(t1.hasIntersection(t2)){
          // join them, placing the resulting object at all intersecting indexes  
          CopperShape result = t1.union(t2);
          cs.set(i, result);
          cs.remove(j);
          t1 = result;
          foundAnIntersect = true;
          //println("  found one: "+i+", "+j);
          j--; // to account for removed element
        }
      }
    }
  }
}
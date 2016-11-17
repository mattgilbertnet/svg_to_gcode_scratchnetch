// This could be greatly improved. I don't even remember what the idea was behind this.

void optimizeDrillOrder(){ 
  
  int count = 4;
  while(count < drills.size()){
    Iterator it = drills.iterator();
    Drill[] drills_local = new Drill[count];
    for(int i=0; i < drills_local.length; i++){
      drills_local[i] = (Drill)(it.next());
    }
    int i = 0;
    while(it.hasNext()){
      
      // generalize
      float d_sum_0 = dDrills_sum(drills_local);
      float d_sum_SWITCH = dDrills_sum_alt(drills_local);
      
      if(d_sum_SWITCH < d_sum_0){
        for(int j = 1; j < count/2; j++){
          Collections.swap(drills, i+j, i+(count-1-j));
        }
        
        Drill[] drills_local2 = new Drill[count];
        for(int j = 0; j < count-2; j++){
          drills_local2[j] = drills_local[count-2-j];
        }
        drills_local2[count-2] = drills_local[count-1];
        drills_local = drills_local2;
        
      } else {
        for(int j=0; j < count-1; j++){
          drills_local[j] = drills_local[j+1];
        }
      }
      i++;
      drills_local[count-1] = (Drill)(it.next());
    }
    count++;
  }
}


float dDrills_sum(Drill[] ds){
  //float d = 0;
  float d = dDrills(ds[0], ds[1]);
  d += dDrills(ds[ds.length-2], ds[ds.length-1]);
  return d;
}
float dDrills_sum_alt(Drill[] ds){
  float d = dDrills(ds[0], ds[ds.length-2]);
  d += dDrills(ds[1], ds[ds.length-1]);
  return d;
}

float dDrills(Drill a, Drill b){
  float dx = b.x - a.x;
  float dy = b.y - a.y;
  return sqrt(sq(dx) + sq(dy));
}
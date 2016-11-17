import controlP5.*;
import geomerative.*;
import java.util.Iterator;
import java.util.Collections;
int MG_MCWIRE = 0; // a deprecated setup that required different G-Code
int MG_3DPRINTMI = 1;

//int printer = MG_MCWIRE;
int printer = MG_3DPRINTMI;

//******************************
//Configuration:
//*****************************
float feedrate_scratch = 600;
float feedrate_scratch_adjustZ = 150;
float feedrate_drill = 400;
float x_scratchOffset_mm = 33.0;
float y_scratchOffset_mm = 13.0;
float x_drillOffset_mm = 2.18;
float y_drillOffset_mm = 24.18; 
float scratchJustAboveSurface_mm = 27.0;
float scratchClearAboveSurface_mm = 25.0;
float drillJustAboveSurface_mm = 35.5;
float drillHeight_mm = 37.5;
float drillClearAboveSurface_mm = 31.0;
float drillCalibEvery = 16;
float calibrateEvery_mm = 2000; 
float pressureUpdateEvery_mm = 2000.0;
float scratchXYCalibEvery = 10000;
float scratchZCalibEvery = 100000;
float feedrate_pressureSearch = 150;

String filename_in = "endstop_002-B.Cu.svg";

//******************************
// End Configuration:
//*****************************



XML svg;


float mm_per_px = 1.0; //will be updated by svg's viewBox, height, and width attributes

ControlP5 cp5;

boolean svgLoaded = false;

void setup() {  
  size(1000, 700);
  smooth();
  RG.init(this);
  cp5 = new ControlP5(this);
  
  cp5.addButton("saveSVG")
     .setValue(0)
     .setPosition(10, 10)
     .setSize(70,17)
     ;
  cp5.addButton("saveGCode")
     .setValue(0)
     .setPosition(90, 10)
     .setSize(70,17)
     ;


  initSVG();
  
}
void draw(){  
  if(svgLoaded){
    background(200);
    pushMatrix();
    scale(8);
    translate(.5, 3.0);
    drawParts(this);
    popMatrix();  
  }
}
import penner.easing.*;
import com.bigbrowncupboard.util.*;
import com.bigbrowncupboard.app.*;
import com.bigbrowncupboard.animate.*;
import com.bigbrowncupboard.ui.*;
import java.awt.Rectangle;
import java.util.Map;
import controlP5.*;
import cvc.CVClient;
import cvc.events.TrackingEvent;
import cvc.blobs.TrackingBlob;
import processing.video.*;
import java.text.DecimalFormat;
import processing.sound.*;
import dmxP512.*;
import processing.serial.*;
DmxP512 dmxOutput;
int universeSize=128;

boolean DMXPRO=true;
String DMXPRO_PORT="/dev/cu.usbserial-ENXQODAK";//case matters ! on windows port must be upper cased.
int DMXPRO_BAUDRATE=115000;

ArrayList<RectangleF> screenRects;
ArrayList<Rectangle> screenRects_;
// Size of each cell in the grid, ratio of window size to video size
float videoScale_h = 426;
float videoScale_v = 360;
// Number of columns and rows in our system
float cols, rows;

CVClient cvc;
PVector c_pos = new PVector();
PVector prev_avg_pos = new PVector();
boolean CVC_DEBUG_RENDER = true;
boolean DEBUG_PLAYHEAD = true;
String network_IP = "149.171.248.221";
ArrayList<SoundFile> soundfiles;
String [] soundnames = {"fireball.wav","choir.wav", "shaker.wav", "drum.wav", "piano.wav", "trap.wav"};

void setup() {
  size(1280, 720);
  
  
   dmxOutput = new DmxP512(this,universeSize,false);
 if(DMXPRO){
   dmxOutput.setupDmxPro(DMXPRO_PORT,DMXPRO_BAUDRATE);
 }
  smooth();
  
  //load in soundfiles
  soundfiles = new ArrayList<SoundFile>();
  for (int i = 0; i < soundnames.length; i ++){
     soundfiles.add(new SoundFile(this, soundnames[i])); 
  } 
    
  
  // Initialize columns and rows
  cols = width/videoScale_h;
  rows = height/videoScale_v;
  
  screenRects = new ArrayList<RectangleF>();
  screenRects_ = new ArrayList<Rectangle>();
  
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      float x = i*videoScale_h;
      float y = j*videoScale_v;
      fill(255);
      stroke(0);
      //rect(x, y, videoScale_h, videoScale_v);
      screenRects.add(new RectangleF(x, y, videoScale_h, videoScale_v));
      screenRects_.add(new Rectangle((int)x, (int)y, (int)videoScale_h, (int)videoScale_v));
    }
  }
  
  
  cvc = new CVClient(this);
  cvc.setMinimalLogging(); // Dont show so much in the console  
  cvc.init(); // initialise CVC 
  cvc.registerEvents(this); // register for the blob tracking events, your code must have methods updateTrackingBlobs & removeTrackingBlobs   
    // Setup VideoTracker server connection and connect
  cvc.setTrackingServer(network_IP, 11001); // ip, port
  cvc.showControlPanel(10, height-165);
  
}

void draw() {
  //background(0); 
  // FPS display  
  //text(frameRate, 2,10);
  int value = int(map(height, 0, width, 0,127));
 int fillvalue = int(map(height, 0, width, 0,255));
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      float x = i*videoScale_h;
      float y = j*videoScale_v;
      fill(255);
      stroke(0);
      rect(x, y, videoScale_h, videoScale_v);
      //screenRects.add(new RectangleF(x, y, videoScale_h, videoScale_v));
      //println(x, y, videoScale_h, videoScale_v);
    }
  }
  
  cvc.update();
    
  if(CVC_DEBUG_RENDER) { 
    cvc.render(0,0);
    cvc.drawImage(5, 5, 160, 120); // debug show copy of the image
  }
  String txt_fps = String.format(getClass().getName() + ", fps: "+ frameRate);
  surface.setTitle(txt_fps);
}
  
void removeTrackingBlobs( TrackingEvent event ) {
  // event.removed_blob_ids ArrayList of ints of the ids of blobs removed.
  // You can use this to remove your own blobs if you have created some

}

void updateTrackingBlobs(TrackingEvent event) {
  
  pushStyle();

 // Loop through all the Tracking blobs found in event.update_blobs


  for(Map.Entry<Integer,TrackingBlob> entry : event.updated_blobs.entrySet()) {  // This is how we loop thru a ConcurrentHashMap (which CVC uses to be thread safe)    
      TrackingBlob blob = entry.getValue(); // See notes below on methods to access TrackingBlob 
      int i = 0;
       if (blob.getRect().intersects(screenRects.get(i))){
         println("FIREBALL RED"+millis());
         if(!soundfiles.get(i).isPlaying()){
           soundfiles.get(i).play();
           println("trigger");
           dmxOutput.set(1,255);
           dmxOutput.set(2,0);
           dmxOutput.set(3,0);
           dmxOutput.set(4,0);
         }
       }
      i += 1;
      if (blob.getRect().intersects(screenRects.get(i))){
         println("CHOIR GREEN"+millis());
         if(!soundfiles.get(i).isPlaying()){
           soundfiles.get(i).play();
           println("trigger");
           dmxOutput.set(1,0);
           dmxOutput.set(2,255);
           dmxOutput.set(3,0);
           dmxOutput.set(4,0);
         }   
       }
       i += 1;
       if (blob.getRect().intersects(screenRects.get(i))){
         println("SHAKER BLUE");
         if(!soundfiles.get(i).isPlaying()){
           soundfiles.get(i).play();
           println("trigger");
           dmxOutput.set(1,0);
           dmxOutput.set(2,0);
           dmxOutput.set(3,255);
           dmxOutput.set(4,0);
         } 
       }
       i += 1;
       if (blob.getRect().intersects(screenRects.get(i))){
         println("DRUM YELLOW");
         if(!soundfiles.get(i).isPlaying()){
           soundfiles.get(i).play();
           println("trigger beats");
           dmxOutput.set(1,0);
           dmxOutput.set(2,0);
           dmxOutput.set(3,0);
           dmxOutput.set(4,255);
         }
       }
       i += 1;
       if (blob.getRect().intersects(screenRects.get(i))){
         println("PIANO PURPLE");
         if(!soundfiles.get(i).isPlaying()){
           soundfiles.get(i).play();
           println("trigger");
           dmxOutput.set(1,255);
           dmxOutput.set(2,0);
           dmxOutput.set(3,255);
           dmxOutput.set(4,0);
         }
       }
      i += 1;
       if (blob.getRect().intersects(screenRects.get(i))){
         println("TRAP ORANGE");
       if(!soundfiles.get(i).isPlaying()){
           soundfiles.get(i).play();
           println("trigger melody file");
           dmxOutput.set(1,255);
           dmxOutput.set(2,0);
           dmxOutput.set(3,0);
           dmxOutput.set(4,255);
         }
       }
    }
  popStyle(); 
} 
  
void keyPressed() {
  
  // Toggle the CVC debug rendering
  if(key == 'D' || key == 'd') CVC_DEBUG_RENDER = !CVC_DEBUG_RENDER; 
  if(key == 'F' || key == 'f') DEBUG_PLAYHEAD = !DEBUG_PLAYHEAD; 
  if(key == 'C' || key == 'c') cvc.toggleControlPanel();
  
}




/*

  Useful public methods of the cvc.blobs.TrackingBlob class
  
  RectangleF getRect() // bounding box of blob
  float getArea() // of rect
  
  PVector getPos() // location of centroid
  PVector getDecPos() // a normalised position vector 0..1  
  
  int getID()
  
  boolean hasOutlines()
  float[] getOutlines() // array of [x,y,x,y,x,y...] coordinates  
  int getOutlinesCount()  
  
  long getAge(){ // how old in milliseconds this blob is  
  long getStagnation(){ // how long it has been still
  
  float getXSpeed() // X velocity
  float getYSpeed() // the Y velocity
  float getMotionSpeed()
  float getMotionAccel()
   
  boolean isMoving()
    
  int getState() // possible values: TracingBlob.ADDED, TracingBlob.ACCELERATING, TracingBlob.DECELERATING, TracingBlob.STOPPED, TracingBlob.REMOVED

  String getStateString() // small readable version of the state: 
  
*/

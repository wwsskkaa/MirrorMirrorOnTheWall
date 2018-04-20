import de.looksgood.ani.*;
import processing.video.*;
import processing.sound.*;
import gab.opencv.*;
import org.opencv.imgproc.Imgproc;

SoundFile hellofile;
SoundFile correctfile;
SoundFile wrongfile;
SoundFile byefile;
SoundFile yawnfile;
SoundFile backfile;

Ani animation;
AniSequence seq_yes;
AniSequence seq_no;
AniSequence seq_start;

Capture cam;
OpenCV opencv;
// scale factor to downsample frame for processing 
float scale1 = 0.5;

int prevchange=-1;
// image to display
PImage output;

// dominant direction of image calculated by optical flow
PVector direction;

// the interactive drawing visualization
PGraphics viz;
// last point of the drawing
PVector lastPoint;

int cols,rows;
int scale=20;
int w=320;
int h=320;
float z=0;
float r=0;
float prevwf=0.5;
float prevrx=1;
float vectorfly=0;

float[][] land;
boolean makeDrawing = false;
String[] questions={"First of all, Are you excited now?",
  "1.Your mood can change very quickly?",
"2.You love to plan ahead for everything?",
"3.You tend to procrastinate until it is too late?",
"4.Your mind is always buzzing with unexplored ideas?",
"5.You get anxious easily, especially under pressure?",
"RESTART?"};

int red,blue,green,colorchange,yescounter,nocounter,opacityN,opacityY,state,qindex,alpha,prevtime,currenttime;
float rotateXfactor,wavefactor,xflyingoffset,yflyingoffset;
boolean nofill=false;
boolean noise=true;
boolean oned=false;
boolean oned2=false;
boolean stroke=false;
boolean pic=false;
boolean firsttime=true;
boolean randpattern=false;
boolean nomotion=false;



void setup(){
    reset();
    hellofile = new SoundFile(this, "robotstart.wav");
    correctfile=new SoundFile(this, "correct.mp3");
    wrongfile=new SoundFile(this, "wrong.wav");
    byefile=new SoundFile(this, "bye.wav");
    yawnfile=new SoundFile(this, "yawn.mp3");
    backfile=new SoundFile(this, "back.wav");
    PFont font;
    // The font must be located in the sketch's 
    // "data" directory to load successfully
    font = createFont("American Typewriter", 32);
    textFont(font);
    size(1280,640,P3D);
    cols=w/scale;
    rows=h/scale;
    land=new float[cols][rows];

    cam = new Capture(this, int(640 * scale1), int(640 * scale1));
    opencv = new OpenCV(this, cam.width, cam.height);
    cam.start();
    // init to empty image
    output = new PImage(cam.width, cam.height);

    lastPoint = new PVector(width/2, height/2);
    direction = new PVector(0, 0);

    viz = createGraphics(width, height);
    Ani.init(this);
    seq_yes = new AniSequence(this);
    seq_yes.beginSequence();
    seq_yes.add(Ani.to(this,1, "xflyingoffset",250));
    seq_yes.add(Ani.to(this,3, "xflyingoffset",0));
    seq_yes.endSequence();

    seq_no = new AniSequence(this);
    seq_no.beginSequence();
    seq_no.add(Ani.to(this,1, "xflyingoffset",-250));
    seq_no.add(Ani.to(this,3, "xflyingoffset",0));
    seq_no.endSequence();

    seq_start = new AniSequence(this);
    seq_start.beginSequence();
    seq_start.add(Ani.to(this,2, "yflyingoffset",0));
    seq_start.add(Ani.to(this,2, "xflyingoffset",0));
    seq_start.endSequence();

    hellofile.play();
    prevtime=millis();

}

void reset(){
    red=255;
    blue=255;
    green=255;
    rotateXfactor=1;
    wavefactor=0.5;
    nofill=false;
    noise=true;
    oned=false;
    oned2=false;
    stroke=false;
    pic=false;
    firsttime=true;
    colorchange=0;
    yescounter=0;
    nocounter=0;
    xflyingoffset=0;
    yflyingoffset=250;
    opacityN=90;
    opacityY=90;
    vectorfly=0;
    state=0;
    qindex=0;
    nomotion=false;
    alpha=100;
    prevtime=millis();
    randpattern=false;
}

void checkAnswers(int index,boolean answer){
  if(index==0){
    if(answer){
      Ani.to(this,1.5, "wavefactor",1);
      Ani.to(this,1.5, "alpha",250);
    }
    else{
      Ani.to(this,1.5, "wavefactor",0);
    }
  }
  else if(index==1){
    //Your mood can change very quickly?",
    if(answer){
      stroke=false;
      colorchange=3;
      Ani.to(this,1.5, "wavefactor",2);
      prevchange=3;
    }
    else{
      stroke=true;
      colorchange=4;
      Ani.to(this,1.5, "wavefactor",0.5);
      alpha=70;
      prevchange=4;
    }
  }
  else if(index==2){
    //"2.You love to plan ahead for everything?",
    if(answer){
      colorchange=5;
      stroke=true;
      oned=true;
      alpha=50;
    }
    else{
      colorchange=6;
      stroke=false;
      oned=false;
      alpha+=10;
    }
  }
  else if(index==4){
        //"4.Your mind is always buzzing with unexplored ideas?",
    if(answer){
       colorchange=1;
       wavefactor+=0.3;
      //make the color change
    }
    else{
      colorchange=2;
      wavefactor-=0.1;      
      alpha=50;
      nofill=false;
      //179 179 179 grey
    }
  }
  else if(index==3){
        //"3.You tend to procrastinate until it is too late?",
    if(answer){
      nofill=true;
      stroke=true;
      wavefactor-=0.1;
      colorchange=7;
    }
    else{
      stroke=true;
      nofill=false;
      oned2=true;
      oned=false;
      colorchange=8;
    }
  }
  else if(index==5){
    //"5.You get anxious easily, especially under pressure?",
    if(answer){
      noise=false;
      stroke=true;
      //blue=255;
    }
    else{
      noise=false;
      nofill=false;
      alpha=70;
      if(random(-1,1)>0){
        Ani.to(this,1.5, "wavefactor",0.3);
        randpattern=true;
      }
      else{
        Ani.to(this,1.5, "wavefactor",0.3);
        randpattern=false;
      }
      colorchange=9;

      //blue=0;
    }
  }
  else{//ask if wanna restart?
    if(answer){
      backfile.play();
      reset();
    }
    else{
      pic=true;
        //saveFrame("line-######.png");
    }
  
  }
}

void detectYes(){
    checkAnswers(qindex,true);
    if(qindex<6){
    correctfile.play();
    }
    seq_yes.start();
    Ani.to(this,0.5, "vectorfly",280);
    opacityY=200;
    opacityN=90;
    if(qindex<6){
      qindex++;
    }
    yescounter=0;
}

void detectNo(){
  
     checkAnswers(qindex,false);
     if(qindex<5){
        wrongfile.play();
      }
    seq_no.start();    
     Ani.to(this,0.5, "vectorfly",-280);
     opacityN=200;
     opacityY=90;
     if(qindex<6){
      qindex++;
     }
     nocounter=0;
}

void draw_helper(boolean moving){

  strokeWeight(1);
  if(!pic){
    stroke(0,255,128,opacityN);
    fill(0,255,128,opacityN);
    noFill();
    textSize(36);
    text("[NO]",66,305);
    stroke(255,0,128,opacityY);
    fill(255,0,128,opacityY);
    noFill();
    text("[YES]",1205,305);
    textAlign(CENTER);
    fill(255);
    if(firsttime){
        seq_start.start();
        firsttime=false;
    }
    if(!moving){
    text(questions[qindex],640,40);
    }
    else{
        if(qindex==6){
            text(questions[qindex],640,40);
        }
        else{
            textSize(26);
            text("[Please return to center for next question]",640,40);
        }
    }
  }

  /*
    I need to explain this part of my code, you might think it is unnecessary to set rgb,
    but there is not many algorithm that can determine the darkness/hue of color by rgb
    and also, some personaity traits has a certain color in my mind so i don't want to mess it up
  */
  if(colorchange==2){
    int var=int(random(10,240));
    red=var;
    blue=var;
    green=var;
  }
  else if(colorchange==3){
    red=255;
    green=165;
    blue=0;
  }
  else if(colorchange==4){
    red=135;
    green=206;
    blue=235;
  }
  else if(colorchange==5){
    if(prevchange==3){
        red=255;
        green=99;
        blue=71;
        prevchange=35;
    }
    else if(prevchange==4){
        red=70;
        green=130;
        blue=180;
        prevchange=45;
    }
    
  }
  else if(colorchange==6){
    //println("6colorchange: ",colorchange);
    if(prevchange==3){
      red=255;
      green=215;
      blue=0;
      prevchange=36;
    }
    else if(prevchange==4){
      red=176;
      green=224;
      blue=230;
      prevchange=46;
    }  
  }
    else if(colorchange==7){
    if(prevchange==35){
      //rgb(219,112,147)
      red=219;
      green=112;
      blue=147;
    }
    else if(prevchange==45){
      //rgb(139,0,139)
      red=139;
      green=0;
      blue=139;
    }
    else if(prevchange==36){
      //rgb(219,112,147)
      red=219;
      green=112;
      blue=147;
    }
    else if(prevchange==46){
      //rgb(147,112,219)
      red=147;
      green=112;
      blue=219;
    }
  }
  else if(colorchange==8){
    if(prevchange==35){
      //rgb(128,128,0)
      red=128;
      green=128;
      blue=0;
    }
    else if(prevchange==45){
      //rgb(0,139,139)
      red=0;
      green=139;
      blue=139;
    }
    else if(prevchange==36){
      //rgb(173,255,47)
      red=173;
      green=255;
      blue=47;
    }
    else if(prevchange==46){
      //rgb(127,255,212)
      red=127;
      green=255;
      blue=212;
    }
  }
  else if(colorchange==9){
    red=int(random(0,30));
    blue=int(random(100,240));
    green=int(random(0,30));
    
  }
  else if(colorchange==0){
  }
  else{
    red=int(random(10,240));
    blue=int(random(10,240));
    green=int(random(10,240));
  }
   stroke(red,green,blue,alpha);
   if(!stroke){
     noStroke();
   }
      if(!nofill){
        fill(red,green,blue,alpha);
      }
      else{
        noFill();
      }

  float trans_width = width/2+xflyingoffset;
  float trans_height = height/2+yflyingoffset;
  translate(trans_width,trans_height);//want everything to draw in relation to center of the window
  rotateX(rotateXfactor);
  translate(-w/2,-h/2);
  for(int y =0;y<rows-1;y++){
    beginShape(TRIANGLE_STRIP);
    for(int x =0;x<cols;x++){
      vertex(x*scale,y*scale,land[x][y]);
      vertex(x*scale,(y+1)*scale,land[x][y+1]);
    }
    endShape();
  }
}
void nap(){
  nomotion=true;
}
void draw(){
  float zy=z;
  z+=0.05;
  for(int y =0;y<rows;y++){
    float zx=0;
    for(int x =0;x<cols;x++){
      if(noise){
        land[x][y]=map(noise(zx,zy),0,1,-100*wavefactor,100*wavefactor);
      }
      else{
        if(colorchange==9){
          if(!randpattern){
            land[x][y]=random(-100*wavefactor,100*wavefactor);
          }
          else{
            land[x][y]=map(noise(zx,zy),0,1,-100*wavefactor,100*wavefactor);
          }
        }
        else{
          land[x][y]=random(-100*wavefactor,100*wavefactor);
        }
      }
      if(!oned){
        zx+=0.2;
      }
    }
    if(!oned2){
      zy+=0.2;
    }
  }
    
  if (cam.available() == true) {
    cam.read();
    // load frame into pipeline 
    opencv.loadImage(cam);
    // mirror
    opencv.flip(1);
    opencv.calculateOpticalFlow();
    // calculate average direction
    direction = opencv.getAverageFlow();
    // if motion is very small, optical flow might return NaN
    if (Float.isNaN(direction.x) || Float.isNaN(direction.y)) {
      direction = new PVector();
    }

    // grab image for display
    output = opencv.getSnapshot(); 
  }
  
  lights();
  background(0);
  
  if((millis()-prevtime)>15000&&!nomotion){
    yawnfile.play();
    println("no motion!!!");
    prevtime=millis();
    prevwf=wavefactor;
    prevrx=rotateXfactor;
    nap();
  }
  stroke(255, 255, 0, 128);
  strokeWeight(4);
  PVector a = new PVector(width/2, height/2);
  PVector b = PVector.add(a, PVector.mult(direction, 50));
  //float slope=(a.y-b.y)/(a.x-b.x);
  boolean falling=(seq_start.getSeek() < 1.0 && seq_start.isPlaying());
  boolean moving = (seq_yes.getSeek() < 1.0 && seq_yes.isPlaying()) || (seq_no.getSeek() < 1.0 && seq_no.isPlaying())||falling;
  if(nomotion&&!moving&&!falling){
    if(abs(direction.y*10)>15)
    {
      nomotion=false;
      Ani.to(this,3, "yflyingoffset",0);
      Ani.to(this, 1, "wavefactor", prevwf);
      Ani.to(this, 1, "rotateXfactor", prevrx);
      backfile.play();
    }
  }
  
  if (!moving&&!nomotion) {
      if(qindex>0&&!nomotion){
        rotateXfactor+=0.02;
      }
    
  if(direction.x*10>5){
    prevtime=millis();
    nocounter=0;
    yescounter+=1;
    if(yescounter==10){
      detectYes();
    }

  }
  else if(direction.x*10<-5){
    prevtime=millis();
    yescounter=0;
    
    nocounter+=1;
    if(nocounter==10){
       detectNo();
    }
  }

  if(!pic){
    //line(a.x, a.y, b.x, b.y);
  }
}
   if(nomotion){
     Ani.to(this, 1, "wavefactor", 0);
     Ani.to(this, 1, "rotateXfactor", PI/2);
     Ani.to(this, 1, "yflyingoffset", 250);
   }
  
draw_helper(moving);
  if(pic){
    saveFrame("line-######.png");
    pic=false;
    byefile.play();
    delay(1000);
    exit();
  }
}

/*
audio citation:
    yawning: https://freesound.org/people/Danieka/sounds/221519/
    welcome back: https://freesound.org/people/epanody/sounds/97836/
    wrong: https://freesound.org/people/TheBuilder15/sounds/415764/
    correct: https://freesound.org/people/LittleRainySeasons/sounds/335908/
    system start up:https://freesound.org/people/Corsica_S/sounds/83342/
    ani library: http://benedikt-gross.de/libraries/Ani/
*/
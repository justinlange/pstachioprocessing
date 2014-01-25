import gab.opencv.*;
import processing.video.*;
import java.awt.*;
import httprocessing.*;
import rekognition.faces.*;

Capture video;
OpenCV opencv;
PImage frame1;

int stachCount = 7;
int currentStach = 0;
int appFrameCount = 2;
int appState = 0;

PImage[] staches = new PImage[stachCount];
PImage[] appFrame = new PImage[appFrameCount];
PImage instructionsbg;
PImage instructionshand;

float x, targetX;
float easing = 0.05;

int numPixels;
int[] backgroundPixels;

int vidW = 640;
int vidH = 480;

String currentUser;
String typedText = "what is your name?";
String fileName;



boolean recImgDebug = false;
boolean showMatches = false;
boolean getUserInfo = false;

int userInfoCounter = 0;

Timer splashScreen;
Timer handDraw;

Rekognition rekog;
RFace[] faces;
float confidenceThresh = .7;
boolean sureBool = false;


color green = color(22, 89, 20); 
color red = color(135, 46, 21);
PFont aller;
PFont allerbold;

String[] rewardPhrases = {
    "You get a\n05% off today!", 
    "You get a\n10% off today!", 
    "You get a\n20% off today!"
  };


void setup() {
  size(1024, 768);
    setupFonts();


  currentUser = "unknown-user";
  video = new Capture(this, vidW, vidH);
  opencv = new OpenCV(this, vidW, vidH);
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);

  setUpRec();
  loadInstructionsPage();

  frame1 = loadImage("page-frame-flipped.png");

  for (int i=0;i<stachCount;i++) {
    staches[i] = loadImage("0" + (i+1) + ".png");
  }

  for (int i=0;i<appFrameCount; i++) {
    appFrame[i] = loadImage("appFrame" + (i+1) + ".png");
  }

  video.start();
  splashScreen = new Timer(3000);
  handDraw = new Timer(2000);
  loadPixels();
}

void setUpRec() {
  // Load the API keys
  String[] keys = loadStrings("key.txt");
  String api_key = keys[0];
  String api_secret = keys[1];

  // Create the face recognizer object
  rekog = new Rekognition(this, api_key, api_secret);
  rekog.setNamespace("stachio");
  rekog.setUserID("processing");
  println("in setUpRec");
}

void tryFaceRec() {
  println("saving video");
  video.read(); // Read a new video frame
  fileName = "data/" + currentUser + ".jpg";
  video.save(fileName);
  println("rekognizing face");
  faces = rekog.recognize(fileName);
  showMatches = true;
  println("in tryFaceRec");
}


void showMatches() {
  for (int i = 0; i < faces.length; i++) {
    // Possible face matches come back in a FloatDict
    // A string (name of face) is paired with a float from 0 to 1 (how likely is it that face)
    FloatDict matches = faces[i].getMatches();

    if (matches.maxValue() > confidenceThresh) {
      saluteUser(matches.maxKey(), matches.maxValue());
    }
    else {
      showMatches = false;
      getUserInfo = true;
    }
  }
}

void getUserInfo() {
  if (userInfoCounter == 0) text("we don't seem to recognize you! \n  stach to create a new account", 200, 200);
  else if (userInfoCounter == 1)  text("Enter your name: /n" + typedText, 200, 200);
  else if (userInfoCounter == 2)  { 
    text("Is your name " + typedText + "?", 200, 200);
    if(keyPressed && key != ENTER) userInfoCounter--;
  }
  else if (userInfoCounter == 3) {
    userInfoCounter++;
    text("Creating account...", 200, 200);
    trainFace();   
  }else if(userInfoCounter == 4) {
    text("account successfully created!", 200, 200);
  }
}

void trainFace() {
    rekog.addFace(fileName, typedText);
    rekog.train();
}

//--- MAIN PROGRAM LOGIC ---//

void draw() {
  background(255);

  if (appState == 0) {
    instructionsPage();
  }
  else if (appState == 1) {
    mainPage();   
    if (showMatches) showMatches();
    if (getUserInfo) getUserInfo();
  }
  else if (appState == 2) {
  }
}


void captureEvent(Capture c) {
  c.read();
}


void loadInstructionsPage() {
  instructionsbg = loadImage("instructions-bg.png");
  instructionshand = loadImage("instructions-hand.png");
  targetX = width * .2;
}


void instructionsPage() {
  if (handDraw.isTimeUp() == true) {
    if (targetX < width * .8) targetX+= 10;
  } 
  float dx = targetX - x;
  if (abs(dx) > 1) {
    x += dx * easing;
  } 
  image(instructionsbg, 0, 0);
  image(instructionshand, x, height-instructionshand.height);
}


void mainPage() {
  float scaleFactor = 1.6;

  pushMatrix();
  pushMatrix();
  opencv.loadImage(video);

  translate(width, 0);
  scale(-1, 1);
  //scale(1.6);

  image(video, 0, 0, 1024, 768);

  noFill();
  stroke(0, 255, 0);
  strokeWeight(3);
  Rectangle[] faces = opencv.detect();

  popMatrix();

  for (int i = 0; i < faces.length; i++) {
    //println(faces[i].x + "," + faces[i].y);
    pushMatrix();
    translate(width, 0);
    scale(-1, 1);
    //rect(faces[i].x, faces[i].y, faces[i].width, faces[i].height);
    imageMode(CORNER);
    image(staches[currentStach], faces[i].x*scaleFactor, (faces[i].y+(faces[i].height * .3))*scaleFactor, faces[i].width*scaleFactor, faces[i].height*scaleFactor);
    popMatrix();
  }
  imageMode(CORNER);
  popMatrix();
  image(frame1, 0, 0);
}


//--- MOUSE AND KEYBOARD INPUT --//

void keyPressed() {
  
 println("userInfoCounter: " + userInfoCounter + "  appState: " + appState);
  
  switch(key) {
  case 's':  
    currentStach = (currentStach + 1)%stachCount;
    break;
  case 'r':
    tryFaceRec();  
    break;
  case 'p':
    recImgDebug = !recImgDebug;
  }
}

void mousePressed() {
  //appState = 1;
}

void mouseReleased() {
  appState = 1;
}

void mouseMoved() {
}

void keyReleased() {
  if (getUserInfo) {
    if (key != CODED) {
      switch(key) {
      case BACKSPACE:
        typedText = typedText.substring(0, max(0, typedText.length()-1));
        break;
      case TAB:
        typedText += "    ";
        break;
      case ENTER:    userInfoCounter++;
      case RETURN:
        // comment out the following two lines to disable line-breaks
        typedText += "\n";
        break;
      case ESC:
      case DELETE:
        break;
      default:
        typedText += key;
      }
    }
    else if (key == ENTER) {
    }
  }
}


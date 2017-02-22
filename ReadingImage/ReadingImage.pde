//=====================================================================
// Author: Felix Ramirez
// Filename: Reading Image's
// Date Last Modified: 10/30/14
// - This Program will work as a simple image browser that reads five images in a certain size and displays
// Them at 5 images at a time or at a single image at a time.

// How to Navigate Images: You can use the Mouse to click on the images, you can use the keys to go through the images,
// If you are in a large image and want to return to the menu where you see the smaller images you can exit with the "down" key
// Press up to open on the image with the arrow hovering on top.
// Use the '<'key to move shift images to the right
// Use the '>' to shift images to the left....

// =====================================Things Added as Of 10/14/2014========================================
// You can Add Tags To Images Depending on their indices... It will wright to a file and save the contents
// For Adding Purposes and for the Purpose of this Assignment only use Add Button...
// Also There are mouse click sounds and sounds for when you are shifting between images and skipping
// to a new page.. All of the images will be handled through Arrays and  ADT's such as ArrayList. 
// ALSO included Real Time Tag Addition...
// NOTE: TO SEE TAG YOU MUST HAVE AN IMAGE ENLARGED
//======================================================================


//====================================THINGS ADDED AS OF 10/20/14=============================================
// I Have now been able to implement the Special Tag Function For my image browser.... TAGS ON THE IMAGE
// In order to use it you must click on the Special Tag Button... Once it is pressed you will be able to draw a 
// a square. After of which, you can place a tag into that location by typing in the tag box and pressing enter...
// After of which the tag has been added, you can highlight where you set up the box and your tag will apear when and
// and only you are
// hovering over it with the mouse...
// I HAVE ALSO GOTTEN RID OF THE OLD METHOD OF USING TAGS WITH INDICES.. I HAVE NOW ASSOCIATED THE TAGS WITH 
// THE FILE NAME...
//==============================================================================================================

//                     Start Of My Global Variables.

// Importing Sound Stuff for Later Use..
//==================MOUSE CONV STUFF=======
import oscP5.*;
import netP5.*;

OscP5 oscP5;
boolean isMouseDown = false;
int mX = 0, mY = 0;
int leftRight = 0;
int upDown = 0;
int shifted = 0;
//=========================================

import ddf.minim.*;
import controlP5.*;
import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.FileReader;
import java.io.BufferedReader;
// Importing for The WebCam
import processing.video.*;
import blobDetection.*;

// ======Variebles For The Camera======
Capture cam;
BlobDetection theBlobDetection;
PImage blobImg;
boolean newFrame=false;
boolean isCalibrating = true;
Boolean inCal = true;
//======================================

// Tag File Variables....
String theTag = "";
PrintWriter output;
String [] theOldTags; 
ArrayList<String> tagsList;
String fileName = "tags.txt";
ArrayList<Character> usedIndex = new ArrayList<Character>();
String tagToDisplay;
ArrayList<String> tagsToBeAdded = new ArrayList<String>();

Minim minim;
AudioPlayer player;

Minim minim2;
AudioPlayer player2;

Minim minim3;
AudioPlayer player3;

ControlP5 cp5;
ControlP5 cp6;

PImage [] img;  // Declare variable "a" of type PImage

int locations = 0;
// Arrow Stuff
int arrowLocation = 0;
PImage arrow;
int arrowX = 5;
int x = 900;
int goingRight = 0;
int oldArr[] = {
  0, 0, 0, 0, 0
};
int arr [] = 
{
  0, 1, 2, 3, 4
};

// If you are in a big screen
Boolean bigScreen = false;

// Current Arrow Location
int pictureLocation = 0;
int leftMost = 0;
int numOfRightClicks = 0;

// Drawing Scroll or Clicked
Boolean drawBImage = false;
Boolean drawSImage = true;
Boolean offsetChange = false;

// Transition Boolean
Boolean transRight = false;
Boolean transLeft = false;
Boolean transArrowRight = false;
Boolean transArrowLeft = false;

Boolean drawBigSquare = true;
Boolean doneSquare = false;
// Variables for The Webcam 

// Limits, Start Points and offsets.
int start = 0;

//=====================DRAWING UP TAGS VARS================
Boolean drawSquare = false;
int x1 = 0, x2 = 0, y1 = 0, y2 = 0;
int finalX = 0,finalY = 0;
int finalX2 = 0,finalY2 = 0;
ArrayList<SpecialTag> sTag = new ArrayList<SpecialTag>();
String [] oldSTags;
File[] files;

void setup() 
{ 
  oscP5 = new OscP5(this,12000);
  //================START OF THE STUFF=========================
  
  //============================================END OF THE ECLIPSE STUFF...=========================
  // Setting Up The Camera Blob...

  // This Will Set up the Used Tags
  theOldTags = loadStrings("/data/tags.txt");
  
  // READ THE SPECIAL TAGS
  oldSTags = loadStrings("/data/specialTags.txt");
  
  setUpUsedTags();
  ArrayToList();

  // Doing all the cp5 Stuff...
  cp5 = new ControlP5(this);
  cp6 = new ControlP5(this);

  cp5.addTextfield("Enter Your Tag Here")
    .setPosition(20, 0) 
      .setSize(200, 40) 
        .setColor(color(255, 0, 0));

  cp5.addBang("AddTags")
    .setPosition(240, 0)
      .setSize(80, 40)
        .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
          ;

  cp6.addBang("TagImage")
    .setPosition(340, 0)
      .setSize(80, 40)
        .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
          ;


  // Program doing all the old traditional stuff...       
  size(800, 600);
  // The image file must be in the data folder of the current sketch 
  // to load successfully

  String path = sketchPath+"/data/images/"; 
  files = listFiles(path);

  img = new PImage[files.length];

  for (int i = 0; i< files.length; i++)
  {
    String temp = Integer.toString(i);
    img[i] = loadImage(files[i].getAbsolutePath());  // Load the image into the program
    println(files[i].getAbsolutePath());
    img[i].resize(0, 60);
  }
  arrow = loadImage("arrowInt.png");
  arrow.resize(300, 300);
  // Setting up the sound for later use
  minim = new Minim(this);
  player = minim.loadFile("ThunderStruckOriginal.wav");
  
  minim2 = new Minim(this);
  player2 = minim2.loadFile("BetterOffBeat.wav");

  minim3 = new Minim(this);
  player3 = minim3.loadFile("SmallSound.wav");
  noStroke();
}

// Start Of The Draw Method
void draw() 
{ 
  if (inCal)
  {
    inCal = false;
  } else 
  {
    // Loading all of the images....
    background(0); // Sets The Background to Zero to start a clean Slate...
    locations = 0; // "Locations" is reset to evenly distribute Images.
    // ==========THIS IS THE START OF THE PLACE===============
    textSize(24);
   ellipse(mX, mY, 10, 10);
    //========================================================
    
    int temp1 = arr[0];
    int temp2 = arr[1];
    int temp3 = arr[2];
    int temp4 = arr[3];
    int temp5 = arr[4];
        
    int oldTemp1 = oldArr[0];
    int oldTemp2 = oldArr[1];
    int oldTemp3 = oldArr[2];
    int oldTemp4 = oldArr[3];
    int oldTemp5 = oldArr[4];

    //==========================================================================
    //=====================THIS IS THE DRAW BIG IMAGE SCREEN====================
    //==========================================================================

    if (drawSImage)
    {
      cp6.hide();
      int temp = leftMost;
      int increment = 0;

      if (transArrowRight)
      {
        player3.close();
        player3 = minim3.loadFile("SmallSound.wav");
        player2.play();
        if (temp == img.length)
        {
          temp = 0;
        }
        if ( x < 900)
        {
          x+=5;
        }

        translate(-x, 0);
        image(img[oldTemp1], 5, 200, img[oldTemp1].width, img[oldTemp1].height);
        image(img[oldTemp2], 175, 200, img[oldTemp2].width, img[oldTemp2].height);
        image(img[oldTemp3], (175*2), 200, img[oldTemp3].width, img[oldTemp3].height);
        image(img[oldTemp4], (175*3), 200, img[oldTemp4].width, img[oldTemp4].height);
        image(img[oldTemp5], (175*4), 200, img[oldTemp5].width, img[oldTemp5].height);

        image(img[temp1], 905, 200, img[temp1].width, img[temp1].height);
        image(img[temp2], 1080, 200, img[temp2].width, img[temp2].height);
        image(img[temp3], 1255, 200, img[temp3].width, img[temp3].height);
        image(img[temp4], 1430, 200, img[temp4].width, img[temp4].height);
        image(img[temp5], 1605, 200, img[temp5].width, img[temp5].height);

        if (x == 900)
        {
          player2.close();
          player2 = minim2.loadFile("BetterOffBeat.wav");
          transArrowRight = false;
        }

        redraw();
      } else if (transArrowLeft)
      {
        player3.close();
        player3 = minim3.loadFile("SmallSound.wav");
        player2.play();

        if (temp == img.length)
        {
          temp = 0;
        }

        if ( x < 900)
        {
          x+=5;
        }

        translate(x, 0);
        image(img[oldTemp1], locations, 200, img[oldTemp1].width, img[oldTemp1].height);
        image(img[oldTemp2], locations +175, 200, img[oldTemp2].width, img[oldTemp2].height);
        image(img[oldTemp3], locations +(175*2), 200, img[oldTemp3].width, img[oldTemp3].height);
        image(img[oldTemp4], locations + (175*3), 200, img[oldTemp4].width, img[oldTemp4].height);
        image(img[oldTemp5], locations + (175*4), 200, img[oldTemp5].width, img[oldTemp5].height);

        image(img[temp1], locations-900, 200, img[temp1].width, img[temp1].height);
        image(img[temp2], (locations + (175)) - 900, 200, img[temp2].width, img[temp2].height);
        image(img[temp3], (locations + (175*2)) - 900, 200, img[temp3].width, img[temp3].height);
        image(img[temp4], (locations + (175*3)) - 900, 200, img[temp4].width, img[temp4].height);
        image(img[temp5], (locations + (175*4)) - 900, 200, img[temp5].width, img[temp5].height);
        if (x == 900)
        {
          player2.close();
          player2 = minim2.loadFile("BetterOffBeat.wav");
          transArrowLeft = false;
        }
        redraw();
      } else
      {
        image(img[temp1], 5, 200, img[temp1].width, img[temp1].height);
        image(img[temp2], 175, 200, img[temp2].width, img[temp2].height);
        image(img[temp3], (175*2), 200, img[temp3].width, img[temp3].height);
        image(img[temp4], (175*3), 200, img[temp4].width, img[temp4].height);
        image(img[temp5], (175*4), 200, img[temp5].width, img[temp5].height);
      }

      image(arrow, arrowX, 100, arrow.width/5, arrow.height/5);
    } // End Of Drawing Pictures if Not In Webcam Mode...
    
  
  }

  // Start of The Big Image and Tranlations....
  //=============================================================================
  //==========================THIS IS THE BIG IMAGE SCREEN=======================
  //=============================================================================

  if (drawBImage)
  { 
    cp6.show();

    imageMode(CENTER);
    // ========================This Is The Trans Right Section...
    if (transRight)
    {
      player.play();
      if ( x < 900)
      {
        x+=5;
      }
      translate(-x, 0);
      image(img[pictureLocation - 1], 400, 300, img[pictureLocation-1].width*4, img[pictureLocation-1].height*4);
      image(img[pictureLocation], 1300, 300, img[pictureLocation].width*4, img[pictureLocation].height*4);
      if (x == 900)
      {
        transRight = false;
        player.close();
        player = minim.loadFile("ThunderStruckOriginal.wav");
      }
      redraw();
    } // End Of The Trans Right...


    //========================== This is the Trans Left Section....

    else if (transLeft)
    {
      player.play();
      if ( x < 900)
      {
        x+=5;
      }
      translate(x, 0);

      if (pictureLocation +1 == img.length)
      {
        image(img[0], 400, 300, img[0].width*4, img[0].height*4);
      } else
      {
        image(img[pictureLocation+1], 400, 300, img[pictureLocation+1].width*4, img[pictureLocation+1].height*4);
      }

      image(img[pictureLocation], -500, 300, img[pictureLocation].width*4, img[pictureLocation].height*4);
      if (x == 900)
      {
        transLeft = false;
        player.close();
        player = minim.loadFile("ThunderStruckOriginal.wav");
      }
      redraw();
    } // End Of The Trans Left...

    else
    {
    image(img[pictureLocation], 400, 300, img[pictureLocation].width*4, img[pictureLocation].height*4);
    getTag();
    
  for (SpecialTag t : sTag) 
  {
    int iTemp = t.getPicLoc();
    String currentFile = files[pictureLocation].getName();
    String checkFile = t.fName;
    println("currentFile: " + currentFile + "checkFile: " + checkFile);
    //if (pictureLocation == iTemp && (mouseX >= t.getX() - 40 && mouseX <= t.getX() + 40) && (mouseY >= t.getY() - 40 && mouseY <= t.getY() + 40 ) )
    if (t.fName.equalsIgnoreCase(currentFile) && (mouseX >= t.getX() && mouseX <= t.x2) && (mouseY >= t.getY() && mouseY <= t.y2) )
    {
      println(t.getTag() + "  " + t.getX() + "  " + t.getY());
      text(t.getTag(), t.getX() ,t.getY() ); 
    }
  }
      
      text("TAGS: " + tagToDisplay, 360, 500);
    }
    stroke(255);
    if (drawSquare)
    {
      line(x1, y1, x2, y1);
      line(x1, y1, x1, y2);
      line(x2, y1, x2, y2);
      line(x1, y2, x2, y2);
    }
  }

  redraw();
}
// END OF THE DRAW METHOD!!!!!


//=========================================
//   This is the Start of the Mouse Pressed Executions

// End of the Mouse Dragged... Keeps the Square in Place....
void mouseDragged() 
{
  if (drawSquare && drawBImage)
  {
    x2 = mouseX;
    y2 = mouseY;
  finalX = x1;
  finalY = y1;
  finalX2 = x2;
  finalY2 = y2;
  }
}

void mousePressed ()
{
  if (drawSquare && drawBImage)
  {
    x1 = mouseX;
    y1 = mouseY;
    x2 = mouseX;
    y2 = mouseY;
  } else
  {

    player3.play();
    // Certain Location For Mouse Click
    // The first Mouse Image Mouse Click
    if (mouseX <= 140 && mouseY >= 200 && bigScreen == false)
    {
      int temp = arr[0];
      pictureLocation = temp;
      arrowX = 0; 
      bigScreen = true;
      drawSImage = false;
      drawBImage = true;
      redraw();
    }
    // Checks if the index is at zero then reverses it to zero.
    int t = leftMost + 1;
    if (t == img.length)
      start = 0;  
    // The Second Mouse Image Click

    if ( (mouseX >= 175 && mouseX <= 350) &&  mouseY >= 200 && bigScreen == false)
    {
      int temp = arr[1];
      pictureLocation = temp;
      arrowX = 180;  
      bigScreen = true;
      drawSImage = false;
      drawBImage = true;
      redraw();
    }

    // The third Image Click
    if ( (mouseX >= 350 && mouseX <= 525) &&  mouseY >= 200 && bigScreen == false)
    {
      int temp = arr[2];
      pictureLocation = temp;
      arrowX = 355;  
      bigScreen = true;
      drawSImage = false;
      drawBImage = true;
      redraw();
    }

    // The fourth Image Click
    if ( (mouseX >= 525 && mouseX <= 690) &&  mouseY >= 200 && bigScreen == false)
    {
      int temp = arr[3];
      pictureLocation = temp;
      arrowX = 530;  
      bigScreen = true;
      drawSImage = false;
      drawBImage = true;
      redraw();
    }

    // The fifth Image Click
    if ( (mouseX >= 690 && mouseX <= 800) &&  mouseY >= 200 && bigScreen == false)
    {
      int temp = arr[4];
      pictureLocation = temp;
      arrowX = 705;  
      bigScreen = true;
      drawSImage = false;
      drawBImage = true;
      redraw();
    }
  } // End Of The Else Statement. For The Standrard Window Drawing....
}

// To end the Sound of the mouse being released...
void mouseReleased()
{
  player3 = minim3.loadFile("SmallSound.wav");
    if(drawSquare)
    {
   
    }
}
//=====================================================
//     Start of The key Pressed Features

void keyPressed()
{
  if (transRight == false && transLeft == false && transArrowRight == false && transArrowLeft == false)
  { 
    // =========================
    //     Moving the Arrow To The right
    if (keyCode == ' ')
    {
      inCal = false;
    }
    if (keyCode == RIGHT)
    {
      if (drawBImage == false)
      {
        player3.play();
      }
      if ( x == 900 && drawBImage == true)
      {
        x = 0;
        transRight = true;
      }
      pictureLocation++;
      if (pictureLocation == img.length)
      {
        pictureLocation = 0;
      }
      if (pictureLocation >= leftMost + 5 || numOfRightClicks > 4)
      {
        populateOldArray();
        // Creating The New Array....
        leftMost = pictureLocation;
        // arr[0] = pictureLocation;
        arr[0] = leftMost;
        processArray();
        processArray();

        // After Correction is Made....
        leftMost = arr[0];
        pictureLocation = arr[0];
        arrowX = 5;
        numOfRightClicks = 0;
        transArrowRight = true;
        x = 0;
      } else
      {
        arrowX +=175 ;
      }
      numOfRightClicks++;
      player3 = minim3.loadFile("SmallSound.wav");
      redraw();
      //  redraw();
    } // End of the Right Key Pressed

    //==============================


    //===============================
    //   Moving the Arrow To The Left

    if (keyCode == LEFT)
    {
      if (drawBImage == false)
      {
        player3.play();
      }

      if ( x == 900 && drawBImage == true)
      {
        x = 0;
        transLeft = true;
      }

      pictureLocation--;

      if (pictureLocation <  leftMost || pictureLocation == -1)
      {
        if (pictureLocation == -1)
        {
          pictureLocation = img.length - 1;
        }
        leftMost = pictureLocation-4;

        arr[0] = leftMost; 
        populateOldArray(); // This Will Populate Old Array
        // Creating The New Array....
        arr[0] = leftMost; 
        processArray();
        leftMost = arr[0];
        arrowX = 700;
        x = 0;
        transArrowLeft = true;
      } else
      {  
        arrowX -= 175;
      }

      if (numOfRightClicks < 0)
      {
        numOfRightClicks = 0;
      } else
      {
        numOfRightClicks--;
      }
      player3 = minim3.loadFile("SmallSound.wav");
      redraw();
    } //  End of the Left Key Pressed

    //====================================

    //=====================================
    //    Pressing Enter to Enter The "Bigger Picture"

    if (keyCode == UP && bigScreen == false)
    {
      bigScreen = true;
      drawSImage = false;
      drawBImage = true;
      redraw();
    } 
    // End of The Small Screen To Big Screen Picture!!!

    //===================================

    //===================================
    // Pressing and And Exiting the "Bigger" Picture....

    if (keyCode == DOWN && bigScreen == true)
    {
      bigScreen = false;
      drawSImage = true;
      drawBImage = false;
      redraw();
    }

    if (key == '<')
    {
      int temp = leftMost;

      leftMost -=5;
      // Populate Old Coordinate Into Array...
      populateOldArray();
      // Populate New Coordinates into Array...
      arr[0] = leftMost;
      processArray();
      pictureLocation = arr[0];
      leftMost = arr[0];
      arrowX = 5;
      x = 0;
      transArrowLeft = true;
      redraw();
    }
    // End Of Greater

    // end of if


    // Trying to skip a few 5 Pictures Ahead....
    if (key == '>')
    {
      int temp = leftMost;
      populateOldArray();
      leftMost +=5;
      processArray();
      pictureLocation = arr[0];
      leftMost = arr[0];
      arrowX = 5;
      transArrowRight = true;
      x = 0;
      redraw();
    }
    // End Of Less.. To Go more Ahead
  }
  //==================================
} // END OF THE CODE

File[] listFiles (String d)
{
  File file = new File(d);
  if (file.isDirectory())
  {
    File[] files = file.listFiles();
    return files;
  } else
  {
    println("Not In Directory");
  }

  return null;
}

void processArray()
{
  arr[0] = leftMost;
  for (int i = 0; i < arr.length; i++)
  {
    if (arr[i] == -1)
    {
      arr[i] = img.length-1;
    }
    if (arr[i] == -2)
    {
      arr[i] = img.length-2;
    } 
    if (arr[i] == -3)
    {
      arr[i] = img.length-3;
    }  
    if (arr[i] == -4)
    {
      arr[i] = img.length-4;
    } else if (arr[i] == -5)
    {
      arr[i] = img.length-5;
    }  
    if (arr[i] == -6)
    {
      arr[i] = img.length - 6;
    } 
    if (arr[i] == img.length)
    {
      arr[i] = 0;
    } 

    if (arr[i] == img.length + 1)
    {
      arr[i] = 1;
    }

    if (arr[i] == img.length + 2)
    {
      arr[i] = 2;
    }  

    if (arr[i] == img.length + 3)
    {
      arr[i] = 3;
    }  
    if (arr[i] == img.length + 4)
    {
      arr[i] = 4;
    }  
    if (arr[i] == img.length + 5)
    {
      arr[i] = 5;
    }
    if (arr[i] == img.length + 6)
    {
      arr[i] = 6;
    } else
    {
      if (i > 0)
      {
        arr[i] = arr[i-1] + 1;
        if (arr[i] ==img.length)
        {
          arr[i] = 0;
        }
      }
    }
  }
} // End Of ProcessArray

void populateOldArray ()
{
  for (int i = 0; i < arr.length; i++)
  {
    oldArr[i] = arr[i];
  }
}

//===============================================================================================
// =====================================TAG STUFF STARTS HERE====================================
void readCurrentTags()
{
  for (int i = 0; i < theOldTags.length; i++)
    println(theOldTags[i]);
}

void appenedTextToFile (String filename, String text)
{
  File f = new File(dataPath(fileName));
  Boolean flag = checkIfTagIsThere();
  if (flag)
  {
    try 
    {
      PrintWriter out = new PrintWriter(new BufferedWriter(new FileWriter(f)));
      for (String t : tagsList) 
      {
        out.println(t);
      }  
      out.println(files[pictureLocation].getName() + " " + text);
      tagsList.add(files[pictureLocation].getName() + " " + text);
      char c = (char) pictureLocation;
      usedIndex.add(c);
      out.close();
    }
    catch(IOException e) 
    {
      println("?????");
    }
  } else
  { 
    appenedFile(filename, text);
    char c = (char) pictureLocation;
    usedIndex.add(c);
  }
}

void appenedFile(String filename, String text)
{

  File f = new File(dataPath(fileName));
  // creates a New File if it does not exist.
  if (!f.exists())
  {
    createFile(f);
  }
  try
  {
    PrintWriter out = new PrintWriter(new BufferedWriter(new FileWriter(f, true)));
    out.println(text);
    out.close();
    // Adding To Tag List...
    tagsList.add(text);
  }
  catch(IOException e)
  {
    e.printStackTrace();
  }
}

// END OF THE APPENED TO TEXT FILE


// Creates a File
void createFile(File f)
{
  File parentDir = f.getParentFile();
  try
  {
    parentDir.mkdirs();
    f.createNewFile();
  }
  catch(Exception e)
  {
    e.printStackTrace();
  }
}
// End of the createFile Function...

// Checks if a Tag is Present for Rewriting...Returns True or False
Boolean checkIfTagIsThere ()
{
  for (int i = 0; i < usedIndex.size (); i++)
  {
    char t = usedIndex.get(i);
    int tempInt = Character.getNumericValue(t);
    if (pictureLocation == tempInt)
    {
      tagsList.remove(i);
      return true;
    }
  }
  return false;
}
// Checks if the Tag is there Then returns true.. Else returns false...

// This will set The arrayList with all the used up tags...
void setUpUsedTags ()
{
  BufferedReader reader = createReader("/data/tags.txt");
  String line = null;
  try
  {
    while ( (line = reader.readLine ()) != null) 
    {
      usedIndex.add(line.charAt(1));
    }
  }
  catch(IOException e)
  {
  }
}
// End if The tag Still exists...

// Converting an Array To A More Flexible Structure...ArrayList

//=========================LOOK AT THE JUICY STUFF=======================

void ArrayToList()
{
  tagsList = new ArrayList<String>();
  for (int i = 0; i < theOldTags.length; i++)
  {
    String[] splited = theOldTags[i].split("\\s+");
    String fName = splited[0];
    String tag="";
    for(int j = 1; j < splited.length; j++)
    {
    tag += splited[j] + " ";
    }
    tagsList.add(fName + " " + tag);
  }
  // SPLIT THE STRINGS TOMORROW....
  for (int i = 0; i < oldSTags.length; i++)
  {
  String pattern = "a-z0-9.";
    
  String[] splited = oldSTags[i].split("\\s+");
  SpecialTag tempSTag = new SpecialTag();
  
  String picLoc = splited[0].replaceAll(pattern,"");
 // int pLoc = Integer.parseInt(picLoc);
  tempSTag.fName = picLoc;
  
  String xCoor = splited[1].replaceAll("\\D+","");
  int xC = Integer.parseInt(xCoor);
  tempSTag.setX(xC);
  
  String yCoor = splited[2].replaceAll("\\D+","");
  int yC = Integer.parseInt(yCoor);
  tempSTag.setY(yC);
  
  String x2Coor = splited[3].replaceAll("\\D+","");
  int x2C = Integer.parseInt(x2Coor);
  tempSTag.x2 = x2C;
  
  String y2Coor = splited[4].replaceAll("\\D+","");
  int y2C = Integer.parseInt(y2Coor);
  tempSTag.y2 = y2C;
  
  
  
  String tempTag = "";
  
  for(int j = 5; j < splited.length; j++)
  {
  tempTag += splited[j] + " "; 
  }
  tempSTag.setTag(tempTag);
  sTag.add(tempSTag);
  }
}

// The event that happens when the Add button is pressed....

// The event for when the Rewrite button is pressed....

public void AddTags()
{
  cp5.get(Textfield.class, "Enter Your Tag Here").clear();
  for (String t : tagsToBeAdded)
  {
    appenedTextToFile(fileName, t);
  }
}

// THIS IS AFTER PRESSING ENTER
void controlEvent(ControlEvent theEvent)
{
  if (drawSquare)
  {
    if (theEvent.isAssignableFrom(Textfield.class))
    {
      SpecialTag tempClass = new SpecialTag();
      theTag = theEvent.getStringValue();
      
      tempClass.setTag(theTag);
      tempClass.setX(finalX);
      tempClass.setY(finalY);
      tempClass.x2 = finalX2;
      tempClass.y2 = finalY2;
      tempClass.setPicLoc(pictureLocation);
      tempClass.fName = files[pictureLocation].getName();
      tempClass.addToFile();
      sTag.add(tempClass);
      drawSquare = false;
    }
    
  } else
  {
    if (theEvent.isAssignableFrom(Textfield.class))
    {
      theTag = theEvent.getStringValue();
      tagsToBeAdded.add(files[pictureLocation].getName() + " " + theTag);
    }
  }
}


// gets The Tag for The user to use...
void getTag()
{
  int i = 0;
  tagToDisplay = "";
  String temp = "";
  for (String t : tagsList) 
  {
    String[] splited = t.split("\\s+");
    String currentFile = files[pictureLocation].getName();
    
    //int iTemp = Character.getNumericValue(cTemp);
    if (splited[0].equalsIgnoreCase(currentFile))
    {
      for(int j = 1; j < splited.length; j++)
      {
      temp += splited[j] + " "; 
      }
      tagToDisplay = temp;
    }
  }
}

public void TagImage()
{
  drawSquare = true;
}

void oscEvent(OscMessage theOscMessage) {

  if (theOscMessage.checkAddrPattern("/mouseDown")==true) 
  {
  if (drawSquare && drawBImage)
  {
    x1 = mX;
    y1 = mY;
    x2 = mX;
    y2 = mY;
  } else
  {

    player3.play();
    // Certain Location For Mouse Click
    // The first Mouse Image Mouse Click
    if (mX <= 140 && mY >= 200 && bigScreen == false)
    {
      int temp = arr[0];
      pictureLocation = temp;
      arrowX = 0; 
      bigScreen = true;
      drawSImage = false;
      drawBImage = true;
      redraw();
    }
    // Checks if the index is at zero then reverses it to zero.
    int t = leftMost + 1;
    if (t == img.length)
      start = 0;  
    // The Second Mouse Image Click

    if ( (mX >= 175 && mX <= 350) &&  mY >= 200 && bigScreen == false)
    {
      int temp = arr[1];
      pictureLocation = temp;
      arrowX = 180;  
      bigScreen = true;
      drawSImage = false;
      drawBImage = true;
      redraw();
    }

    // The third Image Click
    if ( (mX >= 350 && mX <= 525) &&  mY >= 200 && bigScreen == false)
    {
      int temp = arr[2];
      pictureLocation = temp;
      arrowX = 355;  
      bigScreen = true;
      drawSImage = false;
      drawBImage = true;
      redraw();
    }

    // The fourth Image Click
    if ( (mX >= 525 && mX <= 690) &&  mY >= 200 && bigScreen == false)
    {
      int temp = arr[3];
      pictureLocation = temp;
      arrowX = 530;  
      bigScreen = true;
      drawSImage = false;
      drawBImage = true;
      redraw();
    }

    // The fifth Image Click
    if ( (mX >= 690 && mX <= 800) &&  mY >= 200 && bigScreen == false)
    {
      int temp = arr[4];
      pictureLocation = temp;
      arrowX = 705;  
      bigScreen = true;
      drawSImage = false;
      drawBImage = true;
      redraw();
    }
  } // End Of The Else Statement. For The Standrard Window Drawing....
    
  }
  
  // ======= END OF CLICK ON DOWN....=======
  if (theOscMessage.checkAddrPattern("/mouseUp")==true) 
  {
    isMouseDown = false;
  }
  if (theOscMessage.checkAddrPattern("/mouseMoved")==true) 
  {
    int firstInt = theOscMessage.get(0).intValue();
    int secondInt = theOscMessage.get(1).intValue();
    mX = firstInt;
    mY = secondInt;
  }
  
  // ===================RIGHT KEY FROM SENDER================
  if (theOscMessage.checkAddrPattern("/right")==true) 
  {
    if (drawBImage == false)
      {
        player3.play();
      }
      if ( x == 900 && drawBImage == true)
      {
        x = 0;
        transRight = true;
      }
      pictureLocation++;
      if (pictureLocation == img.length)
      {
        pictureLocation = 0;
      }
      if (pictureLocation >= leftMost + 5 || numOfRightClicks > 4)
      {
        populateOldArray();
        // Creating The New Array....
        leftMost = pictureLocation;
        // arr[0] = pictureLocation;
        arr[0] = leftMost;
        processArray();
        processArray();

        // After Correction is Made....
        leftMost = arr[0];
        pictureLocation = arr[0];
        arrowX = 5;
        numOfRightClicks = 0;
        transArrowRight = true;
        x = 0;
     }else
     {
        arrowX +=175 ;
     }
      numOfRightClicks++;
      player3 = minim3.loadFile("SmallSound.wav");
      redraw();
  }
  
  // ====================START OF THE LEFT KEY PRESSED============
  if (theOscMessage.checkAddrPattern("/left")==true) 
  {
    if (drawBImage == false)
      {
        player3.play();
      }

      if ( x == 900 && drawBImage == true)
      {
        x = 0;
        transLeft = true;
      }

      pictureLocation--;

      if (pictureLocation <  leftMost || pictureLocation == -1)
      {
        if (pictureLocation == -1)
        {
          pictureLocation = img.length - 1;
        }
        leftMost = pictureLocation-4;

        arr[0] = leftMost; 
        populateOldArray(); // This Will Populate Old Array
        // Creating The New Array....
        arr[0] = leftMost; 
        processArray();
        leftMost = arr[0];
        arrowX = 700;
        x = 0;
        transArrowLeft = true;
      } else
      {  
        arrowX -= 175;
      }

      if (numOfRightClicks < 0)
      {
        numOfRightClicks = 0;
      } else
      {
        numOfRightClicks--;
      }
      player3 = minim3.loadFile("SmallSound.wav");
      redraw();
  }
  // ===================THE END OF THE LEFT=========================
  
  
  if (theOscMessage.checkAddrPattern("/up")==true && bigScreen == false) 
  {
      bigScreen = true;
      drawSImage = false;
      drawBImage = true;
      redraw();
  }
  
  
  if (theOscMessage.checkAddrPattern("/down")==true && bigScreen == true)
  {
      bigScreen = false;
      drawSImage = true;
      drawBImage = false;
      redraw();
  }
  
  //==========START OF THE SHIFT RIGHT================
  if (theOscMessage.checkAddrPattern("/sRight")==true) 
  {
      int temp = leftMost;
      populateOldArray();
      leftMost +=5;
      processArray();
      pictureLocation = arr[0];
      leftMost = arr[0];
      arrowX = 5;
      transArrowRight = true;
      x = 0;
      redraw();
  }
  
  //============END OF THE SHIFT RIGHT
  
  //==========START OF THE SHIFT LEFT==============
  if (theOscMessage.checkAddrPattern("/sLeft")==true) 
  {
     int temp = leftMost;

      leftMost -=5;
      // Populate Old Coordinate Into Array...
      populateOldArray();
      // Populate New Coordinates into Array...
      arr[0] = leftMost;
      processArray();
      pictureLocation = arr[0];
      leftMost = arr[0];
      arrowX = 5;
      x = 0;
      transArrowLeft = true;
      redraw();
  } 
  //============END OF THE SHIFT LEFT RECIEVER=======
}


// END OF IMAGE BROWSWER
// BY FELIX RAMIREZ
// TOTAL LINE COUNT "1360" As of 10/30/14 at 12:38AM

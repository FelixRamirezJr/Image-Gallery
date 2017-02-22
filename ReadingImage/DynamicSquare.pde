class SpecialTag
{
int x;
int y;
int x2;
int y2;
String tag;
String fileName = "specialTags.txt";
String fName = "";
int pictureLocation = 0;

SpecialTag(){x = 0; y = 0;}

int getX (){return x;}
int getY (){ return y;}
int getPicLoc(){return pictureLocation;}
void setX(int a){x = a;}
void setY(int a){y = a;}
void setTag(String a){ tag = a;}
void setPicLoc(int a){pictureLocation = a;}
String getTag(){return tag;}

void addToFile ()
{
   appenedTextToFile();
}

void appenedTextToFile()
{
    File f = new File(dataPath(fileName));
    appenedFile();
   // char c = (char) pictureLocation;
    //usedIndex.add(c);
}

void appenedFile()
{
  
  File f = new File(dataPath(fileName));
  if (!f.exists())
  {
    createFile(f);
  }
  try
  {
    PrintWriter out = new PrintWriter(new BufferedWriter(new FileWriter(f, true)));
    out.println(fName + " " + "[" + x + "]" +" " + "[" + y + "]" + " " + "[" + x2 + "]"+ " " + "[" + y2 + "]"+   " " + tag);
    out.close();
  }
  catch(IOException e)
  {
    e.printStackTrace();
  }
  
}
}

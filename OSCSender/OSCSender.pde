// simple OSC sender
 
import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;

void setup() {
  size(400,300);
  frameRate(25);
  /* start oscP5, listening for incoming messages at port 12001 */
  oscP5 = new OscP5(this, 12001);
  /* myRemoteLocation is a NetAddress. a NetAddress takes 2 parameters,
   * an ip address and a port number. myRemoteLocation is used as parameter in
   * oscP5.send() when sending osc packets to another computer, device, 
   * application. usage see below. for testing purposes the listening port
   * and the port of the remote location address are the same, hence you will
   * send messages back to this sketch.
   */
  myRemoteLocation = new NetAddress("127.0.0.1",12000);
}


void draw() {
  background(0);  
}

void mousePressed() {
  // make new message "/mouseDown"
  OscMessage myMessage = new OscMessage("/mouseDown");
  
  /* send the message */
  oscP5.send(myMessage, myRemoteLocation); 

}

void mouseReleased() 
{
  OscMessage myMessage = new OscMessage("/mouseUp");
  oscP5.send(myMessage, myRemoteLocation); 
}

void mouseMoved() {
  OscMessage myMessage = new OscMessage("/mouseMoved");
  myMessage.add(2*mouseX);
  myMessage.add(2*mouseY);
  oscP5.send(myMessage, myRemoteLocation); 
}

void keyPressed()
{
  if(keyCode == RIGHT){
    OscMessage myMessage = new OscMessage("/right");
    oscP5.send(myMessage, myRemoteLocation);
  }
  if(keyCode == LEFT){
    OscMessage myMessage = new OscMessage("/left");
    oscP5.send(myMessage, myRemoteLocation);
  }
if(keyCode == UP){
    OscMessage myMessage = new OscMessage("/up");
    oscP5.send(myMessage, myRemoteLocation);
  }
  if(keyCode == DOWN){
    OscMessage myMessage = new OscMessage("/down");
    oscP5.send(myMessage, myRemoteLocation);
  }
  if(key == '>'){
    OscMessage myMessage = new OscMessage("/sRight");
    oscP5.send(myMessage, myRemoteLocation);
  }
  if(key == '<'){
    OscMessage myMessage = new OscMessage("/sLeft");
    oscP5.send(myMessage, myRemoteLocation);
  } 
   
}
  

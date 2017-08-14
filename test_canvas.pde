import cc.arduino.*;
import org.firmata.*;
import netP5.*;
import oscP5.*;
/**
 * <p>Ketai Library for Android: http://ketai.org</p>
 *
 * <p>KetaiBluetooth wraps the Android Bluetooth RFCOMM Features:
 * <ul>
 * <li>Enables Bluetooth for sketch through android</li>
 * <li>Provides list of available Devices</li>
 * <li>Enables Discovery</li>
 * <li>Allows writing data to device</li>
 * </ul>
 * <p>Updated: 2012-05-18 Daniel Sauter/j.duran</p>
 */

//required for BT enabling on startup
import android.content.Intent;
import android.os.Bundle;

import ketai.net.bluetooth.*;
import ketai.ui.*;
import ketai.net.*;

import oscP5.*;

KetaiBluetooth bt;
String info = "";
KetaiList klist;
PVector remoteMouse = new PVector();

ArrayList<String> devicesDiscovered = new ArrayList();
boolean isConfiguring = true;
String UIText;
boolean isPressed = false;
float x1, x2, y1, y2, angle, distance;
byte angle_byte, distance_byte;
byte[] data= new byte[4];

//********************************************************************
// The following code is required to enable bluetooth at startup.
//********************************************************************
void onCreate(Bundle savedInstanceState) {
  super.onCreate(savedInstanceState);
  bt = new KetaiBluetooth(this);
}

void onActivityResult(int requestCode, int resultCode, Intent data) {
  bt.onActivityResult(requestCode, resultCode, data);
}

//********************************************************************

void setup()
{   
  orientation(PORTRAIT);
  background(78, 93, 75);
  stroke(255);
  textSize(24);
size(displayWidth, displayHeight);
  //start listening for BT connections
  bt.start();
  background(0);

  UIText =  "d - discover devices\n" +
    "b - make this device discoverable\n" +
    "c - connect to device\n     from discovered list.\n" +
    "p - list paired devices\n" +
    "i - Bluetooth info";
    
}

void draw()
{
  if (isConfiguring)
  {
    ArrayList<String> names;
    background(78, 93, 75);

    //based on last key pressed lets display
    //  appropriately
    byte[] left = {'l', 'e', 'f', 't', '\r'};
    byte[] right = {'r', 'i', 'g', 'h', 't', '\r'};
    byte[] up = {'u', 'p', '\r'};
    byte[] down = {'d', 'o', 'w', 'n', '\r'};
    byte[] stop = {'s', 't', 'o', 'p', '\r'};
    if(key == 'L'){
      bt.broadcast(left);
    }
    if(key == 'R'){
      bt.broadcast(right);
    }
    if(key == 'U'){
      bt.broadcast(up);
    }
    if(key == 'D'){
      bt.broadcast(down);
    }
    if(key == 'S'){
      bt.broadcast(stop);
    }
    if (key == 'i')
      info = getBluetoothInformation();
    else
    {
      if (key == 'p')
      {
        info = "Paired Devices:\n";
        names = bt.getPairedDeviceNames();
      }
      
      else
      {
        info = "Discovered Devices:\n";
        names = bt.getDiscoveredDeviceNames();
      }

      for (int i=0; i < names.size(); i++)
      {
        info += "["+i+"] "+names.get(i).toString() + "\n";
      }
    }
    text(UIText + "\n\n" + info, 5, 90);
  }
  else
  {
    //background(0);
    if(mousePressed&&(mouseY>50 &&mouseY <(displayHeight-50))){
    pushStyle();
    if(isPressed == false){
      isPressed =true;
      x1 = mouseX;
      y1 = mouseY;
    }
    fill(255);
    ellipse(mouseX, mouseY, 20, 20);
    popStyle();
  
    }
  }
  drawUI();
}


void mouseReleased(){
x2= mouseX;
y2= mouseY;
}

//Call back method to manage data received
void onBluetoothDataEvent(String who, byte[] data)
{
  if (isConfiguring)
    return;

  //KetaiOSCMessage is the same as OscMessage
  //   but allows construction by byte array
  KetaiOSCMessage m = new KetaiOSCMessage(data);
  if (m.isValid())
  {
    if (m.checkAddrPattern("/remoteMouse/"))
    {
      if (m.checkTypetag("ii"))
      {
        remoteMouse.x = m.get(0).intValue();
        remoteMouse.y = m.get(1).intValue();
      }
    }
  }
}

String getBluetoothInformation()
{
  String btInfo = "Server Running: ";
  btInfo += bt.isStarted() + "\n";
  btInfo += "Discovering: " + bt.isDiscovering() + "\n";
  btInfo += "Device Discoverable: "+bt.isDiscoverable() + "\n";
  btInfo += "\nConnected Devices: \n";

  ArrayList<String> devices = bt.getConnectedDeviceNames();
  for (String device: devices)
  {
    btInfo+= device+"\n";
  }

  return btInfo;
}



//uui


/*  UI-related functions */


void mousePressed()
{
  //keyboard button -- toggle virtual keyboard
  if (mouseY <= 50 && mouseX > 0 && mouseX < width/3)
    KetaiKeyboard.toggle(this);
  else if (mouseY <= 50 && mouseX > width/3 && mouseX < 2*(width/3)) //config button
  {
    isConfiguring=true;
  }
  else if (mouseY <= 50 && mouseX >  2*(width/3) && mouseX < width) // draw button
  {
    if (isConfiguring)
    {
      //if we're entering draw mode then clear canvas
    background(78, 93, 75);
    isConfiguring=false;
    }
  }
  
    else if((mouseX>0)&&(mouseX<displayWidth/2) &&(mouseY>displayHeight-50)){
    background(0);
    isPressed =false;
    }
    
    else if((mouseX>displayWidth/2)&&(mouseX<(displayWidth)) &&(mouseY>displayHeight-50)){
      isConfiguring=true;
    angle = (y2-y1)/(x2-x1);
    
    distance = sqrt(pow(x1-x2,2)+pow(y1-y2,2));
  if(distance >9){
    distance = distance%9;
  }
  angle_byte = byte(atan(angle)*(180/PI));
  data[2]=byte(angle_byte%10);
  data[1]=byte(angle_byte/10);
  data[0]=byte(angle_byte/100);
  data[3]=byte(distance);
  bt.broadcast(data);
    }
  }

void mouseDragged()
{
  if (isConfiguring)
    return;

  //send data to everyone
  //  we could send to a specific device through
  //   the writeToDevice(String _devName, byte[] data)
  //  method.
  OscMessage m = new OscMessage("/remoteMouse/");
  m.add(mouseX);
  m.add(mouseY);

  bt.broadcast(m.getBytes());
  ellipse(mouseX, mouseY, 20, 20);
}

public void keyPressed() {
  if (key =='c')
  {
    //If we have not discovered any devices, try prior paired devices
    if (bt.getDiscoveredDeviceNames().size() > 0)
      klist = new KetaiList(this, bt.getDiscoveredDeviceNames());
    else if (bt.getPairedDeviceNames().size() > 0)
      klist = new KetaiList(this, bt.getPairedDeviceNames());
  }
  else if (key == 'd')
  {
    bt.discoverDevices();
  }
  else if (key == 'x')
    bt.stop();
  else if (key == 'b')
  {
    bt.makeDiscoverable();
  }
  else if (key == 's')
  {
    bt.start();
  }
}


void drawUI()
{
  //Draw top shelf UI buttons

  pushStyle();
  fill(0);
  stroke(255);
  rect(0, 0, width/3, 50);

  if (isConfiguring)
  {
    noStroke();
    fill(78, 93, 75);
  }
  else
    fill(0);

  rect(width/3, 0, width/3, 50);

  if (!isConfiguring)
  {  
    noStroke();
    fill(78, 93, 75);
  }
  else
  {
    fill(0);
    stroke(255);
  }
  rect((width/3)*2, 0, width/3, 50);
  stroke(255);
rect(0,displayHeight-50, displayWidth/2, 50);
rect(displayWidth/2,displayHeight-50, displayWidth/2, 50);

  fill(255);
  text("Keyboard", 5, 30); 
  text("Bluetooth", width/3+5, 30); 
  text("Interact", width/3*2+5, 30); 
text("Reset", 20, displayHeight-20);
text("Send",displayWidth/2 + 20, displayHeight-20);
  popStyle();
}

void onKetaiListSelection(KetaiList klist)
{
  String selection = klist.getSelection();
  bt.connectToDeviceByName(selection);

  //dispose of list for now
  klist = null;
}
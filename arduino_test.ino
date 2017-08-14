#include <SoftwareSerial.h>

/* ----------
Arduino Code:
-------------
This example flashes the LED on pin 13
when receive from Bluetooth (serial)
The BT-Module is connected to Pin 0 and 1 like the serial interface
*/
SoftwareSerial mySerial(2, 3); // RX, TX

char chByte = 0;  // incoming serial byte
String strInput = "";    // buffer for incoming packet
String strLeft = "left";
String strRight = "right";
String strUp = "up";
String strDown = "down";
String strStop ="stop";

// the setup routine runs once when you press reset:
void setup() {
 // declare pin 9 to be an output:
 pinMode(8, OUTPUT);
 pinMode(9, OUTPUT);
 pinMode(10, OUTPUT);
 pinMode(11, OUTPUT);
 // initialize serial:
 mySerial.begin(9600);
 Serial.begin(9600);
}

// the loop routine runs over and over again forever:
void loop() {

 while (mySerial.available() > 0)
 {
  // get incoming byte:
  chByte = mySerial.read();
  
  if (chByte == '\r')
  {
   //compare input message
   if(strInput.equals(strLeft))
   {
    motor('L');
    Serial.println(strInput);
     }

     if(strInput.equals(strRight))
   {
    motor('R');
    Serial.println(strInput);
     }

     if(strInput.equals(strUp))
   {
    Serial.println(strInput);
    motor('U');
     }

     if(strInput.equals(strDown))
   {
    Serial.println(strInput);
    motor('D');
     }
     if(strInput.equals(strStop))
   {
    Serial.println(strInput);
    motor('S');
     }
   //reset strInput
   strInput = "";
  }
  else
  {
  strInput += chByte;
  }
 }
}


void motor(char input){
  switch(input){
    case 'U':
      digitalWrite(8,HIGH);
      digitalWrite(9,LOW);
      digitalWrite(10,HIGH);
      digitalWrite(11,LOW);
      break;

     case 'D':
      digitalWrite(8,LOW);
      digitalWrite(9,HIGH);
      digitalWrite(10,LOW);
      digitalWrite(11,HIGH);
      break;

     case 'L':
      digitalWrite(8,HIGH);
      digitalWrite(9,LOW);
      digitalWrite(10,LOW);
      digitalWrite(11,HIGH);
      break;

     case 'R':
      digitalWrite(8,LOW);
      digitalWrite(9,HIGH);
      digitalWrite(10,HIGH);
      digitalWrite(11,LOW);
      break;

     case 'S':
      digitalWrite(8,LOW);
      digitalWrite(9,LOW);
      digitalWrite(10,LOW);
      digitalWrite(11,LOW);
      break;
  }
}

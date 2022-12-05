// -*- Mode:c -*-
// The above incantation tells emacs to do C style syntax highlighting

/* Use a photodiode to to record visual onsets and an FSR to record responses.

  Connect one end of Photodiode to 5V, the other end to Analog 0.
  Then connect one end of a 470Ohm resistor from Analog 0 to ground.

  Connect one end of FSR to 5V, the other end to Analog 5.
  Then connect one end of a 10kOhm resistor from Analog 0 to ground.
  For more information see http://www.ladyada.net/learn/sensors/fsr.html

  For other sensors, please refer to the manufacturer's datasheet.

*/

/////////////////  PRESET VARIABLES
const int photoAnalogPin = 0; // FSR is connected to analog 0
const int fsrAnalogPin = 5; // FSR is connected to analog 0
int photoReading;      // the analog reading from the photodiode resistor divider
int fsrReading;      // the analog reading from the FSR resistor divider
int prevphoto = 1023;
int prevfsr = 1023;
unsigned long timeStamp = 0; // timestamp for Arduino
unsigned long prevt = -1; // the previous time value to ensure sample rate of 1000Hz

///////////////// LOAD LIBRARIES  /////////////////
#include <avr/pgmspace.h>

///////////////// SETUP  /////////////////
void setup() {
  //Serial.begin(9600); // slow speed debugging
  Serial.begin(115200); // high speed  
}

///////////////// LOOP  /////////////////
void loop(void) {
  getInfos(); // read info
  collectData(); // send info
}

///////////////// FUNCTIONS  /////////////////
// Send data to serial port
void collectData() {

  if (prevt == -1 | timeStamp != prevt) {
    // only send if the time has changed, that is,
    // force the data transfer to maximum of 1000Hz.
    // Using higher sample rates can result in buffer
    // overflows and missed packets(!)

    // Send data to the serial port (for degugging in Arduino serial manager)
    //Serial.print("Time = ");
    //Serial.print(timeStamp);
    //Serial.print(",Photodiode = ");
    //Serial.print(photoReading);
    //Serial.print(",FSR = ");
    //Serial.print(fsrReading);
    //Serial.print("\n");

    // If new information...
    if (prevphoto != photoReading | prevfsr != fsrReading) {
    // Send data to the serial port
    Serial.print("B"); // signal packet start (hardcoded)
      sendBinary(timeStamp); // send time
      sendBinary(photoReading); // send photodiode reading
      sendBinary(fsrReading); // send FSR reading
      Serial.print("E"); // signal packet end (hardcoded)
      prevt = timeStamp; // send previous time marker
    }
  }
}

// get FSR and photodiode reading, and timing info
void getInfos() {
  fsrReading = analogRead(fsrAnalogPin); // read fsr
  photoReading = abs(analogRead(photoAnalogPin)-512)*2; // read photodiode
  timeStamp = millis(); // get time (in milliseconds)
}

// Send data in binary to increase speed and reduce buffer overflow
void sendBinary(int value)
// Send a binary value directly (without conversion to string)
// based on http://my.safaribooksonline.com/book/hobbies/9781449399368/serial-communications/sending_binary_data_from_arduino#X2ludGVybmFsX0ZsYXNoUmVhZGVyP3htbGlkPTk3ODE0NDkzOTkzNjgvMTAy
{
  Serial.write(lowByte(value));
  Serial.write(highByte(value));
}

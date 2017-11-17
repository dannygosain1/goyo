/* FSR testing sketch. 
 
Connect one end of FSR to 3.3V, the other end to Analog 0.
Then connect one end of a 10K resistor from Analog 0 to ground
 
code from: https://learn.adafruit.com/force-sensitive-resistor-fsr/using-an-fsr
*/
 
int fsrAnalogPin0 = 5; // inside
int fsrAnalogPin1 = 1; // bottom
int fsrAnalogPin2 = 2; // outside
int fsrAnalogPin3 = 4; // top

int fsrReading0;     
int fsrReading1;
int fsrReading2; 
int fsrReading3; 
String fsrStr;
  
void setup(void) {
  Serial.begin(9600);   // We'll send debugging information via the Serial monitor
}
 
void loop(void) {
  fsrReading0 = analogRead(fsrAnalogPin0);
  fsrReading1 = analogRead(fsrAnalogPin1);
  fsrReading2 = analogRead(fsrAnalogPin2);
  fsrReading3 = analogRead(fsrAnalogPin3);
  
  fsrStr = "";
  fsrStr = fsrStr + fsrReading1 + " " + fsrReading2 + " " + fsrReading3 + " " + fsrReading0;
  
  Serial.println(fsrStr);
  delay(24);
}

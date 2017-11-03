/* FSR testing sketch. 
 
Connect one end of FSR to 3.3V, the other end to Analog 0.
Then connect one end of a 10K resistor from Analog 0 to ground
 
code from: https://learn.adafruit.com/force-sensitive-resistor-fsr/using-an-fsr
*/
 
int fsrAnalogPin = 0; // FSR is connected to analog 0
int fsrReading;      // the analog reading from the FSR resistor divider
 
void setup(void) {
  Serial.begin(9600);   // We'll send debugging information via the Serial monitor
}
 
void loop(void) {
  fsrReading = analogRead(fsrAnalogPin);
  Serial.println(fsrReading);
  delay(100);
}

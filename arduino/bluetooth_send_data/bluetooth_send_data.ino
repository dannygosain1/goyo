//  Pins
//  Arduino 5V out TO BT VCC
//  Arduino GND to BT GND
//  Arduino D9 to BT RX through a voltage divider
//  Arduino D8 BT TX (no need voltage divider)

#include <SoftwareSerial.h>
SoftwareSerial BTserial(8, 9); // RX | TX
 
//const long baudRate = 57600; 
const long baudRate = 9600;
const char END_CHAR = 'E';
char c=' ';
boolean NL = true;

void setup() 
{
    Serial.begin(9600);
    Serial.print("Sketch:   ");   Serial.println(__FILE__);
    Serial.print("Uploaded: ");   Serial.println(__DATE__);
    Serial.println(" ");
 
    BTserial.begin(baudRate);  
    Serial.print("BTserial started at "); Serial.println(baudRate);
    Serial.println(" ");
    Serial.println(BTserial.read());
}
 
void loop()
{
    String dummyData = "1248757348104386098687597512095840396809468714398672496820956805869734985743698743967450985";
 
    // Read from the Bluetooth module and send to the Arduino Serial Monitor
    if (BTserial.available()){
        c = BTserial.read();
        if (String(c).equals("d")) {
          dumpData(dummyData);
        }
    }
 
 
    // Read from the Serial Monitor and send to the Bluetooth module
    if (Serial.available()) {
        // Echo the user input to the main window. The ">" character indicates the user entered text.
        if (NL) { Serial.print(">");  NL = false; }
        Serial.write(c);
        if (c==10) { NL = true; }
    }
}

void dumpData(String data) {
  char charBuf[data.length() + 1];
  data.toCharArray(charBuf, data.length());
  BTserial.write(charBuf);
  BTserial.write(END_CHAR);  
}


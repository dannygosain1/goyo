//  Pins
//  Arduino 5V out TO BT VCC
//  Arduino GND to BT GND
//  Arduino D9 to BT RX through a voltage divider
//  Arduino D8 BT TX (no need voltage divider)

#include <SoftwareSerial.h>
#include <message.pb.h>
#include <pb_encode.h>


SoftwareSerial BTserial(8, 9); // RX | TX
const int MAX_LENGTH = 80;
uint8_t buffer[MAX_LENGTH];
pb_ostream_t pb_out;

const long baudRate = 57600; 
const String END_SENT = "DONE";
char c=' ';
boolean NL = true;
int dataLength = 203;
char data[][10] = {
  {'1','4','1','0','8','6','9','1','4','3'},
  {'3','7','6','1','0','7','5','0','2','4'},
  {'2','7','1','0','8','6','2','7','4','6'}};

void setup() 
{
    Serial.begin(9600);
    BTserial.begin(baudRate);
}

 
void loop()
{    
    if (BTserial.available()){
        c = BTserial.read(); 
        if (String(c).equals("d")) {
          for (int i=0; i<=dataLength; i++){
            dumpData(data[i%2], sizeof(data[i%2])+1);
            delay(5);
          }
          char charBuf[4];
          END_SENT.toCharArray(charBuf, 5);
          dumpData(charBuf, 4);
        }
    }
}

void dumpData(char *data, int dataLength) {
  Serial.println("\nstart encode time: " + String(millis()));
  Msg m = Msg_init_default;  
  pb_out = pb_ostream_from_buffer(buffer, MAX_LENGTH);
  strncpy(m.val, data, dataLength);
  m.val[dataLength+1] = '\x00';
  if (pb_encode(&pb_out, Msg_fields, &m)) {
    Serial.println("start sending time: " + String(millis()));
    BTserial.write(buffer, dataLength+4);
    Serial.println("end time: " + String(millis()));
  } else {
    Serial.println(PB_GET_ERROR(&pb_out));
  }
}



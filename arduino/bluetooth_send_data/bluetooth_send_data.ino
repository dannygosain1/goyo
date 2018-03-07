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
String data[] = {"17108,6,5,0,4,3", "17108,0,2,0,0,0", "17108,9,4,0,3,0"};

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
            int ind = i%2;
            int bufferLength = data[ind].length()+1;
            char charBuf[bufferLength];
            data[ind].toCharArray(charBuf, bufferLength);
            dumpData(charBuf, bufferLength);
            delay(10);
          }
          char charBuf[4];
          END_SENT.toCharArray(charBuf, 5);
          dumpData(charBuf, 4);
        }
    }
}

void dumpData(char *data, int dataLength) {
  Msg m = Msg_init_default;  
  pb_out = pb_ostream_from_buffer(buffer, MAX_LENGTH);

  strncpy(m.val, data, dataLength);
  m.val[dataLength+1] = '\x00';
  if (pb_encode(&pb_out, Msg_fields, &m)) {
    BTserial.write(buffer, dataLength+4);
  } else {
    Serial.println(PB_GET_ERROR(&pb_out));
  }
}



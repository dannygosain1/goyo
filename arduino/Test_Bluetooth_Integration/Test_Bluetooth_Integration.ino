//  Pins
//  Arduino 5V out TO BT VCC
//  Arduino GND to BT GND
//  Arduino D9 to BT RX through a voltage divider
//  Arduino D8 BT TX (no need voltage divider)

#include <data.pb.h>
#include <pb_encode.h>
#include <SPI.h>
#include <SdFat.h>


pb_ostream_t pb_out;
const long baudRate = 57600; 
char c = ' ';
int32_t term_char[] = {999,999,999,999};
const int DATA_LENGTH = 4;
int32_t tmp_data[DATA_LENGTH] = {1,2,3,4};

// Testing setup
int testLength = 500;
int32_t test_data[][DATA_LENGTH] = {{32,1,124,764},{363,518,111,134},{166,646,662,698}};

#define SD_CHIP_SELECT 10
SdFat sd;

short error = 0;
#define ERR_SD_OTHER 12
#define ERR_SD_OPEN_FILE 9

void setupSD() {
  if (!sd.begin(SD_CHIP_SELECT, SD_SCK_MHZ(50))) {
    sd.initErrorHalt();
  }
}

void setup() 
{
    Serial.begin(baudRate);
    pb_out = as_pb_ostream(Serial);
    setupSD();
}

 
void loop()
{    
    if (Serial.available()){
        c = Serial.read(); 
        Serial.println(String(c));
        if (String(c).equals("d")) {
          for (int i=1; i<=testLength; i++){
            dumpData(test_data[i%3]);
            delay(7);
          }
          delay(4);
          Serial.println(millis()); 
        } else if (String(c).equals("m")) {
          Serial.println(millis()); 
        } else if (String(c).equals("f")) {
          // dump from SD card  
          char filename[] = "00000012.csv";
          readFile(filename);
        }
    }
}

void dumpData(int32_t* data) {
  GoYoData point = GoYoData_init_default;  
  point.fsr = data[0];
  point.x_accel = data[1];
  point.y_accel = data[2];
  point.z_accel = data[3];
  if (!pb_encode(&pb_out, GoYoData_fields, &point)) {
    Serial.println(PB_GET_ERROR(&pb_out));
  }
}

static bool pb_print_write(pb_ostream_t *stream, const pb_byte_t *buf, size_t count) {
    Print* p = reinterpret_cast<Print*>(stream->state);
    size_t written = p->write(buf, count);
    return written == count;
};

pb_ostream_s as_pb_ostream(Print& p) {
    return {pb_print_write, &p, SIZE_MAX, 0};
};

void readFile(char * filename) {
  const int line_buffer_size = 18;
  char buffer[line_buffer_size];
  ifstream sdin(filename);
  int line_number = 0;

  while (sdin.getline(buffer, line_buffer_size, '\n') || sdin.gcount()) {
    int count = sdin.gcount();
    if (sdin.fail()) {
//      Serial.println("Partial long line");
      sdin.clear(sdin.rdstate() & ~ios_base::failbit);
    } else if (sdin.eof()) {
//      Serial.println("Partial final line");  // sdin.fail() is false
    } else {
      count--;  // Don’t include newline in count
      String buf = String(buffer);
      int ci1 = buf.indexOf(',');
      int ci2 = buf.indexOf(',', ci1+1);
      int ci3 = buf.indexOf(',', ci2+1);
      tmp_data[0] = (int32_t)buf.substring(0,ci1).toInt();
      tmp_data[1] = (int32_t)buf.substring(ci1+1, ci2).toInt()*-1;
      tmp_data[2] = (int32_t)buf.substring(ci2+1, ci3).toInt();
      tmp_data[3] = (int32_t)buf.substring(ci3+1).toInt();
      dumpData(tmp_data);
//      Serial.println(buf);
      delay(10);
    }
  }
  String buf = String(filename);
  int ci1 = buf.indexOf('.');
  Serial.println(buf.substring(0,ci1));
}



//  Pins
//  Arduino 5V out TO BT VCC
//  Arduino GND to BT GND
//  Arduino D9 to BT RX through a voltage divider
//  Arduino D8 BT TX (no need voltage divider)

#include <SoftwareSerial.h>
#include <datapig.pb.h>
#include <pb_encode.h>

SoftwareSerial BTserial(8, 9); // RX | TX
const long baudRate = 57600;
char c = ' ';

pb_ostream_t pb_out;
const int DATA_LENGTH = 4;
const int DATA_BUFFER_SIZE = 1;
Data points_buffer[DATA_BUFFER_SIZE];

int32_t term_char[] = {999, 999, 999, 999};
Data term_char_data[1];
int testLength = 200;
int32_t test_data[][DATA_LENGTH] = {{234, 134, 124, 764}, {363, 518, 111, 034}, {166, 646, 662, 698}};


void setup()
{
  Serial.begin(9600);
  BTserial.begin(baudRate);
  pb_out = as_pb_ostream(BTserial);

  term_char_data[0] = raw_data_to_gpb(term_char);
}


void loop() {
  if (BTserial.available()) {
    c = BTserial.read();
    if (String(c).equals("d")) {
      for (int i = 1; i <= testLength; i++) {
        if ((i != 1) && i % DATA_BUFFER_SIZE == 0) {
          dumpData(points_buffer);
        }
        points_buffer[(i % DATA_BUFFER_SIZE)] = raw_data_to_gpb(test_data[i % 3]);
        delay(15);
      }
      dumpData(term_char_data);
    }
  }
}

Data raw_data_to_gpb(int32_t* data) {
  Data point = Data_init_default;
  point.fsr = data[0];
  point.x_accel = data[1];
  point.y_accel = data[2];
  point.z_accel = data[3];
  return point;
}

void dumpData(Data* data) {
   Serial.print("encoding");
      Serial.println(data[0].fsr);
  DataPig bulkData = DataPig_init_default;
  bulkData.data.funcs.encode = &send_data_callback;
  bulkData.data.arg = data;
  if (!pb_encode_delimited(&pb_out, DataPig_fields, &bulkData)) {
    Serial.println(PB_GET_ERROR(&pb_out));
  }
}

bool send_data_callback(pb_ostream_t *stream, const pb_field_t *field, void * const *arg)
{
  for (int j = 0; j < DATA_BUFFER_SIZE; j++) {
    // This encodes the header for the field,
    if (!pb_encode_tag_for_field(stream, field)) {
      return false;
    }
    // This encodes the data for the field,
    if (!pb_encode_submessage(stream, Data_fields, &points_buffer[j])) {
      return false;
    }
  }
  return true;
}

// stream data straight to serial
static bool pb_print_write(pb_ostream_t *stream, const pb_byte_t *buf, size_t count) {
  Print* p = reinterpret_cast<Print*>(stream->state);
  size_t written = p->write(buf, count);
  return written == count;
};

pb_ostream_s as_pb_ostream(Print& p) {
  return {pb_print_write, &p, SIZE_MAX, 0};
};


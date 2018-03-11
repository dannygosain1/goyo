
#define BAUD 9600


void setup() {
  // put your setup code here, to run once:
  Serial.begin(BAUD);

}

void loop() {
  Serial.println(1234,DEC);
  //Serial.println(millis(),BIN);

}

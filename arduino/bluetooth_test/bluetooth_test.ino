String state = "a";
String r = "";

void setup()                    
{
 Serial.begin(9600);           
 pinMode(13, OUTPUT);
}

void loop() {
   if(Serial.available()) {
        r = Serial.read();
        if (r != state) {
          Serial.println("toggling light");
          digitalWrite(13, !digitalRead(13));     
        }
    }
}

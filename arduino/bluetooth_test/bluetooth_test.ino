String state = "a";
String r = "";

void setup()                    
{
 Serial.begin(9600);           
 pinMode(13, OUTPUT);
 randomSeed(42);
}

void loop() {
   if(Serial.available()) {
        r = Serial.read();
        if (r == "97") {
          Serial.println(random(1,100));
          digitalWrite(13, !digitalRead(13));     
        }
    }
}

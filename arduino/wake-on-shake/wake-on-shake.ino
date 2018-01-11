//Define LED Pin Connections
int LED1 = 3;
int LED2 = 5;
int LED3 = 6;
int LED4 = 9;

//Define Wake-on-Shake WAKE pin connection
int WAKE = 10;

void setup() {
  pinMode(LED1, OUTPUT);
  pinMode(LED2, OUTPUT);
  pinMode(LED3, OUTPUT);
  pinMode(LED4, OUTPUT);
  pinMode(WAKE, OUTPUT);
  //Set WAKE pin HIGH to prevent the Wake-on-Shake from 'sleeping'
  digitalWrite(WAKE, HIGH);

  //Slowly birghten the first LED
  for( int i = 0; i<255; i++)
  {
    analogWrite(LED1, i);
    delay(20);
  }
  //Turn off the LED
  digitalWrite(LED1, LOW);

  for( int i = 0; i<255; i++)
  {
    analogWrite(LED2, i);
    delay(20);
  }
  digitalWrite(LED2, LOW);

  for( int i = 0; i<255; i++)
  {
    analogWrite(LED3, i);
    delay(20);
  }
  digitalWrite(LED3, LOW);

  for( int i = 0; i<255; i++)
  {
    analogWrite(LED4, i);
    delay(20);
  }
  digitalWrite(LED4, LOW);

  //Allow the Wake-on-Shake to go to sleep
  digitalWrite(WAKE, LOW);
}

// the loop function runs over and over again forever
void loop() {

}

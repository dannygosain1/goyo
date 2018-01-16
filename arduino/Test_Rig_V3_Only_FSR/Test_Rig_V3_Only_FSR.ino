/*
 * FYDP
 * 
 * Hardware V3
 * Read Accelerometer and FSR when recording. 
 * Print Data to console to be saved later
 * 
 * Department of Systems Design Engineering
 * University of Waterloo
 * Class of 2018
 * 
 * SYDE 462 - Group 14
 * Cory Welch - 20520003
 * Sophia Castellarin - 20506069
 * Raunaq Suri - 20519728
 * Dhananjay (Danny) Gosain - 20524438
 * 
 * Technical Details
 * 
 * FSR Should be conncted to 3.3V on one side
 * Other side should be connected to both a 10k resistor to ground, and the analog pin
 * It created a voltage divider with the FSR and the 10k
 * 
 * MPU6050 Pinout
 * VCC = 3.3V
 * GNG = GND
 * SCL = A5
 * SDA = A4
 * XDA = Open
 * XCL = Open
 * ADO = GND
 * INT = D2
 * 
 * UNO SPI Pins
 * SS = D10
 * MOSI = D11
 * MISO = D12
 * SCL = D13 
 * 
 */

//
// INCLUDES
//
  // For MPU6050
  #include "I2Cdev.h"
  #include "MPU6050_6Axis_MotionApps20.h"
  #if I2CDEV_IMPLEMENTATION == I2CDEV_ARDUINO_WIRE
      #include "Wire.h"
  #endif

//
// GLOBAL CONSTANTS
//
  // General
  #define BAUD 9600
  #define pi 3.14159265

  // Record Details
  const char DELIMITER = ',';
  #define SAMPLING_RATE 24 // how many per second
  int SAMPLE_DELAY = 1000/SAMPLING_RATE; 

  // FSR
  #define FSR 0 //Analog Pin
  
  // Accelerometer
  #define ACC_INTERRUPT 3
  MPU6050 ACC;
  
  // Button / Switch Pins
  #define RECORD_BTN 2
  
  // LED Pins
  #define RED_LED 8
  #define GREEN_LED 7

//
// FUNCTION DECLARATIONS
//
  // Record Functions
  void recordingData(); // gets data from FSR and Acc
  void recordButtonPressed(); // runs on button press to toggle record mode

  // Log Data
  void logData(int l); // to Serial for now

//
// GLOBAL VARIABLES
//
  // Data Variables
  int fsrReading = 0;
  
  String timestampString = "";
  String fsrString = "";
  String accString = "";
  
  String dataString = "";
  
  // Record Status
  volatile bool recording = false;
  volatile bool recordBtnStatus = false;
  volatile long recordLastPressed = 0;
  volatile bool recordingStateChange = false;



void setup() {

  // SETUP SERIAL
  Serial.begin(BAUD);
  
  // SETUP DIGITAL OUTPUTS
  pinMode(RED_LED, OUTPUT);
  pinMode(GREEN_LED, OUTPUT);

  // SETUP DIGITAL INPUTS
  pinMode(RECORD_BTN,INPUT_PULLUP);

  // SETUP BUTTON INTERRUPT
  attachInterrupt(digitalPinToInterrupt(RECORD_BTN),recordButtonPressed, RISING);

  recording = false;
  recordingStateChange = true;
  Serial.println("Setup Complete");

}

void loop() {

  if(recording && recordingStateChange){
    //First Run of Recording  
    digitalWrite(RED_LED,LOW);
    digitalWrite(GREEN_LED,HIGH);
    logData(1);
    
    recordingStateChange = false;
  } else if(!recording && recordingStateChange){
    // Just finished Recording
    digitalWrite(RED_LED,HIGH);
    digitalWrite(GREEN_LED,LOW);
    
    recordingStateChange = false;
  } else if(recording){
    // Recording
    recordingData();
    logData(0);
    delay(SAMPLE_DELAY);
    
  } else {
     // Not Recording
  }

}

void logData(int l){
  if(!recording){
    return;
  }
  if(l == 1){
    Serial.println("Timestamp,FSR,X_Acc,Y_Acc,Z_Acc");
  } else {
    Serial.println(dataString);
  }
  
}

// Function Continuously called to get data to write to serial
void recordingData(){
  if(!recording){
    return;
  }
  dataString = "";

  timestampString = String(millis(),DEC);
  
  fsrReading = analogRead(FSR);
  fsrString = fsrReading;

  String xString = "";
  String yString = "";
  String zString = "";
  accString = xString + DELIMITER + yString + DELIMITER + zString;

  dataString = timestampString + DELIMITER + fsrString + DELIMITER + accString;
}

// Function called when record button is pressed, via ISR
void recordButtonPressed(){
  if(recordLastPressed > millis() - 1000){
    return;
  } else {
    recordLastPressed = millis();
  }
  recordBtnStatus = digitalRead(RECORD_BTN);
  if(recordBtnStatus){
      recording = !recording;
      recordingStateChange = true;
      recordBtnStatus = false;
  }
  
}

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
 * SPI Pins
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
  #define  DEBOUNCE_TIME 2000

  // Record Details
  const char DELIMITER = ',';
  #define SAMPLING_RATE 24 // how many per second
  int SAMPLE_DELAY = 1000/SAMPLING_RATE; 

  // FSR
  #define FSR 0 //Analog Pin
  
  // Accelerometer
  #define ACC_INTERRUPT 3
  MPU6050 ACC;
  #define ACC_X_ACC_OFFSET -3526
  #define ACC_Y_ACC_OFFSET 2232
  #define ACC_Z_ACC_OFFSET 1162
  #define ACC_X_GYRO_OFFSET -108
  #define ACC_Y_GYRO_OFFSET -121
  #define ACC_Z_GYRO_OFFSET 11
  
  // Button / Switch Pins
  #define RECORD_BTN 2
  #define WALKING_BTN 6
  
  // LED Pins
  #define RED_LED 8
  #define GREEN_LED 7

  // Errors
  #define ERR_UNCAUGHT 1
  #define ERR_RESET 2
  #define ERR_ACC_NOT_READY 3
  #define ERR_ACC_MEMORY_FAILURE 4
  #define ERR_ACC_DMP_FAILURE 5
  #define ERR_ACC_OTHER 6
  const String errorStrs[7] = { "No Errors",
    "An Uncaught Error Occured",
    "A Microprocessor Restart is Needed",
    "Accelerometer Initial Test Failed",
    "Accelerometer Initial Memory Load Failed",
    "Accelerometer Data Dump Configuration Updates Failed",
    "An uncaught Acceleromter Error Occured"
  };

//
// FUNCTION DECLARATIONS
//
  // Accelerometer Functions
  void accDumpReady();
  void setupMPU6050();
  void getAccData();

  // Record Functions
  void recordingData(); // gets data from FSR and Acc
  void recordButtonPressed(); // runs on button press to toggle record mode

  // Log Data
  void logData(int l); // to Serial for now

//
// GLOBAL VARIABLES
//
  // General
  int error = 0;
  bool errorPrinted = false;
  volatile long lastSerialTime = 0;

  // Accelerometer
    // MPU control/status vars
    bool dmpReady = false;  // set true if DMP init was successful
    uint8_t mpuIntStatus;   // holds actual interrupt status byte from MPU
    uint8_t devStatus;      // return status after each device operation (0 = success, !0 = error)
    uint16_t packetSize;    // expected DMP packet size (default is 42 bytes)
    uint16_t fifoCount;     // count of all bytes currently in FIFO
    uint8_t fifoBuffer[64]; // FIFO storage buffer
    volatile bool mpuInterrupt = false; // indicates whether MPU interrupt pin has gone high

  Quaternion q;           // [w, x, y, z]         quaternion container
  VectorFloat gravity;    // [x, y, z]            gravity vector
  float AccX = 0;
  float AccY = 0;
  float AccZ = 0;
  
  // Data Variables
  int fsrReading = 0;
  
  String timestampString = "";
  String fsrString = "";
  String accString = "";
  String walkingString = "";
  
  String dataString = "";
  
  // Record Status
  volatile bool recording = false;
  volatile bool recordBtnStatus = false;
  volatile long recordLastPressed = 0;
  volatile bool recordingStateChange = false;

  // Walking
  bool walking = false;

void setup() {

  // SETUP SERIAL
  Serial.begin(BAUD);
  
  // SETUP DIGITAL OUTPUTS
  pinMode(RED_LED, OUTPUT);
  pinMode(GREEN_LED, OUTPUT);

  // SETUP DIGITAL INPUTS
  pinMode(ACC_INTERRUPT, INPUT);
  pinMode(RECORD_BTN,INPUT);
  pinMode(WALKING_BTN,INPUT);

  // SETUP BUTTON INTERRUPT
  attachInterrupt(digitalPinToInterrupt(RECORD_BTN),recordButtonPressed, RISING);

  // ACCELEROMETER SETUP
  //MPU6050 Specific
  #if I2CDEV_IMPLEMENTATION == I2CDEV_ARDUINO_WIRE
    Wire.begin();
    // Wire.setClock(400000); // 400kHz I2C clock. Comment this line if having compilation difficulties
  #elif I2CDEV_IMPLEMENTATION == I2CDEV_BUILTIN_FASTWIRE
    Fastwire::setup(400, true);
  #endif
  setupMPU6050();
  
  recording = false;
  recordingStateChange = true;
  recordLastPressed = millis();
  Serial.println("Setup Complete");

}

void loop() {

  if(error != 0){
    if(!errorPrinted){
      Serial.println(errorStrs[error]);
    }
    return;
  }
  
  //recordButtonPressed();

  if(recording && recordingStateChange){
    //First Run of Recording  
    digitalWrite(RED_LED,LOW);
    digitalWrite(GREEN_LED,HIGH);
    recordingData();
    logData(1);
    
    recordingStateChange = false;
  } else if(!recording && recordingStateChange){
    // Just finished Recording
    digitalWrite(RED_LED,HIGH);
    digitalWrite(GREEN_LED,LOW);
    ACC.resetFIFO();
    recordingStateChange = false;
  } else if(recording){
    // Recording
    if(millis() - SAMPLE_DELAY > lastSerialTime){
      recordingData();
      logData(0);
      lastSerialTime = millis();
    }
  } else {
     // Not Recording no Error
  }

}

// Function called to actually log data to the serial 
void logData(int l){
  if(!recording || error != 0){
    return;
  }
  if(l == 1){
    Serial.println("timestamp,is_walking,fsr,x_acc,y_acc,z_acc");
  } else {
    Serial.println(dataString);
  }
  
}

// Function Continuously called to get data to write to serial
void recordingData(){
  if(!recording || error != 0){
    return;
  }
  dataString = "";

  timestampString = String(millis(),DEC);
  
  fsrReading = analogRead(FSR);
  fsrString = String(fsrReading);

  getAccData();

  String xString = String(AccX);
  String yString = String(AccY);
  String zString = String(AccZ);
  accString = xString + DELIMITER + yString + DELIMITER + zString;

  walking = digitalRead(WALKING_BTN);
  walkingString = String(walking);

  dataString = timestampString + DELIMITER + walkingString + DELIMITER + fsrString + DELIMITER + accString;
}

// Function to setup MPU6050 and test connection
void setupMPU6050(){
  ACC.initialize();
  if(!ACC.testConnection()){
    error = ERR_ACC_NOT_READY;
  }

  devStatus = ACC.dmpInitialize();
  ACC.setXAccelOffset(-3526);
  ACC.setYAccelOffset(2232);
  ACC.setZAccelOffset(1162);
  ACC.setXGyroOffset(-108);
  ACC.setYGyroOffset(-121);
  ACC.setZGyroOffset(11);
  
  // make sure it worked (returns 0 if so)
    if (devStatus == 0) {
        // turn on the DMP, now that it's ready
        ACC.setDMPEnabled(true);

        // enable Arduino interrupt detection
        attachInterrupt(digitalPinToInterrupt(ACC_INTERRUPT), accDumpReady, RISING);
        mpuIntStatus = ACC.getIntStatus();

        // set our DMP Ready flag so the main loop() function knows it's okay to use it
        dmpReady = true;

        // get expected DMP packet size for later comparison
        packetSize = ACC.dmpGetFIFOPacketSize();
    } else if(devStatus == 1){
      error =  ERR_ACC_MEMORY_FAILURE;
    } else if(devStatus == 2){
      error = ERR_ACC_DMP_FAILURE;
    } else {
      error = ERR_ACC_OTHER;
    }
}

// Function to allow accelerometer dump to occur
void accDumpReady(){
  mpuInterrupt = true;
}

// Function to get data from Accelerometer
void getAccData(){
    // if programming failed, don't try to do anything
    if (!dmpReady) return;

    // reset interrupt flag and get INT_STATUS byte
    mpuInterrupt = false;
    mpuIntStatus = ACC.getIntStatus();

    // get current FIFO count
    fifoCount = ACC.getFIFOCount();

    // check for overflow (this should never happen unless our code is too inefficient)
    if ((mpuIntStatus & 0x10) || fifoCount == 1024) {
        // reset so we can continue cleanly
        ACC.resetFIFO();
        //Serial.println(F("FIFO overflow!"));

    // otherwise, check for DMP data ready interrupt (this should happen frequently)
    } else if (mpuIntStatus & 0x02) {
        // wait for correct available data length, should be a VERY short wait
        while (fifoCount < packetSize) fifoCount = ACC.getFIFOCount();

        // read a packet from FIFO
        ACC.getFIFOBytes(fifoBuffer, packetSize);
        
        // track FIFO count here in case there is > 1 packet available
        // (this lets us immediately read more without waiting for an interrupt)
        fifoCount -= packetSize;
 
        
        //mpu.dmpGetQuaternion(&q, fifoBuffer);
        Quaternion* qt = &q;
        int16_t qI[4];
        qI[0] = ((fifoBuffer[0] << 8) | fifoBuffer[1]);
        qI[1] = ((fifoBuffer[4] << 8) | fifoBuffer[5]);
        qI[2] = ((fifoBuffer[8] << 8) | fifoBuffer[9]);
        qI[3] = ((fifoBuffer[12] << 8) | fifoBuffer[13]);
          
        qt -> w = (float)qI[0] / 16384.0f;
        qt -> x = (float)qI[1] / 16384.0f;
        qt -> y = (float)qI[2] / 16384.0f;
        qt -> z = (float)qI[3] / 16384.0f;
        /*/
        
        Serial.print(" w ");
        Serial.print(qt->w);
        Serial.print(" x ");
        Serial.print(qt->x);
        Serial.print(" y ");
        Serial.print(qt->y);
        Serial.print(" z ");
        Serial.print(qt->z);
        //*/
        VectorFloat* gravityt = &gravity;
          
        //mpu.dmpGetGravity(&gravity, &q);  
        gravityt -> x = 2 * (qt -> x*qt -> z - qt -> w*qt -> y);
        gravityt -> y = 2 * (qt -> w*qt -> x + qt -> y*qt -> z);
        gravityt -> z = qt -> w*qt -> w - qt -> x*qt -> x - qt -> y*qt -> y + qt -> z*qt -> z;
        //*/
        AccX = gravityt->x;
        AccY = gravityt->y;
        AccZ = gravityt->z;
        
        /*Serial.print(" gx: ");
        Serial.print(gravityt->x);
        Serial.print(" gy: ");
        Serial.print(gravityt->y);
        Serial.print(" gz: ");
        Serial.println(gravityt->z);

        Serial.print(" gx: ");
        Serial.print(AccX);
        Serial.print(" gy: ");
        Serial.print(AccY);
        Serial.print(" gz: ");
        Serial.println(AccZ);*/
    }

}


// Function called when record button is pressed
void recordButtonPressed(){
  if(millis() - recordLastPressed < DEBOUNCE_TIME){
    // To Close to Previous Button Press (or is debounce)
    return;
  } else {
    recordLastPressed = millis();
  }
  recordBtnStatus = digitalRead(RECORD_BTN);
  if(recordBtnStatus){
    // Button Pressed
    recording = !recording;
    recordingStateChange = true;
    recordBtnStatus = false;
  }
}

/*
 * FYDP
 * 
 * Hardware V4
 * Read Accelerometer and FSR when recording. 
 * Print Data to SD Card via SdFat Library
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
 * MPU6050 Should also be connected to 3.3V for VCC 
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
 * SD Pinout
 * /‾‾|‾|‾|‾|‾|‾|‾‾|
 * | 1 2 3 4 5 6 78
 * 9 
 * ----------------
 * 1 (Data 3 / Chip Select / Slave Select 3.3V) = D10 (Voltage Divider down to 3.3V) 
 * 2 (DI / MOSI 3.3V) = D11 (Voltage Divider down to 3.3V) 
 * 3 (VSS = GND) = GND)
 * 4 (VDD 3.7V - 3.6V) = 3.3V 
 * 5 (SCLK 3.3V) = D13 (Voltage Divider down to 3.3V) 
 * 6 (VSS = GND) = Open
 * 7 (DO / MISO) = D12 (DO)
 * 8 (Data 1) = Open
 * 9 (Data 2) = Open
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

  // For SD
  #include <SPI.h>
  #include "SdFat.h"

//
// GLOBAL CONSTANTS
//
  // General
  #define BAUD 9600
  #define DEBOUNCE_TIME 2000
  #define BLINK_TIME 500

  // Record Details
  const char DELIMITER = ',';
  #define SAMPLING_RATE 30 // Hz
  const uint32_t SAMPLE_INTERVAL = 1000/SAMPLING_RATE; 
  #define BUFFER_SIZE 10
  #define LOG_MODE 2 /*
  0 = Serial Only, 1 = SD Only, 2 = SD and Serial,
  3 = Buffer Serial Only, 4 = Buffer SD Only, 5 = Buffer SD and Serial
  */

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

  // SPI Pins
  #define CLOCK 13
  #define MOSI 11
  #define MISO 12

  // SD Pins
  #define SD_CHIP_SELECT 10
  #define FILE_BASE_NAME "Data" //Must be six characters or less

  // Errors
  #define ERR_UNCAUGHT 1
  #define ERR_RESET 2
  #define ERR_ACC_NOT_READY 3
  #define ERR_ACC_MEMORY_FAILURE 4
  #define ERR_ACC_DMP_FAILURE 5
  #define ERR_ACC_OTHER 6
  #define ERR_SD_INIT_FAILURE 7
  #define ERR_SD_FILENAME_TO_LONG 8
  #define ERR_SD_OPEN_FILE 9
  #define ERR_SD_CANT_CREATE_FILENAME 10
  #define ERR_SD_DATA_NOT_FORCED 11
  #define ERR_SD_OTHER 12

//
// FUNCTION DECLARATIONS
//
  // Accelerometer Functions
  void accDumpReady();
  void setupMPU6050();
  void getAccData();

  // Record Functions
  void recordButtonPressed(); // runs on button press to toggle record mode

  // SD Functions
  void setupSD();
  void setupLogFile();
  void doneLogFile();
  
  // Log / Buffer Data
  void logData();
  void writeBuffer();

//
// GLOBAL VARIABLES
//
  // General
  short error = 0;
  bool errorPrinted = false;
  volatile long lastSerialTime = 0;
  long lastBlinkTime = 0;

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

  float AccX = 0.0;
  float AccY = 0.0;
  float AccZ = 0.0;
  
  // Data Variables
  int fsrReading = 0;
  
  // Record Status
  volatile bool recording = false;
  volatile bool recordBtnStatus = false;
  volatile long recordLastPressed = 0;
  volatile bool recordingStateChange = false;

  // Walking
  bool walking = false;

  // SD
  SdFat sd;
  SdFile file;

  // Logging / Buffer
  short bufferIndex = 0;

  long millisBuffer[BUFFER_SIZE];
  bool isWalkingBuffer[BUFFER_SIZE];
  short fsrBuffer[BUFFER_SIZE];
  float xAccBuffer[BUFFER_SIZE];
  float yAccBuffer[BUFFER_SIZE];
  float zAccBuffer[BUFFER_SIZE];

void setup() {

  // SETUP SERIAL
  Serial.begin(BAUD);

  Serial.println("Setup Starting");
  
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

  Serial.println("Setting up MPU6050");
  setupMPU6050();
  Serial.println("Done");

  
  Serial.println("Setting up SD");
  setupSD();
  Serial.println("Done");
  Serial.println();

  recording = false;
  recordingStateChange = false;
  recordLastPressed = millis();

  digitalWrite(RED_LED,HIGH);
  digitalWrite(GREEN_LED,LOW);

  Serial.print("Recording at ");
  Serial.print(SAMPLE_INTERVAL);
  Serial.print(" ms or ");
  Serial.print(SAMPLING_RATE);
  Serial.println(" hz");
  Serial.print("With a Buffer Size of ");
  Serial.println(BUFFER_SIZE);

  Serial.println();

  Serial.print("Logging Mode Set to ");
  Serial.println(LOG_MODE);
  

  Serial.println("Setup Complete");

}

void loop() {

  if(error != 0){
    if(!errorPrinted){
      Serial.print("Error: ");
      Serial.println(error);
      errorPrinted = true;
    }
    if(millis() - lastBlinkTime > BLINK_TIME){
      digitalWrite(GREEN_LED,LOW);
      digitalWrite(RED_LED,!digitalRead(RED_LED));
      lastBlinkTime = millis();
    }
    return;
  }

  if(recording && recordingStateChange){
    //First Run of Recording  
    digitalWrite(RED_LED,LOW);
    digitalWrite(GREEN_LED,HIGH);
    Serial.println(F("Initializing Log File"));
    setupLogFile();
    
    recordingStateChange = false;
    
  } else if(!recording && recordingStateChange){
    // Just finished Recording
    digitalWrite(RED_LED,HIGH);
    digitalWrite(GREEN_LED,LOW);
    ACC.resetFIFO();

    doneLogFile();
    
    recordingStateChange = false;
    
  } else if(recording){
    // Recording
    if(millis() - SAMPLE_INTERVAL > lastSerialTime){
      
      getAccData();
      
      logData();
      lastSerialTime = millis();

      if(bufferIndex >= BUFFER_SIZE){
        writeBuffer();
        bufferIndex = 0;
      }
    }
    
  } else {
     // Not Recording no Error
  }

}

// Function to setup SD card, get next test number 
void setupSD() {
  if (!sd.begin(SD_CHIP_SELECT, SD_SCK_MHZ(50))) {
    sd.initErrorHalt();
  }
}

void setupLogFile() {
  if(!recording || error != 0){
    return;
  }

  const uint8_t BASE_NAME_SIZE = sizeof(FILE_BASE_NAME) - 1;
  char fileName[13] = FILE_BASE_NAME "00.csv";

  // Find an unused file name.
  if (BASE_NAME_SIZE > 6) {
    error = ERR_SD_FILENAME_TO_LONG;
  }
  while (sd.exists(fileName)) {
    if (fileName[BASE_NAME_SIZE + 1] != '9') {
      fileName[BASE_NAME_SIZE + 1]++;
    } else if (fileName[BASE_NAME_SIZE] != '9') {
      fileName[BASE_NAME_SIZE + 1] = '0';
      fileName[BASE_NAME_SIZE]++;
    } else {
      error = ERR_SD_CANT_CREATE_FILENAME;
    }
  }
  if (!file.open(fileName, O_CREAT | O_WRITE | O_EXCL)) {
    error = ERR_SD_OPEN_FILE;
  }

  Serial.print(F("Logging to: "));
  Serial.println(fileName);

  // Write data header.
  writeHeader();

  // Start on a multiple of the sample interval.
  /*
  lastSerialTime = micros()/(1000UL*SAMPLE_INTERVAL) + 1;
  lastSerialTime *= 1000UL*SAMPLE_INTERVAL;*/
}


// Write data header.
void writeHeader() {

  String headerString = "timestamp,is_walking,fsr,x_acc,y_acc,z_acc";
  
  if(LOG_MODE == 0 || LOG_MODE == 2 || LOG_MODE == 3 || LOG_MODE == 5){
    Serial.print(headerString);
    Serial.println();
  }

  if(LOG_MODE == 1 || LOG_MODE == 2 || LOG_MODE == 4 || LOG_MODE == 5){
    file.print(headerString);
    file.println();
  }
}

// Log a single data record to the SD Card via Preestablished File Details
void logData() {
  if(!recording || error != 0){
    return;
  }

  long curTime = millis();

  if(LOG_MODE == 0 || LOG_MODE == 2){
    Serial.print(curTime);
    Serial.write(DELIMITER);
    Serial.print(digitalRead(WALKING_BTN));
    Serial.write(DELIMITER);
    Serial.print(analogRead(FSR));
    Serial.write(DELIMITER);
    Serial.print(AccX);
    Serial.write(DELIMITER);
    Serial.print(AccY);
    Serial.write(DELIMITER);
    Serial.print(AccZ);
    Serial.println();
  }

  if(LOG_MODE == 1 || LOG_MODE == 2){
    file.print(curTime);
    file.write(DELIMITER);
    file.print(digitalRead(WALKING_BTN));
    file.write(DELIMITER);
    file.print(analogRead(FSR));
    file.write(DELIMITER);
    file.print(AccX);
    file.write(DELIMITER);
    file.print(AccY);
    file.write(DELIMITER);
    file.print(AccZ);
    file.println();

    /*if (!file.sync() || file.getWriteError()) {
      error = ERR_SD_DATA_NOT_FORCED;
    }*/
  }

  if(LOG_MODE == 3 || LOG_MODE == 4 || LOG_MODE == 5){
    millisBuffer[bufferIndex] = curTime;
    isWalkingBuffer[bufferIndex] = digitalRead(WALKING_BTN);
    fsrBuffer[bufferIndex] = analogRead(FSR);
    xAccBuffer[bufferIndex] = AccX;
    yAccBuffer[bufferIndex] = AccY;
    zAccBuffer[bufferIndex] = AccZ;

    bufferIndex++;
  }
  

}

void writeBuffer(){
  if(LOG_MODE == 3 || LOG_MODE == 5){
    for(int i = 0; i < BUFFER_SIZE; i++){
      Serial.print(millisBuffer[i]);
      Serial.write(DELIMITER);
      Serial.print(isWalkingBuffer[i]);
      Serial.write(DELIMITER);
      Serial.print(fsrBuffer[i]);
      Serial.write(DELIMITER);
      Serial.print(xAccBuffer[i]);
      Serial.write(DELIMITER);
      Serial.print(yAccBuffer[i]);
      Serial.write(DELIMITER);
      Serial.print(zAccBuffer[i]);
      Serial.println();
    }
  }

  if(LOG_MODE == 4 || LOG_MODE == 5){
    for(int i = 0; i < BUFFER_SIZE; i++){
      file.print(millisBuffer[i]);
      file.write(DELIMITER);
      file.print(isWalkingBuffer[i]);
      file.write(DELIMITER);
      file.print(fsrBuffer[i]);
      file.write(DELIMITER);
      file.print(xAccBuffer[i]);
      file.write(DELIMITER);
      file.print(yAccBuffer[i]);
      file.write(DELIMITER);
      file.print(zAccBuffer[i]);
      file.println();
    }
  }
}

void doneLogFile(){
  file.close();
  Serial.println(F("Done Recording"));
}

// Function to setup MPU6050 and test connection
void setupMPU6050(){
  ACC.initialize();
  if(!ACC.testConnection()){
    error = ERR_ACC_NOT_READY;
  }

  devStatus = ACC.dmpInitialize();
  ACC.setXAccelOffset(ACC_X_ACC_OFFSET);
  ACC.setYAccelOffset(ACC_Y_ACC_OFFSET);
  ACC.setZAccelOffset(ACC_Z_ACC_OFFSET);
  ACC.setXGyroOffset(ACC_X_GYRO_OFFSET);
  ACC.setYGyroOffset(ACC_Y_GYRO_OFFSET);
  ACC.setZGyroOffset(ACC_Z_GYRO_OFFSET);
  
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

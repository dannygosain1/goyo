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
 * It creates a voltage divider with the FSR and the 10k
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

  // For GPB and bluetooth
  #include <data.pb.h>
  #include <pb_encode.h>

//
// GLOBAL CONSTANTS
//
  // General
  #define BLINK_TIME 500

  // Debug Mode
  #define DEBUG_ENABLED false
  #define DEBUG_LEVEL 2 
  /*  0 = Basic Messages Only
   *  1 = 0 + Major Step Completion
   *  2 = All Messages
   */

  // Record Details
  const char DELIMITER = ',';
  #define SAMPLING_RATE 50 // Hz
  const uint32_t SAMPLE_INTERVAL = 1000/SAMPLING_RATE; 

  // Bluetooth
  #define BT_ENABLED true
  #define BAUD 57600
  #define DATA_LENGTH 4

  // FSR
  #define FSR 0 //Analog Pin
  
  // Accelerometer
  #define ACC_INTERRUPT 2
  MPU6050 ACC;
  #define ACC_X_ACC_OFFSET -3526
  #define ACC_Y_ACC_OFFSET 2232
  #define ACC_Z_ACC_OFFSET 1162
  #define ACC_X_GYRO_OFFSET -108
  #define ACC_Y_GYRO_OFFSET -121
  #define ACC_Z_GYRO_OFFSET 11
  
  // Button / Switch Pins

  
  // LED Pins
  #define RED_LED 8
  #define GREEN_LED 7
  #define BLUE_LED 9

  // SPI Pins
  #define CLOCK 13
  #define MOSI 11
  #define MISO 12

  // SD Pins
  #define SD_CHIP_SELECT 10

  // Errors
  #define ERR_UNCAUGHT 1
  #define ERR_RESET 2
  #define ERR_ACC_NOT_READY 3
  #define ERR_ACC_MEMORY_FAILURE 4
  #define ERR_ACC_DMP_FAILURE 5
  #define ERR_ACC_OTHER 6
  #define ERR_SD_INIT_FAILURE 7
  #define ERR_SD_OPEN_FILE 9
  #define ERR_SD_CANT_CREATE_FILENAME 10
  #define ERR_SD_OTHER 12

//
// FUNCTION DECLARATIONS
//
  // Accelerometer Functions
  void accDumpReady();
  void setupMPU6050();
  void getAccData();

  // SD Functions
  void setupSD();
  void setupLogFile();
  void doneLogFile();
  
  // Log / Buffer Data
  void logData();

  // Bluetooth Funtions
  void dumpData(int32_t* data);
  void dumpFile();
  

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
  int32_t tmp_data[DATA_LENGTH] = {1,2,3,4};
  char read_serial = ' ';
  char filename[14];
  
  // Record Status
  volatile bool recordingStateChange = false;

  // SD
  SdFat sd;
  SdFile file;

  // GPB output stream
  pb_ostream_t pb_out;


  // Functions to support Serial (bluetooth) for gpb encoding
  static bool pb_print_write(pb_ostream_t *stream, const pb_byte_t *buf, size_t count) {
      Print* p = reinterpret_cast<Print*>(stream->state);
      size_t written = p->write(buf, count);
      return written == count;
  };
  
  pb_ostream_s as_pb_ostream(Print& p) {
      return {pb_print_write, &p, SIZE_MAX, 0};
  };

void setup() {
  // SETUP SERIAL
  if(BT_ENABLED || DEBUG_ENABLED){
    Serial.begin(BAUD);
    if(DEBUG_ENABLED){
      Serial.print("Debug Level Set to ");
      Serial.println(DEBUG_LEVEL);
    }
  }

  if(DEBUG_ENABLED && DEBUG_LEVEL >= 0){
    Serial.print("DEBUG 0: ");
    Serial.println("DEBUG Setup Starting");
  }
  
  // SETUP DIGITAL OUTPUTS
  pinMode(RED_LED, OUTPUT);
  pinMode(GREEN_LED, OUTPUT);
  pinMode(BLUE_LED, OUTPUT);

  // SETUP DIGITAL INPUTS
  pinMode(ACC_INTERRUPT, INPUT);

  // ACCELEROMETER SETUP
  //MPU6050 Specific
  #if I2CDEV_IMPLEMENTATION == I2CDEV_ARDUINO_WIRE
    Wire.begin();
    // Wire.setClock(400000); // 400kHz I2C clock. Comment this line if having compilation difficulties
  #elif I2CDEV_IMPLEMENTATION == I2CDEV_BUILTIN_FASTWIRE
    Fastwire::setup(400, true);
  #endif

  if(DEBUG_ENABLED && DEBUG_LEVEL >= 1){
    Serial.print("DEBUG 1: ");
    Serial.println("Setting up MPU6050");
  }
  setupMPU6050();
  if(DEBUG_ENABLED && DEBUG_LEVEL >= 2){
    Serial.print("DEBUG 2: ");
    Serial.println("Done setting up MPU6050");
  }

  if(DEBUG_ENABLED && DEBUG_LEVEL >= 1){
    Serial.print("DEBUG 1: ");
    Serial.println("Setting up SD Card");
  }
  setupSD();
  if(DEBUG_ENABLED && DEBUG_LEVEL >= 2){
    Serial.print("DEBUG 2: ");
    Serial.println("Done setting up SD Card");
  }

  if(DEBUG_ENABLED && DEBUG_LEVEL >= 1){
    Serial.print("DEBUG 1: ");
    Serial.println("Setting up Bluetooth");
  }

  pb_out = as_pb_ostream(Serial);
  if(DEBUG_ENABLED && DEBUG_LEVEL >= 2){
    Serial.print("DEBUG 2: ");
    Serial.println("Done setting up Bluetooth encoding");
  }

  recordingStateChange = true;

  digitalWrite(RED_LED,LOW);
  digitalWrite(GREEN_LED,LOW);
  digitalWrite(BLUE_LED,LOW);

  if(DEBUG_ENABLED && DEBUG_LEVEL >= 2){
    Serial.print("DEBUG 2: ");
    Serial.print("Recording at ");
    Serial.print(SAMPLE_INTERVAL);
    Serial.print(" ms or ");
    Serial.print(SAMPLING_RATE);
    Serial.println(" hz");
  }

  if(DEBUG_ENABLED && DEBUG_LEVEL >= 0){
    Serial.print("DEBUG 0: ");
    Serial.println("DEBUG Setup Complete");
  }
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

  if (Serial.available()){
    read_serial = Serial.read(); 
    if (String(read_serial).equals("d")) {
      // For debug
      ACC.resetFIFO();
      doneLogFile();
      recordingStateChange = true;
      detachInterrupt(digitalPinToInterrupt(ACC_INTERRUPT));
      dumpFile();
      attachInterrupt(digitalPinToInterrupt(ACC_INTERRUPT), accDumpReady, RISING);
    } else if (String(read_serial).equals("m")) {
      detachInterrupt(digitalPinToInterrupt(ACC_INTERRUPT));
      Serial.println(millis()); 
      attachInterrupt(digitalPinToInterrupt(ACC_INTERRUPT), accDumpReady, RISING);
    }
  } 

  if(recordingStateChange){
    //First Run of Recording  
    digitalWrite(RED_LED,LOW);
    digitalWrite(GREEN_LED,HIGH);
    Serial.println(F("Initializing Log File"));
    setupLogFile();
    recordingStateChange = false;
    
  } else {
    // Recording
    if(millis() - SAMPLE_INTERVAL >= lastSerialTime){
      getAccData();
      logData();
      lastSerialTime = millis() - 7;
      
    }   
  }
}

// Function to write debug line to Serial
void debug(){
  
}

// Function to setup SD card, get next test number 
void setupSD() {
  if (!sd.begin(SD_CHIP_SELECT, SD_SCK_MHZ(50))) {
    sd.initErrorHalt();
  }
}

void setupLogFile() {
  if(error != 0){
    return;
  }
  
  String strfile = String(millis());
  strfile.concat(".csv");
  strfile.toCharArray(filename, 14);

  if (sd.exists(filename)) {
     error = ERR_SD_CANT_CREATE_FILENAME; 
  }
  
  if (!file.open(filename, O_CREAT | O_WRITE | O_EXCL)) {
    error = ERR_SD_OPEN_FILE;
  }

  Serial.print(F("Logging to: "));
  Serial.println(filename);
}



// Log a single data record to the SD Card via Preestablished File Details
void logData() {

  int afsr = analogRead(FSR);
  String entry = String(afsr) + DELIMITER + String(int(AccX*100)) + DELIMITER + String(int(AccY*100)) + DELIMITER + String(int(AccZ*100));
  file.println(entry);
}

void doneLogFile(){
  file.close();
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
    if (!dmpReady) return;

    mpuInterrupt = false;
    mpuIntStatus = ACC.getIntStatus();

    fifoCount = ACC.getFIFOCount();

    if ((mpuIntStatus & 0x10) || fifoCount == 1024) {
        ACC.resetFIFO();
    } else if (mpuIntStatus & 0x02) {
        while (fifoCount < packetSize) fifoCount = ACC.getFIFOCount();

        ACC.getFIFOBytes(fifoBuffer, packetSize);

        fifoCount -= packetSize;
        
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

        VectorFloat* gravityt = &gravity;
          
        gravityt -> x = 2 * (qt -> x*qt -> z - qt -> w*qt -> y);
        gravityt -> y = 2 * (qt -> w*qt -> x + qt -> y*qt -> z);
        gravityt -> z = qt -> w*qt -> w - qt -> x*qt -> x - qt -> y*qt -> y + qt -> z*qt -> z;
        
        AccX = gravityt->x;
        AccY = gravityt->y;
        AccZ = gravityt->z;   
    }
}

// Function to dump data array
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

// Function to dump a file filled with data given it's name
void dumpFile() {
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
      delay(10);
    }
  }
  String buf = String(filename);
  int ci1 = buf.indexOf('.');
  Serial.println(buf.substring(0,ci1));
}


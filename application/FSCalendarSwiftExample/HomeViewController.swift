//
//  HomeViewController.swift
//  FSCalendarSwiftExample
//
//  Created by Danny Gosain on 2018-03-06.
//  Copyright © 2018 wenchao. All rights reserved.
//
// UUID: D9B0BD7F-E600-034A-C795-119E77AAB719


import UIKit
import CoreBluetooth

class HomeViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    
    @IBOutlet weak var dailyGoal: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var starCosmos: CosmosView!
    @IBOutlet weak var message: UILabel!
    
    // bluetooth stuff
    var manager:CBCentralManager!
    var peripheral:CBPeripheral!
    
    // hc-08 info
    let BEAN_NAME = "GoYo"
    let BEAN_SCRATCH_UUID =
        CBUUID(string: "0x0025")
    let BEAN_SERVICE_UUID =
        CBUUID(string: "0x0025")
    
    var tempData: [[Double]] = [[0.010968921389396709,0.003251151449471805,-0.15496254681647964,0.8669483568075118,0.346455460450265,0.03314024286637835,0.16184266642799194,0.3465015219909012,0.03314078194292833,0.16184421884299838],[1.0,-0.13492278515307535,-0.13436329588015009,0.8718309859154929,0.2105182764337448,0.03272925927168528,0.1609407133091557,0.21040523459857455,0.03272909306608637,0.16094071330915558],[0.6910420475319927,-0.4687076672988364,0.46863295880149775,0.9470422535211269,0.06756236740110351,0.17821837097749677,0.014721144603459817,0.06752407668418528,0.17821751024747023,0.0147211446034597],[0.14076782449725778,-0.4779192630723401,0.4676966292134828,0.9470422535211269,0.06727014547285769,0.17824405407281044,0.014721144603459817,0.06722840381026443,0.17824323741711895,0.014721144603459706]]
    
    var classifiedData: [Double] = [0,0,1,1]

    
    var goal = 60.0 // to be provided
    var activityCompleted = 44.0 // to be provided
    
    let model_random_forest = random_forest()
    let model_svm = svm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // bluetooth stuff
        manager = CBCentralManager(delegate: self, queue: nil)
        
        // application stuff
        dailyGoal.text = "Daily Goal: " + String(goal) + " minutes"
        
        let rating = activityCompleted/goal * 5.0 // type double
        let activityLeft = goal - activityCompleted
        
        dailyGoal.text = "Daily Goal: " + String(Int(goal)) + " active minutes"
        
        
        if (rating <= 1.5) {
            image.image = UIImage(named: "old-man-sad.png")
            message.text = "Let's get going, you still have " + String(Int(activityLeft)) + " active minutes left."
        } else if (rating > 1.5 && rating < 4) {
            image.image = UIImage(named: "old-man-happy.png")
            message.text = "Keep up the good work, you only have " + String(Int(activityLeft)) + " active minutes left."
        } else if (rating >= 4 && rating < 5){
            image.image = UIImage(named: "old-man-very-happy.png")
            message.text = "You're ALMOST there, only " + String(Int(activityLeft)) + " active minutes left."
        } else if (rating == 5) {
            image.image = UIImage(named: "old-man-very-happy.png")
            message.text = "Congratulations on the 5 stars, you have reached your daily activity goal."
        } else {
            image.image = UIImage(named: "old-man-happy.png")
            message.text = " "
        }
        
        starCosmos.rating = rating
        starCosmos.settings.updateOnTouch = false
        
        message.numberOfLines = 0
        
        
        for (index, data) in tempData.enumerated() {
            guard let walkingOutput = try? model_random_forest.prediction(fromFsr_med: data[0], x_mean: data[1], y_mean: data[2], z_mean: data[3], x_var: data[4], y_var: data[5], z_var: data[6], x_energy: data[7], y_energy: data[8], z_energy: data[9]) else {
                fatalError("Unexpected Runtime Error.")
            }
            
            let isWalking = walkingOutput
            print("classfiedData: " + String(describing: classifiedData[index]))
            print("isWalking: " + String(describing: isWalking.is_walking))

        }

    }
    
    // bluetooth stuff
    
    // Called after CBCentralManager instance is finished creating.
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        // if Bluetooth is available (as in "turned on"), you can start scanning for devices.
        if (central.state == CBManagerState.poweredOn) {
            central.scanForPeripherals(withServices: nil, options: nil)
        } else {
            print("Bluetooth not available.")
        }
    }
    
    // connecting to the device
    func centralManager(
        central: CBCentralManager,
        didDiscoverPeripheral peripheral: CBPeripheral,
        advertisementData: [String : AnyObject],
        RSSI: NSNumber) {
        let device = (advertisementData as NSDictionary)
            .object(forKey: CBAdvertisementDataLocalNameKey)
            as? NSString
        
        if device?.contains(BEAN_NAME) == true {
            self.manager.stopScan()
            
            self.peripheral = peripheral
            self.peripheral.delegate = self
            
            manager.connect(peripheral, options: nil)
        }
    }
    
    // getting characteristics of the device
    func peripheral(
        peripheral: CBPeripheral,
        didDiscoverServices error: Error?) {
        for service in peripheral.services! {
            let thisService = service as CBService
            
            if service.uuid == BEAN_SERVICE_UUID {
                peripheral.discoverCharacteristics(
                    nil,
                    for: thisService
                )
            }
        }
    }
    
    // setup notifications
    func peripheral(
        peripheral: CBPeripheral,
        didDiscoverCharacteristicsForService service: CBService,
        error: NSError?) {
        for characteristic in service.characteristics! {
            let thisCharacteristic = characteristic as CBCharacteristic
            
            if thisCharacteristic.uuid == BEAN_SCRATCH_UUID {
                self.peripheral.setNotifyValue(
                    true,
                    for: thisCharacteristic
                )
            }
        }
    }
    
    // Any characteristic changes setup receive notifications for will call this delegate method
    func peripheral(
        peripheral: CBPeripheral,
        didUpdateValueForCharacteristic characteristic: CBCharacteristic,
        error: NSError?) {
        var count:UInt32 = 0;
//
//        if characteristic.uuid == BEAN_SCRATCH_UUID {
//            characteristic.value!.getBytes(&count, length: sizeof(UInt32))
//            labelCount.text = NSString(format: "%llu", count) as String
//        }
    }
    
    func centralManager(
        central: CBCentralManager,
        didDisconnectPeripheral peripheral: CBPeripheral,
        error: NSError?) {
        central.scanForPeripherals(withServices: nil, options: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


//
//  HomeViewController.swift
//  FSCalendarSwiftExample
//
//  Created by Danny Gosain on 2018-03-06.
//  Copyright © 2018 wenchao. All rights reserved.
//
// UUID: D9B0BD7F-E600-034A-C795-119E77AAB719


import UIKit
import Bluejay
import CoreBluetooth

class HomeViewController: UIViewController {
    
    @IBOutlet weak var dailyGoal: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var starCosmos: CosmosView!
    @IBOutlet weak var message: UILabel!
    
    // bluetooth stuff
    let serviceUUID = ServiceIdentifier(uuid: "FFE0")
    
    var tempData: [[Double]] = [[0.010968921389396709,0.003251151449471805,-0.15496254681647964,0.8669483568075118,0.346455460450265,0.03314024286637835,0.16184266642799194,0.3465015219909012,0.03314078194292833,0.16184421884299838],[1.0,-0.13492278515307535,-0.13436329588015009,0.8718309859154929,0.2105182764337448,0.03272925927168528,0.1609407133091557,0.21040523459857455,0.03272909306608637,0.16094071330915558],[0.6910420475319927,-0.4687076672988364,0.46863295880149775,0.9470422535211269,0.06756236740110351,0.17821837097749677,0.014721144603459817,0.06752407668418528,0.17821751024747023,0.0147211446034597],[0.14076782449725778,-0.4779192630723401,0.4676966292134828,0.9470422535211269,0.06727014547285769,0.17824405407281044,0.014721144603459817,0.06722840381026443,0.17824323741711895,0.014721144603459706]]
    
    var classifiedData: [Double] = [0,0,1,1]

    
    var goal = 60.0 // to be provided
    var activityCompleted = 44.0 // to be provided
    
    let model_random_forest = random_forest()
    let model_svm = svm()
    
//    var peripherals = [ScanDiscovery]() {
//        didSet {
//
//        }
//    }
    
    
    // bluejay stuff
    weak var bluejay: Bluejay?
    var peripheralIdentifier: PeripheralIdentifier?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // bluetooth stuff
        guard let bluejay = bluejay else {
            print("Did not connect.")
            return
        }
        
        bluejay.register(observer: self)
        let peripheralIdentifier = self.peripheralIdentifier!
        
//        bluejay.scan(
//            serviceIdentifiers: [serviceUUID],
//            discovery: { [weak self] (discovery, discoveries) -> ScanAction in
//                guard let weakSelf = self else {
//                    return .stop
//                }
//
//                weakSelf.peripherals = discoveries
//                print(discoveries)
//
//                return .continue
//            },
//            stopped: { (discoveries, error) in
//                if let error = error {
//                    debugPrint("Scan stopped with error: \(error.localizedDescription)")
//                }
//                else {
//                    debugPrint("Scan stopped without error.")
//                }
//        })
//        bluejay.connect(peripheralIdentifier, timeout: .none) { (result) in
//            switch result {
//            case .success(let peripheral):
//                debugPrint("Connection to \(peripheral.identifier) successful.")
//            case .cancelled:
//                debugPrint("Connection to \(peripheralIdentifier.uuid.uuidString) cancelled.")
//            case .failure(let error):
//                debugPrint("Connection to \(peripheralIdentifier.uuid.uuidString) failed with error: \(error.localizedDescription)")
//            }
//        }
        
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        readFromSerial()
        writeToSerial()
    }
    
    func readFromSerial() {
        
        guard let bluejay = bluejay else {
            print("unable to read.")
            return
        }
        print("about to read")
        let bean_scratch_uuid = "FFE1"
//        let bean_service_uuid = ServiceIdentifier(uuid: "0000ffe1-0000-1000-8000-00805f9b34fb")
        let characteristicUUID = CharacteristicIdentifier(uuid: bean_scratch_uuid, service: serviceUUID)
//         let characteristicUUID = CharacteristicIdentifier(uuid: bean_scratch_uuid, service: bean_service_uuid)
        print("char ID: " + String(describing: characteristicUUID))

        bluejay.read(from: characteristicUUID) { [weak self] (result:ReadResult<String>) in
            guard let weakSelf = self else {
                return
            }
            switch result {
            case .success:
                debugPrint("Reading to sensor location is successful.")
            case .cancelled:
                debugPrint("Cancelled reading to sensor location.")
            case .failure(let error):
                debugPrint("Failed to reading to sensor location with error: \(error.localizedDescription)")
            }
        }
    }
    
    func writeToSerial() {
        
        guard let bluejay = bluejay else {
            print("unable to write.")
            return
        }
        print("about to write")
        let bean_scratch_uuid = "FFE1"
        let characteristicUUID = CharacteristicIdentifier(uuid: bean_scratch_uuid, service: serviceUUID)

        print("char ID: " + String(describing: characteristicUUID))
        
        bluejay.write(to: characteristicUUID, value: UInt8(4), completion: { [weak self]  (result) in
            guard let weakSelf = self else {
                return
            }
            switch result {
            case .success:
                debugPrint("Writing to sensor location is successful.")
            case .cancelled:
                debugPrint("Cancelled writing to sensor location.")
            case .failure(let error):
                debugPrint("Failed to writing to sensor location with error: \(error.localizedDescription)")
            }
        })
    }
    
//    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
//        //peripheral.discoverServices(nil)
//        //peripheral.discoverServices([CBUUID(string: "6e400001-b5a3-f393-e0a9-e50e24dcca9e")])
//
//        // Disover peripheral with service UUID that was given to us during initialization (self.serviceUUID)
//        peripheral.discoverServices([CBUUID(string: self.serviceUUID)])
//    }
    
//    func scanSensors() {
//        bluejay.scan(
//            serviceIdentifiers: [serviceUUID],
//            discovery: { [weak self] (discovery, discoveries) -> ScanAction in
//                guard let weakSelf = self else {
//                    return .stop
//                }
//
//                weakSelf.peripherals = discoveries
//                print(discoveries)
//
//                return .continue
//            },
//            stopped: { (discoveries, error) in
//                if let error = error {
//                    debugPrint("Scan stopped with error: \(error.localizedDescription)")
//                }
//                else {
//                    debugPrint("Scan stopped without error.")
//                }
//        })
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


extension HomeViewController: ConnectionObserver {
    
    func connected(to peripheral: Peripheral) {
        print("Connected Bluetooth")
//        readFromSerial()
        writeToSerial()
    }
    
    func disconnected(from peripheral: Peripheral) {
        print("Disconnected Bluetooth")
    }
    
}


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
import SQLite

class HomeViewController: UIViewController {
    
    @IBOutlet weak var dailyGoal: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var starCosmos: CosmosView!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var syncData: UIButton!
    
    // bluetooth stuff
    let serviceUUID = ServiceIdentifier(uuid: "FFE0")
    
    var tempData: [[Double]] = [[0.010968921389396709,0.003251151449471805,-0.15496254681647964,0.8669483568075118,0.346455460450265,0.03314024286637835,0.16184266642799194,0.3465015219909012,0.03314078194292833,0.16184421884299838],[1.0,-0.13492278515307535,-0.13436329588015009,0.8718309859154929,0.2105182764337448,0.03272925927168528,0.1609407133091557,0.21040523459857455,0.03272909306608637,0.16094071330915558],[0.6910420475319927,-0.4687076672988364,0.46863295880149775,0.9470422535211269,0.06756236740110351,0.17821837097749677,0.014721144603459817,0.06752407668418528,0.17821751024747023,0.0147211446034597],[0.14076782449725778,-0.4779192630723401,0.4676966292134828,0.9470422535211269,0.06727014547285769,0.17824405407281044,0.014721144603459817,0.06722840381026443,0.17824323741711895,0.014721144603459706]]
    
    var classifiedData: [Double] = [0,0,1,1]

    var listeningToSerial = false
    var goal = 60.0 // to be provided
    var activityCompleted = 44.0 // to be provided
    
    let model_random_forest = random_forest()
    let model_svm = svm()
    
//    var peripherals = [ScanDiscovery]() {
//        didSet {
//
//        }
//    }
    let GOYO_SAMPLING_RATE = 50
    
    // bluejay stuff
    weak var bluejay: Bluejay?
    var peripheralIdentifier: PeripheralIdentifier?
    
    var db: Connection?
    
    //raw data table
    var raw_data: Table?
    let xAcc = Expression<Double>("x_acc")
    let yAcc = Expression<Double>("y_acc")
    let zAcc = Expression<Double>("z_acc")
    var timestamp = Expression<Int64>("timestamp")
    let fsr = Expression<Int64>("fsr")
    var recordedMillis: Int32 = 0
    
    var features: Table?
    let xMean = Expression<Double>("x_mean")
    let yMean = Expression<Double>("y_mean")
    let zMean = Expression<Double>("z_mean")
    let xVariance = Expression<Double>("x_var")
    let yVariance = Expression<Double>("y_var")
    let zVariance = Expression<Double>("z_var")
    let isWalking = Expression<Bool>("is_walking")
    let windowStart = Expression<Int64>("window_start")
    let windowEnd = Expression<Int64>("window_end")
    let medianFsr = Expression<Int64>("median_fsr")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // bluetooth stuff
        guard let bluejay = bluejay else {
            print("Did not connect.")
            return
        }

        bluejay.register(observer: self)
        let peripheralIdentifier = self.peripheralIdentifier!
        print("registered")
        do {
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
            ).first!
        
        db = try Connection("\(path)/goyo.sqlite3")
        raw_data = Table("raw_data")
            
        try db!.run(raw_data!.drop(ifExists: true)) // TODO: Delete in prod
        try db!.run(raw_data!.create(ifNotExists: true) { t in
            t.column(xAcc)
            t.column(yAcc)
            t.column(zAcc)
            t.column(fsr)
            t.column(timestamp)
        })
            
        features = Table("features")
            try db!.run(features!.create(ifNotExists: true) { t in
                t.column(xMean)
                t.column(yMean)
                t.column(zMean)
                t.column(xVariance)
                t.column(yVariance)
                t.column(zVariance)
                t.column(medianFsr)
                t.column(isWalking)
                t.column(windowStart)
                t.column(windowEnd)
            })
        } catch {
            fatalError("unable to create db")
        }
        
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
            message.text = "Keep up the good work, you have completed " + String(Int(activityCompleted)) + " minutes"
        } else if (rating >= 4 && rating < 5){
            image.image = UIImage(named: "old-man-very-happy.png")
            message.text = "You're ALMOST there, you have completed" + String(Int(activityCompleted)) + " minutes."
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
        
        
//        for (index, data) in tempData.enumerated() {
//            guard let walkingOutput = try? model_random_forest.prediction(fromFsr_med: data[0], x_mean: data[1], y_mean: data[2], z_mean: data[3], x_var: data[4], y_var: data[5], z_var: data[6], x_energy: data[7], y_energy: data[8], z_energy: data[9]) else {
//                fatalError("Unexpected Runtime Error.")
//            }
//
//            let isWalking = walkingOutput
//            print("classfiedData: " + String(describing: classifiedData[index]))
//            print("isWalking: " + String(describing: isWalking.is_walking))
//
//        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        readFromSerial()
        syncData.addTarget(self, action: #selector(HomeViewController.syncButtonTapped), for: .touchUpInside)
    }

    @objc func syncButtonTapped() {
        if !self.listeningToSerial {
            listenFromSerial()
        }
        writeToSerial()
        debugPrint(NSDate().timeIntervalSince1970 * 1000)
    }

    func readFromSerial() {

        guard let bluejay = bluejay else {
            print("unable to read.")
            return
        }
        print("about to read")
        let char_uuid = "FFE1"
        let characteristicUUID = CharacteristicIdentifier(uuid: char_uuid, service: serviceUUID)
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

        bluejay.write(to: characteristicUUID, value: "d", type: CBCharacteristicWriteType.withoutResponse, completion: { [weak self]  (result) in
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

    func listenFromSerial() {
        var num_data_points = 1
        let start_time = NSDate().timeIntervalSince1970
        print("In listen function")
        if listeningToSerial {
            return
        }
        guard let bluejay = bluejay else {
            print("unable to listen.")
            return
        }

        let bean_scratch_uuid = "FFE1"
        let characteristicUUID = CharacteristicIdentifier(uuid: bean_scratch_uuid, service: serviceUUID)
        
        bluejay.listen(to: characteristicUUID) { [weak self] (result: ReadResult<RawMeasurement>) in
            guard let weakSelf = self else {
                return
            }

            switch result {
            case .success(let dataResult):
                weakSelf.listeningToSerial = true
                if dataResult.millis == 0 {
                    do{
                        let data_time =  start_time * 1000 + Double(1000/weakSelf.GOYO_SAMPLING_RATE) * Double(num_data_points)
                        try weakSelf.db!.run(weakSelf.raw_data!.insert(
                            weakSelf.xAcc <- Double(dataResult.x) / 100.0,
                            weakSelf.yAcc <- Double(dataResult.y) / 100.0,
                            weakSelf.zAcc <- Double(dataResult.z) / 100.0,
                            weakSelf.fsr <- Int64(dataResult.fsr) ,
                            weakSelf.timestamp <- Int64(data_time)
                        ))
                        num_data_points+=1
                    } catch {
                            debugPrint("unable to insert data point")
                    }
                } else {
                    weakSelf.listeningToSerial = false
                    weakSelf.recordedMillis = dataResult.millis
                    
                    let insertedData = weakSelf.raw_data!.order(weakSelf.timestamp.desc).limit(num_data_points)
                    do {
                        try weakSelf.db!.run(insertedData.update(weakSelf.timestamp -= Int64(weakSelf.recordedMillis)))
                    } catch {
                        debugPrint("Unable to update timestamps in raw data with millis")
                    }
                    
                    num_data_points = 1
                    weakSelf.recordedMillis = 0
                    do  {
                         try weakSelf.stopCollectingData()
                    } catch {
                        debugPrint(error)
                    }
                }
            case .cancelled:
                debugPrint("Cancelled listen to goyo.")
                weakSelf.listeningToSerial = false
            case .failure(let error):
                debugPrint("Failed to listen to goyo with error: \(error.localizedDescription)")
                weakSelf.listeningToSerial = false
            }
        }
    }
    func stopCollectingData() throws {
        guard let bluejay = bluejay else {
            print("unable to stop listening.")
            return
        }
        let notify_uuid = "FFE1"
        let characteristicUUID = CharacteristicIdentifier(uuid: notify_uuid, service: serviceUUID)
        bluejay.endListen(to: characteristicUUID)
        self.listeningToSerial = false
        for data in try self.db!.prepare(self.raw_data!) {
            print("xAcc: \(data[xAcc]), fsr: \(data[fsr]), ts: \(data[timestamp])")
        }
    }

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
        print("Connected to Bluetooth")
//        listenFromSerial()
//        readFromSerial()
//        writeToSerial()
    }
    
    func disconnected(from peripheral: Peripheral) {
        print("Disconnected from Bluetooth")
    }
    
}


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
import SigmaSwiftStatistics
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
    var goal = 30.0 // in seconds
    var activityCompleted = 0.0 // to be provided
    
    let model_random_forest = random_forest()
    let model_svm = svm()
    
//    var peripherals = [ScanDiscovery]() {
//        didSet {
//
//        }
//    }
    let GOYO_SAMPLING_RATE_HZ: Int64 = 50
    let GOYO_WINDOW_SIZE_MS: Int64 = 2000
    let GOYO_WINDOW_OVERLAP_MS: Int64 = 1000
    
    // bluejay stuff
    weak var bluejay: Bluejay?
    var peripheralIdentifier: PeripheralIdentifier?
    var recordedMillis: Int32 = 0
    
    //Intermediary information
    var goyoStartTime: Int64 = 0
    var goyoEndTime: Int64 = 0
    
    
    //midnight
    var midnight: Int64 = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // getting date components
        //For Start Date
        var calendar = NSCalendar.current
        calendar.timeZone = NSTimeZone.local //OR NSTimeZone.localTimeZone()
        let dateAtMidnight = calendar.startOfDay(for: NSDate() as Date)
        self.midnight = Int64(NSInteger(dateAtMidnight.timeIntervalSince1970) * 1000)
        
        // bluetooth stuff
        guard let bluejay = bluejay else {
            print("Did not connect.")
            return
        }

        bluejay.register(observer: self)
        let peripheralIdentifier = self.peripheralIdentifier!
        print("registered")
        
        self.updateRating(rating: 0.0)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        readFromSerial()
        syncData.addTarget(self, action: #selector(HomeViewController.syncButtonTapped), for: .touchUpInside)
    }

    @objc func syncButtonTapped() {
        syncData.isEnabled = false
        syncData.tintColor = UIColor(red:84, green:86, blue:119, alpha: 0.5)
        syncData.setTitle("Syncing...", for: .normal)
        listenFromSerial()
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
        let char_uuid = "FFE1"
        let characteristicUUID = CharacteristicIdentifier(uuid: char_uuid, service: serviceUUID)

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
        var numDataPoints = 1
        let startCollectingTime = NSDate().timeIntervalSince1970
        print("In listen function")
//        if listeningToSerial {
//            return
//        }
        guard let bluejay = bluejay else {
            print("unable to listen.")
            return
        }

        let char_uuid = "FFE1"
        let characteristicUUID = CharacteristicIdentifier(uuid: char_uuid, service: serviceUUID)
        
        bluejay.listen(to: characteristicUUID) { [weak self] (result: ReadResult<RawMeasurement>) in
            guard let weakSelf = self else {
                return
            }

            switch result {
            case .success(let dataResult):
                weakSelf.listeningToSerial = true
                if dataResult.millis == 0 {
                    do{
                        let data_time =  startCollectingTime * 1000 + Double(1000/weakSelf.GOYO_SAMPLING_RATE_HZ) * Double(numDataPoints)
                        try GoYoDB.instance.db!.run(GoYoDB.instance.raw_data!.insert(
                            GoYoDB.instance.xAcc <- Double(dataResult.x) / 100.0,
                            GoYoDB.instance.yAcc <- Double(dataResult.y) / 100.0,
                            GoYoDB.instance.zAcc <- Double(dataResult.z) / 100.0,
                            GoYoDB.instance.fsr <- Int64(dataResult.fsr) ,
                            GoYoDB.instance.timestamp <- Int64(data_time)
                        ))
                        numDataPoints+=1
                    } catch {
                            debugPrint("unable to insert data point")
                    }
                } else {
                    weakSelf.listeningToSerial = false
                    weakSelf.recordedMillis = dataResult.millis
                    weakSelf.goyoStartTime = Int64(startCollectingTime * 1000 - Double(weakSelf.recordedMillis))
                    weakSelf.goyoEndTime = Int64(startCollectingTime * 1000 + Double(1000/weakSelf.GOYO_SAMPLING_RATE_HZ) * Double(numDataPoints) - Double(weakSelf.recordedMillis))
                
                    let insertedData = GoYoDB.instance.raw_data!.order(GoYoDB.instance.timestamp.desc).limit(numDataPoints)
                    do {
                        try GoYoDB.instance.db!.run(insertedData.update(GoYoDB.instance.timestamp -= Int64(weakSelf.recordedMillis)))
                    } catch {
                        debugPrint("Unable to update timestamps in raw data with millis")
                    }
                    
                    numDataPoints = 1
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
//        for data in try self.db!.prepare(self.raw_data!) {
//            print("xAcc: \(data[xAcc]), fsr: \(data[fsr]), ts: \(data[timestamp])")
//        }
        try self.generateFeatures()
        print(self.goyoStartTime)
        print(self.goyoEndTime)
        try self.determineActiveFrames(resolutionInSeconds: 10)
        try self.updateUI()
        print(self.listeningToSerial)
    }
    
    func generateFeatures() throws {
        var startTime: Int64 = self.goyoStartTime
        var endTime: Int64 = startTime + self.GOYO_WINDOW_SIZE_MS
        while endTime < self.goyoEndTime {
            let data_in_window = GoYoDB.instance.raw_data!.filter(GoYoDB.instance.timestamp >= startTime && GoYoDB.instance.timestamp <= endTime)
            
            let dataX = try GoYoDB.instance.db!.prepare(data_in_window)
            let dataY = try GoYoDB.instance.db!.prepare(data_in_window)
            let dataZ = try GoYoDB.instance.db!.prepare(data_in_window)
            let dataFsr = try GoYoDB.instance.db!.prepare(data_in_window)
            let xAccelerations = try dataX.map {try $0.get(GoYoDB.instance.xAcc)}
            let yAccelerations = try dataY.map {try $0.get(GoYoDB.instance.yAcc)}
            let zAccelerations = try dataZ.map {try $0.get(GoYoDB.instance.zAcc)}
            let fsrMeasurements = try dataFsr.map {try Double($0.get(GoYoDB.instance.fsr))}

            let meanX = normalizeFeature(
                min: FeatureScalingFactors.X_MEAN_MIN,
                max: FeatureScalingFactors.X_MEAN_MAX,
                feature: Sigma.average(xAccelerations)!
            )
            let varX = normalizeFeature(
                min: FeatureScalingFactors.X_VAR_MIN,
                max: FeatureScalingFactors.X_VAR_MAX,
                feature: Sigma.varianceSample(xAccelerations)!
            )
            let meanY = normalizeFeature(
                min: FeatureScalingFactors.Y_MEAN_MIN,
                max: FeatureScalingFactors.Y_MEAN_MAX,
                feature: Sigma.average(yAccelerations)!
            )
            let varY = normalizeFeature(
                min: FeatureScalingFactors.Y_VAR_MIN,
                max: FeatureScalingFactors.Y_VAR_MAX,
                feature: Sigma.varianceSample(yAccelerations)!
            )
            
            let meanZ = normalizeFeature(
                min: FeatureScalingFactors.Z_MEAN_MIN,
                max: FeatureScalingFactors.Z_MEAN_MAX,
                feature: Sigma.average(zAccelerations)!
            )
            let varZ = normalizeFeature(
                min: FeatureScalingFactors.Z_VAR_MIN,
                max: FeatureScalingFactors.Z_VAR_MAX,
                feature: Sigma.varianceSample(zAccelerations)!
            )
            
            let fsrMedian = normalizeFeature(
                min: FeatureScalingFactors.FSR_MIN,
                max: FeatureScalingFactors.FSR_MAX,
                feature: Sigma.median(fsrMeasurements)!
            )
            
            guard let modelOutput = try? model_random_forest.prediction(
                fromFsr_med: fsrMedian,
                x_mean: meanX,
                y_mean: meanY,
                z_mean: meanZ,
                x_var: varX,
                y_var: varY,
                z_var: varZ
            ) else {
                debugPrint("unable to classify feature")
                return
            }
            let isWalking = (modelOutput.is_walking == 1)
            
            try GoYoDB.instance.db!.run(GoYoDB.instance.features!.insert(
                GoYoDB.instance.xMean <- meanX,
                GoYoDB.instance.yMean <- meanY,
                GoYoDB.instance.zMean <- meanZ,
                GoYoDB.instance.xVariance <- varX,
                GoYoDB.instance.yVariance <- varY,
                GoYoDB.instance.zVariance <- varZ,
                GoYoDB.instance.medianFsr <- fsrMedian,
                GoYoDB.instance.windowStart <- startTime,
                GoYoDB.instance.windowEnd <- endTime,
                GoYoDB.instance.isWalking <- isWalking
            ))
            debugPrint(isWalking)
            
            
            
            startTime += GOYO_WINDOW_OVERLAP_MS
            endTime += GOYO_WINDOW_OVERLAP_MS
            
        }
    }
    
    func normalizeFeature(min: Double, max: Double, feature: Double) -> Double {
        return (feature - min) / (max - min)
    }
    
    func determineActiveFrames(resolutionInSeconds: Int64 = 10) throws {
        let firstFeature = GoYoDB.instance.features!.select(GoYoDB.instance.isWalking, GoYoDB.instance.windowStart).order(GoYoDB.instance.windowStart.asc)
        let lastFeature = GoYoDB.instance.features!.select(GoYoDB.instance.isWalking, GoYoDB.instance.windowEnd).order(GoYoDB.instance.windowEnd.desc)
        var startTime = try GoYoDB.instance.db!.pluck(firstFeature)?.get(GoYoDB.instance.windowStart)
        let ABS_END_TIME = try GoYoDB.instance.db!.pluck(lastFeature)?.get(GoYoDB.instance.windowEnd)
        var endTime = startTime! + resolutionInSeconds * 1000
        debugPrint("determining modes across windows")
        while endTime <= ABS_END_TIME! {
            let successWalkingQuery = GoYoDB.instance.features!.select(GoYoDB.instance.isWalking)
                .filter(GoYoDB.instance.windowStart >= startTime! && GoYoDB.instance.windowEnd <= endTime && GoYoDB.instance.isWalking == true)
            let failureWalkingQuery = GoYoDB.instance.features!.select(GoYoDB.instance.isWalking)
                .filter(GoYoDB.instance.windowStart >= startTime! && GoYoDB.instance.windowEnd <= endTime && GoYoDB.instance.isWalking == false)
            let successCount = try GoYoDB.instance.db!.scalar(successWalkingQuery.count)
            let failureCount = try GoYoDB.instance.db!.scalar(failureWalkingQuery.count)
            
            let mode = failureCount > successCount ? false : true
            if mode {
                try GoYoDB.instance.db!.run(GoYoDB.instance.results!.insert(
                    GoYoDB.instance.frameStartTime <- startTime!,
                    GoYoDB.instance.frameEndTime <- endTime
                ))
            }
            
            startTime! += resolutionInSeconds * 1000
            endTime += resolutionInSeconds * 1000
        }
        print("finished creating result table")
    }
    
    func updateUI() throws {
        print("updating UI now")
        print(self.midnight)
        var activeRowQuery = try GoYoDB.instance.results!
            .filter(GoYoDB.instance.frameStartTime >= self.midnight)
        
        let count = try GoYoDB.instance.db!.scalar(activeRowQuery.count)
        print(count)
        self.activityCompleted = Double(count * 10)
        let rating = self.activityCompleted / self.goal * 5.0
        self.updateRating(rating: rating)
        syncData.isEnabled = true
        syncData.tintColor = UIColor(red:84, green:86, blue:119, alpha: 1.0)
        syncData.setTitle("Sync Data", for: .normal)

    }
    
    func updateRating(rating: Double = 0) {
        // application stuff
        dailyGoal.text = "Daily Goal: " + String(goal) + " seconds"
    
        let activityLeft = self.goal - self.activityCompleted
        
        dailyGoal.text = "Daily Goal: " + String(Int(goal)) + " active seconds"
        
        
        if (rating <= 1.5) {
            image.image = UIImage(named: "sad-emoji.png")
            message.text = "Let's get going, you still have " + String(Int(activityLeft)) + " active seconds left."
        } else if (rating > 1.5 && rating < 4) {
            image.image = UIImage(named: "happy-emoji.png")
            message.text = "Keep up the good work, you have completed " + String(Int(activityCompleted)) + " seconds"
        } else if (rating >= 4 && rating < 5){
            image.image = UIImage(named: "very-happy-emoji.png")
            message.text = "You're ALMOST there, you have completed " + String(Int(activityCompleted)) + " seconds"
        } else if (rating >= 5) {
            image.image = UIImage(named: "very-happy-emoji.png")
            message.text = "Congratulations! You have completed " + String(Int(activityCompleted)) + " seconds"
        } else {
            image.image = UIImage(named: "happy-emoji.png")
            message.text = " "
        }
        
        starCosmos.rating = rating
        starCosmos.settings.updateOnTouch = false
        
        message.numberOfLines = 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}


extension HomeViewController: ConnectionObserver {
    
    func connected(to peripheral: Peripheral) {
        print("Connected to Bluetooth")
    }
    
    func disconnected(from peripheral: Peripheral) {
        print("Disconnected from Bluetooth")
    }
    
}


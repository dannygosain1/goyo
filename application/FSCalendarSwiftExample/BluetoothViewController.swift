//
//  BluetoothViewController.swift
//  FSCalendarSwiftExample
//
//  Created by Danny Gosain on 2018-03-12.
//  Copyright © 2018 wenchao. All rights reserved.
//
// 07A5C33B-8707-B0EB-7C04-0F7B6E8BDAEE - RAUNAQ UUID
// D9B0BD7F-E600-034A-C795-119E77AAB719 - DANNY UUID
// F0868D31-552D-22E6-5C1C-6B0F955395AA - RAUNAQ POOP UUID

import UIKit
import Bluejay
import CoreBluetooth

class BluetoothViewController: UIViewController, ConnectionObserver {
    
    let bluejay = Bluejay()
    
    private var goyoPeripheralIdentifier: PeripheralIdentifier?
    
    let RAUNAQ_UUID_GOYO = "07A5C33B-8707-B0EB-7C04-0F7B6E8BDAEE"
    let DANNY_UUID_GOYO = "D9B0BD7F-E600-034A-C795-119E77AAB719"
    let DANNY_UUID_RAUNAQ = "09B62099-9B2F-7DA4-D04D-EE6932F76AC2"
    let RAUNAQ_UUID_POOP = "F0868D31-552D-22E6-5C1C-6B0F955395AA"
    let RAUNAQ_UUID_RAUNAQ = "AE6B5FDB-E7F7-496E-5078-839B17C01535"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bluejay.start()
        
        var peripheralUUID = UUID.init(uuidString: self.DANNY_UUID_RAUNAQ)
        var peripheralIdentifier = PeripheralIdentifier(uuid: peripheralUUID!)
        bluejay.connect(peripheralIdentifier, timeout: Timeout.seconds(30) )  { [weak self] (result) in
            switch result {
            case .success(let peripheral):
                debugPrint("Connection to \(peripheral.identifier) successful.")
                
                guard let weakSelf = self else {
                    return
                }
            weakSelf.goyoPeripheralIdentifier = peripheralIdentifier
            weakSelf.performSegue(withIdentifier: "showApplication", sender: self)
            
            case .cancelled:
                debugPrint("Connection  cancelled.")
            case .failure(let error):
                debugPrint("Connection to failed with error: \(error.localizedDescription)")
            }
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showApplication" {
            print("trying to segue")
            let barViewControllers = segue.destination as! UITabBarController
            let nav = barViewControllers.viewControllers![0] as! UINavigationController
            let destinationController = nav.topViewController as! HomeViewController
            destinationController.bluejay = bluejay
            destinationController.peripheralIdentifier = goyoPeripheralIdentifier
            
        }
    }
    
    func bluetoothAvailable(_ available: Bool) {
        debugPrint("Bluetooth available: \(available)")
        
//        if available && !bluejay.isScanning {
//            scanSensors()
//        }
    }
    
    func connected(_ peripheral: Peripheral) {
        debugPrint("Connected to \(peripheral)")
    }
    
    func disconnected() {
        debugPrint("Disconnected")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

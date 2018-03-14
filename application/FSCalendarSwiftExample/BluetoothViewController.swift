//
//  BluetoothViewController.swift
//  FSCalendarSwiftExample
//
//  Created by Danny Gosain on 2018-03-12.
//  Copyright © 2018 wenchao. All rights reserved.
//

import UIKit
import Bluejay
import CoreBluetooth

class BluetoothViewController: UIViewController, ConnectionObserver {
    
    let bluejay = Bluejay()
    
    private var goyoPeripheralIdentifier: PeripheralIdentifier?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bluejay.start()
        
        var peripheralUUID = UUID.init(uuidString: "D9B0BD7F-E600-034A-C795-119E77AAB719")
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
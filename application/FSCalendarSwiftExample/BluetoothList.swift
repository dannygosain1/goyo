//
//  BluetoothList.swift
//  FSCalendarSwiftExample
//
//  Created by Danny Gosain on 2018-03-11.
//  Copyright © 2018 wenchao. All rights reserved.
//

import UIKit
import CoreBluetooth

class BluetoothList: UITableViewController,CBCentralManagerDelegate, CBPeripheralDelegate {

//    var listValue = [Lista]()
    var Blue: CBCentralManager!
    var conn: CBPeripheral!
    var a: String!
    var char: CBCharacteristic!
    
    private let UuidSerialService = "0000ffe1-0000-1000-8000-00805f9b34fb"
    private let UuidTx =            "0000ffe1-0000-1000-8000-00805f9b34fb"
    private let UuidRx =            "0000ffe1-0000-1000-8000-00805f9b34fb"
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        if (peripheral.name == a){
            self.conn = peripheral
            self.conn.delegate = self
            Blue.stopScan()
            Blue.connect(self.conn, options: nil)
            self.performSegue(withIdentifier: "ConnectionSegue", sender: nil)
        }
        else{
//            listValue = [
////                Lista(Name: peripheral.name!, RSS: RSSI.stringValue)
//            ]
            self.tableView.reloadData()
        }
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        if let servicePeripheral = peripheral.services! as [CBService]!{
            for service in servicePeripheral{
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
//    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
//        if let characterArray = service.characteristics! as [CBCharacteristic]!{
//
//            for cc in characterArray {
//                if(cc.uuid.uuidString == "FF05"){
//                    print("OKOK")
//                    peripheral.readValue(for: cc)
//                }
//            }
//        }
//    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?)
    {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                // Tx:
                if characteristic.uuid == CBUUID(string: UuidTx) {
                    print("Tx char found: \(characteristic.uuid)")
                    let txCharacteristic = characteristic
                }
                
                // Rx:
                if characteristic.uuid == CBUUID(string: UuidRx) {
                    let rxCharacteristic = characteristic
//                    if let rxCharacteristic = rxCharacteristic {
//                        print("Rx char found: \(characteristic.uuid)")
//                        serialPortPeripheral?.setNotifyValue(true, for: rxCharacteristic)
//                    }
                }
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if (characteristic.uuid.uuidString == "FF05"){
            
//            let value = UnsafePointer<Int>((characteristic.value?.bytes.memory)!)
//            print("\(value)")
        }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager){
        switch(central.state){
        case .poweredOn:
            Blue.scanForPeripherals(withServices: nil, options:nil)
            print("Bluetooth is powered ON")
        case .poweredOff:
            print("Bluetooth is powered OFF")
        case .resetting:
            print("Bluetooth is resetting")
        case .unauthorized:
            print("Bluetooth is unauthorized")
        case .unknown:
            print("Bluetooth is unknown")
        case .unsupported:
            print("Bluetooth is not supported")
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        Blue = CBCentralManager(delegate: self, queue: nil)
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let currentCell = tableView.cellForRow(at: tableView.indexPathForSelectedRow!)! as UITableViewCell
        a = currentCell.textLabel?.text
        Blue = CBCentralManager(delegate: self, queue: nil)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    @IBAction func Reload_BTN(sender: AnyObject) {
        self.tableView.reloadData()
    }
    
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return self.listValue.count
//    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
//    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//
//        let cella = self.tableView.dequeueReusableCell(withIdentifier: "Cella", for: indexPath as IndexPath as IndexPath)
//        let Lista = self.listValue[indexPath.row]
//        cella.textLabel?.text = Lista.Name
//        cella.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
//        return cella
//    }

}
